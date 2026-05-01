import { NextResponse } from 'next/server';
import { createSupabaseServer } from '@/lib/supabase/server';
import { getStripe } from '@/lib/stripe/server';

/**
 * Crée (ou récupère) un compte Stripe Connect Express pour le prestataire courant
 * et renvoie un onboarding link.
 */
export async function POST(request: Request) {
  const supabase = createSupabaseServer();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) {
    return NextResponse.json({ error: 'Non authentifié' }, { status: 401 });
  }

  const { data: profile } = await supabase
    .from('users')
    .select('id, email')
    .eq('auth_user_id', user.id)
    .maybeSingle();
  if (!profile) {
    return NextResponse.json({ error: 'Profil introuvable' }, { status: 404 });
  }

  const { data: provider } = await supabase
    .from('providers')
    .select('id, stripe_account_id')
    .eq('user_id', profile.id)
    .maybeSingle();
  if (!provider) {
    return NextResponse.json({ error: 'Provider non créé' }, { status: 404 });
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

  let accountId = provider.stripe_account_id;
  if (!accountId) {
    const account = await stripe.accounts.create({
      type: 'express',
      country: 'FR',
      email: profile.email ?? user.email ?? undefined,
      capabilities: {
        card_payments: { requested: true },
        transfers: { requested: true },
      },
      business_type: 'individual',
    });
    accountId = account.id;
    await supabase
      .from('providers')
      .update({ stripe_account_id: accountId })
      .eq('id', provider.id);
  }

  const origin = new URL(request.url).origin;
  const link = await stripe.accountLinks.create({
    account: accountId,
    refresh_url: `${origin}/setup`,
    return_url: `${origin}/dashboard`,
    type: 'account_onboarding',
  });

  return NextResponse.json({ url: link.url });
}
