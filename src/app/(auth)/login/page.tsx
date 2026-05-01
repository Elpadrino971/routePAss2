'use client';

import { Suspense, useState } from 'react';
import Link from 'next/link';
import { useRouter, useSearchParams } from 'next/navigation';
import { Mail, Phone } from 'lucide-react';
import { RPButton, RPInput, RPLogo } from '@/components/ui';
import { createSupabaseBrowser } from '@/lib/supabase/client';

type Mode = 'email' | 'phone';

export default function LoginPage() {
  return (
    <Suspense fallback={null}>
      <LoginInner />
    </Suspense>
  );
}

function LoginInner() {
  const router = useRouter();
  const params = useSearchParams();
  const next = params.get('next') ?? '/home';

  const [mode, setMode] = useState<Mode>('email');
  const [identifier, setIdentifier] = useState('');
  const [otp, setOtp] = useState('');
  const [step, setStep] = useState<'identifier' | 'otp'>('identifier');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function sendOtp() {
    setError(null);
    setLoading(true);
    try {
      const supabase = createSupabaseBrowser();
      const { error: otpError } =
        mode === 'email'
          ? await supabase.auth.signInWithOtp({
              email: identifier.trim().toLowerCase(),
              options: { emailRedirectTo: `${window.location.origin}/auth/callback` },
            })
          : await supabase.auth.signInWithOtp({ phone: identifier.trim() });
      if (otpError) throw otpError;
      setStep('otp');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erreur inconnue');
    } finally {
      setLoading(false);
    }
  }

  async function verifyOtp() {
    setError(null);
    setLoading(true);
    try {
      const supabase = createSupabaseBrowser();
      const payload =
        mode === 'email'
          ? { email: identifier.trim().toLowerCase(), token: otp.trim(), type: 'email' as const }
          : { phone: identifier.trim(), token: otp.trim(), type: 'sms' as const };
      const { error: verifyError } = await supabase.auth.verifyOtp(payload);
      if (verifyError) throw verifyError;
      router.replace(next);
      router.refresh();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Code invalide');
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="flex flex-1 flex-col">
      <div className="flex flex-1 flex-col justify-center gap-8">
        <div className="flex flex-col items-center gap-4">
          <RPLogo size={56} />
          <h1 className="text-center font-display text-2xl text-rp-white">
            Bienvenue sur <span className="rp-text-gradient-gold">ROUTEPASS</span>
          </h1>
          <p className="text-center text-sm text-rp-gray">
            Connectez-vous pour scanner, réserver, accéder.
          </p>
        </div>

        {step === 'identifier' ? (
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-2 rounded-rp-btn border border-rp-border bg-rp-dark p-1">
              <button
                type="button"
                onClick={() => setMode('email')}
                className={`flex items-center justify-center gap-2 rounded-rp-input py-2 text-sm transition ${
                  mode === 'email'
                    ? 'bg-rp-dark-2 text-rp-gold'
                    : 'text-rp-gray hover:text-rp-white'
                }`}
              >
                <Mail className="h-4 w-4" /> Email
              </button>
              <button
                type="button"
                onClick={() => setMode('phone')}
                className={`flex items-center justify-center gap-2 rounded-rp-input py-2 text-sm transition ${
                  mode === 'phone'
                    ? 'bg-rp-dark-2 text-rp-gold'
                    : 'text-rp-gray hover:text-rp-white'
                }`}
              >
                <Phone className="h-4 w-4" /> Téléphone
              </button>
            </div>

            <RPInput
              label={mode === 'email' ? 'Adresse email' : 'Numéro de téléphone'}
              type={mode === 'email' ? 'email' : 'tel'}
              autoComplete={mode === 'email' ? 'email' : 'tel'}
              inputMode={mode === 'email' ? 'email' : 'tel'}
              value={identifier}
              onChange={(e) => setIdentifier(e.target.value)}
            />

            {error ? (
              <p className="rounded-rp-input border border-rp-danger/30 bg-rp-danger/10 p-3 text-xs text-rp-danger">
                {error}
              </p>
            ) : null}

            <RPButton
              block
              size="lg"
              loading={loading}
              disabled={identifier.trim().length < 4}
              onClick={sendOtp}
            >
              Recevoir un code
            </RPButton>
          </div>
        ) : (
          <div className="space-y-4">
            <p className="text-center text-sm text-rp-gray">
              Code envoyé à <span className="text-rp-white">{identifier}</span>
            </p>
            <RPInput
              label="Code de vérification"
              inputMode="numeric"
              autoComplete="one-time-code"
              value={otp}
              onChange={(e) => setOtp(e.target.value.replace(/\D/g, '').slice(0, 6))}
            />
            {error ? (
              <p className="rounded-rp-input border border-rp-danger/30 bg-rp-danger/10 p-3 text-xs text-rp-danger">
                {error}
              </p>
            ) : null}
            <RPButton
              block
              size="lg"
              loading={loading}
              disabled={otp.length < 4}
              onClick={verifyOtp}
            >
              Valider
            </RPButton>
            <button
              type="button"
              onClick={() => setStep('identifier')}
              className="block w-full text-center text-xs text-rp-gray hover:text-rp-white"
            >
              Modifier l&apos;identifiant
            </button>
          </div>
        )}
      </div>

      <p className="mt-8 text-center text-xs text-rp-gray">
        Pas encore de compte ?{' '}
        <Link href="/register" className="text-rp-gold hover:underline">
          Créer un compte
        </Link>
      </p>
    </div>
  );
}
