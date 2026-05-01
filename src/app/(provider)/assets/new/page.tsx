'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { Camera, Home, Key, Ship, Wrench, Hammer, PartyPopper } from 'lucide-react';
import { RPButton, RPInput } from '@/components/ui';
import { cn } from '@/lib/utils';
import { createSupabaseBrowser } from '@/lib/supabase/client';
import type { AssetCategory } from '@/lib/supabase/types';

const CATEGORIES: { id: AssetCategory; label: string; icon: typeof Home }[] = [
  { id: 'vehicle', label: 'Véhicule', icon: Key },
  { id: 'property', label: 'Bien', icon: Home },
  { id: 'boat', label: 'Bateau', icon: Ship },
  { id: 'equipment', label: 'Matériel', icon: Wrench },
  { id: 'tool', label: 'Outil', icon: Hammer },
  { id: 'event', label: 'Événement', icon: PartyPopper },
];

export default function NewAssetPage() {
  const router = useRouter();
  const supabase = createSupabaseBrowser();
  const [authUserId, setAuthUserId] = useState<string | null>(null);

  const [category, setCategory] = useState<AssetCategory>('property');
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [hourlyRate, setHourlyRate] = useState('');
  const [dailyRate, setDailyRate] = useState('');
  const [deposit, setDeposit] = useState('');
  const [address, setAddress] = useState('');
  const [photos, setPhotos] = useState<File[]>([]);
  const [previews, setPreviews] = useState<string[]>([]);

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    supabase.auth.getUser().then(({ data }) => setAuthUserId(data.user?.id ?? null));
  }, [supabase]);

  function pickPhotos(e: React.ChangeEvent<HTMLInputElement>) {
    const files = Array.from(e.target.files ?? []).slice(0, 6);
    setPhotos(files);
    setPreviews(files.map((f) => URL.createObjectURL(f)));
  }

  async function uploadPhoto(file: File, prefix: string): Promise<string> {
    const path = `${authUserId}/${prefix}-${Date.now()}-${Math.random().toString(36).slice(2, 8)}.${file.name.split('.').pop()}`;
    const { error: upErr } = await supabase.storage
      .from('asset-photos')
      .upload(path, file, { contentType: file.type });
    if (upErr) throw upErr;
    return supabase.storage.from('asset-photos').getPublicUrl(path).data.publicUrl;
  }

  async function submit() {
    setError(null);
    setLoading(true);
    try {
      if (!authUserId) throw new Error('Session expirée');
      const { data: profile } = await supabase
        .from('users')
        .select('id')
        .eq('auth_user_id', authUserId)
        .maybeSingle();
      if (!profile) throw new Error('Profil introuvable');

      const photoUrls: string[] = [];
      for (let i = 0; i < photos.length; i++) {
        const file = photos[i];
        if (file) photoUrls.push(await uploadPhoto(file, `asset-${i}`));
      }

      const { data, error: insErr } = await supabase
        .from('assets')
        .insert({
          owner_id: profile.id,
          category,
          name,
          description: description || null,
          photos: photoUrls.length > 0 ? photoUrls : null,
          hourly_rate: hourlyRate ? Number(hourlyRate) : null,
          daily_rate: dailyRate ? Number(dailyRate) : null,
          deposit_amount: deposit ? Number(deposit) : null,
          address: address || null,
          status: 'available',
        })
        .select('id')
        .single();
      if (insErr) throw insErr;

      router.replace(`/assets`);
      router.refresh();
      void data;
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Erreur');
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="space-y-5 px-5 pt-8">
      <header>
        <p className="text-xs uppercase tracking-[0.3em] text-rp-gold">Nouveau bien</p>
        <h1 className="font-display text-2xl text-rp-white">Ajouter un bien</h1>
      </header>

      <div>
        <p className="mb-2 text-xs uppercase tracking-[0.3em] text-rp-gold">
          Catégorie
        </p>
        <div className="grid grid-cols-3 gap-2">
          {CATEGORIES.map((c) => {
            const selected = category === c.id;
            return (
              <button
                key={c.id}
                type="button"
                onClick={() => setCategory(c.id)}
                className={cn(
                  'flex flex-col items-center gap-1.5 rounded-rp border p-3 transition',
                  selected
                    ? 'border-rp-gold bg-rp-gold/5'
                    : 'border-rp-border bg-rp-dark hover:border-rp-gold/40'
                )}
              >
                <span className="flex h-9 w-9 items-center justify-center rounded-full bg-rp-gold/10 text-rp-gold">
                  <c.icon className="h-4 w-4" />
                </span>
                <span className="text-[11px] text-rp-white">{c.label}</span>
              </button>
            );
          })}
        </div>
      </div>

      <RPInput label="Nom" value={name} onChange={(e) => setName(e.target.value)} />
      <RPInput
        label="Description"
        value={description}
        onChange={(e) => setDescription(e.target.value)}
      />

      <div className="grid grid-cols-2 gap-3">
        <RPInput
          label="€/heure"
          type="number"
          inputMode="decimal"
          value={hourlyRate}
          onChange={(e) => setHourlyRate(e.target.value)}
        />
        <RPInput
          label="€/jour"
          type="number"
          inputMode="decimal"
          value={dailyRate}
          onChange={(e) => setDailyRate(e.target.value)}
        />
      </div>

      <RPInput
        label="Caution (€)"
        type="number"
        inputMode="decimal"
        value={deposit}
        onChange={(e) => setDeposit(e.target.value)}
      />

      <RPInput
        label="Adresse"
        value={address}
        onChange={(e) => setAddress(e.target.value)}
      />

      <label className="flex cursor-pointer items-center gap-3 rounded-rp border border-dashed border-rp-border bg-rp-dark p-4">
        <span className="flex h-10 w-10 items-center justify-center rounded-full bg-rp-gold/10 text-rp-gold">
          <Camera className="h-5 w-5" />
        </span>
        <span className="flex-1 text-sm text-rp-white">
          {photos.length > 0
            ? `${photos.length} photo${photos.length > 1 ? 's' : ''} sélectionnée${photos.length > 1 ? 's' : ''}`
            : 'Photos du bien (jusqu\'à 6)'}
        </span>
        <input type="file" accept="image/*" multiple onChange={pickPhotos} className="hidden" />
      </label>

      {previews.length > 0 ? (
        <div className="flex gap-2 overflow-x-auto pb-2">
          {previews.map((src, i) => (
            <span
              key={i}
              className="relative block h-20 w-28 shrink-0 overflow-hidden rounded-rp-input"
            >
              {/* preview locale, dataURL/blob — pas besoin de next/image */}
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img src={src} alt="" className="h-full w-full object-cover" />
            </span>
          ))}
        </div>
      ) : null}

      {error ? (
        <p className="rounded-rp-input border border-rp-danger/30 bg-rp-danger/10 p-3 text-xs text-rp-danger">
          {error}
        </p>
      ) : null}

      <div className="pb-4">
        <RPButton
          block
          size="lg"
          loading={loading}
          disabled={!name || (!hourlyRate && !dailyRate)}
          onClick={submit}
        >
          Enregistrer
        </RPButton>
      </div>
    </div>
  );
}
