import Link from 'next/link';
import { ChevronRight, Wallet, Shield, Bell, LogOut, Settings } from 'lucide-react';
import { createSupabaseServer } from '@/lib/supabase/server';
import { RPAvatar, RPBadge } from '@/components/ui';
import { SignOutButton } from './SignOutButton';

const MENU = [
  { id: 'wallet', label: 'Wallet', icon: Wallet, href: '/wallet' },
  { id: 'security', label: 'Sécurité', icon: Shield, href: '/account#security' },
  { id: 'notifications', label: 'Notifications', icon: Bell, href: '/account#notifications' },
  { id: 'settings', label: 'Préférences', icon: Settings, href: '/account#settings' },
];

export default async function AccountPage() {
  const supabase = createSupabaseServer();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const { data: profile } = await supabase
    .from('users')
    .select('full_name, email, role, avatar_url')
    .eq('auth_user_id', user?.id ?? '')
    .maybeSingle();

  return (
    <div className="space-y-6 px-5 pt-8">
      <header className="flex items-center gap-4">
        <RPAvatar
          src={profile?.avatar_url}
          fallback={profile?.full_name ?? user?.email ?? 'R'}
          size="lg"
          verified
        />
        <div>
          <h1 className="font-display text-xl text-rp-white">
            {profile?.full_name ?? 'Utilisateur'}
          </h1>
          <p className="text-xs text-rp-gray">{profile?.email ?? user?.email}</p>
          <RPBadge tone="gold" className="mt-1.5">
            {profile?.role ?? 'client'}
          </RPBadge>
        </div>
      </header>

      <ul className="space-y-2">
        {MENU.map((m) => (
          <li key={m.id}>
            <Link
              href={m.href}
              className="flex items-center gap-3 rounded-rp border border-rp-border bg-rp-dark px-4 py-3.5 transition hover:border-rp-gold/40"
            >
              <span className="flex h-9 w-9 items-center justify-center rounded-full bg-rp-gold/10 text-rp-gold">
                <m.icon className="h-4 w-4" />
              </span>
              <span className="flex-1 text-sm text-rp-white">{m.label}</span>
              <ChevronRight className="h-4 w-4 text-rp-gray" />
            </Link>
          </li>
        ))}
      </ul>

      <SignOutButton />

      <p className="text-center text-[10px] uppercase tracking-[0.3em] text-rp-gray">
        Axen Digital © 2026
      </p>
    </div>
  );
}
