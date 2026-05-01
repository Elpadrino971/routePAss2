import { NextResponse } from 'next/server';
import { createSupabaseServer } from '@/lib/supabase/server';
import { deactivateNFCCard } from '@/lib/ttlock';

export async function POST(request: Request) {
  const supabase = createSupabaseServer();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return NextResponse.json({ error: 'Non authentifié' }, { status: 401 });

  const body = (await request.json()) as { bookingId?: string };
  if (!body.bookingId) {
    return NextResponse.json({ error: 'bookingId requis' }, { status: 400 });
  }

  const { data: booking } = await supabase
    .from('bookings')
    .select('id, nfc_card_id, assets:asset_id(ttlock_lock_id)')
    .eq('id', body.bookingId)
    .maybeSingle();
  if (!booking) {
    return NextResponse.json({ error: 'Réservation introuvable' }, { status: 404 });
  }

  type AssetLookup = { ttlock_lock_id: string | null };
  const assetRow = booking.assets as unknown as AssetLookup | AssetLookup[] | null;
  const asset = Array.isArray(assetRow) ? assetRow[0] : assetRow;
  if (!asset?.ttlock_lock_id || !booking.nfc_card_id) {
    return NextResponse.json({ ok: true, skipped: true });
  }

  try {
    await deactivateNFCCard(asset.ttlock_lock_id, booking.nfc_card_id);
  } catch (err) {
    return NextResponse.json(
      { error: err instanceof Error ? err.message : 'TTLock erreur' },
      { status: 502 }
    );
  }

  return NextResponse.json({ ok: true });
}
