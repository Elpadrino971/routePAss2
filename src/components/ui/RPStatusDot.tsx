import { cn } from '@/lib/utils';

type Tone = 'success' | 'danger' | 'warning' | 'info' | 'gold' | 'muted' | null | undefined;

interface RPStatusDotProps {
  tone?: Tone;
  pulse?: boolean;
  className?: string;
}

const TONE_BG: Record<NonNullable<Tone>, string> = {
  success: 'bg-rp-success',
  danger: 'bg-rp-danger',
  warning: 'bg-rp-warning',
  info: 'bg-rp-info',
  gold: 'bg-rp-gold',
  muted: 'bg-rp-gray',
};

export function RPStatusDot({ tone = 'muted', pulse, className }: RPStatusDotProps) {
  const color = TONE_BG[tone ?? 'muted'];
  return (
    <span className={cn('relative inline-flex h-2 w-2', className)}>
      {pulse ? (
        <span
          className={cn(
            'absolute inline-flex h-full w-full rounded-full opacity-60 animate-pulse-dot',
            color
          )}
        />
      ) : null}
      <span className={cn('relative inline-flex h-2 w-2 rounded-full', color)} />
    </span>
  );
}
