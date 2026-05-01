import { NextResponse } from 'next/server';
import type Stripe from 'stripe';
import { getStripe } from '@/lib/stripe/server';
import { createSupabaseServiceRole } from '@/lib/supabase/server';

export const runtime = 'nodejs';
export const dynamic = 'force-dynamic';

/**
 * Webhook Stripe — met à jour le statut des transactions/bookings.
 * Appelé par Stripe en POST avec signature dans le header `stripe-signature`.
 */
export async function POST(request: Request) {
  const sig = request.headers.get('stripe-signature');
  const secret = process.env.STRIPE_WEBHOOK_SECRET;
  if (!sig || !secret) {
    return NextResponse.json({ error: 'Webhook non configuré' }, { status: 503 });
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

  const body = await request.text();
  let event: Stripe.Event;
  try {
    event = stripe.webhooks.constructEvent(body, sig, secret);
  } catch (err) {
    return NextResponse.json(
      { error: `Signature invalide : ${err instanceof Error ? err.message : 'unknown'}` },
      { status: 400 }
    );
  }

  const supabase = await createSupabaseServiceRole();

  switch (event.type) {
    case 'payment_intent.succeeded': {
      const intent = event.data.object as Stripe.PaymentIntent;
      const kind = intent.metadata?.kind;
      if (kind === 'transport') {
        await supabase
          .from('transactions')
          .update({ status: 'confirmed' })
          .eq('stripe_payment_intent_id', intent.id);
      } else if (kind === 'booking') {
        await supabase
          .from('bookings')
          .update({ status: 'confirmed' })
          .eq('stripe_payment_intent_id', intent.id);
      }
      break;
    }
    case 'payment_intent.payment_failed':
    case 'payment_intent.canceled': {
      const intent = event.data.object as Stripe.PaymentIntent;
      const kind = intent.metadata?.kind;
      if (kind === 'transport') {
        await supabase
          .from('transactions')
          .update({ status: 'cancelled' })
          .eq('stripe_payment_intent_id', intent.id);
      } else if (kind === 'booking') {
        await supabase
          .from('bookings')
          .update({ status: 'cancelled' })
          .eq('stripe_payment_intent_id', intent.id);
      }
      break;
    }
    case 'account.updated': {
      const account = event.data.object as Stripe.Account;
      // Marquer le prestataire/propriétaire comme vérifié dès que les capabilities sont actives.
      const fullyOnboarded =
        account.charges_enabled && account.payouts_enabled && account.details_submitted;
      if (fullyOnboarded) {
        await supabase
          .from('providers')
          .update({ verified: true })
          .eq('stripe_account_id', account.id);
        await supabase
          .from('assets')
          .update({ verified: true })
          .eq('stripe_account_id', account.id);
      }
      break;
    }
    default:
      // Événements ignorés en Phase 2.
      break;
  }

  return NextResponse.json({ received: true });
}
