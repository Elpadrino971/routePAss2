import { Key, Home, Ship, Wrench, Hammer, PartyPopper } from 'lucide-react';
import { RPEmptyState } from '@/components/ui';

const CATEGORIES = [
  { id: 'vehicle', label: 'Véhicules', icon: Key },
  { id: 'property', label: 'Biens', icon: Home },
  { id: 'boat', label: 'Bateaux', icon: Ship },
  { id: 'equipment', label: 'Matériel', icon: Wrench },
  { id: 'tool', label: 'Outils', icon: Hammer },
  { id: 'event', label: 'Événement', icon: PartyPopper },
] as const;

export default function LocationPage() {
  return (
    <div className="space-y-6 px-5 pt-8">
      <header className="space-y-1">
        <p className="text-xs uppercase tracking-[0.3em] text-rp-gold">Location</p>
        <h1 className="font-display text-2xl text-rp-white">
          Catalogue autonome
        </h1>
      </header>

      <div className="grid grid-cols-3 gap-3">
        {CATEGORIES.map((c) => (
          <button
            key={c.id}
            type="button"
            className="flex flex-col items-center gap-2 rounded-rp border border-rp-border bg-rp-dark p-4 transition hover:border-rp-gold/40"
          >
            <span className="flex h-10 w-10 items-center justify-center rounded-full bg-rp-gold/10 text-rp-gold">
              <c.icon className="h-5 w-5" />
            </span>
            <span className="text-[11px] font-medium text-rp-white">{c.label}</span>
          </button>
        ))}
      </div>

      <RPEmptyState
        icon={Key}
        title="Catalogue à venir"
        description="Les biens en location autonome (TTLock + Shelly) seront disponibles en Phase 3."
      />
    </div>
  );
}
