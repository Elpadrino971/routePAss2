import { redirect } from 'next/navigation';
import Link from 'next/link';
import { LayoutDashboard, ShieldCheck, Banknote } from 'lucide-react';
import { createSupabaseServer } from '@/lib/supabase/server';

export default async function AdminLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const supabase = createSupabaseServer();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const { data: profile } = await supabase
    .from('users')
    .select('role')
    .eq('auth_user_id', user.id)
    .maybeSingle();
  if (profile?.role !== 'admin') redirect('/home');

  return (
    <div className="mx-auto flex min-h-dvh max-w-3xl flex-col">
      <header className="flex items-center justify-between border-b border-rp-border bg-rp-dark/80 px-5 py-4 backdrop-blur">
        <div>
          <p className="text-[10px] uppercase tracking-[0.4em] text-rp-gold">
            ROUTEPASS
          </p>
          <h1 className="font-display text-lg text-rp-white">Console admin</h1>
        </div>
        <nav className="flex items-center gap-2 text-xs">
          <Link href="/admin/dashboard" className="flex items-center gap-1.5 rounded-rp-btn px-3 py-1.5 text-rp-gray hover:bg-rp-dark-2 hover:text-rp-white">
            <LayoutDashboard className="h-3.5 w-3.5" /> Tableau
          </Link>
          <Link href="/admin/validations" className="flex items-center gap-1.5 rounded-rp-btn px-3 py-1.5 text-rp-gray hover:bg-rp-dark-2 hover:text-rp-white">
            <ShieldCheck className="h-3.5 w-3.5" /> Validations
          </Link>
          <Link href="/admin/payouts" className="flex items-center gap-1.5 rounded-rp-btn px-3 py-1.5 text-rp-gray hover:bg-rp-dark-2 hover:text-rp-white">
            <Banknote className="h-3.5 w-3.5" /> Virements
          </Link>
        </nav>
      </header>
      <main className="flex-1 px-5 py-6">{children}</main>
    </div>
  );
}
