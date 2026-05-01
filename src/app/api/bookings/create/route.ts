import { NextResponse } from 'next/server';
import { createSupabaseServer } from '@/lib/supabase/server';
import { getStripe } from '@/lib/stripe/server';
import { commissionCents, toCents } from '@/lib/stripe/commission';

interface Body {
  assetId: string;
  startAt: string;
  endAt: string;
}

/**
 * Crée une réservation `pending` :
 *   - 1 PaymentIntent loyer (capture immédiate, application_fee + transfer_data)
 *   - 1 PaymentIntent caution (capture_method: manual → autorisation sans débit)
 * Retourne les 2 client_secret pour la confirmation côté front.
 */
export async function POST(request: Request) {
  const supabase = createSupabaseServer();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return NextResponse.json({ error: 'Non authentifié' }, { status: 401 });

  const body = (await request.json()) as Partial<Body>;
  if (!body.assetId || !body.startAt || !body.endAt) {
    return NextResponse.json({ error: 'Paramètres invalides' }, { status: 400 });
  }
  const start = new Date(body.startAt);
  const end = new Date(body.endAt);
  if (Number.isNaN(start.getTime()) || Number.isNaN(end.getTime()) || end <= start) {
    return NextResponse.json({ error: 'Dates invalides' }, { status: 400 });
  }

  const { data: profile } = await supabase
    .from('users')
    .select('id')
    .eq('auth_user_id', user.id)
    .maybeSingle();
  if (!profile) return NextResponse.json({ error: 'Profil introuvable' }, { status: 404 });

  const { data: asset } = await supabase
    .from('assets')
    .select(
      'id, category, daily_rate, hourly_rate, deposit_amount, status, stripe_account_id'
    )
    .eq('id', body.assetId)
    .maybeSingle();
  if (!asset || !asset.stripe_account_id) {
    return NextResponse.json({ error: 'Bien indisponible' }, { status: 404 });
  }
  if (asset.status !== 'available') {
    return NextResponse.json({ error: `Bien ${asset.status}` }, { status: 409 });
  }

  // Calcul du total : daily_rate * jours, sinon hourly_rate * heures.
  const ms = end.getTime() - start.getTime();
  const hours = Math.max(1, Math.ceil(ms / 3_600_000));
  const days = Math.max(1, Math.ceil(ms / 86_400_000));
  const total =
    asset.daily_rate && days >= 1
      ? Number(asset.daily_rate) * days
      : asset.hourly_rate
      ? Number(asset.hourly_rate) * hours
      : 0;
  if (total <= 0) {
    return NextResponse.json({ error: 'Tarif manquant' }, { status: 400 });
  }
  const deposit = Number(asset.deposit_amount ?? 0);

  let stripe: ReturnType<typeof getStripe>;
  try {
    stripe = getStripe();
  } catch (err) {
    return NextResponse.json(
      { error: err instanceof Error ? err.message : 'Stripe indisponible' },
      { status: 503 }
    );
  }

  const fee = commissionCents(total, asset.category ?? 'property');

  const rentalIntent = await stripe.paymentIntents.create({
    amount: toCents(total),
    currency: 'eur',
    automatic_payment_methods: { enabled: true },
    application_fee_amount: fee,
    transfer_data: { destination: asset.stripe_account_id },
    metadata: { kind: 'booking', assetId: asset.id, clientId: profile.id },
  });

  let holdIntent: Awaited<ReturnType<typeof stripe.paymentIntents.create>> | null = null;
  if (deposit > 0) {
    holdIntent = await stripe.paymentIntents.create({
      amount: toCents(deposit),
      currency: 'eur',
      capture_method: 'manual',
      automatic_payment_methods: { enabled: true, allow_redirects: 'never' },
      metadata: { kind: 'booking_hold', assetId: asset.id, clientId: profile.id },
    });
  }

  const { data: booking, error: insErr } = await supabase
    .from('bookings')
    .insert({
      client_id: profile.id,
      asset_id: asset.id,
      start_at: start.toISOString(),
      end_at: end.toISOString(),
      total_amount: total,
      commission_amount: fee / 100,
      deposit_amount: deposit,
      stripe_payment_intent_id: rentalIntent.id,
      stripe_hold_intent_id: holdIntent?.id ?? null,
      status: 'pending',
    })
    .select('id')
    .single();
  if (insErr) {
    return NextResponse.json({ error: insErr.message }, { status: 500 });
  }

  return NextResponse.json({
    bookingId: booking.id,
    rentalClientSecret: rentalIntent.client_secret,
    holdClientSecret: holdIntent?.client_secret ?? null,
    total,
    deposit,
    commission: fee / 100,
  });
}
