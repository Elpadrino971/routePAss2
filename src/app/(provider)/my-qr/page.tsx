import { redirect } from 'next/navigation';
import Link from 'next/link';
import { createSupabaseServer } from '@/lib/supabase/server';
import { signProviderQR } from '@/lib/qr';
import { RPButton, RPLogo, RPQRDisplay } from '@/components/ui';

export const dynamic = 'force-dynamic';

export default async function MyQRPage() {
  const supabase = createSupabaseServer();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const { data: profile } = await supabase
    .from('users')
    .select('id, full_name')
    .eq('auth_user_id', user.id)
    .maybeSingle();
  if (!profile) redirect('/onboarding');

  const { data: provider } = await supabase
    .from('providers')
    .select('id, vehicle_name, service_type, qr_code_data')
    .eq('user_id', profile.id)
    .maybeSingle();
  if (!provider) redirect('/setup');

  // Génère ou récupère le payload QR persistant.
  let qrToken = provider.qr_code_data;
  if (!qrToken) {
    qrToken = signProviderQR(provider.id);
    await supabase
      .from('providers')
      .update({ qr_code_data: qrToken })
      .eq('id', provider.id);
  }

  return (
    <div className="flex min-h-dvh flex-col px-5 pt-6">
      <div className="flex flex-col items-center gap-1 pb-4">
        <RPLogo size={36} />
        <p className="font-display text-sm italic text-rp-gray">
          Présentez ce code à votre client
        </p>
      </div>

      <div className="flex flex-1 flex-col items-center justify-center gap-6">
        <RPQRDisplay
          value={qrToken}
          size={260}
          caption={`${provider.vehicle_name ?? 'Course'} · ${provider.service_type ?? ''}`}
        />
        <p className="max-w-xs text-center text-xs text-rp-gray">
          Le client scanne ce QR depuis l&apos;application ROUTEPASS pour
          réserver et payer la course en quelques secondes.
        </p>
      </div>

      <Link href="/validate" className="mt-auto pb-4">
        <RPButton block size="lg" variant="outlineGold">
          Valider une course
        </RPButton>
      </Link>
    </div>
  );
}
