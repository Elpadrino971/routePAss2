import { NextResponse } from 'next/server';
import { createSupabaseServer } from '@/lib/supabase/server';
import { getStripe } from '@/lib/stripe/server';
import { commissionCents, toCents } from '@/lib/stripe/commission';
import { generateValidationCode } from '@/lib/utils';

interface Body {
  providerId: string;
  amount: number; // euros
}

/**
 * Crée un PaymentIntent transport :
 *   - destination = stripe_account_id du prestataire
 *   - application_fee_amount = commission ROUTEPASS (5–10%)
 *   - retourne client_secret + transactionId + validationCode (montré au client)
 */
export async function POST(request: Request) {
  const supabase = createSupabaseServer();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) {
    return NextResponse.json({ error: 'Non authentifié' }, { status: 401 });
  }

  const body = (await request.json()) as Partial<Body>;
  if (!body.providerId || typeof body.amount !== 'number' || body.amount <= 0) {
    return NextResponse.json({ error: 'Paramètres invalides' }, { status: 400 });
  }

  const { data: profile } = await supabase
    .from('users')
    .select('id')
    .eq('auth_user_id', user.id)
    .maybeSingle();
  if (!profile) {
    return NextResponse.json({ error: 'Profil introuvable' }, { status: 404 });
  }

  const { data: provider } = await supabase
    .from('providers')
    .select('id, service_type, stripe_account_id, verified')
    .eq('id', body.providerId)
    .maybeSingle();
  if (!provider || !provider.stripe_account_id) {
    return NextResponse.json(
      { error: 'Prestataire non disponible' },
      { status: 404 }
    );
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

  const fee = commissionCents(body.amount, provider.service_type ?? 'taxi');
  const intent = await stripe.paymentIntents.create({
    amount: toCents(body.amount),
    currency: 'eur',
    automatic_payment_methods: { enabled: true },
    application_fee_amount: fee,
    transfer_data: { destination: provider.stripe_account_id },
    metadata: { kind: 'transport', providerId: provider.id, clientId: profile.id },
  });

  const validationCode = generateValidationCode();

  const { data: txn, error: txnErr } = await supabase
    .from('transactions')
    .insert({
      client_id: profile.id,
      provider_id: provider.id,
      amount: body.amount,
      commission_amount: fee / 100,
      stripe_payment_intent_id: intent.id,
      status: 'pending',
      validation_code: validationCode,
    })
    .select('id')
    .single();
  if (txnErr) {
    return NextResponse.json({ error: txnErr.message }, { status: 500 });
  }

  return NextResponse.json({
    clientSecret: intent.client_secret,
    transactionId: txn.id,
    validationCode,
  });
}
