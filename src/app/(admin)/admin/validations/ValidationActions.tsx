'use client';

import { useRouter } from 'next/navigation';
import { useState } from 'react';
import { Check, X } from 'lucide-react';
import { RPButton } from '@/components/ui';

interface Props {
  kind: 'provider' | 'asset';
  id: string;
}

export function ValidationActions({ kind, id }: Props) {
  const router = useRouter();
  const [busy, setBusy] = useState<'approve' | 'reject' | null>(null);

  async function action(approve: boolean) {
    setBusy(approve ? 'approve' : 'reject');
    await fetch('/api/admin/validate', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ kind, id, approve }),
    });
    router.refresh();
    setBusy(null);
  }

  return (
    <div className="flex gap-2">
      <RPButton
        size="sm"
        variant="secondary"
        loading={busy === 'reject'}
        onClick={() => action(false)}
      >
        <X className="h-4 w-4" /> Rejeter
      </RPButton>
      <RPButton
        size="sm"
        loading={busy === 'approve'}
        onClick={() => action(true)}
      >
        <Check className="h-4 w-4" /> Approuver
      </RPButton>
    </div>
  );
}
