-- GYMSIBS V13 · NATACIÓN
create table if not exists public.swimming (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  date date not null,
  lengths integer not null default 0 check (lengths >= 0),
  created_at timestamptz not null default now(),
  unique(user_id, date)
);
alter table public.swimming enable row level security;
drop policy if exists "swimming_select_authenticated" on public.swimming;
drop policy if exists "swimming_insert_own" on public.swimming;
drop policy if exists "swimming_update_own" on public.swimming;
drop policy if exists "swimming_delete_own" on public.swimming;
create policy "swimming_select_authenticated" on public.swimming for select to authenticated using (true);
create policy "swimming_insert_own" on public.swimming for insert to authenticated with check (user_id = auth.uid());
create policy "swimming_update_own" on public.swimming for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "swimming_delete_own" on public.swimming for delete to authenticated using (user_id = auth.uid());
create index if not exists swimming_user_date_idx on public.swimming(user_id, date);
