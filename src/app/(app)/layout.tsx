import { redirect } from 'next/navigation';
import { BottomNav } from '@/components/layout/BottomNav';
import { SwipeContainer } from '@/components/layout/SwipeContainer';
import { createSupabaseServer } from '@/lib/supabase/server';

export default async function AppLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const supabase = createSupabaseServer();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) redirect('/login');

  // Si pas de profil ROUTEPASS encore, on force l'onboarding.
  const { data: profile } = await supabase
    .from('users')
    .select('id, role')
    .eq('auth_user_id', user.id)
    .maybeSingle();

  if (!profile) redirect('/onboarding');

  return (
    <SwipeContainer>
      <main className="mx-auto min-h-dvh max-w-md pb-24">{children}</main>
      <BottomNav />
    </SwipeContainer>
  );
}
