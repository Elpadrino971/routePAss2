import { createSupabaseServer } from '@/lib/supabase/server';
import { RPAvatar, RPBadge } from '@/components/ui';
import { ValidationActions } from './ValidationActions';

export default async function AdminValidations() {
  const supabase = createSupabaseServer();

  const { data: pendingProviders } = await supabase
    .from('providers')
    .select('id, vehicle_name, service_type, id_doc_url, license_url, vehicle_photo_url, users:user_id(full_name, avatar_url, email)')
    .eq('verified', false)
    .limit(50);

  const { data: pendingAssets } = await supabase
    .from('assets')
    .select('id, name, category, photos, users:owner_id(full_name)')
    .eq('verified', false)
    .limit(50);

  return (
    <div className="space-y-8">
      <section>
        <h2 className="mb-3 font-display text-xl text-rp-white">
          Prestataires en attente
        </h2>
        {(pendingProviders ?? []).length === 0 ? (
          <p className="text-sm text-rp-gray">Tout est à jour.</p>
        ) : (
          <ul className="space-y-2">
            {(pendingProviders ?? []).map((p) => {
              type UserLookup = { full_name: string | null; avatar_url: string | null; email: string | null };
              const uRow = p.users as unknown as UserLookup | UserLookup[] | null;
              const u = Array.isArray(uRow) ? uRow[0] : uRow;
              return (
                <li
                  key={p.id}
                  className="flex flex-col gap-3 rounded-rp border border-rp-border bg-rp-dark p-4 md:flex-row md:items-center"
                >
                  <RPAvatar src={u?.avatar_url} fallback={u?.full_name ?? 'R'} />
                  <div className="flex-1">
                    <p className="text-sm text-rp-white">{u?.full_name ?? '—'}</p>
                    <p className="text-xs text-rp-gray">
                      {p.service_type} · {p.vehicle_name}
                    </p>
                    <div className="mt-1 flex gap-2 text-[10px]">
                      {p.id_doc_url ? (
                        <a href={p.id_doc_url} target="_blank" rel="noreferrer" className="text-rp-gold hover:underline">
                          Pièce ID
                        </a>
                      ) : null}
                      {p.license_url ? (
                        <a href={p.license_url} target="_blank" rel="noreferrer" className="text-rp-gold hover:underline">
                          Permis
                        </a>
                      ) : null}
                      {p.vehicle_photo_url ? (
                        <a href={p.vehicle_photo_url} target="_blank" rel="noreferrer" className="text-rp-gold hover:underline">
                          Véhicule
                        </a>
                      ) : null}
                    </div>
                  </div>
                  <ValidationActions kind="provider" id={p.id} />
                </li>
              );
            })}
          </ul>
        )}
      </section>

      <section>
        <h2 className="mb-3 font-display text-xl text-rp-white">
          Biens en attente
        </h2>
        {(pendingAssets ?? []).length === 0 ? (
          <p className="text-sm text-rp-gray">Tout est à jour.</p>
        ) : (
          <ul className="space-y-2">
            {(pendingAssets ?? []).map((a) => (
              <li
                key={a.id}
                className="flex flex-col gap-3 rounded-rp border border-rp-border bg-rp-dark p-4 md:flex-row md:items-center"
              >
                <div className="flex-1">
                  <p className="text-sm text-rp-white">{a.name}</p>
                  <p className="text-xs text-rp-gray">{a.category}</p>
                  <RPBadge tone="warning" className="mt-1">À valider</RPBadge>
                </div>
                <ValidationActions kind="asset" id={a.id} />
              </li>
            ))}
          </ul>
        )}
      </section>
    </div>
  );
}
