import { NextResponse } from 'next/server';
import { createSupabaseServer, createSupabaseServiceRole } from '@/lib/supabase/server';

interface Body {
  kind: 'provider' | 'asset';
  id: string;
  approve: boolean;
}

export async function POST(request: Request) {
  const supabase = createSupabaseServer();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return NextResponse.json({ error: 'Non authentifié' }, { status: 401 });

  const { data: profile } = await supabase
    .from('users')
    .select('role')
    .eq('auth_user_id', user.id)
    .maybeSingle();
  if (profile?.role !== 'admin') {
    return NextResponse.json({ error: 'Réservé admin' }, { status: 403 });
  }

  const body = (await request.json()) as Body;
  if (!body.kind || !body.id || typeof body.approve !== 'boolean') {
    return NextResponse.json({ error: 'Paramètres invalides' }, { status: 400 });
  }

  const service = await createSupabaseServiceRole();
  if (body.kind === 'provider') {
    if (body.approve) {
      await service.from('providers').update({ verified: true }).eq('id', body.id);
    } else {
      await service.from('providers').delete().eq('id', body.id);
    }
  } else {
    if (body.approve) {
      await service.from('assets').update({ verified: true }).eq('id', body.id);
    } else {
      await service.from('assets').update({ status: 'unavailable' }).eq('id', body.id);
    }
  }

  return NextResponse.json({ ok: true });
}
