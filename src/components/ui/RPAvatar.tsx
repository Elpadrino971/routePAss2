import Image from 'next/image';
import { BadgeCheck } from 'lucide-react';
import { cn } from '@/lib/utils';

interface RPAvatarProps {
  src?: string | null;
  fallback?: string;
  verified?: boolean;
  size?: 'xs' | 'sm' | 'md' | 'lg';
  className?: string;
}

const SIZE = {
  xs: 'h-7 w-7 text-[10px]',
  sm: 'h-9 w-9 text-xs',
  md: 'h-12 w-12 text-sm',
  lg: 'h-16 w-16 text-base',
};

const BADGE_SIZE = {
  xs: 'h-3 w-3 -bottom-0 -right-0',
  sm: 'h-3.5 w-3.5 -bottom-0 -right-0',
  md: 'h-4 w-4 -bottom-0 -right-0',
  lg: 'h-5 w-5 -bottom-0.5 -right-0.5',
};

function initials(name?: string): string {
  if (!name) return 'R';
  const parts = name.trim().split(/\s+/).slice(0, 2);
  return parts.map((p) => p[0]?.toUpperCase() ?? '').join('') || 'R';
}

export function RPAvatar({
  src,
  fallback,
  verified,
  size = 'md',
  className,
}: RPAvatarProps) {
  return (
    <span
      className={cn(
        'relative inline-flex shrink-0 items-center justify-center overflow-hidden rounded-full border border-rp-border bg-rp-dark-2 font-medium text-rp-gold',
        SIZE[size],
        className
      )}
    >
      {src ? (
        <Image src={src} alt={fallback ?? ''} fill className="object-cover" />
      ) : (
        <span>{initials(fallback)}</span>
      )}
      {verified ? (
        <BadgeCheck
          className={cn('absolute fill-rp-gold text-rp-black', BADGE_SIZE[size])}
        />
      ) : null}
    </span>
  );
}
