'use client';

import { useEffect, useMemo, useState } from 'react';
import { Elements, PaymentElement, useElements, useStripe } from '@stripe/react-stripe-js';
import { loadStripe, type Stripe } from '@stripe/stripe-js';
import { Apple, CheckCircle2, CreditCard } from 'lucide-react';
import { RPButton, RPInput } from '@/components/ui';
import { cn, formatEUR } from '@/lib/utils';

const PUBLISHABLE = process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY ?? '';
let stripePromise: Promise<Stripe | null> | null = null;
function getStripeJs(): Promise<Stripe | null> {
  if (!PUBLISHABLE) return Promise.resolve(null);
  stripePromise ??= loadStripe(PUBLISHABLE);
  return stripePromise;
}

interface Props {
  providerId: string;
  baseRate: number | null;
}

interface IntentInfo {
  clientSecret: string;
  transactionId: string;
  validationCode: string;
}

export function CheckoutPanel({ providerId, baseRate }: Props) {
  const [amount, setAmount] = useState<string>(baseRate ? String(baseRate) : '');
  const [intent, setIntent] = useState<IntentInfo | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  async function startPayment() {
    setError(null);
    setLoading(true);
    try {
      const res = await fetch('/api/stripe/create-payment', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ providerId, amount: Number(amount) }),
      });
      const json = (await res.json()) as IntentInfo & { error?: string };
      if (!res.ok) throw new Error(json.error ?? 'Erreur paiement');
      setIntent({
        clientSecret: json.clientSecret,
        transactionId: json.transactionId,
        validationCode: json.validationCode,
      });
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erreur inconnue');
    } finally {
      setLoading(false);
    }
  }

  if (!PUBLISHABLE) {
    return (
      <div className="rounded-rp border border-rp-warning/30 bg-rp-warning/5 p-4 text-sm text-rp-warning">
        Stripe n&apos;est pas configuré (NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY manquant).
      </div>
    );
  }

  if (intent) {
    return (
      <Elements
        stripe={getStripeJs()}
        options={{
          clientSecret: intent.clientSecret,
          appearance: stripeAppearance,
        }}
      >
        <PaymentForm validationCode={intent.validationCode} amount={Number(amount)} />
      </Elements>
    );
  }

  return (
    <div className="space-y-4 rounded-rp border border-rp-border bg-rp-dark p-5">
      <div>
        <p className="text-xs uppercase tracking-[0.3em] text-rp-gold">Course</p>
        <h2 className="font-display text-lg text-rp-white">Récapitulatif</h2>
      </div>

      <RPInput
        label="Montant (€)"
        type="number"
        inputMode="decimal"
        value={amount}
        onChange={(e) => setAmount(e.target.value)}
      />

      <div className="flex items-center justify-between rounded-rp-input bg-rp-dark-2 px-3 py-3">
        <span className="text-xs text-rp-gray">Commission ROUTEPASS (5 %)</span>
        <span className="font-mono text-xs text-rp-gold">
          {formatEUR((Number(amount || 0) * 5) / 100)}
        </span>
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
        disabled={!amount || Number(amount) <= 0}
        onClick={startPayment}
      >
        <CreditCard className="h-5 w-5" />
        Payer {amount ? formatEUR(Number(amount)) : ''}
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
    spacingUnit: '4px',
  },
};

function PaymentForm({ validationCode, amount }: { validationCode: string; amount: number }) {
  const stripe = useStripe();
  const elements = useElements();
  const [submitting, setSubmitting] = useState(false);
  const [paid, setPaid] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function pay() {
    if (!stripe || !elements) return;
    setSubmitting(true);
    setError(null);
    const { error: payErr } = await stripe.confirmPayment({
      elements,
      redirect: 'if_required',
    });
    if (payErr) {
      setError(payErr.message ?? 'Paiement refusé');
      setSubmitting(false);
      return;
    }
    setPaid(true);
    setSubmitting(false);
  }

  if (paid) {
    return (
      <div className="space-y-4 rounded-rp border border-rp-gold/40 bg-rp-dark p-6 text-center shadow-rp-gold">
        <CheckCircle2 className="mx-auto h-12 w-12 text-rp-success" />
        <p className="font-display text-lg text-rp-white">Paiement confirmé</p>
        <p className="text-sm text-rp-gray">
          Communiquez ce code à votre prestataire pour démarrer la course.
        </p>
        <div className="flex justify-center gap-3">
          {validationCode.split('').map((d, i) => (
            <span
              key={i}
              className="flex h-16 w-14 items-center justify-center rounded-rp border border-rp-gold bg-rp-dark-2 font-mono text-3xl text-rp-gold"
            >
              {d}
            </span>
          ))}
        </div>
        <p className="text-[10px] uppercase tracking-[0.3em] text-rp-gold">
          {formatEUR(amount)}
        </p>
      </div>
    );
  }

  return (
    <div className="space-y-4 rounded-rp border border-rp-border bg-rp-dark p-5">
      <PaymentElement
        options={{
          paymentMethodOrder: ['apple_pay', 'google_pay', 'card'],
          wallets: { applePay: 'auto', googlePay: 'auto' },
        }}
      />
      {error ? (
        <p className="rounded-rp-input border border-rp-danger/30 bg-rp-danger/10 p-3 text-xs text-rp-danger">
          {error}
        </p>
      ) : null}
      <RPButton block size="lg" loading={submitting} onClick={pay}>
        Confirmer {formatEUR(amount)}
      </RPButton>
    </div>
  );
}

interface AppleHintProps {
  className?: string;
}
export function AppleHint({ className }: AppleHintProps) {
  return (
    <span className={cn('inline-flex items-center gap-1 text-xs text-rp-gray', className)}>
      <Apple className="h-3.5 w-3.5" /> Apple Pay accepté
    </span>
  );
}
