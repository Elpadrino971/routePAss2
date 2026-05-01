-- ROUTEPASS — Schema initial
-- Toutes les tables critiques + RLS + Realtime

create extension if not exists "uuid-ossp";

-- ─────────────────────────────────────────────────────────────
-- USERS
-- ─────────────────────────────────────────────────────────────
create table if not exists public.users (
  id uuid primary key default uuid_generate_v4(),
  auth_user_id uuid unique references auth.users(id) on delete cascade,
  email text unique,
  phone text,
  full_name text,
  avatar_url text,
  role text check (role in ('client','provider','owner','admin')) default 'client',
  stripe_customer_id text,
  created_at timestamptz default now()
);

-- ─────────────────────────────────────────────────────────────
-- PROVIDERS (transport)
-- ─────────────────────────────────────────────────────────────
create table if not exists public.providers (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references public.users(id) on delete cascade,
  service_type text check (service_type in ('taxi','minibus','boat','truck')),
  vehicle_name text,
  vehicle_photo_url text,
  id_doc_url text,
  license_url text,
  verified boolean default false,
  stripe_account_id text,
  qr_code_data text,
  base_rate numeric,
  is_available boolean default true,
  current_lat numeric,
  current_lng numeric,
  created_at timestamptz default now()
);

-- ─────────────────────────────────────────────────────────────
-- ASSETS (biens en location)
-- ─────────────────────────────────────────────────────────────
create table if not exists public.assets (
  id uuid primary key default uuid_generate_v4(),
  owner_id uuid references public.users(id) on delete cascade,
  category text check (category in ('vehicle','boat','property','equipment','tool','event')),
  name text,
  description text,
  photos text[],
  hourly_rate numeric,
  daily_rate numeric,
  weekly_rate numeric,
  deposit_amount numeric,
  min_duration_hours int default 1,
  cleaning_duration_minutes int default 60,
  status text check (status in ('available','occupied','cleaning','unavailable'))
    default 'available',
  available_from timestamptz,
  lat numeric,
  lng numeric,
  address text,
  -- Hardware IoT
  ttlock_lock_id text,
  shelly_device_id text,
  nfc_card_ids text[],
  access_instructions text,
  -- Stripe
  stripe_account_id text,
  verified boolean default false,
  created_at timestamptz default now()
);

-- ─────────────────────────────────────────────────────────────
-- TRANSACTIONS (transport immédiat)
-- ─────────────────────────────────────────────────────────────
create table if not exists public.transactions (
  id uuid primary key default uuid_generate_v4(),
  client_id uuid references public.users(id) on delete set null,
  provider_id uuid references public.providers(id) on delete set null,
  amount numeric,
  commission_amount numeric,
  stripe_payment_intent_id text,
  status text check (status in ('pending','confirmed','completed','cancelled','disputed'))
    default 'pending',
  validation_code char(4),
  created_at timestamptz default now(),
  completed_at timestamptz
);

-- ─────────────────────────────────────────────────────────────
-- BOOKINGS (location avec dates)
-- ─────────────────────────────────────────────────────────────
create table if not exists public.bookings (
  id uuid primary key default uuid_generate_v4(),
  client_id uuid references public.users(id) on delete set null,
  asset_id uuid references public.assets(id) on delete cascade,
  start_at timestamptz,
  end_at timestamptz,
  total_amount numeric,
  commission_amount numeric,
  deposit_amount numeric,
  deposit_released boolean default false,
  stripe_payment_intent_id text,
  stripe_hold_intent_id text,
  status text check (status in ('pending','confirmed','active','completed','cancelled','disputed'))
    default 'pending',
  access_qr_code text,
  nfc_card_id text,
  checkin_photos text[],
  checkout_photos text[],
  checklist_ok boolean,
  damage_amount numeric default 0,
  created_at timestamptz default now()
);

-- ─────────────────────────────────────────────────────────────
-- PAYOUTS (virements)
-- ─────────────────────────────────────────────────────────────
create table if not exists public.payouts (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references public.users(id) on delete cascade,
  amount numeric,
  stripe_payout_id text,
  status text check (status in ('pending','processing','paid','failed')),
  created_at timestamptz default now()
);

