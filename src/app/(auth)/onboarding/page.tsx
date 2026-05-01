'use client';

import { useMemo, useState } from 'react';
import { useRouter } from 'next/navigation';
import Image from 'next/image';
import { motion, AnimatePresence } from 'framer-motion';
import { RPButton, RPLogo } from '@/components/ui';
import { cn } from '@/lib/utils';
import { createSupabaseBrowser } from '@/lib/supabase/client';
import type { UserRole } from '@/lib/supabase/types';

interface Slide {
  imageUrl: string;
  title: string;
  highlight: string;
  description: string;
}

/**
 * 3 slides reprenant exactement les visuels du master prompt :
 * 1. "Payez, montez, partez" — voiture devant un hôtel de luxe
 * 2. "Louez sans, contact"   — Mercedes éclairée, clé sans contact
 * 3. "Vos actifs, travaillent pour vous" — villa avec graphes de revenus
 */
const SLIDES: Slide[] = [
  {
    imageUrl:
      'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=1200&q=80',
    title: 'Payez, montez,',
    highlight: 'partez',
    description:
      'Scannez, réservez et accédez à vos transports et locations en quelques secondes.',
  },
  {
    imageUrl:
      'https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?auto=format&fit=crop&w=1200&q=80',
    title: 'Louez sans,',
    highlight: 'contact',
    description:
      'Véhicules, bateaux, appartements. Disponibilité en temps réel, accès autonome.',
  },
  {
    imageUrl:
      'https://images.unsplash.com/photo-1613977257363-707ba9348227?auto=format&fit=crop&w=1200&q=80',
    title: 'Vos actifs,',
    highlight: 'travaillent pour vous',
    description:
      'Mettez vos biens en location. Recevez vos paiements automatiquement.',
  },
];

