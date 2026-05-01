'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import Image from 'next/image';
import { Car, Bus, Ship, Truck, Upload, FileText, Camera } from 'lucide-react';
import { RPButton, RPInput, RPLogo } from '@/components/ui';
import { cn } from '@/lib/utils';
import { createSupabaseBrowser } from '@/lib/supabase/client';
import type { ServiceType } from '@/lib/supabase/types';

const SERVICES = [
  { id: 'taxi' as const, label: 'Taxi', icon: Car },
  { id: 'minibus' as const, label: 'Minibus', icon: Bus },
  { id: 'boat' as const, label: 'Bateau', icon: Ship },
  { id: 'truck' as const, label: 'Fret', icon: Truck },
];

interface Docs {
  vehiclePhoto?: File;
  idDoc?: File;
  license?: File;
}

export default function ProviderOnboarding() {
  const router = useRouter();
  const supabase = createSupabaseBrowser();
  const [authUserId, setAuthUserId] = useState<string | null>(null);
  const [providerId, setProviderId] = useState<string | null>(null);

  const [serviceType, setServiceType] = useState<ServiceType>('taxi');
  const [vehicleName, setVehicleName] = useState('');
  const [baseRate, setBaseRate] = useState('');
  const [docs, setDocs] = useState<Docs>({});
  const [previewUrl, setPreviewUrl] = useState<string | null>(null);

  const [step, setStep] = useState<1 | 2 | 3>(1);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    supabase.auth.getUser().then(({ data }) => {
      setAuthUserId(data.user?.id ?? null);
    });
  }, [supabase]);

  function pickFile(field: keyof Docs) {
    return (e: React.ChangeEvent<HTMLInputElement>) => {
      const file = e.target.files?.[0];
      if (!file) return;
      setDocs((d) => ({ ...d, [field]: file }));
      if (field === 'vehiclePhoto') {
        setPreviewUrl(URL.createObjectURL(file));
      }
    };
  }

  async function uploadDoc(file: File, path: string): Promise<string> {
    const { error: upErr } = await supabase.storage
      .from('provider-docs')
      .upload(path, file, { upsert: true, contentType: file.type });
    if (upErr) throw upErr;
    const { data } = supabase.storage.from('provider-docs').getPublicUrl(path);
    return data.publicUrl;
  }

  async function saveProvider() {
    setError(null);
    setLoading(true);
    try {
      if (!authUserId) throw new Error('Session expirée');
      const { data: profile, error: profileErr } = await supabase
        .from('users')
        .select('id')
        .eq('auth_user_id', authUserId)
        .maybeSingle();
      if (profileErr) throw profileErr;
      if (!profile) throw new Error('Profil introuvable');

      const userId = profile.id;
      let vehiclePhotoUrl: string | null = null;
      let idDocUrl: string | null = null;
      let licenseUrl: string | null = null;

      if (docs.vehiclePhoto) {
        vehiclePhotoUrl = await uploadDoc(
          docs.vehiclePhoto,
          `${authUserId}/vehicle-${Date.now()}.${docs.vehiclePhoto.name.split('.').pop()}`
        );
      }
      if (docs.idDoc) {
        idDocUrl = await uploadDoc(
          docs.idDoc,
          `${authUserId}/id-${Date.now()}.${docs.idDoc.name.split('.').pop()}`
        );
      }
      if (docs.license) {
        licenseUrl = await uploadDoc(
          docs.license,
          `${authUserId}/license-${Date.now()}.${docs.license.name.split('.').pop()}`
        );
      }

      // upsert sur user_id pour permettre la reprise
      const { data: provider, error: provErr } = await supabase
        .from('providers')
        .upsert(
          {
            user_id: userId,
            service_type: serviceType,
            vehicle_name: vehicleName || null,
            vehicle_photo_url: vehiclePhotoUrl,
            id_doc_url: idDocUrl,
            license_url: licenseUrl,
            base_rate: baseRate ? Number(baseRate) : null,
          },
          { onConflict: 'user_id' }
        )
        .select('id')
        .single();
      if (provErr) throw provErr;

      setProviderId(provider.id);
      setStep(3);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erreur inconnue');
    } finally {
      setLoading(false);
    }
  }

  async function connectStripe() {
    setError(null);
    setLoading(true);
    try {
      const res = await fetch('/api/stripe/connect/onboard', { method: 'POST' });
      const json = (await res.json()) as { url?: string; error?: string };
      if (!res.ok || !json.url) throw new Error(json.error ?? 'Stripe indisponible');
      window.location.href = json.url;
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erreur Stripe');
      setLoading(false);
    }
  }

  return (
    <main className="mx-auto flex min-h-dvh max-w-md flex-col px-6 py-8">
      <div className="flex items-center justify-between">
        <RPLogo size={36} />
        <span className="text-[10px] uppercase tracking-[0.3em] text-rp-gold">
          Étape {step} / 3
        </span>
      </div>

      <div className="mt-8 flex flex-1 flex-col gap-6">
        {step === 1 ? (
          <>
            <div>
              <h1 className="font-display text-2xl text-rp-white">
                Quel est votre <span className="rp-text-gradient-gold">métier</span> ?
              </h1>
              <p className="mt-1 text-sm text-rp-gray">
                Sélectionnez votre service principal.
              </p>
            </div>
            <div className="grid grid-cols-2 gap-3">
              {SERVICES.map((s) => {
                const selected = serviceType === s.id;
                return (
                  <button
                    key={s.id}
                    type="button"
                    onClick={() => setServiceType(s.id)}
                    className={cn(
                      'flex flex-col items-center gap-2 rounded-rp border p-4 transition-all',
                      selected
                        ? 'border-rp-gold bg-rp-gold/5 shadow-rp-gold'
                        : 'border-rp-border bg-rp-dark hover:border-rp-gold/40'
                    )}
                  >
                    <span className="flex h-12 w-12 items-center justify-center rounded-full bg-rp-gold/10 text-rp-gold">
                      <s.icon className="h-6 w-6" />
                    </span>
                    <span className="font-display text-sm text-rp-white">{s.label}</span>
                  </button>
                );
              })}
            </div>

            <RPInput
              label="Nom du véhicule (ex. Mercedes Classe E)"
              value={vehicleName}
              onChange={(e) => setVehicleName(e.target.value)}
            />

            <RPInput
              label="Tarif indicatif (€)"
              type="number"
              inputMode="decimal"
              value={baseRate}
              onChange={(e) => setBaseRate(e.target.value)}
            />

            <RPButton
              block
              size="lg"
              disabled={!vehicleName || !baseRate}
              onClick={() => setStep(2)}
            >
              Continuer
            </RPButton>
          </>
        ) : null}

        {step === 2 ? (
          <>
            <div>
              <h1 className="font-display text-2xl text-rp-white">
                Vos <span className="rp-text-gradient-gold">documents</span>
              </h1>
              <p className="mt-1 text-sm text-rp-gray">
                Photo du véhicule, pièce d&apos;identité, permis ou licence.
              </p>
            </div>

            <FileSlot
              label="Photo du véhicule"
              icon={Camera}
              file={docs.vehiclePhoto}
              accept="image/*"
              previewUrl={previewUrl}
              onChange={pickFile('vehiclePhoto')}
            />
            <FileSlot
              label="Pièce d'identité"
              icon={FileText}
              file={docs.idDoc}
              accept="image/*,application/pdf"
              onChange={pickFile('idDoc')}
            />
            <FileSlot
              label="Permis / licence"
              icon={FileText}
              file={docs.license}
              accept="image/*,application/pdf"
              onChange={pickFile('license')}
            />

            {error ? (
              <p className="rounded-rp-input border border-rp-danger/30 bg-rp-danger/10 p-3 text-xs text-rp-danger">
                {error}
              </p>
            ) : null}

            <div className="mt-auto space-y-2">
              <RPButton
                block
                size="lg"
                loading={loading}
                disabled={!docs.vehiclePhoto || !docs.idDoc}
                onClick={saveProvider}
              >
                Enregistrer
              </RPButton>
              <button
                type="button"
                onClick={() => setStep(1)}
                className="block w-full text-center text-xs text-rp-gray hover:text-rp-white"
              >
                Retour
              </button>
            </div>
          </>
        ) : null}

        {step === 3 ? (
          <>
            <div>
              <h1 className="font-display text-2xl text-rp-white">
                Activez <span className="rp-text-gradient-gold">vos paiements</span>
              </h1>
              <p className="mt-1 text-sm text-rp-gray">
                ROUTEPASS utilise Stripe Connect pour vous reverser
                automatiquement vos courses (commission 5 %).
              </p>
            </div>

            <div className="rounded-rp border border-rp-border bg-rp-dark p-5 text-sm text-rp-gray">
              <ul className="space-y-2">
                <li>• Création d&apos;un compte Stripe Express</li>
                <li>• KYC automatique (identité, IBAN)</li>
                <li>• Versements quotidiens directs sur votre compte</li>
              </ul>
            </div>

            {error ? (
              <p className="rounded-rp-input border border-rp-danger/30 bg-rp-danger/10 p-3 text-xs text-rp-danger">
                {error}
              </p>
            ) : null}

            <div className="mt-auto space-y-2">
              <RPButton block size="lg" loading={loading} onClick={connectStripe}>
                Connecter Stripe
              </RPButton>
              <button
                type="button"
                onClick={() => router.replace('/dashboard')}
                className="block w-full text-center text-xs text-rp-gray hover:text-rp-white"
              >
                Plus tard
              </button>
            </div>
          </>
        ) : null}
      </div>
    </main>
  );
}

