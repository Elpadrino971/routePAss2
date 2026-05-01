'use client';

import Image from 'next/image';
import { cn, formatEUR } from '@/lib/utils';
import { RPStatusBadge, type AssetStatus } from './RPBadge';

interface RPCardProps {
  imageUrl?: string;
  title: string;
  subtitle?: string;
  price?: number;
  priceUnit?: '€/h' | '€/j' | '€/sem' | '€';
  status?: AssetStatus;
  availableFrom?: Date | string | null;
  highlight?: string;
  onClick?: () => void;
  className?: string;
  imageHeight?: 'sm' | 'md' | 'lg';
}

const HEIGHTS = { sm: 'h-32', md: 'h-44', lg: 'h-56' };

/**
 * Card universelle ROUTEPASS — image + titre + statut + prix.
 * Sert pour les biens, véhicules, prestataires, etc.
 */
export function RPCard({
  imageUrl,
  title,
  subtitle,
  price,
  priceUnit = '€/j',
  status,
  availableFrom,
  highlight,
  onClick,
  className,
  imageHeight = 'md',
}: RPCardProps) {
  const interactive = Boolean(onClick);
  return (
    <div
      onClick={onClick}
      role={interactive ? 'button' : undefined}
      tabIndex={interactive ? 0 : undefined}
      onKeyDown={
        interactive
          ? (e) => {
              if (e.key === 'Enter' || e.key === ' ') {
                e.preventDefault();
                onClick?.();
              }
            }
          : undefined
      }
      className={cn(
        'group relative overflow-hidden rounded-rp border border-rp-border bg-rp-dark shadow-rp transition-all',
        interactive && 'cursor-pointer hover:border-rp-gold/40 hover:shadow-rp-gold',
        className
      )}
    >
      {imageUrl ? (
        <div className={cn('relative w-full overflow-hidden', HEIGHTS[imageHeight])}>
          <Image
            src={imageUrl}
            alt={title}
            fill
            sizes="(max-width: 768px) 100vw, 400px"
            className="object-cover transition-transform duration-500 group-hover:scale-105"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-rp-black/80 via-transparent to-transparent" />
          {status ? (
            <div className="absolute right-3 top-3">
              <RPStatusBadge status={status} availableFrom={availableFrom} />
            </div>
          ) : null}
          {highlight ? (
            <div className="absolute left-3 top-3 rounded-full bg-rp-gold/90 px-2.5 py-1 text-[10px] font-semibold uppercase tracking-wider text-rp-black">
              {highlight}
            </div>
          ) : null}
        </div>
      ) : null}

      <div className="space-y-1 p-4">
        <div className="flex items-start justify-between gap-2">
          <h3 className="font-display text-base text-rp-white">{title}</h3>
          {price !== undefined ? (
            <span className="font-mono text-sm font-semibold text-rp-gold whitespace-nowrap">
              {formatEUR(price)}
              <span className="ml-0.5 text-[10px] font-normal text-rp-gold-muted">
                {priceUnit.replace('€', '')}
              </span>
            </span>
          ) : null}
        </div>
        {subtitle ? (
          <p className="text-xs text-rp-gray line-clamp-1">{subtitle}</p>
        ) : null}
      </div>
    </div>
  );
}
