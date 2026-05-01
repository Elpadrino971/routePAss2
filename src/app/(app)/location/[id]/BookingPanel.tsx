'use client';

import { useMemo, useState } from 'react';
import { useRouter } from 'next/navigation';
import { CreditCard, ShieldCheck } from 'lucide-react';
import { Elements, PaymentElement, useElements, useStripe } from '@stripe/react-stripe-js';
import { loadStripe, type Stripe } from '@stripe/stripe-js';
import { RPButton, RPInput } from '@/components/ui';
import { formatEUR } from '@/lib/utils';

const PUBLISHABLE = process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY ?? '';
let stripePromise: Promise<Stripe | null> | null = null;
function getStripeJs(): Promise<Stripe | null> {
  if (!PUBLISHABLE) return Promise.resolve(null);
  stripePromise ??= loadStripe(PUBLISHABLE);
  return stripePromise;
}

interface Props {
  assetId: string;
  dailyRate: number | null;
  hourlyRate: number | null;
  deposit: number;
}

interface IntentInfo {
  bookingId: string;
  rentalClientSecret: string;
  holdClientSecret: string | null;
  total: number;
  deposit: number;
  commission: number;
}

function defaultStart(): string {
  const d = new Date();
  d.setMinutes(0, 0, 0);
  d.setHours(d.getHours() + 1);
  return d.toISOString().slice(0, 16);
}

function defaultEnd(): string {
  const d = new Date();
  d.setMinutes(0, 0, 0);
  d.setHours(d.getHours() + 25);
  return d.toISOString().slice(0, 16);
}

export function BookingPanel({ assetId, dailyRate, hourlyRate, deposit }: Props) {
  const [startAt, setStartAt] = useState(defaultStart());
  const [endAt, setEndAt] = useState(defaultEnd());
  const [intent, setIntent] = useState<IntentInfo | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const estimate = useMemo(() => {
    const ms = new Date(endAt).getTime() - new Date(startAt).getTime();
    if (ms <= 0) return 0;
    const days = Math.max(1, Math.ceil(ms / 86_400_000));
    const hours = Math.max(1, Math.ceil(ms / 3_600_000));
    if (dailyRate) return dailyRate * days;
    if (hourlyRate) return hourlyRate * hours;
    return 0;
  }, [startAt, endAt, dailyRate, hourlyRate]);

  async function reserve() {
    setLoading(true);
    setError(null);
    try {
      const res = await fetch('/api/bookings/create', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ assetId, startAt: new Date(startAt).toISOString(), endAt: new Date(endAt).toISOString() }),
      });
      const json = (await res.json()) as IntentInfo & { error?: string };
      if (!res.ok) throw new Error(json.error ?? 'Erreur réservation');
      setIntent(json);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erreur');
    } finally {
      setLoading(false);
    }
  }

  if (!PUBLISHABLE) {
    return (
      <div className="rounded-rp border border-rp-warning/30 bg-rp-warning/5 p-4 text-sm text-rp-warning">
        Stripe n&apos;est pas configuré.
      </div>
    );
  }

  if (intent) {
    return (
      <Elements
        stripe={getStripeJs()}
        options={{ clientSecret: intent.rentalClientSecret, appearance: stripeAppearance }}
      >
        <BookingPayment intent={intent} />
      </Elements>
    );
  }

  return (
    <div className="space-y-4 rounded-rp border border-rp-border bg-rp-dark p-5">
      <div>
        <p className="text-xs uppercase tracking-[0.3em] text-rp-gold">Réservation</p>
        <h2 className="font-display text-lg text-rp-white">Choisir vos dates</h2>
      </div>

      <RPInput
        label="Début"
        type="datetime-local"
        value={startAt}
        onChange={(e) => setStartAt(e.target.value)}
      />
      <RPInput
        label="Fin"
        type="datetime-local"
        value={endAt}
        onChange={(e) => setEndAt(e.target.value)}
      />

      <div className="space-y-1.5 rounded-rp-input bg-rp-dark-2 p-3 text-sm">
        <div className="flex items-center justify-between">
          <span className="text-rp-gray">Loyer estimé</span>
          <span className="font-mono text-rp-white">{formatEUR(estimate)}</span>
        </div>
        {deposit > 0 ? (
          <div className="flex items-center justify-between">
            <span className="text-rp-gray inline-flex items-center gap-1">
              <ShieldCheck className="h-3.5 w-3.5" />
              Caution (autorisation, non débitée)
            </span>
            <span className="font-mono text-rp-gold">{formatEUR(deposit)}</span>
          </div>
        ) : null}
      </div>

      {error ? (
        <p className="rounded-rp-input border border-rp-danger/30 bg-rp-danger/10 p-3 text-xs text-rp-danger">
          {error}
        </p>
      ) : null}

      <RPButton
        block
        size="lg"
        loading={loading}
        disabled={estimate <= 0}
        onClick={reserve}
      >
        <CreditCard className="h-5 w-5" />
        Réserver
      </RPButton>
    </div>
  );
}

const stripeAppearance = {
  theme: 'night' as const,
  variables: {
    colorPrimary: '#C9A84C',
    colorBackground: '#0F0F18',
    colorText: '#F5F0E8',
    colorDanger: '#EF4444',
    fontFamily: 'Inter, sans-serif',
    borderRadius: '12px',
  },
};

function BookingPayment({ intent }: { intent: IntentInfo }) {
  const stripe = useStripe();
  const elements = useElements();
  const router = useRouter();
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function pay() {
    if (!stripe || !elements) return;
    setSubmitting(true);
    setError(null);

    // 1. Confirme le paiement loyer (PaymentElement actuellement monté).
    const { error: rentalErr } = await stripe.confirmPayment({
      elements,
      redirect: 'if_required',
    });
    if (rentalErr) {
      setError(rentalErr.message ?? 'Paiement refusé');
      setSubmitting(false);
      return;
    }

    // 2. Confirme la caution si présente (capture_method: manual).
    if (intent.holdClientSecret) {
      const result = await stripe.confirmCardPayment(intent.holdClientSecret);
      if (result.error) {
        setError(`Caution refusée: ${result.error.message}`);
        setSubmitting(false);
        return;
      }
    }

    router.replace(`/location/booking/${intent.bookingId}`);
  }

  return (
    <div className="space-y-4 rounded-rp border border-rp-border bg-rp-dark p-5">
      <PaymentElement
        options={{
          paymentMethodOrder: ['apple_pay', 'google_pay', 'card'],
          wallets: { applePay: 'auto', googlePay: 'auto' },
        }}
      />
      <p className="text-xs text-rp-gray">
        Loyer : {formatEUR(intent.total)}
        {intent.deposit > 0
          ? ` · Caution autorisée séparément : ${formatEUR(intent.deposit)}`
          : ''}
      </p>
      {error ? (
        <p className="rounded-rp-input border border-rp-danger/30 bg-rp-danger/10 p-3 text-xs text-rp-danger">
          {error}
        </p>
      ) : null}
      <RPButton block size="lg" loading={submitting} onClick={pay}>
        Confirmer le paiement
      </RPButton>
    </div>
  );
}
