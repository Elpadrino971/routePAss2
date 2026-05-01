import Link from 'next/link';
import { Map as MapIcon } from 'lucide-react';
import { createSupabaseServer } from '@/lib/supabase/server';
import { RPButton } from '@/components/ui';
import { LiveMap } from './LiveMap';

export default async function MapPage() {
  const supabase = createSupabaseServer();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const { data: profile } = await supabase
    .from('users')
    .select('id')
    .eq('auth_user_id', user?.id ?? '')
    .maybeSingle();

  // Carte verrouillée tant qu'aucun paiement confirmé.
  let unlocked = false;
  if (profile) {
    const [{ count: txCount }, { count: bkCount }] = await Promise.all([
      supabase
        .from('transactions')
        .select('id', { count: 'exact', head: true })
        .eq('client_id', profile.id)
        .in('status', ['confirmed', 'completed']),
      supabase
        .from('bookings')
        .select('id', { count: 'exact', head: true })
        .eq('client_id', profile.id)
        .in('status', ['confirmed', 'active', 'completed']),
    ]);
    unlocked = (txCount ?? 0) + (bkCount ?? 0) > 0;
  }

  if (!unlocked) {
    return (
      <div className="px-5 pt-8">
        <header className="space-y-1">
          <p className="text-xs uppercase tracking-[0.3em] text-rp-gold">Carte</p>
          <h1 className="font-display text-2xl text-rp-white">Temps réel</h1>
        </header>
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
      </div>
    );
  }

  // Récupère les biens et prestataires géolocalisés visibles.
  const [{ data: assets }, { data: providers }] = await Promise.all([
    supabase
      .from('assets')
      .select('id, name, category, lat, lng, status')
      .eq('verified', true)
      .not('lat', 'is', null)
      .not('lng', 'is', null)
      .limit(200),
    supabase
      .from('providers')
      .select('id, vehicle_name, service_type, current_lat, current_lng, is_available')
      .eq('verified', true)
      .eq('is_available', true)
      .not('current_lat', 'is', null)
      .not('current_lng', 'is', null)
      .limit(200),
  ]);

  return <LiveMap assets={assets ?? []} providers={providers ?? []} />;
}
