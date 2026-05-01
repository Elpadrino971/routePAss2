import Link from 'next/link';
import { Car, Bus, Ship, Truck, QrCode } from 'lucide-react';
import { createSupabaseServer } from '@/lib/supabase/server';
import { RPAvatar, RPBadge, RPButton, RPEmptyState } from '@/components/ui';
import { formatEUR } from '@/lib/utils';
import type { ServiceType } from '@/lib/supabase/types';

const SERVICE_LABEL: Record<ServiceType, { label: string; icon: typeof Car }> = {
  taxi: { label: 'Taxi', icon: Car },
  minibus: { label: 'Minibus', icon: Bus },
  boat: { label: 'Bateau', icon: Ship },
  truck: { label: 'Fret', icon: Truck },
};

export default async function TransportPage() {
  const supabase = createSupabaseServer();
  const { data: providers } = await supabase
    .from('providers')
    .select(
      'id, service_type, vehicle_name, vehicle_photo_url, base_rate, verified, is_available, users:user_id(full_name, avatar_url)'
    )
    .eq('verified', true)
    .eq('is_available', true)
    .limit(40);

  const counts: Record<ServiceType, number> = { taxi: 0, minibus: 0, boat: 0, truck: 0 };
  for (const p of providers ?? []) {
    if (p.service_type) counts[p.service_type as ServiceType]++;
  }

  return (
    <div className="space-y-6 px-5 pt-8">
      <header>
        <p className="text-xs uppercase tracking-[0.3em] text-rp-gold">Transport</p>
        <h1 className="font-display text-2xl text-rp-white">
          Trouvez votre prestataire
        </h1>
      </header>

      <div className="grid grid-cols-4 gap-3">
        {(Object.entries(SERVICE_LABEL) as [ServiceType, { label: string; icon: typeof Car }][]).map(
          ([id, cfg]) => (
            <button
              key={id}
              type="button"
              className="flex flex-col items-center gap-2 rounded-rp border border-rp-border bg-rp-dark p-3 transition hover:border-rp-gold/40"
            >
              <span className="flex h-12 w-12 items-center justify-center rounded-full bg-rp-gold/10 text-rp-gold">
                <cfg.icon className="h-6 w-6" />
              </span>
              <span className="text-[11px] font-medium text-rp-white">{cfg.label}</span>
              <span className="text-[10px] text-rp-gray">{counts[id]} dispo</span>
            </button>
          )
        )}
      </div>

      <Link href="/transport/scan">
        <RPButton block size="lg">
          <QrCode className="h-5 w-5" />
          Scanner un QR code
        </RPButton>
      </Link>

      <section className="space-y-3">
        <h2 className="font-display text-lg text-rp-white">Prestataires proches</h2>
        {(providers ?? []).length === 0 ? (
          <RPEmptyState
            icon={Car}
            title="Aucun prestataire vérifié"
            description="Les prestataires apparaîtront ici dès leur inscription validée."
          />
        ) : (
          <ul className="space-y-2">
            {(providers ?? []).map((p) => {
              type UserLookup = { full_name: string | null; avatar_url: string | null };
              const userRow = p.users as unknown as UserLookup | UserLookup[] | null;
              const u = Array.isArray(userRow) ? userRow[0] : userRow;
              return (
                <li key={p.id}>
                  <Link
                    href={`/transport/${p.id}`}
                    className="flex items-center gap-3 rounded-rp border border-rp-border bg-rp-dark p-3 transition hover:border-rp-gold/40"
                  >
                    <RPAvatar src={u?.avatar_url} fallback={u?.full_name ?? 'R'} verified={p.verified} />
                    <div className="flex-1">
                      <p className="text-sm text-rp-white">
                        {u?.full_name ?? 'Prestataire'}
                      </p>
                      <p className="text-xs text-rp-gray">
                        {p.vehicle_name ?? '—'}
                      </p>
                    </div>
                    <div className="text-right">
                      <p className="font-mono text-sm text-rp-gold">
                        {p.base_rate ? formatEUR(Number(p.base_rate)) : '—'}
                      </p>
                      <RPBadge tone="success" withDot pulse className="mt-1">
                        Disponible
                      </RPBadge>
                    </div>
                  </Link>
                </li>
              );
            })}
          </ul>
        )}
      </section>
    </div>
  );
}
