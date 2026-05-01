import { NextResponse } from 'next/server';
import { createSupabaseServer } from '@/lib/supabase/server';

interface Body {
  code: string;
}

/**
 * Le prestataire saisit le code à 4 chiffres communiqué par le client.
 * Si correct ET la transaction est `confirmed` → on passe en `completed`.
 */
export async function POST(request: Request) {
  const supabase = createSupabaseServer();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) {
    return NextResponse.json({ error: 'Non authentifié' }, { status: 401 });
  }

  const body = (await request.json()) as Partial<Body>;
  const code = (body.code ?? '').trim();
  if (!/^\d{4}$/.test(code)) {
    return NextResponse.json({ error: 'Code à 4 chiffres requis' }, { status: 400 });
  }

  const { data: profile } = await supabase
    .from('users')
    .select('id')
    .eq('auth_user_id', user.id)
    .maybeSingle();
  if (!profile) {
    return NextResponse.json({ error: 'Profil introuvable' }, { status: 404 });
  }

  const { data: provider } = await supabase
    .from('providers')
    .select('id')
    .eq('user_id', profile.id)
    .maybeSingle();
  if (!provider) {
    return NextResponse.json({ error: 'Prestataire introuvable' }, { status: 404 });
  }

  // On cherche la dernière transaction en statut confirmé pour ce provider et ce code.
  const { data: txn, error: lookupErr } = await supabase
    .from('transactions')
    .select('id, amount, client_id, status, users:client_id(full_name)')
    .eq('provider_id', provider.id)
    .eq('validation_code', code)
    .in('status', ['pending', 'confirmed'])
    .order('created_at', { ascending: false })
    .limit(1)
    .maybeSingle();

  if (lookupErr) {
    return NextResponse.json({ error: lookupErr.message }, { status: 500 });
  }
  if (!txn) {
    return NextResponse.json({ error: 'Code invalide ou expiré' }, { status: 404 });
  }

  if (txn.status !== 'confirmed') {
    return NextResponse.json(
      { error: 'Paiement pas encore confirmé — réessayez dans quelques secondes' },
      { status: 409 }
    );
  }

  const { error: updErr } = await supabase
    .from('transactions')
    .update({ status: 'completed', completed_at: new Date().toISOString() })
    .eq('id', txn.id);
  if (updErr) {
    return NextResponse.json({ error: updErr.message }, { status: 500 });
  }

  type ClientLookup = { full_name: string | null };
  const clientRow = txn.users as unknown as ClientLookup | ClientLookup[] | null;
  const clientName = Array.isArray(clientRow)
    ? clientRow[0]?.full_name ?? null
    : clientRow?.full_name ?? null;

  return NextResponse.json({
    ok: true,
    amount: Number(txn.amount ?? 0),
    client: clientName,
  });
}
