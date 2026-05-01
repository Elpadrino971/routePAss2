'use client';

import { useEffect, useRef, useState } from 'react';
import { X } from 'lucide-react';
import { cn } from '@/lib/utils';

interface RPQRScannerProps {
  onResult: (text: string) => void;
  onClose?: () => void;
  className?: string;
}

/**
 * Scanner QR fullscreen avec guides animés aux coins.
 * Charge html5-qrcode dynamiquement côté client uniquement.
 */
export function RPQRScanner({ onResult, onClose, className }: RPQRScannerProps) {
  const containerRef = useRef<HTMLDivElement>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let scanner: { stop: () => Promise<void>; clear: () => void } | null = null;
    let cancelled = false;

    (async () => {
      try {
        const { Html5Qrcode } = await import('html5-qrcode');
        if (cancelled || !containerRef.current) return;
        const elementId = 'rp-qr-scanner-region';
        containerRef.current.id = elementId;
        const instance = new Html5Qrcode(elementId, { verbose: false });
        scanner = instance;
        await instance.start(
          { facingMode: 'environment' },
          { fps: 10, qrbox: { width: 260, height: 260 } },
          (decodedText) => {
            onResult(decodedText);
          },
          () => {
            // Erreurs de frame ignorées — bruit normal pendant le scan.
          }
        );
      } catch (err) {
        const msg = err instanceof Error ? err.message : 'Caméra inaccessible';
        setError(msg);
      }
    })();

    return () => {
      cancelled = true;
      if (scanner) {
        scanner
          .stop()
          .catch(() => undefined)
          .finally(() => scanner?.clear());
      }
    };
  }, [onResult]);

  return (
    <div className={cn('fixed inset-0 z-50 flex flex-col bg-rp-black', className)}>
      <div className="relative flex-1 overflow-hidden">
        <div ref={containerRef} className="absolute inset-0 [&>video]:h-full [&>video]:w-full [&>video]:object-cover" />
        {/* Overlay avec guides */}
        <div className="pointer-events-none absolute inset-0 flex items-center justify-center">
          <div className="relative h-64 w-64">
            {[
              'left-0 top-0 border-l-2 border-t-2',
              'right-0 top-0 border-r-2 border-t-2',
              'left-0 bottom-0 border-l-2 border-b-2',
              'right-0 bottom-0 border-r-2 border-b-2',
            ].map((pos, i) => (
              <span
                key={i}
                className={cn(
                  'absolute h-10 w-10 rounded-sm border-rp-gold',
                  pos
                )}
              />
            ))}
          </div>
        </div>
        {error ? (
          <div className="absolute inset-x-0 bottom-24 mx-4 rounded-rp border border-rp-danger/40 bg-rp-danger/10 p-4 text-sm text-rp-danger">
            {error}
          </div>
        ) : null}
      </div>

      <div className="flex items-center justify-between border-t border-rp-border bg-rp-dark px-5 py-4">
        <p className="font-display text-sm italic text-rp-gold">
          Scannez un QR ROUTEPASS
        </p>
        {onClose ? (
          <button
            type="button"
            onClick={onClose}
            aria-label="Fermer le scanner"
            className="rounded-full bg-rp-dark-2 p-2 text-rp-white hover:bg-rp-border"
          >
            <X className="h-5 w-5" />
          </button>
        ) : null}
      </div>
    </div>
  );
}
