import { Car, Key, QrCode, Map as MapIcon } from 'lucide-react';
import Link from 'next/link';
import { createSupabaseServer } from '@/lib/supabase/server';
import { RPAvatar, RPCard, RPEmptyState, RPLogo } from '@/components/ui';

const QUICK_ACTIONS = [
  { id: 'transport', label: 'Me déplacer', icon: Car, href: '/transport' },
  { id: 'location', label: 'Louer', icon: Key, href: '/location' },
  { id: 'scan', label: 'Accéder', icon: QrCode, href: '/transport/scan' },
  { id: 'map', label: 'Carte', icon: MapIcon, href: '/map' },
] as const;

export default async function HomePage() {
  const supabase = createSupabaseServer();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const { data: profile } = await supabase
    .from('users')
    .select('full_name, avatar_url')
    .eq('auth_user_id', user?.id ?? '')
    .maybeSingle();

  const firstName =
    profile?.full_name?.split(' ')[0] ?? user?.email?.split('@')[0] ?? 'invité';

  // Featured assets — vides en Phase 1, feront l'objet de la Phase 3.
  const featured: { id: string; name: string }[] = [];

  return (
    <div className="space-y-7 px-5 pt-8">
      <header className="flex items-center justify-between">
        <div>
          <p className="text-xs uppercase tracking-[0.3em] text-rp-gold">Bonjour</p>
          <h1 className="font-display text-2xl text-rp-white">{firstName}</h1>
        </div>
        <Link href="/account" aria-label="Mon compte">
          <RPAvatar
            src={profile?.avatar_url}
            fallback={profile?.full_name ?? user?.email ?? 'R'}
            size="md"
          />
        </Link>
      </header>

      <section className="grid grid-cols-4 gap-3">
        {QUICK_ACTIONS.map((a) => (
          <Link
            key={a.id}
            href={a.href}
            className="flex flex-col items-center gap-2 rounded-rp border border-rp-border bg-rp-dark p-3 transition hover:border-rp-gold/40"
          >
            <span className="flex h-10 w-10 items-center justify-center rounded-full bg-rp-gold/10 text-rp-gold">
              <a.icon className="h-5 w-5" />
            </span>
            <span className="text-[10px] font-medium text-rp-gray">{a.label}</span>
          </Link>
        ))}
      </section>

      <section className="space-y-3">
        <div className="flex items-baseline justify-between">
          <h2 className="font-display text-lg text-rp-white">En vedette</h2>
          <Link href="/location" className="text-xs text-rp-gold hover:underline">
            Tout voir
          </Link>
        </div>
        {featured.length === 0 ? (
          <RPEmptyState
            icon={Key}
            title="Catalogue à venir"
            description="Les biens en vedette apparaîtront ici dès la Phase 3."
          />
        ) : (
          <div className="flex gap-3 overflow-x-auto pb-2 [&>*]:min-w-[260px]">
            {featured.map((f) => (
              <RPCard key={f.id} title={f.name} />
            ))}
          </div>
        )}
      </section>

      <section className="space-y-3">
        <h2 className="font-display text-lg text-rp-white">Récemment consultés</h2>
        <RPEmptyState
          icon={Car}
          title="Aucun historique"
          description="Vos consultations récentes apparaîtront ici."
        />
      </section>

      <div className="flex justify-center pt-4 opacity-50">
        <RPLogo size={32} withWordmark />
      </div>
    </div>
  );
}
