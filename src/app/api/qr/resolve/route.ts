import { NextResponse } from 'next/server';
import { verifyQR } from '@/lib/qr';
import { createSupabaseServer } from '@/lib/supabase/server';

/**
 * Décode un QR ROUTEPASS et renvoie l'entité associée (provider ou booking).
 * Utilisé après un scan client pour rediriger vers le bon écran de paiement.
 */
export async function POST(request: Request) {
  const { token } = (await request.json()) as { token?: string };
  if (!token) {
    return NextResponse.json({ error: 'Token requis' }, { status: 400 });
  }

  let payload;
  try {
    payload = verifyQR(token);
  } catch {
    return NextResponse.json({ error: 'QR invalide' }, { status: 400 });
  }

  const supabase = createSupabaseServer();

  if (payload.kind === 'provider') {
    const { data: provider } = await supabase
      .from('providers')
      .select(
        'id, vehicle_name, vehicle_photo_url, service_type, base_rate, verified, users:user_id(full_name, avatar_url)'
      )
      .eq('id', payload.pid)
      .maybeSingle();
    if (!provider) {
      return NextResponse.json({ error: 'Prestataire introuvable' }, { status: 404 });
    }
    return NextResponse.json({ kind: 'provider', provider });
  }

  if (payload.kind === 'access') {
    return NextResponse.json({ kind: 'access', bookingId: payload.bid });
  }

  return NextResponse.json({ error: 'QR non reconnu' }, { status: 400 });
}
