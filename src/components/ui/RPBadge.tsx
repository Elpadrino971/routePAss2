import { cva, type VariantProps } from 'class-variance-authority';
import { cn } from '@/lib/utils';
import { RPStatusDot } from './RPStatusDot';

const badgeVariants = cva(
  'inline-flex items-center gap-1.5 rounded-full px-3 py-1 text-xs font-medium tracking-wide',
  {
    variants: {
      tone: {
        success: 'bg-rp-success/15 text-rp-success border border-rp-success/30',
        danger: 'bg-rp-danger/15 text-rp-danger border border-rp-danger/30',
        warning: 'bg-rp-warning/15 text-rp-warning border border-rp-warning/30',
        info: 'bg-rp-info/15 text-rp-info border border-rp-info/30',
        gold: 'bg-rp-gold/15 text-rp-gold border border-rp-gold/30',
        muted: 'bg-rp-dark-2 text-rp-gray border border-rp-border',
      },
    },
    defaultVariants: { tone: 'muted' },
  }
);

export type AssetStatus = 'available' | 'occupied' | 'cleaning' | 'unavailable';

const STATUS_CONFIG: Record<
  AssetStatus,
  { label: string; tone: VariantProps<typeof badgeVariants>['tone']; pulse: boolean }
> = {
  available: { label: 'Disponible', tone: 'success', pulse: true },
  occupied: { label: 'Occupé', tone: 'danger', pulse: false },
  cleaning: { label: 'Nettoyage', tone: 'warning', pulse: false },
  unavailable: { label: 'Indisponible', tone: 'muted', pulse: false },
};

interface RPBadgeProps extends VariantProps<typeof badgeVariants> {
  children: React.ReactNode;
  className?: string;
  withDot?: boolean;
  pulse?: boolean;
}

export function RPBadge({
  tone,
  children,
  className,
  withDot,
  pulse,
}: RPBadgeProps) {
  return (
    <span className={cn(badgeVariants({ tone }), className)}>
      {withDot ? <RPStatusDot tone={tone ?? 'muted'} pulse={pulse} /> : null}
      {children}
    </span>
  );
}

interface RPStatusBadgeProps {
  status: AssetStatus;
  availableFrom?: Date | string | null;
  className?: string;
}

/** Badge prêt à l'emploi qui mappe le statut d'un actif. */
export function RPStatusBadge({ status, availableFrom, className }: RPStatusBadgeProps) {
  const cfg = STATUS_CONFIG[status];
  let label = cfg.label;
  if (status === 'cleaning' && availableFrom) {
    const d = new Date(availableFrom);
    label = `Libre à ${d.toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })}`;
  }
  return (
    <RPBadge tone={cfg.tone} withDot pulse={cfg.pulse} className={className}>
      {label}
    </RPBadge>
  );
}
