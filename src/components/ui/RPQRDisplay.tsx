'use client';

import { QRCodeCanvas } from 'qrcode.react';
import { cn } from '@/lib/utils';

interface RPQRDisplayProps {
  value: string;
  size?: number;
  caption?: string;
  className?: string;
}

/** Card blanche, logo R centré, QR net. */
export function RPQRDisplay({
  value,
  size = 240,
  caption,
  className,
}: RPQRDisplayProps) {
  return (
    <div
      className={cn(
        'flex flex-col items-center gap-4 rounded-rp bg-rp-white p-6 shadow-rp',
        className
      )}
    >
      <div className="rounded-2xl bg-white p-3">
        <QRCodeCanvas
          value={value}
          size={size}
          level="H"
          bgColor="#FFFFFF"
          fgColor="#08080D"
          includeMargin={false}
          imageSettings={{
            src: '/logo-r.svg',
            height: 36,
            width: 36,
            excavate: true,
          }}
        />
      </div>
      {caption ? (
        <p className="text-center font-display text-sm italic text-rp-black/70">
          {caption}
        </p>
      ) : null}
    </div>
  );
}
