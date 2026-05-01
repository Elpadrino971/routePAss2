import { createSupabaseServer } from '@/lib/supabase/server';
import { RPBadge } from '@/components/ui';
import { formatEUR } from '@/lib/utils';
import { PayoutsBatchButton } from './PayoutsBatchButton';

export default async function AdminPayouts() {
  const supabase = createSupabaseServer();

  const { data: payouts } = await supabase
    .from('payouts')
    .select('id, amount, status, created_at, users:user_id(full_name, email)')
    .order('created_at', { ascending: false })
    .limit(100);

  const totalPaid = (payouts ?? [])
    .filter((p) => p.status === 'paid')
    .reduce((s, p) => s + Number(p.amount ?? 0), 0);

  return (
    <div className="space-y-6">
      <div className="flex items-end justify-between">
        <div>
          <h2 className="font-display text-2xl text-rp-white">Virements</h2>
          <p className="text-sm text-rp-gray">
            Total versé : <span className="font-mono text-rp-gold">{formatEUR(totalPaid)}</span>
          </p>
        </div>
        <PayoutsBatchButton />
      </div>

      <ul className="space-y-2">
        {(payouts ?? []).map((p) => {
          type UserLookup = { full_name: string | null; email: string | null };
          const uRow = p.users as unknown as UserLookup | UserLookup[] | null;
          const u = Array.isArray(uRow) ? uRow[0] : uRow;
          return (
            <li
              key={p.id}
              className="flex items-center justify-between rounded-rp border border-rp-border bg-rp-dark p-4"
            >
              <div>
                <p className="text-sm text-rp-white">{u?.full_name ?? u?.email ?? '—'}</p>
                <p className="text-[10px] text-rp-gray">
                  {new Date(p.created_at).toLocaleString('fr-FR')}
                </p>
              </div>
              <div className="text-right">
                <p className="font-mono text-base text-rp-gold">
                  {formatEUR(Number(p.amount ?? 0))}
                </p>
                <RPBadge
                  tone={
                    p.status === 'paid'
                      ? 'success'
                      : p.status === 'failed'
                      ? 'danger'
                      : 'muted'
                  }
                  className="mt-1"
                >
                  {p.status}
                </RPBadge>
              </div>
            </li>
          );
        })}
      </ul>
    </div>
  );
}
