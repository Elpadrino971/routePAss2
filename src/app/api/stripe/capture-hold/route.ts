import { NextResponse } from 'next/server';
import { getStripe } from '@/lib/stripe/server';
import { toCents } from '@/lib/stripe/commission';
import { createSupabaseServer } from '@/lib/supabase/server';

/** Capture totale ou partielle de la caution en cas de dommage. */
export async function POST(request: Request) {
  const supabase = createSupabaseServer();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return NextResponse.json({ error: 'Non authentifié' }, { status: 401 });

  const { bookingId, damageAmount } = (await request.json()) as {
    bookingId?: string;
    damageAmount?: number;
  };
  if (!bookingId || typeof damageAmount !== 'number' || damageAmount <= 0) {
    return NextResponse.json({ error: 'Paramètres invalides' }, { status: 400 });
  }

  const { data: booking } = await supabase
    .from('bookings')
    .select('id, stripe_hold_intent_id, deposit_amount, deposit_released')
    .eq('id', bookingId)
    .maybeSingle();
  if (!booking?.stripe_hold_intent_id) {
    return NextResponse.json({ error: 'Caution introuvable' }, { status: 404 });
  }
  if (booking.deposit_released) {
    return NextResponse.json({ error: 'Caution déjà libérée' }, { status: 409 });
  }

  const cap = Math.min(damageAmount, Number(booking.deposit_amount ?? 0));
  if (cap <= 0) {
    return NextResponse.json({ error: 'Montant invalide' }, { status: 400 });
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

  await stripe.paymentIntents.capture(booking.stripe_hold_intent_id, {
    amount_to_capture: toCents(cap),
  });

  await supabase
    .from('bookings')
    .update({
      deposit_released: true,
      damage_amount: cap,
      status: 'disputed',
    })
    .eq('id', booking.id);

  return NextResponse.json({ ok: true, captured: cap });
}
