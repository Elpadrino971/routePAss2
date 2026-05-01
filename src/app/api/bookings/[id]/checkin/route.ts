import { NextResponse } from 'next/server';
import { createSupabaseServer } from '@/lib/supabase/server';
import { activateNFCCard } from '@/lib/ttlock';
import { powerOn } from '@/lib/shelly';

interface RouteContext {
  params: { id: string };
}

/**
 * Démarre la location :
 *   - Active la carte NFC TTLock pour la fenêtre de réservation
 *   - Allume l'électricité Shelly
 *   - Passe le bien en `occupied` et le booking en `active`
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
      'id, end_at, status, nfc_card_id, client_id, asset_id, assets:asset_id(id, ttlock_lock_id, shelly_device_id, nfc_card_ids)'
    )
    .eq('id', params.id)
    .eq('client_id', profile.id)
    .maybeSingle();
  if (!booking) return NextResponse.json({ error: 'Réservation introuvable' }, { status: 404 });
  if (booking.status !== 'confirmed') {
    return NextResponse.json({ error: `Statut ${booking.status}` }, { status: 409 });
  }
  if (!booking.end_at) {
    return NextResponse.json({ error: 'end_at manquant' }, { status: 400 });
  }

  type AssetLookup = {
    id: string;
    ttlock_lock_id: string | null;
    shelly_device_id: string | null;
    nfc_card_ids: string[] | null;
  };
  const aRow = booking.assets as unknown as AssetLookup | AssetLookup[] | null;
  const asset = Array.isArray(aRow) ? aRow[0] : aRow;
  if (!asset) {
    return NextResponse.json({ error: 'Bien introuvable' }, { status: 404 });
  }

  const cardNumber = booking.nfc_card_id ?? asset.nfc_card_ids?.[0] ?? null;

  // 1. NFC
  if (asset.ttlock_lock_id && cardNumber) {
    try {
      await activateNFCCard(asset.ttlock_lock_id, cardNumber, new Date(booking.end_at));
    } catch (err) {
      return NextResponse.json(
        { error: `TTLock: ${err instanceof Error ? err.message : 'erreur'}` },
        { status: 502 }
      );
    }
  }

  // 2. Shelly
  if (asset.shelly_device_id) {
    try {
      await powerOn(asset.shelly_device_id);
    } catch {
      // erreur Shelly non bloquante (peut être hors-ligne) — on continue
    }
  }

  // 3. États
  await supabase
    .from('bookings')
    .update({
      status: 'active',
      nfc_card_id: cardNumber,
    })
    .eq('id', booking.id);

  await supabase
    .from('assets')
    .update({ status: 'occupied' })
    .eq('id', asset.id);

  return NextResponse.json({ ok: true });
}
