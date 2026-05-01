import Link from 'next/link';
import { Key, Home, Ship, Wrench, Hammer, PartyPopper } from 'lucide-react';
import { createSupabaseServer } from '@/lib/supabase/server';
import { RPCard, RPEmptyState } from '@/components/ui';
import type { AssetCategory } from '@/lib/supabase/types';

const CATEGORIES: { id: AssetCategory; label: string; icon: typeof Key }[] = [
  { id: 'vehicle', label: 'Véhicules', icon: Key },
  { id: 'property', label: 'Biens', icon: Home },
  { id: 'boat', label: 'Bateaux', icon: Ship },
  { id: 'equipment', label: 'Matériel', icon: Wrench },
  { id: 'tool', label: 'Outils', icon: Hammer },
  { id: 'event', label: 'Événement', icon: PartyPopper },
];

interface PageProps {
  searchParams: { c?: string };
}

export default async function LocationPage({ searchParams }: PageProps) {
  const supabase = createSupabaseServer();
  const selected = searchParams.c as AssetCategory | undefined;

  let query = supabase
    .from('assets')
    .select('id, name, category, photos, daily_rate, hourly_rate, status, available_from')
    .eq('verified', true)
    .order('created_at', { ascending: false })
    .limit(40);
  if (selected) query = query.eq('category', selected);

  const { data: assets } = await query;

  return (
    <div className="space-y-6 px-5 pt-8">
      <header>
        <p className="text-xs uppercase tracking-[0.3em] text-rp-gold">Location</p>
        <h1 className="font-display text-2xl text-rp-white">Catalogue autonome</h1>
      </header>

      <div className="-mx-5 flex gap-2 overflow-x-auto px-5 pb-2">
        <Link
          href="/location"
          className={`shrink-0 rounded-full border px-3.5 py-1.5 text-xs ${
            !selected
              ? 'border-rp-gold bg-rp-gold/10 text-rp-gold'
              : 'border-rp-border bg-rp-dark text-rp-gray'
          }`}
        >
          Tous
        </Link>
        {CATEGORIES.map((c) => (
          <Link
            key={c.id}
            href={`/location?c=${c.id}`}
            className={`shrink-0 rounded-full border px-3.5 py-1.5 text-xs ${
              selected === c.id
                ? 'border-rp-gold bg-rp-gold/10 text-rp-gold'
                : 'border-rp-border bg-rp-dark text-rp-gray'
            }`}
          >
            {c.label}
          </Link>
        ))}
      </div>

      {(assets ?? []).length === 0 ? (
        <RPEmptyState
          icon={Key}
          title="Catalogue vide"
          description="Aucun bien vérifié dans cette catégorie pour le moment."
        />
      ) : (
        <ul className="space-y-3">
          {(assets ?? []).map((a) => (
            <li key={a.id}>
              <Link href={`/location/${a.id}`}>
                <RPCard
                  imageUrl={a.photos?.[0]}
                  title={a.name ?? 'Sans nom'}
                  subtitle={a.category ?? undefined}
                  price={a.daily_rate ? Number(a.daily_rate) : a.hourly_rate ? Number(a.hourly_rate) : undefined}
                  priceUnit={a.daily_rate ? '€/j' : '€/h'}
                  status={a.status}
                  availableFrom={a.available_from}
                />
              </Link>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
