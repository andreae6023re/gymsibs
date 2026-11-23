-- GYMSIBS V13.7 - permisos para editar ejercicios compartidos
-- Ejecutar solo si al editar un ejercicio Supabase devuelve un error de permisos/RLS.
alter table public.exercises enable row level security;
drop policy if exists "exercises_update_authenticated" on public.exercises;
create policy "exercises_update_authenticated" on public.exercises
for update to authenticated
using (true)
with check (true);
