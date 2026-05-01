import { redirect } from 'next/navigation';
import { createSupabaseServer } from '@/lib/supabase/server';
import { RPBadge, RPEmptyState } from '@/components/ui';
import { formatEUR } from '@/lib/utils';

export default async function WalletPage() {
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

  // Côté client : transactions payées
  const { data: txns } = await supabase
    .from('transactions')
    .select('id, amount, status, created_at')
    .eq('client_id', profile.id)
    .order('created_at', { ascending: false })
    .limit(50);

  const spent = (txns ?? [])
    .filter((t) => ['confirmed', 'completed'].includes(t.status))
    .reduce((s, t) => s + Number(t.amount ?? 0), 0);

  return (
    <div className="space-y-6 px-5 pt-8">
      <header>
        <p className="text-xs uppercase tracking-[0.3em] text-rp-gold">Wallet</p>
        <h1 className="font-display text-2xl text-rp-white">Mes paiements</h1>
      </header>

      <section className="rounded-rp border border-rp-border bg-rp-dark p-5">
        <p className="text-xs uppercase tracking-[0.3em] text-rp-gold">
          Total dépensé
        </p>
        <p className="mt-1 font-mono text-3xl text-rp-white">{formatEUR(spent)}</p>
      </section>

      <section className="space-y-2">
        <h2 className="font-display text-lg text-rp-white">Historique</h2>
        {(txns ?? []).length === 0 ? (
          <RPEmptyState
            title="Aucune transaction"
            description="Vos paiements apparaîtront ici."
          />
        ) : (
          (txns ?? []).map((t) => (
            <div
              key={t.id}
              className="flex items-center justify-between rounded-rp border border-rp-border bg-rp-dark p-4"
            >
              <div>
                <p className="text-sm text-rp-white">
                  {new Date(t.created_at).toLocaleString('fr-FR', {
                    day: '2-digit',
                    month: 'short',
                    hour: '2-digit',
                    minute: '2-digit',
                  })}
                </p>
                <RPBadge
                  tone={
                    t.status === 'completed'
                      ? 'success'
                      : t.status === 'confirmed'
                      ? 'info'
                      : t.status === 'cancelled'
                      ? 'danger'
                      : 'muted'
                  }
                  className="mt-1"
                >
                  {t.status}
                </RPBadge>
              </div>
              <p className="font-mono text-base text-rp-gold">
                {formatEUR(Number(t.amount ?? 0))}
              </p>
            </div>
          ))
        )}
      </section>
    </div>
  );
}
