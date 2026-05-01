import { NextResponse } from 'next/server';
import { createSupabaseServer } from '@/lib/supabase/server';

interface Body {
  endpoint: string;
  keys: { p256dh: string; auth: string };
}

export async function POST(request: Request) {
  const supabase = createSupabaseServer();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return NextResponse.json({ error: 'Non authentifié' }, { status: 401 });

  const sub = (await request.json()) as Body;
  if (!sub?.endpoint || !sub.keys?.p256dh || !sub.keys?.auth) {
    return NextResponse.json({ error: 'Subscription invalide' }, { status: 400 });
  }

  const { data: profile } = await supabase
    .from('users')
    .select('id')
    .eq('auth_user_id', user.id)
    .maybeSingle();
  if (!profile) return NextResponse.json({ error: 'Profil introuvable' }, { status: 404 });

  await supabase
    .from('push_subscriptions')
    .upsert(
      {
        user_id: profile.id,
        endpoint: sub.endpoint,
        p256dh: sub.keys.p256dh,
        auth: sub.keys.auth,
      },
      { onConflict: 'user_id,endpoint' }
    );

  return NextResponse.json({ ok: true });
}
