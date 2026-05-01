import { redirect } from 'next/navigation';
import Link from 'next/link';
import { Plus, Building2 } from 'lucide-react';
import { createSupabaseServer } from '@/lib/supabase/server';
import { RPButton, RPCard, RPEmptyState } from '@/components/ui';

export default async function MyAssetsPage() {
  const supabase = createSupabaseServer();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const { data: profile } = await supabase
    .from('users')
    .select('id')
    .eq('auth_user_id', user.id)
    .maybeSingle();
  if (!profile) redirect('/onboarding');

  const { data: assets } = await supabase
    .from('assets')
    .select('id, name, photos, daily_rate, hourly_rate, status, available_from, verified, category')
    .eq('owner_id', profile.id)
    .order('created_at', { ascending: false });

  return (
    <div className="space-y-5 px-5 pt-8">
      <header className="flex items-end justify-between">
        <div>
          <p className="text-xs uppercase tracking-[0.3em] text-rp-gold">
            Mes biens
          </p>
          <h1 className="font-display text-2xl text-rp-white">Catalogue</h1>
        </div>
        <Link href="/assets/new">
          <RPButton size="sm">
            <Plus className="h-4 w-4" />
            Ajouter
          </RPButton>
        </Link>
      </header>

      {(assets ?? []).length === 0 ? (
        <RPEmptyState
          icon={Building2}
          title="Aucun bien encore"
          description="Ajoutez votre premier bien pour commencer à recevoir des réservations."
        />
      ) : (
        <ul className="space-y-3">
          {(assets ?? []).map((a) => (
            <li key={a.id}>
              <Link href={`/location/${a.id}`}>
                <RPCard
                  imageUrl={a.photos?.[0]}
                  title={a.name ?? 'Sans nom'}
                  subtitle={`${a.category ?? ''} · ${a.verified ? 'Vérifié' : 'En attente'}`}
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
