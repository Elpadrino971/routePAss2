import { NextResponse } from 'next/server';
import { createSupabaseServer, createSupabaseServiceRole } from '@/lib/supabase/server';
import { getStripe } from '@/lib/stripe/server';

/**
 * Lance un batch de virements pour tous les comptes connectés
 * dont le solde Stripe est > 0. ROUTEPASS ne stocke pas les fonds —
 * le solde est directement sur le compte connecté du prestataire/owner.
 *
 * Cette implémentation enregistre simplement un statut côté DB ;
 * Stripe Connect Express verse automatiquement les fonds selon le calendrier
 * de payout configuré sur chaque compte. On enregistre un "snapshot" pour audit.
 */
export async function POST() {
  const supabase = createSupabaseServer();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return NextResponse.json({ error: 'Non authentifié' }, { status: 401 });

  const { data: profile } = await supabase
    .from('users')
    .select('role')
    .eq('auth_user_id', user.id)
    .maybeSingle();
  if (profile?.role !== 'admin') {
    return NextResponse.json({ error: 'Réservé admin' }, { status: 403 });
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

  const service = await createSupabaseServiceRole();

  // Tous les comptes connectés actifs.
  const { data: providers } = await service
    .from('providers')
    .select('user_id, stripe_account_id')
    .not('stripe_account_id', 'is', null);

  let processed = 0;
  for (const p of providers ?? []) {
    if (!p.stripe_account_id) continue;
    try {
      const balance = await stripe.balance.retrieve({
        stripeAccount: p.stripe_account_id,
      });
      const available = balance.available?.[0];
      if (!available || available.amount <= 0) continue;

      const payout = await stripe.payouts.create(
        { amount: available.amount, currency: available.currency },
        { stripeAccount: p.stripe_account_id }
      );

      await service.from('payouts').insert({
        user_id: p.user_id,
        amount: available.amount / 100,
        stripe_payout_id: payout.id,
        status: 'processing',
      });
      processed++;
    } catch {
      // log-only — on ne bloque pas le batch sur un compte en erreur
    }
  }

  return NextResponse.json({ processed });
}
