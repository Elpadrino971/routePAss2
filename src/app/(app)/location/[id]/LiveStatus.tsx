'use client';

import { RPStatusBadge } from '@/components/ui';
import { useAssetStatus } from '@/hooks/useAssetStatus';
import type { AssetStatus } from '@/lib/supabase/types';

interface Props {
  assetId: string;
  initialStatus: AssetStatus;
  initialAvailableFrom: string | null;
}

export function LiveStatus({ assetId, initialStatus, initialAvailableFrom }: Props) {
  const { status, availableFrom } = useAssetStatus(assetId, {
    status: initialStatus,
    availableFrom: initialAvailableFrom,
  });
  return (
    <div className="flex items-center justify-between rounded-rp border border-rp-border bg-rp-dark px-4 py-3">
      <span className="text-xs uppercase tracking-[0.3em] text-rp-gold">
        Statut temps réel
      </span>
      <RPStatusBadge status={status} availableFrom={availableFrom} />
    </div>
  );
}
