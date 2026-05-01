import { cn } from '@/lib/utils';

interface RPSkeletonProps {
  className?: string;
}

export function RPSkeleton({ className }: RPSkeletonProps) {
  return <div className={cn('rp-skeleton rounded-rp-input', className)} />;
}

/** Skeleton card prêt à l'emploi pour les listes en chargement. */
export function RPCardSkeleton() {
  return (
    <div className="overflow-hidden rounded-rp border border-rp-border bg-rp-dark">
      <RPSkeleton className="h-44 w-full rounded-none" />
      <div className="space-y-2 p-4">
        <RPSkeleton className="h-4 w-2/3" />
        <RPSkeleton className="h-3 w-1/3" />
      </div>
    </div>
  );
}
