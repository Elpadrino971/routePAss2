-- Buckets Supabase Storage pour ROUTEPASS

insert into storage.buckets (id, name, public)
values
  ('avatars', 'avatars', true),
  ('provider-docs', 'provider-docs', false),
  ('asset-photos', 'asset-photos', true),
  ('booking-photos', 'booking-photos', false)
on conflict (id) do nothing;

-- Policies : chaque utilisateur écrit dans son propre dossier (auth.uid()/...)
drop policy if exists "avatars_owner_write" on storage.objects;
create policy "avatars_owner_write" on storage.objects
  for all using (
    bucket_id = 'avatars'
    and auth.uid()::text = (storage.foldername(name))[1]
  ) with check (
    bucket_id = 'avatars'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

drop policy if exists "provider_docs_owner_write" on storage.objects;
create policy "provider_docs_owner_write" on storage.objects
  for all using (
    bucket_id = 'provider-docs'
    and auth.uid()::text = (storage.foldername(name))[1]
  ) with check (
    bucket_id = 'provider-docs'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

drop policy if exists "asset_photos_owner_write" on storage.objects;
create policy "asset_photos_owner_write" on storage.objects
  for all using (
    bucket_id = 'asset-photos'
    and auth.uid()::text = (storage.foldername(name))[1]
  ) with check (
    bucket_id = 'asset-photos'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

drop policy if exists "booking_photos_owner_write" on storage.objects;
create policy "booking_photos_owner_write" on storage.objects
  for all using (
    bucket_id = 'booking-photos'
    and auth.uid()::text = (storage.foldername(name))[1]
  ) with check (
    bucket_id = 'booking-photos'
    and auth.uid()::text = (storage.foldername(name))[1]
  );
