-- Active Realtime sur la table providers (positions GPS live).
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and tablename = 'providers'
  ) then
    alter publication supabase_realtime add table public.providers;
  end if;
end $$;
