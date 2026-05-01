import { redirect } from 'next/navigation';
import { ProviderBottomNav } from '@/components/layout/ProviderBottomNav';
import { createSupabaseServer } from '@/lib/supabase/server';

export default async function ProviderLayout({
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
    .select('id, role')
    .eq('auth_user_id', user.id)
    .maybeSingle();

  if (!profile) redirect('/onboarding');
  if (profile.role !== 'provider' && profile.role !== 'admin') redirect('/home');

  return (
    <>
      <main className="mx-auto min-h-dvh max-w-md pb-24">{children}</main>
      <ProviderBottomNav />
    </>
  );
}
