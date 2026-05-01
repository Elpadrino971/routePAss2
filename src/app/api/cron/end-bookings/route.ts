import { NextResponse } from 'next/server';
import { createSupabaseServiceRole } from '@/lib/supabase/server';
import { deactivateNFCCard } from '@/lib/ttlock';
import { powerOff } from '@/lib/shelly';
import { getStripe } from '@/lib/stripe/server';

export const runtime = 'nodejs';
export const dynamic = 'force-dynamic';

/**
 * Cron toutes les 5 minutes :
 *   1. Locations actives expirées → NFC off, Shelly off, asset cleaning, booking completed,
 *      libération caution si pas de dommage.
 *   2. Biens en cleaning dont available_from ≤ now → available.
 */
export async function GET(request: Request) {
  // Auth simple par header secret (Vercel Cron)
  const auth = request.headers.get('authorization');
  const expected = process.env.CRON_SECRET;
  if (expected && auth !== `Bearer ${expected}`) {
    return NextResponse.json({ error: 'Forbidden' }, { status: 403 });
  }

  const supabase = await createSupabaseServiceRole();
  const now = new Date();

  // 1. Locations actives expirées
  const { data: expired, error: expiredErr } = await supabase
    .from('bookings')
    .select(
      'id, end_at, damage_amount, deposit_released, stripe_hold_intent_id, nfc_card_id, asset_id, client_id, assets:asset_id(id, ttlock_lock_id, shelly_device_id, cleaning_duration_minutes)'
    )
    .eq('status', 'active')
    .lt('end_at', now.toISOString());
  if (expiredErr) {
    return NextResponse.json({ error: expiredErr.message }, { status: 500 });
  }

  let processed = 0;
  for (const booking of expired ?? []) {
    type AssetLookup = {
      id: string;
      ttlock_lock_id: string | null;
      shelly_device_id: string | null;
      cleaning_duration_minutes: number;
    };
    const aRow = booking.assets as unknown as AssetLookup | AssetLookup[] | null;
    const asset = Array.isArray(aRow) ? aRow[0] : aRow;
    if (!asset) continue;

    if (asset.ttlock_lock_id && booking.nfc_card_id) {
      try {
        await deactivateNFCCard(asset.ttlock_lock_id, booking.nfc_card_id);
      } catch (err) {
        console.error('[cron] TTLock deactivate', booking.id, err);
      }
    }
    if (asset.shelly_device_id) {
      try {
        await powerOff(asset.shelly_device_id);
      } catch (err) {
        console.error('[cron] Shelly off', booking.id, err);
      }
    }

    const cleaningEnd = new Date(
      now.getTime() + (asset.cleaning_duration_minutes ?? 60) * 60_000
    );
    await supabase
      .from('assets')
      .update({ status: 'cleaning', available_from: cleaningEnd.toISOString() })
      .eq('id', asset.id);
    await supabase
      .from('bookings')
      .update({ status: 'completed' })
      .eq('id', booking.id);

    // Libération de la caution si pas de dommage
    if (
      booking.stripe_hold_intent_id &&
      !booking.deposit_released &&
      !booking.damage_amount
    ) {
      try {
        const stripe = getStripe();
        await stripe.paymentIntents.cancel(booking.stripe_hold_intent_id);
        await supabase
          .from('bookings')
          .update({ deposit_released: true })
          .eq('id', booking.id);
      } catch (err) {
        console.error('[cron] Stripe release', booking.id, err);
      }
    }

    processed++;
  }

  // 2. Nettoyage terminé → disponible
  const { data: cleaned } = await supabase
    .from('assets')
    .select('id')
    .eq('status', 'cleaning')
    .lt('available_from', now.toISOString());
  for (const a of cleaned ?? []) {
    await supabase
      .from('assets')
      .update({ status: 'available', available_from: null })
      .eq('id', a.id);
  }

  return NextResponse.json({
    processed,
    cleaned: cleaned?.length ?? 0,
  });
}
