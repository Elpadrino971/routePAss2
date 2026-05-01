-- Web Push subscriptions par utilisateur.

create table if not exists public.push_subscriptions (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references public.users(id) on delete cascade,
  endpoint text not null,
  p256dh text not null,
  auth text not null,
  created_at timestamptz default now(),
  unique(user_id, endpoint)
);

alter table public.push_subscriptions enable row level security;

drop policy if exists "push_self" on public.push_subscriptions;
create policy "push_self" on public.push_subscriptions
  for all using (user_id = public.current_user_id())
  with check (user_id = public.current_user_id());
