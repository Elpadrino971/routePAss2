import Link from 'next/link';
import { Car, Bus, Ship, Truck, QrCode } from 'lucide-react';
import { RPButton, RPEmptyState } from '@/components/ui';

const SERVICES = [
  { id: 'taxi', label: 'Taxi', icon: Car, count: 24 },
  { id: 'minibus', label: 'Minibus', icon: Bus, count: 12 },
  { id: 'boat', label: 'Bateau', icon: Ship, count: 6 },
  { id: 'truck', label: 'Fret', icon: Truck, count: 18 },
] as const;

export default function TransportPage() {
  return (
    <div className="space-y-6 px-5 pt-8">
      <header className="space-y-1">
        <p className="text-xs uppercase tracking-[0.3em] text-rp-gold">Transport</p>
        <h1 className="font-display text-2xl text-rp-white">
          Trouvez votre prestataire
        </h1>
      </header>

      <div className="grid grid-cols-4 gap-3">
        {SERVICES.map((s) => (
          <button
            key={s.id}
            type="button"
            className="flex flex-col items-center gap-2 rounded-rp border border-rp-border bg-rp-dark p-3 transition hover:border-rp-gold/40"
          >
            <span className="flex h-12 w-12 items-center justify-center rounded-full bg-rp-gold/10 text-rp-gold">
              <s.icon className="h-6 w-6" />
            </span>
            <span className="text-[11px] font-medium text-rp-white">{s.label}</span>
            <span className="text-[10px] text-rp-gray">{s.count} dispo</span>
          </button>
        ))}
      </div>

      <Link href="/transport/scan">
        <RPButton block size="lg">
          <QrCode className="h-5 w-5" />
          Scanner un QR code
        </RPButton>
      </Link>

      <RPEmptyState
        icon={Car}
        title="Aucun prestataire proche"
        description="L'inscription des prestataires arrive en Phase 2. Activez la géolocalisation pour découvrir les courses disponibles autour de vous."
      />
    </div>
  );
}
