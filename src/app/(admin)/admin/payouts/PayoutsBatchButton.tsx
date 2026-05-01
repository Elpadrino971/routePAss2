'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { Banknote } from 'lucide-react';
import { RPButton } from '@/components/ui';

export function PayoutsBatchButton() {
  const router = useRouter();
  const [busy, setBusy] = useState(false);
  const [result, setResult] = useState<string | null>(null);

  async function run() {
    setBusy(true);
    setResult(null);
    const res = await fetch('/api/admin/payouts/batch', { method: 'POST' });
    const json = (await res.json()) as { processed?: number; error?: string };
    setResult(
      res.ok ? `${json.processed ?? 0} virements lancés` : json.error ?? 'Erreur'
    );
    router.refresh();
    setBusy(false);
  }

  return (
    <div className="flex items-center gap-2">
      {result ? <span className="text-xs text-rp-gray">{result}</span> : null}
      <RPButton size="sm" loading={busy} onClick={run}>
        <Banknote className="h-4 w-4" />
        Lancer le batch
      </RPButton>
    </div>
  );
}
