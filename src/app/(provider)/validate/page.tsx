'use client';

import { useState } from 'react';
import { CheckCircle2 } from 'lucide-react';
import { RPButton } from '@/components/ui';
import { cn, formatEUR } from '@/lib/utils';

interface ValidationResult {
  ok: boolean;
  amount?: number;
  client?: string;
  error?: string;
}

export default function ValidatePage() {
  const [code, setCode] = useState('');
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<ValidationResult | null>(null);

  async function submit() {
    setLoading(true);
    setResult(null);
    try {
      const res = await fetch('/api/transactions/validate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ code }),
      });
      const json = (await res.json()) as ValidationResult;
      if (!res.ok) {
        setResult({ ok: false, error: json.error ?? 'Code invalide' });
        return;
      }
      setResult({ ...json, ok: true });
      setCode('');
    } catch {
      setResult({ ok: false, error: 'Erreur réseau' });
    } finally {
      setLoading(false);
    }
  }

  function setDigit(i: number, v: string) {
    const clean = v.replace(/\D/g, '').slice(-1);
    const arr = code.padEnd(4, ' ').split('');
    arr[i] = clean || ' ';
    setCode(arr.join('').replace(/\s/g, ''));
  }

  return (
    <div className="flex min-h-dvh flex-col px-5 pt-8">
      <header>
        <p className="text-xs uppercase tracking-[0.3em] text-rp-gold">Valider</p>
        <h1 className="font-display text-2xl text-rp-white">Code client</h1>
        <p className="mt-1 text-sm text-rp-gray">
          Le client a reçu un code à 4 chiffres après son paiement.
        </p>
      </header>

      <div className="mt-10 flex justify-center gap-3">
        {[0, 1, 2, 3].map((i) => (
          <input
            key={i}
            type="tel"
            inputMode="numeric"
            maxLength={1}
            autoFocus={i === 0}
            value={code[i] ?? ''}
            onChange={(e) => {
              setDigit(i, e.target.value);
              const next = e.target.parentElement?.children[i + 1] as
                | HTMLInputElement
                | undefined;
              if (e.target.value && next) next.focus();
            }}
            onKeyDown={(e) => {
              if (e.key === 'Backspace' && !code[i]) {
                const prev = (e.target as HTMLInputElement).parentElement
                  ?.children[i - 1] as HTMLInputElement | undefined;
                prev?.focus();
              }
            }}
            className={cn(
              'h-16 w-14 rounded-rp border bg-rp-dark text-center font-mono text-2xl text-rp-white focus:outline-none',
              code[i] ? 'border-rp-gold' : 'border-rp-border'
            )}
          />
        ))}
      </div>

      {result?.ok ? (
        <div className="mt-8 rounded-rp border border-rp-success/40 bg-rp-success/10 p-5 text-center">
          <CheckCircle2 className="mx-auto h-10 w-10 text-rp-success" />
          <p className="mt-2 font-display text-lg text-rp-white">Course validée</p>
          {result.amount !== undefined ? (
            <p className="font-mono text-2xl text-rp-success">
              {formatEUR(result.amount)}
            </p>
          ) : null}
          {result.client ? (
            <p className="text-xs text-rp-gray">Client : {result.client}</p>
          ) : null}
        </div>
      ) : null}

      {result && !result.ok ? (
        <p className="mt-8 rounded-rp-input border border-rp-danger/30 bg-rp-danger/10 p-3 text-center text-sm text-rp-danger">
          {result.error}
        </p>
      ) : null}

      <RPButton
        block
        size="lg"
        loading={loading}
        disabled={code.length < 4}
        onClick={submit}
        className="mt-auto mb-4"
      >
        Valider
      </RPButton>
    </div>
  );
}
