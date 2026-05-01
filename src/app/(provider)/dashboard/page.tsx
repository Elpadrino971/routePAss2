import { redirect } from 'next/navigation';
import Link from 'next/link';
import { QrCode, CheckCircle2, Wallet, ShieldAlert } from 'lucide-react';
import { createSupabaseServer } from '@/lib/supabase/server';
import { RPAvatar, RPBadge, RPButton, RPEmptyState } from '@/components/ui';
import { formatEUR } from '@/lib/utils';

export default async function ProviderDashboard() {
  const supabase = createSupabaseServer();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const { data: profile } = await supabase
    .from('users')
    .select('id, full_name, avatar_url')
    .eq('auth_user_id', user.id)
    .maybeSingle();
  if (!profile) redirect('/onboarding');

  const { data: provider } = await supabase
    .from('providers')
    .select('id, service_type, vehicle_name, verified, stripe_account_id, is_available')
    .eq('user_id', profile.id)
    .maybeSingle();

  if (!provider) redirect('/setup');

  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const { data: txns } = await supabase
    .from('transactions')
    .select('amount, status, created_at, completed_at')
    .eq('provider_id', provider.id)
    .gte('created_at', today.toISOString());

  const completed = (txns ?? []).filter((t) => t.status === 'completed');
  const todayRevenue = completed.reduce(
    (sum, t) => sum + Number(t.amount ?? 0),
    0
  );
  const todayCount = completed.length;

  const stripeReady = Boolean(provider.stripe_account_id);

  return (
    <div className="space-y-6 px-5 pt-8">
      <header className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <RPAvatar src={profile.avatar_url} fallback={profile.full_name ?? 'R'} size="md" verified={provider.verified} />
          <div>
            <p className="text-xs uppercase tracking-[0.3em] text-rp-gold">
              Prestataire
            </p>
            <h1 className="font-display text-lg text-rp-white">
              {provider.vehicle_name ?? profile.full_name ?? 'Mon véhicule'}
            </h1>
          </div>
        </div>
        <RPBadge tone={provider.is_available ? 'success' : 'muted'} withDot pulse={provider.is_available}>
          {provider.is_available ? 'En ligne' : 'Hors ligne'}
        </RPBadge>
      </header>

      {!stripeReady ? (
        <Link
          href="/setup"
          className="flex items-start gap-3 rounded-rp border border-rp-warning/30 bg-rp-warning/5 p-4"
        >
          <ShieldAlert className="h-5 w-5 shrink-0 text-rp-warning" />
          <div>
            <p className="text-sm text-rp-white">
              Activez Stripe pour recevoir vos paiements
            </p>
            <p className="text-xs text-rp-gray">
              Sans Stripe, les courses ne peuvent pas être encaissées.
            </p>
          </div>
        </Link>
      ) : null}

      <section className="rounded-rp border border-rp-border bg-rp-dark p-5">
        <p className="text-xs uppercase tracking-[0.3em] text-rp-gold">
          Revenus du jour
        </p>
        <p className="mt-1 font-mono text-3xl text-rp-white">
          {formatEUR(todayRevenue)}
        </p>
        <p className="mt-1 text-xs text-rp-gray">
          {todayCount} course{todayCount > 1 ? 's' : ''} terminée{todayCount > 1 ? 's' : ''}
        </p>
      </section>

      <section className="grid grid-cols-3 gap-3">
        <ActionTile href="/my-qr" icon={QrCode} label="Afficher mon QR" />
        <ActionTile href="/validate" icon={CheckCircle2} label="Valider une course" />
        <ActionTile href="/earnings" icon={Wallet} label="Mes revenus" />
      </section>

      <section className="space-y-3">
        <h2 className="font-display text-lg text-rp-white">Activité récente</h2>
        {(txns ?? []).length === 0 ? (
          <RPEmptyState
            icon={QrCode}
            title="Aucune course aujourd'hui"
            description="Affichez votre QR pour qu'un client puisse réserver."
          />
        ) : (
          <ul className="space-y-2">
            {(txns ?? []).slice(0, 8).map((t, i) => (
              <li
                key={i}
                className="flex items-center justify-between rounded-rp-input border border-rp-border bg-rp-dark px-4 py-3"
              >
                <span className="text-sm text-rp-white">
                  {new Date(t.created_at).toLocaleTimeString('fr-FR', {
                    hour: '2-digit',
                    minute: '2-digit',
                  })}
                </span>
                <span className="font-mono text-sm text-rp-gold">
                  {formatEUR(Number(t.amount ?? 0))}
                </span>
                <RPBadge
                  tone={
                    t.status === 'completed'
                      ? 'success'
                      : t.status === 'confirmed'
                      ? 'info'
                      : 'muted'
                  }
                >
                  {t.status}
                </RPBadge>
              </li>
            ))}
          </ul>
        )}
      </section>
    </div>
  );
}

function ActionTile({
  href,
  icon: Icon,
  label,
}: {
  href: string;
  icon: React.ComponentType<{ className?: string }>;
  label: string;
}) {
  return (
    <Link
      href={href}
      className="flex flex-col items-center gap-2 rounded-rp border border-rp-border bg-rp-dark p-4 text-center transition hover:border-rp-gold/40"
    >
      <span className="flex h-10 w-10 items-center justify-center rounded-full bg-rp-gold/10 text-rp-gold">
        <Icon className="h-5 w-5" />
      </span>
      <span className="text-[11px] font-medium text-rp-white leading-tight">
        {label}
      </span>
    </Link>
  );
}
