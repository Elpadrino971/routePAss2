import { NextResponse } from 'next/server';
import { createSupabaseServer } from '@/lib/supabase/server';
import { deactivateNFCCard } from '@/lib/ttlock';
import { powerOff } from '@/lib/shelly';
import { getStripe } from '@/lib/stripe/server';

interface RouteContext {
  params: { id: string };
}

/**
 * Restitution manuelle par le client :
 *   - Désactive la carte NFC
 *   - Coupe l'électricité
 *   - Bien → `cleaning` jusqu'à `available_from`
 *   - Booking → `completed`
 *   - Caution libérée si pas de dommage signalé
 */
export async function POST(_req: Request, { params }: RouteContext) {
  const supabase = createSupabaseServer();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return NextResponse.json({ error: 'Non authentifié' }, { status: 401 });

  const { data: profile } = await supabase
    .from('users')
    .select('id')
    .eq('auth_user_id', user.id)
    .maybeSingle();
  if (!profile) return NextResponse.json({ error: 'Profil introuvable' }, { status: 404 });

  const { data: booking } = await supabase
    .from('bookings')
    .select(
      'id, status, nfc_card_id, damage_amount, deposit_released, stripe_hold_intent_id, asset_id, client_id, assets:asset_id(id, ttlock_lock_id, shelly_device_id, cleaning_duration_minutes)'
    )
    .eq('id', params.id)
    .eq('client_id', profile.id)
    .maybeSingle();
  if (!booking) return NextResponse.json({ error: 'Réservation introuvable' }, { status: 404 });
  if (booking.status !== 'active') {
    return NextResponse.json({ error: `Statut ${booking.status}` }, { status: 409 });
  }

  type AssetLookup = {
    id: string;
    ttlock_lock_id: string | null;
    shelly_device_id: string | null;
    cleaning_duration_minutes: number;
  };
  const aRow = booking.assets as unknown as AssetLookup | AssetLookup[] | null;
  const asset = Array.isArray(aRow) ? aRow[0] : aRow;
  if (!asset) {
    return NextResponse.json({ error: 'Bien introuvable' }, { status: 404 });
  }

  if (asset.ttlock_lock_id && booking.nfc_card_id) {
    try {
      await deactivateNFCCard(asset.ttlock_lock_id, booking.nfc_card_id);
    } catch {
      // non bloquant
    }
  }
  if (asset.shelly_device_id) {
    try {
      await powerOff(asset.shelly_device_id);
    } catch {
      // non bloquant
    }
  }

  const cleaningEnd = new Date(
    Date.now() + (asset.cleaning_duration_minutes ?? 60) * 60_000
  );

  await supabase
    .from('assets')
    .update({ status: 'cleaning', available_from: cleaningEnd.toISOString() })
    .eq('id', asset.id);

  await supabase
    .from('bookings')
    .update({ status: 'completed' })
    .eq('id', booking.id);

  // Libère la caution si aucun dommage signalé.
  if (
    !booking.deposit_released &&
    !booking.damage_amount &&
    booking.stripe_hold_intent_id
  ) {
    try {
      const stripe = getStripe();
      await stripe.paymentIntents.cancel(booking.stripe_hold_intent_id);
      await supabase
        .from('bookings')
        .update({ deposit_released: true })
        .eq('id', booking.id);
    } catch {
      // erreur Stripe — sera retentée par le cron
    }
  }

  return NextResponse.json({ ok: true });
}
