import Stripe from 'stripe';

let cached: Stripe | null = null;

/** Singleton Stripe — lazy pour ne pas exiger la clé au build. */
export function getStripe(): Stripe {
  if (!cached) {
    const key = process.env.STRIPE_SECRET_KEY;
    if (!key) throw new Error('STRIPE_SECRET_KEY manquant');
    cached = new Stripe(key, { apiVersion: '2024-06-20', typescript: true });
  }
  return cached;
}
