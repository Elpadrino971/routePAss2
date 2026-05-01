import { notFound, redirect } from 'next/navigation';
import { format } from 'date-fns';
import { fr } from 'date-fns/locale';
import { ShieldCheck } from 'lucide-react';
import { createSupabaseServer } from '@/lib/supabase/server';
import { signAccessQR } from '@/lib/qr';
import { RPBadge, RPQRDisplay } from '@/components/ui';
import { formatEUR } from '@/lib/utils';
import { CheckinActions } from './CheckinActions';

interface PageProps {
  params: { id: string };
}

export const dynamic = 'force-dynamic';

export default async function BookingPage({ params }: PageProps) {
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

  const { data: booking } = await supabase
    .from('bookings')
    .select(
      'id, start_at, end_at, total_amount, deposit_amount, deposit_released, status, access_qr_code, assets:asset_id(id, name, photos, address, ttlock_lock_id, shelly_device_id, access_instructions)'
    )
    .eq('id', params.id)
    .eq('client_id', profile.id)
    .maybeSingle();

  if (!booking) notFound();

  // Génère et persiste le QR d'accès une fois la réservation confirmée.
  let qrToken = booking.access_qr_code;
  if (
    !qrToken &&
    (booking.status === 'confirmed' || booking.status === 'active') &&
    booking.end_at
  ) {
    type AssetLookup = { id: string };
    const aRow = booking.assets as unknown as AssetLookup | AssetLookup[] | null;
    const a = Array.isArray(aRow) ? aRow[0] : aRow;
    if (a?.id) {
      qrToken = signAccessQR(booking.id, a.id, new Date(booking.end_at));
      await supabase
        .from('bookings')
        .update({ access_qr_code: qrToken })
        .eq('id', booking.id);
    }
  }

  type AssetLookup = {
    id: string;
    name: string | null;
    photos: string[] | null;
    address: string | null;
    ttlock_lock_id: string | null;
    shelly_device_id: string | null;
    access_instructions: string | null;
  };
  const aRow = booking.assets as unknown as AssetLookup | AssetLookup[] | null;
  const asset = Array.isArray(aRow) ? aRow[0] : aRow;

  return (
    <div className="space-y-6 px-5 pt-8 pb-32">
      <header className="space-y-2">
        <p className="text-xs uppercase tracking-[0.3em] text-rp-gold">Réservation</p>
        <h1 className="font-display text-2xl text-rp-white">
          {asset?.name ?? 'Bien'}
        </h1>
        <RPBadge
          tone={
            booking.status === 'completed'
              ? 'muted'
              : booking.status === 'active'
              ? 'success'
              : booking.status === 'confirmed'
              ? 'info'
              : booking.status === 'cancelled' || booking.status === 'disputed'
              ? 'danger'
              : 'warning'
          }
          withDot
          pulse={booking.status === 'active'}
        >
          {booking.status}
        </RPBadge>
      </header>

      <section className="space-y-2 rounded-rp border border-rp-border bg-rp-dark p-4 text-sm">
        <Row label="Du" value={booking.start_at ? format(new Date(booking.start_at), 'PPp', { locale: fr }) : '—'} />
        <Row label="Au" value={booking.end_at ? format(new Date(booking.end_at), 'PPp', { locale: fr }) : '—'} />
        <Row label="Loyer" value={booking.total_amount ? formatEUR(Number(booking.total_amount)) : '—'} mono />
        {booking.deposit_amount && Number(booking.deposit_amount) > 0 ? (
          <Row
            label={booking.deposit_released ? 'Caution libérée' : 'Caution autorisée'}
            value={formatEUR(Number(booking.deposit_amount))}
            mono
            icon={<ShieldCheck className="h-3.5 w-3.5 text-rp-gold" />}
          />
        ) : null}
        {asset?.address ? <Row label="Adresse" value={asset.address} /> : null}
      </section>

      {qrToken && (booking.status === 'confirmed' || booking.status === 'active') ? (
        <section className="flex flex-col items-center gap-3">
          <RPQRDisplay
            value={qrToken}
            size={220}
            caption="Présentez ce QR à la serrure ou à la porte"
          />
          {asset?.access_instructions ? (
            <p className="max-w-xs text-center text-xs text-rp-gray">
              {asset.access_instructions}
            </p>
          ) : null}
        </section>
      ) : null}

      {(booking.status === 'confirmed' || booking.status === 'active') && asset ? (
        <CheckinActions
          bookingId={booking.id}
          status={booking.status}
          hasLock={Boolean(asset.ttlock_lock_id)}
          hasShelly={Boolean(asset.shelly_device_id)}
          shellyId={asset.shelly_device_id}
        />
      ) : null}
    </div>
  );
}

function Row({
  label,
  value,
  mono,
  icon,
}: {
  label: string;
  value: string;
  mono?: boolean;
  icon?: React.ReactNode;
}) {
  return (
    <div className="flex items-center justify-between">
      <span className="inline-flex items-center gap-1.5 text-xs text-rp-gray">
        {icon}
        {label}
      </span>
      <span className={mono ? 'font-mono text-sm text-rp-white' : 'text-sm text-rp-white'}>
        {value}
      </span>
    </div>
  );
}
