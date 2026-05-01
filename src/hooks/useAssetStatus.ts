'use client';

import { useEffect, useState } from 'react';
import { createSupabaseBrowser } from '@/lib/supabase/client';
import type { AssetStatus } from '@/lib/supabase/types';

interface AssetStatusState {
  status: AssetStatus;
  availableFrom: string | null;
}

/**
 * S'abonne au statut d'un bien via Supabase Realtime.
 * Initialise avec la valeur fournie pour éviter les transitions visuelles.
 */
export function useAssetStatus(
  assetId: string,
  initial: AssetStatusState
): AssetStatusState {
  const [state, setState] = useState<AssetStatusState>(initial);

  useEffect(() => {
    const supabase = createSupabaseBrowser();
    const channel = supabase
      .channel(`asset:${assetId}`)
      .on(
        'postgres_changes',
        {
          event: 'UPDATE',
          schema: 'public',
          table: 'assets',
          filter: `id=eq.${assetId}`,
        },
        (payload) => {
          const next = payload.new as { status: AssetStatus; available_from: string | null };
          setState({ status: next.status, availableFrom: next.available_from });
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, [assetId]);

  return state;
}
