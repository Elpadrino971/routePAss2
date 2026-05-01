'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { LayoutDashboard, QrCode, Check, Wallet, User, Building2 } from 'lucide-react';
import { cn } from '@/lib/utils';

interface NavItem {
  id: string;
  label: string;
  icon: typeof LayoutDashboard;
  href: string;
}

const PROVIDER_NAV: NavItem[] = [
  { id: 'dashboard', label: 'Tableau', icon: LayoutDashboard, href: '/dashboard' },
  { id: 'my-qr', label: 'Mon QR', icon: QrCode, href: '/my-qr' },
  { id: 'validate', label: 'Valider', icon: Check, href: '/validate' },
  { id: 'earnings', label: 'Revenus', icon: Wallet, href: '/earnings' },
  { id: 'account', label: 'Compte', icon: User, href: '/account' },
];

const OWNER_NAV: NavItem[] = [
  { id: 'dashboard', label: 'Tableau', icon: LayoutDashboard, href: '/dashboard' },
  { id: 'assets', label: 'Mes biens', icon: Building2, href: '/assets' },
  { id: 'earnings', label: 'Revenus', icon: Wallet, href: '/earnings' },
  { id: 'account', label: 'Compte', icon: User, href: '/account' },
];

export function ProviderBottomNav({
  role,
}: {
  role: 'provider' | 'owner' | 'admin';
}) {
  const pathname = usePathname();
  const items = role === 'owner' ? OWNER_NAV : PROVIDER_NAV;

  return (
    <nav className="fixed inset-x-0 bottom-0 z-30 border-t border-rp-border bg-rp-dark/90 pb-[env(safe-area-inset-bottom)] backdrop-blur-lg">
      <ul
        className="mx-auto grid max-w-md"
        style={{ gridTemplateColumns: `repeat(${items.length}, minmax(0, 1fr))` }}
      >
        {items.map((s) => {
          const active = pathname === s.href || pathname.startsWith(`${s.href}/`);
          const Icon = s.icon;
          return (
            <li key={s.id}>
              <Link
                href={s.href}
                className={cn(
                  'flex flex-col items-center gap-1 px-2 py-2.5 text-[10px] font-medium tracking-wide transition-colors',
                  active ? 'text-rp-gold' : 'text-rp-gray hover:text-rp-white'
                )}
              >
                <span
                  className={cn(
                    'flex h-9 w-9 items-center justify-center rounded-full transition-all',
                    active && 'bg-rp-gold/10'
                  )}
                >
                  <Icon className="h-5 w-5" />
                </span>
                <span>{s.label}</span>
              </Link>
            </li>
          );
        })}
      </ul>
    </nav>
  );
}
