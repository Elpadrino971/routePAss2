import { NextResponse } from 'next/server';
import { getStripe } from '@/lib/stripe/server';
import { createSupabaseServer } from '@/lib/supabase/server';

/** Annule l'autorisation de caution (release sans débit). */
export async function POST(request: Request) {
  const supabase = createSupabaseServer();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return NextResponse.json({ error: 'Non authentifié' }, { status: 401 });

  const { bookingId } = (await request.json()) as { bookingId?: string };
  if (!bookingId) {
    return NextResponse.json({ error: 'bookingId requis' }, { status: 400 });
  }

  const { data: booking } = await supabase
    .from('bookings')
    .select('id, stripe_hold_intent_id, deposit_released')
    .eq('id', bookingId)
    .maybeSingle();
  if (!booking?.stripe_hold_intent_id) {
    return NextResponse.json({ ok: true, skipped: true });
  }
  if (booking.deposit_released) {
    return NextResponse.json({ ok: true, alreadyReleased: true });
  }

  let stripe: ReturnType<typeof getStripe>;
  try {
    stripe = getStripe();
  } catch (err) {
    return NextResponse.json(
      { error: err instanceof Error ? err.message : 'Stripe indisponible' },
      { status: 503 }
    );
  }

  await stripe.paymentIntents.cancel(booking.stripe_hold_intent_id);
  await supabase
    .from('bookings')
    .update({ deposit_released: true })
    .eq('id', booking.id);

  return NextResponse.json({ ok: true });
}