export default function OnboardingPage() {
  const router = useRouter();
  const [index, setIndex] = useState(0);
  const [step, setStep] = useState<'intro' | 'role'>('intro');
  const [role, setRole] = useState<UserRole>('client');
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const slide = useMemo(() => SLIDES[index]!, [index]);
  const isLast = index === SLIDES.length - 1;

  function next() {
    if (!isLast) {
      setIndex((i) => i + 1);
    } else {
      setStep('role');
    }
  }

  async function finish() {
    setError(null);
    setSaving(true);
    try {
      const supabase = createSupabaseBrowser();
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) throw new Error('Session expirée');

      // upsert profil ROUTEPASS
      const { error: upsertError } = await supabase
        .from('users')
        .upsert(
          {
            auth_user_id: user.id,
            email: user.email,
            full_name:
              (user.user_metadata?.full_name as string | undefined) ?? null,
            phone: (user.user_metadata?.phone as string | undefined) ?? null,
            role,
          },
          { onConflict: 'auth_user_id' }
        );
      if (upsertError) throw upsertError;

      const dest =
        role === 'admin'
          ? '/admin/dashboard'
          : role === 'provider'
          ? '/setup'
          : role === 'owner'
          ? '/dashboard'
          : '/home';
      router.replace(dest);
      router.refresh();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erreur inconnue');
    } finally {
      setSaving(false);
    }
  }

  if (step === 'role') {
    return (
      <div className="flex flex-1 flex-col gap-8 py-6">
        <div className="flex flex-col items-center gap-3">
          <RPLogo size={48} />
          <h1 className="text-center font-display text-2xl text-rp-white">
            Quel est votre <span className="rp-text-gradient-gold">profil</span> ?
          </h1>
          <p className="text-center text-sm text-rp-gray">
            Vous pourrez en ajouter d&apos;autres plus tard.
          </p>
        </div>

        <div className="space-y-3">
          {(
            [
              {
                value: 'client' as const,
                title: 'Client',
                desc: 'Réserver transports et locations',
              },
              {
                value: 'provider' as const,
                title: 'Prestataire transport',
                desc: 'Taxi, minibus, bateau, fret',
              },
              {
                value: 'owner' as const,
                title: 'Propriétaire',
                desc: 'Louer mes véhicules, biens, équipements',
              },
            ] satisfies { value: UserRole; title: string; desc: string }[]
          ).map((opt) => {
            const selected = role === opt.value;
            return (
              <button
                key={opt.value}
                type="button"
                onClick={() => setRole(opt.value)}
                className={cn(
                  'flex w-full items-start gap-3 rounded-rp border p-4 text-left transition-all',
                  selected
                    ? 'border-rp-gold bg-rp-gold/5 shadow-rp-gold'
                    : 'border-rp-border bg-rp-dark hover:border-rp-gold/40'
                )}
              >
                <span
                  className={cn(
                    'mt-0.5 h-5 w-5 shrink-0 rounded-full border-2 transition',
                    selected
                      ? 'border-rp-gold bg-rp-gold'
                      : 'border-rp-border'
                  )}
                />
                <span>
                  <span className="block font-display text-base text-rp-white">
                    {opt.title}
                  </span>
                  <span className="block text-xs text-rp-gray">{opt.desc}</span>
                </span>
              </button>
            );
          })}
        </div>

        {error ? (
          <p className="rounded-rp-input border border-rp-danger/30 bg-rp-danger/10 p-3 text-xs text-rp-danger">
            {error}
          </p>
        ) : null}

        <div className="mt-auto space-y-3">
          <RPButton block size="lg" loading={saving} onClick={finish}>
            Continuer
          </RPButton>
          <button
            type="button"
            onClick={() => setStep('intro')}
            className="block w-full text-center text-xs text-rp-gray hover:text-rp-white"
          >
            Retour
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="flex flex-1 flex-col">
      <div className="relative -mx-6 mt-2 overflow-hidden rounded-rp">
        <AnimatePresence mode="wait">
          <motion.div
            key={index}
            initial={{ opacity: 0, scale: 1.04 }}
            animate={{ opacity: 1, scale: 1 }}
            exit={{ opacity: 0, scale: 0.98 }}
            transition={{ duration: 0.4 }}
            className="relative h-[58dvh] w-full"
          >
            <Image
              src={slide.imageUrl}
              alt=""
              fill
              priority
              sizes="100vw"
              className="object-cover"
            />
            <div className="absolute inset-0 bg-gradient-to-b from-rp-black/30 via-transparent to-rp-black" />
            <div className="absolute left-1/2 top-8 -translate-x-1/2">
              <RPLogo size={44} />
            </div>
          </motion.div>
        </AnimatePresence>
      </div>

      <div className="mt-6 flex flex-1 flex-col items-center gap-5 px-2 pb-2">
        <AnimatePresence mode="wait">
          <motion.div
            key={`txt-${index}`}
            initial={{ opacity: 0, y: 12 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -8 }}
            transition={{ duration: 0.3 }}
            className="flex flex-col items-center gap-3"
          >
            <h1 className="text-center font-display text-3xl leading-tight text-rp-white">
              {slide.title}{' '}
              <span className="rp-text-gradient-gold italic">{slide.highlight}</span>
            </h1>
            <div className="rp-divider w-24">R</div>
            <p className="max-w-xs text-center text-sm text-rp-gray">
              {slide.description}
            </p>
          </motion.div>
        </AnimatePresence>

        <div className="mt-2 flex items-center gap-1.5">
          {SLIDES.map((_, i) => (
            <span
              key={i}
              className={cn(
                'h-1.5 rounded-full transition-all',
                i === index ? 'w-6 bg-rp-gold' : 'w-1.5 bg-rp-border'
              )}
            />
          ))}
        </div>

        <div className="mt-auto w-full">
          <RPButton block size="lg" onClick={next}>
            Suivant
          </RPButton>
          {!isLast ? (
            <button
              type="button"
              onClick={() => setStep('role')}
              className="mt-3 block w-full text-center text-xs text-rp-gray hover:text-rp-white"
            >
              Passer
            </button>
          ) : null}
        </div>
      </div>
    </div>
  );
}
