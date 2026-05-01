import { NextResponse } from 'next/server';
import { powerOff } from '@/lib/shelly';
import { createSupabaseServer } from '@/lib/supabase/server';

export async function POST(request: Request) {
  const supabase = createSupabaseServer();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return NextResponse.json({ error: 'Non authentifié' }, { status: 401 });

  const { deviceId } = (await request.json()) as { deviceId?: string };
  if (!deviceId) {
    return NextResponse.json({ error: 'deviceId requis' }, { status: 400 });
  }

  try {
    await powerOff(deviceId);
  } catch (err) {
    return NextResponse.json(
      { error: err instanceof Error ? err.message : 'Shelly erreur' },
      { status: 502 }
    );
  }
  return NextResponse.json({ ok: true });
}
