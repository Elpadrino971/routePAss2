'use client';

import { useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { RPButton, RPInput, RPLogo } from '@/components/ui';
import { createSupabaseBrowser } from '@/lib/supabase/client';

export default function RegisterPage() {
  const router = useRouter();
  const [fullName, setFullName] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function submit() {
    setError(null);
    setLoading(true);
    try {
      const supabase = createSupabaseBrowser();
      const { error: signUpError } = await supabase.auth.signInWithOtp({
        email: email.trim().toLowerCase(),
        options: {
          data: { full_name: fullName.trim(), phone: phone.trim() },
          emailRedirectTo: `${window.location.origin}/auth/callback?next=/onboarding`,
        },
      });
      if (signUpError) throw signUpError;
      router.replace(`/login?next=/onboarding`);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erreur inconnue');
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
            Créer un compte <span className="rp-text-gradient-gold">ROUTEPASS</span>
          </h1>
        </div>

        <div className="space-y-4">
          <RPInput
            label="Nom complet"
            autoComplete="name"
            value={fullName}
            onChange={(e) => setFullName(e.target.value)}
          />
          <RPInput
            label="Adresse email"
            type="email"
            autoComplete="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
          />
          <RPInput
            label="Téléphone (optionnel)"
            type="tel"
            autoComplete="tel"
            value={phone}
            onChange={(e) => setPhone(e.target.value)}
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
            disabled={fullName.trim().length < 2 || !email.includes('@')}
            onClick={submit}
          >
            Continuer
          </RPButton>
        </div>
      </div>

      <p className="mt-8 text-center text-xs text-rp-gray">
        Déjà un compte ?{' '}
        <Link href="/login" className="text-rp-gold hover:underline">
          Se connecter
        </Link>
      </p>
    </div>
  );
}
