import { Map as MapIcon } from 'lucide-react';
import Link from 'next/link';
import { RPButton } from '@/components/ui';
import { createSupabaseServer } from '@/lib/supabase/server';

export default async function MapPage() {
  const supabase = createSupabaseServer();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  // Carte visible uniquement après au moins un paiement confirmé.
  const { data: profile } = await supabase
    .from('users')
    .select('id')
    .eq('auth_user_id', user?.id ?? '')
    .maybeSingle();

  const { count } = profile
    ? await supabase
        .from('transactions')
        .select('id', { count: 'exact', head: true })
        .eq('client_id', profile.id)
        .in('status', ['confirmed', 'completed'])
    : { count: 0 };

  const unlocked = (count ?? 0) > 0;

  return (
    <div className="px-5 pt-8">
      <header className="space-y-1">
        <p className="text-xs uppercase tracking-[0.3em] text-rp-gold">Carte</p>
        <h1 className="font-display text-2xl text-rp-white">Temps réel</h1>
      </header>

      {unlocked ? (
        <div className="mt-6 flex h-[60dvh] items-center justify-center rounded-rp border border-rp-border bg-rp-dark text-rp-gray">
          {/* Phase 4 : intégration Mapbox GL JS ici. */}
          <p className="text-sm">Mapbox arrive en Phase 4.</p>
        </div>
      ) : (
        <div className="mt-6 space-y-4 rounded-rp border border-dashed border-rp-border bg-rp-dark/40 p-8 text-center">
          <span className="mx-auto flex h-14 w-14 items-center justify-center rounded-full bg-rp-gold/10 text-rp-gold">
            <MapIcon className="h-7 w-7" />
          </span>
          <h2 className="font-display text-lg text-rp-white">
            Réservez pour accéder à la carte
          </h2>
          <p className="text-sm text-rp-gray">
            La carte temps réel se débloque dès votre premier paiement confirmé.
          </p>
          <Link href="/transport">
            <RPButton variant="outlineGold">Voir les prestataires</RPButton>
          </Link>
        </div>
      )}
    </div>
  );
}