-- ─────────────────────────────────────────────────────────────
-- INDEXES
-- ─────────────────────────────────────────────────────────────
create index if not exists idx_assets_status on public.assets(status);
create index if not exists idx_assets_category on public.assets(category);
create index if not exists idx_bookings_client on public.bookings(client_id);
create index if not exists idx_bookings_asset on public.bookings(asset_id);
create index if not exists idx_bookings_status on public.bookings(status);
create index if not exists idx_bookings_end_at on public.bookings(end_at);
create index if not exists idx_transactions_client on public.transactions(client_id);
create index if not exists idx_transactions_provider on public.transactions(provider_id);

-- ─────────────────────────────────────────────────────────────
-- ROW LEVEL SECURITY
-- ─────────────────────────────────────────────────────────────
alter table public.users enable row level security;
alter table public.providers enable row level security;
alter table public.assets enable row level security;
alter table public.transactions enable row level security;
alter table public.bookings enable row level security;
alter table public.payouts enable row level security;

-- Helper: récupère l'id ROUTEPASS depuis l'auth.uid()
create or replace function public.current_user_id()
returns uuid
language sql stable
as $$
  select id from public.users where auth_user_id = auth.uid() limit 1;
$$;

-- Users: chacun lit/modifie son profil
drop policy if exists "users_self_select" on public.users;
create policy "users_self_select" on public.users
  for select using (auth_user_id = auth.uid());

drop policy if exists "users_self_update" on public.users;
create policy "users_self_update" on public.users
  for update using (auth_user_id = auth.uid());

drop policy if exists "users_self_insert" on public.users;
create policy "users_self_insert" on public.users
  for insert with check (auth_user_id = auth.uid());

-- Providers: lecture publique pour les vérifiés, écriture par le propriétaire
drop policy if exists "providers_public_read" on public.providers;
create policy "providers_public_read" on public.providers
  for select using (verified = true or user_id = public.current_user_id());

drop policy if exists "providers_self_write" on public.providers;
create policy "providers_self_write" on public.providers
  for all using (user_id = public.current_user_id())
  with check (user_id = public.current_user_id());

-- Assets: lecture publique des biens vérifiés, écriture par le propriétaire
drop policy if exists "assets_public_read" on public.assets;
create policy "assets_public_read" on public.assets
  for select using (verified = true or owner_id = public.current_user_id());

drop policy if exists "assets_owner_write" on public.assets;
create policy "assets_owner_write" on public.assets
  for all using (owner_id = public.current_user_id())
  with check (owner_id = public.current_user_id());

-- Transactions: client ou provider concerné
drop policy if exists "transactions_party_read" on public.transactions;
create policy "transactions_party_read" on public.transactions
  for select using (
    client_id = public.current_user_id()
    or provider_id in (select id from public.providers where user_id = public.current_user_id())
  );

-- Bookings: client ou propriétaire du bien
drop policy if exists "bookings_party_read" on public.bookings;
create policy "bookings_party_read" on public.bookings
  for select using (
    client_id = public.current_user_id()
    or asset_id in (select id from public.assets where owner_id = public.current_user_id())
  );

drop policy if exists "bookings_client_insert" on public.bookings;
create policy "bookings_client_insert" on public.bookings
  for insert with check (client_id = public.current_user_id());

-- Payouts: lecture par l'utilisateur concerné uniquement
drop policy if exists "payouts_self_read" on public.payouts;
create policy "payouts_self_read" on public.payouts
  for select using (user_id = public.current_user_id());

-- ─────────────────────────────────────────────────────────────
-- REALTIME : statuts des biens et bookings
-- ─────────────────────────────────────────────────────────────
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and tablename = 'assets'
  ) then
    alter publication supabase_realtime add table public.assets;
  end if;
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and tablename = 'bookings'
  ) then
    alter publication supabase_realtime add table public.bookings;
  end if;
end $$;
