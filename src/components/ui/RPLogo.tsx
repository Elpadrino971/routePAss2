import { cn } from '@/lib/utils';

interface RPLogoProps {
  className?: string;
  size?: number;
  withWordmark?: boolean;
}

/** Monogramme R + wordmark ROUTEPASS. */
export function RPLogo({ className, size = 48, withWordmark = true }: RPLogoProps) {
  return (
    <div className={cn('flex flex-col items-center gap-1.5', className)}>
      <svg
        width={size}
        height={size}
        viewBox="0 0 64 64"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        aria-label="ROUTEPASS"
      >
        <defs>
          <linearGradient id="rp-gold" x1="0" y1="0" x2="64" y2="64">
            <stop offset="0%" stopColor="#E8C96A" />
            <stop offset="50%" stopColor="#C9A84C" />
            <stop offset="100%" stopColor="#8B6E2A" />
          </linearGradient>
        </defs>
        <text
          x="32"
          y="46"
          textAnchor="middle"
          fontFamily="Playfair Display, serif"
          fontWeight="700"
          fontSize="44"
          fill="url(#rp-gold)"
        >
          R
        </text>
      </svg>
      {withWordmark ? (
        <span className="font-display text-[10px] tracking-[0.4em] text-rp-gold">
          ROUTEPASS
        </span>
      ) : null}
    </div>
  );
}
