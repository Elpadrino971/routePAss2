import type { LucideIcon } from 'lucide-react';
import { Inbox } from 'lucide-react';
import { cn } from '@/lib/utils';
import { RPButton } from './RPButton';

interface RPEmptyStateProps {
  icon?: LucideIcon;
  title: string;
  description?: string;
  actionLabel?: string;
  onAction?: () => void;
  className?: string;
}

export function RPEmptyState({
  icon: Icon = Inbox,
  title,
  description,
  actionLabel,
  onAction,
  className,
}: RPEmptyStateProps) {
  return (
    <div
      className={cn(
        'flex flex-col items-center justify-center gap-3 rounded-rp border border-dashed border-rp-border bg-rp-dark/40 px-6 py-12 text-center',
        className
      )}
    >
      <span className="rounded-full bg-rp-dark-2 p-3 text-rp-gold">
        <Icon className="h-6 w-6" />
      </span>
      <h3 className="font-display text-lg text-rp-white">{title}</h3>
      {description ? (
        <p className="max-w-xs text-sm text-rp-gray">{description}</p>
      ) : null}
      {actionLabel && onAction ? (
        <RPButton variant="outlineGold" size="sm" onClick={onAction} className="mt-2">
          {actionLabel}
        </RPButton>
      ) : null}
    </div>
  );
}
