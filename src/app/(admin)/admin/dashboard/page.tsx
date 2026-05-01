import { createSupabaseServer } from '@/lib/supabase/server';
import { formatEUR } from '@/lib/utils';

export default async function AdminDashboard() {
  const supabase = createSupabaseServer();

  const [users, providers, assets, txns, bookings] = await Promise.all([
    supabase.from('users').select('id', { count: 'exact', head: true }),
    supabase.from('providers').select('id', { count: 'exact', head: true }),
    supabase.from('assets').select('id', { count: 'exact', head: true }),
    supabase
      .from('transactions')
      .select('amount, commission_amount, status, created_at'),
    supabase
      .from('bookings')
      .select('total_amount, commission_amount, status, created_at'),
  ]);

  const completedTx = (txns.data ?? []).filter((t) => t.status === 'completed');
  const completedBk = (bookings.data ?? []).filter((b) => b.status === 'completed');

  const gmv =
    completedTx.reduce((s, t) => s + Number(t.amount ?? 0), 0) +
    completedBk.reduce((s, b) => s + Number(b.total_amount ?? 0), 0);
  const commission =
    completedTx.reduce((s, t) => s + Number(t.commission_amount ?? 0), 0) +
    completedBk.reduce((s, b) => s + Number(b.commission_amount ?? 0), 0);

  return (
    <div className="space-y-6">
      <h2 className="font-display text-2xl text-rp-white">Vue globale</h2>

      <div className="grid grid-cols-2 gap-3 md:grid-cols-4">
        <Stat label="Utilisateurs" value={String(users.count ?? 0)} />
        <Stat label="Prestataires" value={String(providers.count ?? 0)} />
        <Stat label="Actifs" value={String(assets.count ?? 0)} />
        <Stat label="Transactions" value={String(completedTx.length + completedBk.length)} />
      </div>

      <div className="grid grid-cols-1 gap-3 md:grid-cols-2">
        <Stat label="GMV" value={formatEUR(gmv)} highlight />
        <Stat label="Commission ROUTEPASS" value={formatEUR(commission)} highlight />
      </div>
    </div>
  );
}

function Stat({
  label,
  value,
  highlight,
}: {
  label: string;
  value: string;
  highlight?: boolean;
}) {
  return (
    <div
      className={`rounded-rp border p-5 ${
        highlight
          ? 'border-rp-gold/40 bg-rp-gold/5 shadow-rp-gold'
          : 'border-rp-border bg-rp-dark'
      }`}
    >
      <p className="text-[10px] uppercase tracking-[0.3em] text-rp-gold">{label}</p>
      <p className="mt-1 font-mono text-2xl text-rp-white">{value}</p>
    </div>
  );
}
