'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { Home, Car, Key, Map, User } from 'lucide-react';
import { cn } from '@/lib/utils';

const SECTIONS = [
  { id: 'home', label: 'Accueil', icon: Home, href: '/home' },
  { id: 'transport', label: 'Transport', icon: Car, href: '/transport' },
  { id: 'location', label: 'Location', icon: Key, href: '/location' },
  { id: 'map', label: 'Carte', icon: Map, href: '/map' },
  { id: 'account', label: 'Compte', icon: User, href: '/account' },
] as const;

export function BottomNav() {
  const pathname = usePathname();
  return (
    <nav className="fixed inset-x-0 bottom-0 z-30 border-t border-rp-border bg-rp-dark/90 pb-[env(safe-area-inset-bottom)] backdrop-blur-lg">
      <ul className="mx-auto grid max-w-md grid-cols-5">
        {SECTIONS.map((s) => {
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
