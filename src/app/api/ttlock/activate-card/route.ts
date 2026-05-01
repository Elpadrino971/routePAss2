import { NextResponse } from 'next/server';
import { createSupabaseServer } from '@/lib/supabase/server';
import { activateNFCCard } from '@/lib/ttlock';

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
    .select('id, end_at, nfc_card_id, assets:asset_id(ttlock_lock_id, nfc_card_ids)')
    .eq('id', body.bookingId)
    .maybeSingle();
  if (!booking) {
    return NextResponse.json({ error: 'Réservation introuvable' }, { status: 404 });
  }

  type AssetLookup = { ttlock_lock_id: string | null; nfc_card_ids: string[] | null };
  const assetRow = booking.assets as unknown as AssetLookup | AssetLookup[] | null;
  const asset = Array.isArray(assetRow) ? assetRow[0] : assetRow;
  if (!asset?.ttlock_lock_id) {
    return NextResponse.json({ error: 'Aucune serrure liée' }, { status: 400 });
  }

  const cardNumber = booking.nfc_card_id ?? asset.nfc_card_ids?.[0];
  if (!cardNumber) {
    return NextResponse.json({ error: 'Aucune carte NFC disponible' }, { status: 400 });
  }
  if (!booking.end_at) {
    return NextResponse.json({ error: 'end_at manquant' }, { status: 400 });
  }

  try {
    await activateNFCCard(asset.ttlock_lock_id, cardNumber, new Date(booking.end_at));
  } catch (err) {
    return NextResponse.json(
      { error: err instanceof Error ? err.message : 'TTLock erreur' },
      { status: 502 }
    );
  }

  await supabase
    .from('bookings')
    .update({ nfc_card_id: cardNumber })
    .eq('id', booking.id);

  return NextResponse.json({ ok: true, cardNumber });
}
