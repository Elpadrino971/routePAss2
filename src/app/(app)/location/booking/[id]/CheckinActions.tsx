'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { Camera, KeyRound, PowerOff, Power } from 'lucide-react';
import { RPButton } from '@/components/ui';

interface Props {
  bookingId: string;
  status: string;
  hasLock: boolean;
  hasShelly: boolean;
  shellyId: string | null;
}

export function CheckinActions({
  bookingId,
  status,
  hasLock,
  hasShelly,
  shellyId,
}: Props) {
  const router = useRouter();
  const [busy, setBusy] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  async function call(label: string, fn: () => Promise<Response>) {
    setBusy(label);
    setError(null);
    try {
      const res = await fn();
      if (!res.ok) {
        const json = (await res.json().catch(() => ({}))) as { error?: string };
        throw new Error(json.error ?? 'Erreur');
      }
      router.refresh();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erreur');
    } finally {
      setBusy(null);
    }
  }

  async function checkin() {
    await call('checkin', () =>
      fetch(`/api/bookings/${bookingId}/checkin`, { method: 'POST' })
    );
  }

  async function checkout() {
    await call('checkout', () =>
      fetch(`/api/bookings/${bookingId}/checkout`, { method: 'POST' })
    );
  }

  async function powerOn() {
    if (!shellyId) return;
    await call('on', () =>
      fetch('/api/shelly/power-on', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ deviceId: shellyId }),
      })
    );
  }

  async function powerOff() {
    if (!shellyId) return;
    await call('off', () =>
      fetch('/api/shelly/power-off', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ deviceId: shellyId }),
      })
    );
  }

  return (
    <section className="space-y-3">
      <h2 className="font-display text-lg text-rp-white">Accès & contrôles</h2>

      {status === 'confirmed' ? (
        <RPButton
          block
          size="lg"
          loading={busy === 'checkin'}
          onClick={checkin}
        >
          <KeyRound className="h-5 w-5" />
          Démarrer la location
        </RPButton>
      ) : null}

      {status === 'active' ? (
        <>
          <div className="grid grid-cols-2 gap-2">
            {hasShelly ? (
              <>
                <RPButton variant="secondary" loading={busy === 'on'} onClick={powerOn}>
                  <Power className="h-4 w-4" />
                  Allumer
                </RPButton>
                <RPButton variant="secondary" loading={busy === 'off'} onClick={powerOff}>
                  <PowerOff className="h-4 w-4" />
                  Éteindre
                </RPButton>
              </>
            ) : null}
          </div>

          <RPButton
            block
            size="lg"
            variant="outlineGold"
            loading={busy === 'checkout'}
            onClick={checkout}
          >
            <Camera className="h-5 w-5" />
            Restituer
          </RPButton>
        </>
      ) : null}

      {!hasLock && !hasShelly ? (
        <p className="text-xs text-rp-gray">
          Ce bien n&apos;est pas équipé d&apos;automatisation IoT — l&apos;accès se fait
          via les instructions du propriétaire.
        </p>
      ) : null}

      {error ? (
        <p className="rounded-rp-input border border-rp-danger/30 bg-rp-danger/10 p-3 text-xs text-rp-danger">
          {error}
        </p>
      ) : null}
    </section>
  );
}
