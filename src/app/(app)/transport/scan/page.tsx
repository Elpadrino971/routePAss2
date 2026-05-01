'use client';

import { useRouter } from 'next/navigation';
import { useState } from 'react';
import { RPQRScanner } from '@/components/ui';

export default function ScanPage() {
  const router = useRouter();
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleResult(token: string) {
    if (busy) return;
    setBusy(true);
    setError(null);
    try {
      const res = await fetch('/api/qr/resolve', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ token }),
      });
      const json = (await res.json()) as
        | { kind: 'provider'; provider: { id: string } }
        | { kind: 'access'; bookingId: string }
        | { error: string };
      if ('error' in json) throw new Error(json.error);
      if (json.kind === 'provider') {
        router.replace(`/transport/${json.provider.id}`);
      } else {
        router.replace(`/location/booking/${json.bookingId}`);
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'QR invalide');
      setBusy(false);
    }
  }

  return (
    <>
      <RPQRScanner onResult={handleResult} onClose={() => router.back()} />
      {error ? (
        <div className="fixed inset-x-0 bottom-24 z-[60] mx-auto max-w-md px-5">
          <div className="rounded-rp-input border border-rp-danger/40 bg-rp-danger/15 p-3 text-center text-sm text-rp-danger">
            {error}
          </div>
        </div>
      ) : null}
    </>
  );
}
