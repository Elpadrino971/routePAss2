import type { AssetCategory, ServiceType } from '@/lib/supabase/types';

/** Taux de commission ROUTEPASS par verticale (cf. master prompt). */
export const COMMISSION_RATES: Record<ServiceType | AssetCategory, number> = {
  taxi: 0.05,
  minibus: 0.05,
  boat: 0.08,
  truck: 0.07,
  vehicle: 0.08,
  property: 0.08,
  equipment: 0.1,
  tool: 0.1,
  event: 0.1,
};

/** Convertit un montant euros en centimes pour Stripe. */
export function toCents(amount: number): number {
  return Math.round(amount * 100);
}

/** Calcule la commission Stripe (en centimes) pour une verticale. */
export function commissionCents(
  amount: number,
  vertical: ServiceType | AssetCategory
): number {
  const rate = COMMISSION_RATES[vertical] ?? 0.05;
  return Math.round(amount * rate * 100);
}
