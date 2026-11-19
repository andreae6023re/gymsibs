-- GYMSIBS V14 · Tabla para registrar clases de Pilates
create table if not exists public.pilates (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  date date not null,
  classes integer not null default 1 check (classes >= 0),
  created_at timestamptz not null default now(),
  unique(user_id, date)
);

alter table public.pilates enable row level security;
drop policy if exists "pilates_select_authenticated" on public.pilates;
drop policy if exists "pilates_insert_own" on public.pilates;
drop policy if exists "pilates_update_own" on public.pilates;
drop policy if exists "pilates_delete_own" on public.pilates;
create policy "pilates_select_authenticated" on public.pilates for select to authenticated using (true);
create policy "pilates_insert_own" on public.pilates for insert to authenticated with check (user_id = auth.uid());
create policy "pilates_update_own" on public.pilates for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "pilates_delete_own" on public.pilates for delete to authenticated using (user_id = auth.uid());
create index if not exists pilates_user_date_idx on public.pilates(user_id, date);
