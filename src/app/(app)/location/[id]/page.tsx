import { notFound } from 'next/navigation';
import Image from 'next/image';
import { MapPin } from 'lucide-react';
import { createSupabaseServer } from '@/lib/supabase/server';
import { formatEUR } from '@/lib/utils';
import { BookingPanel } from './BookingPanel';
import { LiveStatus } from './LiveStatus';

interface PageProps {
  params: { id: string };
}

export default async function AssetDetailPage({ params }: PageProps) {
  const supabase = createSupabaseServer();
  const { data: asset } = await supabase
    .from('assets')
    .select(
      'id, name, description, category, photos, hourly_rate, daily_rate, weekly_rate, deposit_amount, status, available_from, address, ttlock_lock_id, shelly_device_id'
    )
    .eq('id', params.id)
    .maybeSingle();

  if (!asset) notFound();

  return (
    <div className="space-y-5 pb-32">
      <div className="relative -mx-0 h-72 w-full overflow-hidden">
        {asset.photos?.[0] ? (
          <Image src={asset.photos[0]} alt={asset.name ?? ''} fill sizes="100vw" className="object-cover" />
        ) : (
          <div className="h-full w-full bg-rp-dark-2" />
        )}
        <div className="absolute inset-0 bg-gradient-to-t from-rp-black via-rp-black/30 to-transparent" />
        <div className="absolute bottom-4 left-5 right-5">
          <p className="text-xs uppercase tracking-[0.3em] text-rp-gold">{asset.category}</p>
          <h1 className="font-display text-2xl text-rp-white">{asset.name}</h1>
          {asset.address ? (
            <p className="mt-1 inline-flex items-center gap-1 text-xs text-rp-gray">
              <MapPin className="h-3.5 w-3.5" />
              {asset.address}
            </p>
          ) : null}
        </div>
      </div>

      <div className="space-y-4 px-5">
        <LiveStatus
          assetId={asset.id}
          initialStatus={asset.status}
          initialAvailableFrom={asset.available_from}
        />

        {asset.description ? (
          <p className="text-sm leading-relaxed text-rp-gray">{asset.description}</p>
        ) : null}

        <div className="grid grid-cols-3 gap-2">
          <PriceTile label="Heure" value={asset.hourly_rate} />
          <PriceTile label="Jour" value={asset.daily_rate} />
          <PriceTile label="Semaine" value={asset.weekly_rate} />
        </div>

        <BookingPanel
          assetId={asset.id}
          dailyRate={asset.daily_rate ? Number(asset.daily_rate) : null}
          hourlyRate={asset.hourly_rate ? Number(asset.hourly_rate) : null}
          deposit={asset.deposit_amount ? Number(asset.deposit_amount) : 0}
        />
      </div>
    </div>
  );
}

function PriceTile({ label, value }: { label: string; value: number | string | null }) {
  const n = value ? Number(value) : null;
  return (
    <div className="rounded-rp border border-rp-border bg-rp-dark p-3 text-center">
      <p className="text-[10px] uppercase tracking-[0.3em] text-rp-gold">{label}</p>
      <p className="mt-1 font-mono text-sm text-rp-white">
        {n ? formatEUR(n) : '—'}
      </p>
    </div>
  );
}
