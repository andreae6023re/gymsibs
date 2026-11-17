-- GymSis · XP y recompensas idempotentes
-- Ejecutar una sola vez en Supabase SQL Editor antes de publicar el ZIP.
-- No modifica ni borra entrenamientos, rutinas ni logros existentes.

ALTER TABLE public.xp_transactions ADD COLUMN IF NOT EXISTS award_key text;
CREATE UNIQUE INDEX IF NOT EXISTS ux_xp_transactions_award_key
  ON public.xp_transactions(award_key) WHERE award_key IS NOT NULL;

ALTER TABLE public.xp_transactions DROP CONSTRAINT IF EXISTS xp_transactions_transaction_type_check;
ALTER TABLE public.xp_transactions ADD CONSTRAINT xp_transactions_transaction_type_check
  CHECK (transaction_type IN ('achievement','duel_win','step_battle_win','step_goal_bonus','step_tie','reward_redemption','admin_adjustment','routine_complete'));

-- Cada usuario puede insertar sus propios premios. La app solo concede XP a la cuenta activa
-- para rutinas/pasos; los premios de duelo se insertan para ambas participantes desde la app.
DROP POLICY IF EXISTS xp_transactions_insert_own ON public.xp_transactions;
DROP POLICY IF EXISTS xp_transactions_insert_shared_players ON public.xp_transactions;
CREATE POLICY xp_transactions_insert_shared_players ON public.xp_transactions
  FOR INSERT TO authenticated
  WITH CHECK (
    user_id = auth.uid()
    OR (
      EXISTS (SELECT 1 FROM public.profiles caller WHERE caller.id=auth.uid() AND lower(caller.name) IN ('ara','andrea'))
      AND EXISTS (SELECT 1 FROM public.profiles target WHERE target.id=user_id AND lower(target.name) IN ('ara','andrea'))
    )
  );

-- El catálogo es visible para ambas participantes.
ALTER TABLE public.achievements ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS achievements_select_authenticated ON public.achievements;
CREATE POLICY achievements_select_authenticated ON public.achievements
  FOR SELECT TO authenticated USING (true);
