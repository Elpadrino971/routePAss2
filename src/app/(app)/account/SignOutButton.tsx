'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { LogOut } from 'lucide-react';
import { RPButton } from '@/components/ui';
import { createSupabaseBrowser } from '@/lib/supabase/client';

export function SignOutButton() {
  const router = useRouter();
  const [loading, setLoading] = useState(false);

  async function signOut() {
    setLoading(true);
    const supabase = createSupabaseBrowser();
    await supabase.auth.signOut();
    router.replace('/login');
    router.refresh();
  }

  return (
    <RPButton variant="secondary" block onClick={signOut} loading={loading}>
      <LogOut className="h-4 w-4" />
      Se déconnecter
    </RPButton>
  );
}
