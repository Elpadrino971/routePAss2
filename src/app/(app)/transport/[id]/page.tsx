import { notFound } from 'next/navigation';
import Image from 'next/image';
import { createSupabaseServer } from '@/lib/supabase/server';
import { RPAvatar, RPBadge } from '@/components/ui';
import { CheckoutPanel } from './CheckoutPanel';

interface PageProps {
  params: { id: string };
}

export default async function ProviderDetailPage({ params }: PageProps) {
  const supabase = createSupabaseServer();
  const { data: provider } = await supabase
    .from('providers')
    .select(
      'id, service_type, vehicle_name, vehicle_photo_url, base_rate, verified, is_available, users:user_id(full_name, avatar_url)'
    )
    .eq('id', params.id)
    .maybeSingle();

  if (!provider) notFound();

  type UserLookup = { full_name: string | null; avatar_url: string | null };
  const userRow = provider.users as unknown as UserLookup | UserLookup[] | null;
  const u = Array.isArray(userRow) ? userRow[0] : userRow;

  return (
    <div className="space-y-5">
      <div className="relative h-64 w-full overflow-hidden">
        {provider.vehicle_photo_url ? (
          <Image
            src={provider.vehicle_photo_url}
            alt={provider.vehicle_name ?? ''}
            fill
            sizes="100vw"
            className="object-cover"
          />
        ) : (
          <div className="h-full w-full bg-rp-dark-2" />
        )}
        <div className="absolute inset-0 bg-gradient-to-t from-rp-black via-rp-black/30 to-transparent" />
        <div className="absolute bottom-4 left-5 right-5 flex items-end justify-between">
          <div>
            <p className="text-xs uppercase tracking-[0.3em] text-rp-gold">
              {provider.service_type}
            </p>
            <h1 className="font-display text-2xl text-rp-white">
              {provider.vehicle_name}
            </h1>
          </div>
          <RPBadge tone={provider.is_available ? 'success' : 'muted'} withDot pulse={provider.is_available}>
            {provider.is_available ? 'Disponible' : 'Hors ligne'}
          </RPBadge>
        </div>
      </div>

      <div className="space-y-4 px-5">
        <div className="flex items-center gap-3 rounded-rp border border-rp-border bg-rp-dark p-3">
          <RPAvatar src={u?.avatar_url} fallback={u?.full_name ?? 'R'} verified={provider.verified} />
          <div>
            <p className="text-sm text-rp-white">{u?.full_name ?? 'Prestataire'}</p>
            <p className="text-xs text-rp-gray">
              {provider.verified ? 'Identité vérifiée' : 'En cours de vérification'}
            </p>
          </div>
        </div>

        <CheckoutPanel
          providerId={provider.id}
          baseRate={provider.base_rate ? Number(provider.base_rate) : null}
        />
      </div>
    </div>
  );
}