interface FileSlotProps {
  label: string;
  icon: typeof Upload;
  file?: File;
  accept: string;
  previewUrl?: string | null;
  onChange: (e: React.ChangeEvent<HTMLInputElement>) => void;
}

function FileSlot({ label, icon: Icon, file, accept, previewUrl, onChange }: FileSlotProps) {
  return (
    <label
      className={cn(
        'group flex cursor-pointer items-center gap-3 rounded-rp border p-4 transition',
        file
          ? 'border-rp-gold/60 bg-rp-gold/5'
          : 'border-dashed border-rp-border bg-rp-dark hover:border-rp-gold/40'
      )}
    >
      <span className="flex h-10 w-10 shrink-0 items-center justify-center overflow-hidden rounded-full bg-rp-dark-2 text-rp-gold">
        {previewUrl && file?.type.startsWith('image/') ? (
          <Image src={previewUrl} alt="" width={40} height={40} className="h-full w-full object-cover" />
        ) : (
          <Icon className="h-5 w-5" />
        )}
      </span>
      <span className="flex-1">
        <span className="block text-sm text-rp-white">{label}</span>
        <span className="block text-xs text-rp-gray">
          {file ? file.name : 'Toucher pour charger'}
        </span>
      </span>
      <input
        type="file"
        accept={accept}
        onChange={onChange}
        className="hidden"
      />
    </label>
  );
}
