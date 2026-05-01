import { redirect } from 'next/navigation';
import { createSupabaseServer } from '@/lib/supabase/server';
import { RPBadge, RPEmptyState } from '@/components/ui';
import { formatEUR } from '@/lib/utils';

export default async function EarningsPage() {
  const supabase = createSupabaseServer();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const { data: profile } = await supabase
    .from('users')
    .select('id')
    .eq('auth_user_id', user.id)
    .maybeSingle();
  if (!profile) redirect('/onboarding');

  const { data: provider } = await supabase
    .from('providers')
    .select('id')
    .eq('user_id', profile.id)
    .maybeSingle();
  if (!provider) redirect('/setup');

  const { data: txns } = await supabase
    .from('transactions')
    .select('id, amount, commission_amount, status, created_at, completed_at')
    .eq('provider_id', provider.id)
    .order('created_at', { ascending: false })
    .limit(50);

  const total = (txns ?? [])
    .filter((t) => t.status === 'completed')
    .reduce((s, t) => s + Number(t.amount ?? 0) - Number(t.commission_amount ?? 0), 0);

  return (
    <div className="space-y-6 px-5 pt-8">
      <header>
        <p className="text-xs uppercase tracking-[0.3em] text-rp-gold">Revenus</p>
        <h1 className="font-display text-2xl text-rp-white">Historique</h1>
      </header>

      <section className="rounded-rp border border-rp-border bg-rp-dark p-5">
        <p className="text-xs uppercase tracking-[0.3em] text-rp-gold">
          Net (après commission)
        </p>
        <p className="mt-1 font-mono text-3xl text-rp-white">{formatEUR(total)}</p>
      </section>

      <section className="space-y-2">
        {(txns ?? []).length === 0 ? (
          <RPEmptyState
            title="Pas encore de course"
            description="Vos courses apparaîtront ici dès le premier paiement."
          />
        ) : (
          (txns ?? []).map((t) => (
            <div
              key={t.id}
              className="flex items-center justify-between rounded-rp border border-rp-border bg-rp-dark p-4"
            >
              <div>
                <p className="text-xs text-rp-gray">
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
                      : t.status === 'cancelled' || t.status === 'disputed'
                      ? 'danger'
                      : 'muted'
                  }
                  className="mt-1"
                >
                  {t.status}
                </RPBadge>
              </div>
              <div className="text-right">
                <p className="font-mono text-base text-rp-gold">
                  {formatEUR(Number(t.amount ?? 0))}
                </p>
                <p className="text-[10px] text-rp-gray">
                  − {formatEUR(Number(t.commission_amount ?? 0))} comm.
                </p>
              </div>
            </div>
          ))
        )}
      </section>
    </div>
  );
}
