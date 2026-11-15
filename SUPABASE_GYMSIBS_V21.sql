-- GYMSIBS V21 · ampliación de esquema
-- Compatible con el esquema existente inspeccionado (profiles, exercises, workouts, steps, swimming).
-- No elimina ni modifica registros históricos.
-- Ejecutar una sola vez en Supabase > SQL Editor.

create extension if not exists pgcrypto;

-- RUTINAS PERSONALES Y SESIONES
create table if not exists public.routines (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  name text not null,
  description text,
  is_archived boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.routine_exercises (
  id uuid primary key default gen_random_uuid(),
  routine_id uuid not null references public.routines(id) on delete cascade,
  exercise_id uuid references public.exercises(id) on delete set null,
  exercise_name text not null,
  position integer not null default 0,
  target_sets integer not null default 3 check (target_sets > 0),
  target_reps text not null default '10-12',
  target_weight numeric(8,2) not null default 0 check (target_weight >= 0),
  rest_seconds integer not null default 90 check (rest_seconds >= 0),
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.workout_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  routine_id uuid references public.routines(id) on delete set null,
  routine_name text,
  session_date date not null default current_date,
  status text not null default 'in_progress' check (status in ('in_progress','paused','completed','partial','cancelled')),
  started_at timestamptz not null default now(),
  finished_at timestamptz,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.workout_session_sets (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.workout_sessions(id) on delete cascade,
  exercise_id uuid references public.exercises(id) on delete set null,
  exercise_name text not null,
  position integer not null default 0,
  set_number integer not null default 1 check (set_number > 0),
  reps integer not null default 0 check (reps >= 0),
  weight numeric(8,2) not null default 0 check (weight >= 0),
  completed boolean not null default false,
  skipped boolean not null default false,
  notes text,
  created_at timestamptz not null default now()
);

-- LOGROS, XP Y PREMIOS
create table if not exists public.achievements (
  id uuid primary key default gen_random_uuid(),
  creator_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  description text,
  category text not null default 'personal' check (category in ('personal','competitive','shared','custom')),
  goal_type text not null default 'manual',
  goal_value numeric(12,2) not null default 1,
  xp_reward integer not null default 0 check (xp_reward >= 0),
  participant_scope text not null default 'self' check (participant_scope in ('self','both','selected')),
  starts_on date,
  ends_on date,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.user_achievements (
  id uuid primary key default gen_random_uuid(),
  achievement_id uuid not null references public.achievements(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  progress numeric(12,2) not null default 0,
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  unique (achievement_id,user_id)
);

-- XP es un libro de movimientos: no se permiten UPDATE ni DELETE desde el cliente.
create table if not exists public.xp_transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  amount integer not null check (amount <> 0),
  transaction_type text not null check (transaction_type in ('achievement','duel_win','step_battle_win','step_goal_bonus','step_tie','reward_redemption','admin_adjustment')),
  description text not null,
  reference_id uuid,
  created_at timestamptz not null default now()
);

create table if not exists public.rewards (
  id uuid primary key default gen_random_uuid(),
  creator_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  description text,
  xp_cost integer not null default 0 check (xp_cost >= 0),
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.reward_redemptions (
  id uuid primary key default gen_random_uuid(),
  reward_id uuid references public.rewards(id) on delete set null,
  user_id uuid not null references public.profiles(id) on delete cascade,
  xp_cost integer not null check (xp_cost >= 0),
  status text not null default 'requested' check (status in ('requested','approved','delivered','rejected')),
  requested_at timestamptz not null default now(),
  resolved_at timestamptz
);

-- RETOS PERSONALIZADOS
create table if not exists public.custom_challenges (
  id uuid primary key default gen_random_uuid(),
  creator_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  description text,
  category text not null default 'personal',
  goal_type text not null default 'manual',
  goal_value numeric(12,2) not null default 1,
  xp_reward integer not null default 0 check (xp_reward >= 0),
  starts_on date not null default current_date,
  ends_on date,
  status text not null default 'active' check (status in ('active','completed','cancelled','closed')),
  created_at timestamptz not null default now()
);

create table if not exists public.challenge_participants (
  id uuid primary key default gen_random_uuid(),
  challenge_id uuid not null references public.custom_challenges(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  progress numeric(12,2) not null default 0,
  completed_at timestamptz,
  joined_at timestamptz not null default now(),
  unique (challenge_id,user_id)
);

-- COMPETICIÓN SEMANAL DE PASOS. Los pasos diarios siguen en la tabla steps existente.
create table if not exists public.step_battles (
  id uuid primary key default gen_random_uuid(),
  week_start date not null unique,
  weekly_goal integer not null default 70000 check (weekly_goal > 0),
  winner_xp integer not null default 20 check (winner_xp >= 0),
  goal_bonus_xp integer not null default 10 check (goal_bonus_xp >= 0),
  tie_xp integer not null default 10 check (tie_xp >= 0),
  status text not null default 'open' check (status in ('open','closed','pending_review')),
  created_at timestamptz not null default now()
);

create table if not exists public.step_battle_results (
  id uuid primary key default gen_random_uuid(),
  battle_id uuid not null references public.step_battles(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  total_steps bigint not null default 0 check (total_steps >= 0),
  reached_goal boolean not null default false,
  placement integer check (placement is null or placement > 0),
  xp_awarded integer not null default 0,
  calculated_at timestamptz not null default now(),
  unique (battle_id,user_id)
);

-- Índices de consulta
create index if not exists idx_routines_user on public.routines(user_id, is_archived);
create index if not exists idx_routine_exercises_routine on public.routine_exercises(routine_id, position);
create index if not exists idx_sessions_user_date on public.workout_sessions(user_id, session_date desc);
create index if not exists idx_session_sets_session on public.workout_session_sets(session_id, position, set_number);
create index if not exists idx_xp_user_created on public.xp_transactions(user_id, created_at desc);
create index if not exists idx_user_achievements_user on public.user_achievements(user_id);
create index if not exists idx_challenge_participants_user on public.challenge_participants(user_id);
create index if not exists idx_step_battle_results_user on public.step_battle_results(user_id);

-- updated_at automático para plantillas de rutina
create or replace function public.gymsibs_touch_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end; $$;
drop trigger if exists trg_gymsibs_routines_updated_at on public.routines;
create trigger trg_gymsibs_routines_updated_at before update on public.routines
for each row execute function public.gymsibs_touch_updated_at();

-- RLS
alter table public.routines enable row level security;
alter table public.routine_exercises enable row level security;
alter table public.workout_sessions enable row level security;
alter table public.workout_session_sets enable row level security;
alter table public.achievements enable row level security;
alter table public.user_achievements enable row level security;
alter table public.xp_transactions enable row level security;
alter table public.rewards enable row level security;
alter table public.reward_redemptions enable row level security;
alter table public.custom_challenges enable row level security;
alter table public.challenge_participants enable row level security;
alter table public.step_battles enable row level security;
alter table public.step_battle_results enable row level security;

-- Re-runnable policies
DO $$ DECLARE t text; BEGIN
  FOREACH t IN ARRAY ARRAY['user_achievements','xp_transactions','step_battle_results'] LOOP
    EXECUTE format('drop policy if exists %I on public.%I', t||'_select_authenticated', t);
    EXECUTE format('create policy %I on public.%I for select to authenticated using (true)', t||'_select_authenticated', t);
  END LOOP;
END $$;

-- Datos estrictamente personales
drop policy if exists routines_select_authenticated on public.routines;
drop policy if exists routines_select_own on public.routines;
create policy routines_select_own on public.routines for select to authenticated using (user_id=auth.uid());
drop policy if exists workout_sessions_select_authenticated on public.workout_sessions;
drop policy if exists sessions_select_own on public.workout_sessions;
create policy sessions_select_own on public.workout_sessions for select to authenticated using (user_id=auth.uid());
drop policy if exists reward_redemptions_select_authenticated on public.reward_redemptions;
drop policy if exists redemptions_select_own on public.reward_redemptions;
create policy redemptions_select_own on public.reward_redemptions for select to authenticated using (user_id=auth.uid());
drop policy if exists routines_insert_own on public.routines;
create policy routines_insert_own on public.routines for insert to authenticated with check (user_id = auth.uid());
drop policy if exists routines_update_own on public.routines;
create policy routines_update_own on public.routines for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
drop policy if exists routines_delete_own on public.routines;
create policy routines_delete_own on public.routines for delete to authenticated using (user_id = auth.uid());
drop policy if exists routine_exercises_select_own on public.routine_exercises;
create policy routine_exercises_select_own on public.routine_exercises for select to authenticated using (exists(select 1 from public.routines r where r.id=routine_id and r.user_id=auth.uid()));
drop policy if exists routine_exercises_insert_own on public.routine_exercises;
create policy routine_exercises_insert_own on public.routine_exercises for insert to authenticated with check (exists(select 1 from public.routines r where r.id=routine_id and r.user_id=auth.uid()));
drop policy if exists routine_exercises_update_own on public.routine_exercises;
create policy routine_exercises_update_own on public.routine_exercises for update to authenticated using (exists(select 1 from public.routines r where r.id=routine_id and r.user_id=auth.uid())) with check (exists(select 1 from public.routines r where r.id=routine_id and r.user_id=auth.uid()));
drop policy if exists routine_exercises_delete_own on public.routine_exercises;
create policy routine_exercises_delete_own on public.routine_exercises for delete to authenticated using (exists(select 1 from public.routines r where r.id=routine_id and r.user_id=auth.uid()));
drop policy if exists sessions_insert_own on public.workout_sessions;
create policy sessions_insert_own on public.workout_sessions for insert to authenticated with check (user_id=auth.uid());
drop policy if exists sessions_update_own on public.workout_sessions;
create policy sessions_update_own on public.workout_sessions for update to authenticated using (user_id=auth.uid()) with check (user_id=auth.uid());
drop policy if exists sessions_delete_own on public.workout_sessions;
create policy sessions_delete_own on public.workout_sessions for delete to authenticated using (user_id=auth.uid());
drop policy if exists session_sets_select_own on public.workout_session_sets;
create policy session_sets_select_own on public.workout_session_sets for select to authenticated using (exists(select 1 from public.workout_sessions s where s.id=session_id and s.user_id=auth.uid()));
drop policy if exists session_sets_insert_own on public.workout_session_sets;
create policy session_sets_insert_own on public.workout_session_sets for insert to authenticated with check (exists(select 1 from public.workout_sessions s where s.id=session_id and s.user_id=auth.uid()));
drop policy if exists session_sets_update_own on public.workout_session_sets;
create policy session_sets_update_own on public.workout_session_sets for update to authenticated using (exists(select 1 from public.workout_sessions s where s.id=session_id and s.user_id=auth.uid())) with check (exists(select 1 from public.workout_sessions s where s.id=session_id and s.user_id=auth.uid()));
drop policy if exists session_sets_delete_own on public.workout_session_sets;
create policy session_sets_delete_own on public.workout_session_sets for delete to authenticated using (exists(select 1 from public.workout_sessions s where s.id=session_id and s.user_id=auth.uid()));
drop policy if exists user_achievements_insert_own on public.user_achievements;
create policy user_achievements_insert_own on public.user_achievements for insert to authenticated with check (user_id=auth.uid());
drop policy if exists user_achievements_update_own on public.user_achievements;
create policy user_achievements_update_own on public.user_achievements for update to authenticated using (user_id=auth.uid()) with check (user_id=auth.uid());
drop policy if exists user_achievements_delete_own on public.user_achievements;
create policy user_achievements_delete_own on public.user_achievements for delete to authenticated using (user_id=auth.uid());
drop policy if exists xp_transactions_insert_own on public.xp_transactions;
create policy xp_transactions_insert_own on public.xp_transactions for insert to authenticated with check (user_id=auth.uid());
drop policy if exists rewards_select_authenticated on public.rewards;
create policy rewards_select_authenticated on public.rewards for select to authenticated using (true);
drop policy if exists rewards_insert_own on public.rewards;
create policy rewards_insert_own on public.rewards for insert to authenticated with check (creator_id=auth.uid());
drop policy if exists rewards_update_own on public.rewards;
create policy rewards_update_own on public.rewards for update to authenticated using (creator_id=auth.uid()) with check (creator_id=auth.uid());
drop policy if exists rewards_delete_own on public.rewards;
create policy rewards_delete_own on public.rewards for delete to authenticated using (creator_id=auth.uid());
drop policy if exists reward_redemptions_insert_own on public.reward_redemptions;
create policy reward_redemptions_insert_own on public.reward_redemptions for insert to authenticated with check (user_id=auth.uid());
drop policy if exists reward_redemptions_update_own on public.reward_redemptions;
create policy reward_redemptions_update_own on public.reward_redemptions for update to authenticated using (user_id=auth.uid()) with check (user_id=auth.uid());
drop policy if exists challenges_select_authenticated on public.custom_challenges;
create policy challenges_select_authenticated on public.custom_challenges for select to authenticated using (true);
drop policy if exists challenges_insert_own on public.custom_challenges;
create policy challenges_insert_own on public.custom_challenges for insert to authenticated with check (creator_id=auth.uid());
drop policy if exists challenges_update_creator on public.custom_challenges;
create policy challenges_update_creator on public.custom_challenges for update to authenticated using (creator_id=auth.uid()) with check (creator_id=auth.uid());
drop policy if exists challenges_delete_creator on public.custom_challenges;
create policy challenges_delete_creator on public.custom_challenges for delete to authenticated using (creator_id=auth.uid());
drop policy if exists challenge_participants_select_authenticated on public.challenge_participants;
create policy challenge_participants_select_authenticated on public.challenge_participants for select to authenticated using (true);
drop policy if exists challenge_participants_insert_self_or_creator on public.challenge_participants;
create policy challenge_participants_insert_self_or_creator on public.challenge_participants for insert to authenticated with check (user_id=auth.uid() or exists(select 1 from public.custom_challenges c where c.id=challenge_id and c.creator_id=auth.uid()));
drop policy if exists challenge_participants_update_own on public.challenge_participants;
create policy challenge_participants_update_own on public.challenge_participants for update to authenticated using (user_id=auth.uid()) with check (user_id=auth.uid());
drop policy if exists challenge_participants_delete_own on public.challenge_participants;
create policy challenge_participants_delete_own on public.challenge_participants for delete to authenticated using (user_id=auth.uid());
drop policy if exists step_battles_select_authenticated on public.step_battles;
create policy step_battles_select_authenticated on public.step_battles for select to authenticated using (true);
drop policy if exists step_battles_insert_authenticated on public.step_battles;
create policy step_battles_insert_authenticated on public.step_battles for insert to authenticated with check (true);
drop policy if exists step_battles_update_authenticated on public.step_battles;
create policy step_battles_update_authenticated on public.step_battles for update to authenticated using (true) with check (true);
drop policy if exists step_battle_results_select_authenticated on public.step_battle_results;
create policy step_battle_results_select_authenticated on public.step_battle_results for select to authenticated using (true);
drop policy if exists step_battle_results_insert_authenticated on public.step_battle_results;
create policy step_battle_results_insert_authenticated on public.step_battle_results for insert to authenticated with check (true);
drop policy if exists step_battle_results_update_authenticated on public.step_battle_results;
create policy step_battle_results_update_authenticated on public.step_battle_results for update to authenticated using (true) with check (true);

-- Nota: los movimientos XP se insertan desde el cliente con RLS por propietario.
-- Para producción competitiva, el cálculo y concesión de XP debe migrarse a funciones RPC
-- SECURITY DEFINER para impedir que un cliente manipule premios o resultados.
