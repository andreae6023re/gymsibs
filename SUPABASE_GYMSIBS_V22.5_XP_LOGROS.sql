-- GYMSIBS V22.5 · XP por ejercicio, rutinas y logros automáticos
-- Ejecutar UNA VEZ en Supabase > SQL Editor antes de publicar los archivos.
-- Idempotente: award_key evita conceder dos veces el mismo premio.

ALTER TABLE public.xp_transactions ADD COLUMN IF NOT EXISTS award_key text;
CREATE UNIQUE INDEX IF NOT EXISTS ux_xp_transactions_award_key
  ON public.xp_transactions(award_key) WHERE award_key IS NOT NULL;

-- El catálogo de logros debe poder leerse desde ambos perfiles.
ALTER TABLE public.achievements ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS achievements_select_authenticated ON public.achievements;
CREATE POLICY achievements_select_authenticated ON public.achievements
  FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS achievements_insert_own ON public.achievements;
CREATE POLICY achievements_insert_own ON public.achievements
  FOR INSERT TO authenticated WITH CHECK (creator_id=auth.uid());
DROP POLICY IF EXISTS achievements_update_own ON public.achievements;
CREATE POLICY achievements_update_own ON public.achievements
  FOR UPDATE TO authenticated USING (creator_id=auth.uid()) WITH CHECK (creator_id=auth.uid());

-- En el duelo se pueden conceder premios a cualquiera de los dos perfiles.
-- La política queda limitada a Ara y Andrea, no a otros perfiles del proyecto.
DROP POLICY IF EXISTS xp_transactions_insert_own ON public.xp_transactions;
DROP POLICY IF EXISTS xp_transactions_insert_shared_players ON public.xp_transactions;
CREATE POLICY xp_transactions_insert_shared_players ON public.xp_transactions
  FOR INSERT TO authenticated
  WITH CHECK (
    user_id=auth.uid()
    OR (
      EXISTS (SELECT 1 FROM public.profiles caller WHERE caller.id=auth.uid() AND lower(caller.name) IN ('ara','andrea'))
      AND EXISTS (SELECT 1 FROM public.profiles target WHERE target.id=user_id AND lower(target.name) IN ('ara','andrea'))
    )
  );

ALTER TABLE public.xp_transactions DROP CONSTRAINT IF EXISTS xp_transactions_transaction_type_check;
ALTER TABLE public.xp_transactions ADD CONSTRAINT xp_transactions_transaction_type_check
  CHECK (transaction_type IN ('achievement','duel_win','step_battle_win','step_goal_bonus','step_tie','reward_redemption','admin_adjustment','routine_complete','daily_steps_goal'));

-- La recompensa estándar de cualquier logro pasa a ser 5 XP.
UPDATE public.achievements SET xp_reward=5 WHERE xp_reward IS DISTINCT FROM 5;

DO $$
DECLARE v_creator uuid;
BEGIN
  SELECT id INTO v_creator FROM public.profiles
  WHERE lower(name) LIKE '%andrea%' OR lower(name) LIKE '%ara%'
  ORDER BY CASE WHEN lower(name) LIKE '%andrea%' THEN 0 ELSE 1 END, created_at LIMIT 1;
  IF v_creator IS NULL THEN SELECT id INTO v_creator FROM public.profiles ORDER BY created_at LIMIT 1; END IF;
  IF v_creator IS NULL THEN RAISE EXCEPTION 'No hay perfiles en public.profiles.'; END IF;

  INSERT INTO public.achievements
    (creator_id,title,description,category,goal_type,goal_value,xp_reward,participant_scope,is_active)
  SELECT v_creator,x.title,x.description,x.category,'auto',x.goal,5,'both',true
  FROM (VALUES
    ('KACHOW!','Registra tu primer entrenamiento.','personal',1),
    ('MACHINE','Consigue 5 registros de entrenamiento.','personal',5),
    ('A POR EL SIGUIENTE','Consigue 10 registros de entrenamiento.','personal',10),
    ('MODO BESTIA','Consigue 20 registros de entrenamiento.','personal',20),
    ('CENTURION','Consigue 25 registros de entrenamiento.','personal',25),
    ('NO HAY QUIEN LA PARE','Gana al menos un ejercicio en una semana.','competitive',1),
    ('ARA-POCALYPSE','Gana 5 ejercicios en una misma semana.','competitive',5),
    ('REINA DEL HIERRO','Gana 10 ejercicios en una misma semana.','competitive',10),
    ('ANDREA POWER','Gana al menos un ejercicio en una semana.','competitive',1),
    ('ANDREA SUPREMA','Gana 5 ejercicios en una misma semana.','competitive',5),
    ('REINA DEL DUELO','Gana 10 ejercicios en una misma semana.','competitive',10),
    ('COMEBACK KING','Consigue un empate en un ejercicio.','competitive',1),
    ('TODO CONTROLADO','Prueba 5 ejercicios diferentes.','personal',5),
    ('50 CLUB','Levanta 50 kg o más en un ejercicio.','personal',50),
    ('100 CLUB','Levanta 100 kg o más en un ejercicio.','personal',100),
    ('MODO TITÁN','Levanta 150 kg o más en un ejercicio.','personal',150),
    ('CONSTANCIA','Entrena en 3 días diferentes.','personal',3),
    ('SIN FRENOS','Entrena en 7 días diferentes.','personal',7),
    ('PRIMER RÉCORD','Supera una marca personal anterior.','personal',1),
    ('Primera rutina','Finaliza tu primera rutina.','personal',1),
    ('Cinco rutinas','Finaliza 5 rutinas.','personal',5),
    ('Diez rutinas','Finaliza 10 rutinas.','personal',10),
    ('Veinticinco rutinas','Finaliza 25 rutinas.','personal',25),
    ('Semana de tres rutinas','Finaliza 3 rutinas en una misma semana.','personal',3),
    ('Catálogo explorado','Prueba 15 ejercicios diferentes.','personal',15),
    ('Constancia de cuatro semanas','Entrena en 4 semanas diferentes consecutivas.','personal',4),
    ('Mes constante','Entrena en 12 días diferentes de un mismo mes.','personal',12),
    ('Fuerza 75','Levanta 75 kg o más en un ejercicio.','personal',75),
    ('Fuerza 125','Levanta 125 kg o más en un ejercicio.','personal',125),
    ('Fuerza 200','Levanta 200 kg o más en un ejercicio.','personal',200),
    ('Movilidad consciente','Completa 5 sesiones de movilidad o Pilates.','personal',5),
    ('Primera brazada','Registra tu primera sesión de natación.','personal',1),
    ('Dúo imparable','Entre las dos acumuláis 50 registros de entrenamiento.','shared',50),
    ('Semana dominante','Gana más ejercicios que tu rival en una semana.','competitive',1),
    ('Empate técnico','Empata al menos un ejercicio en un duelo.','competitive',1)
  ) AS x(title,description,category,goal)
  WHERE NOT EXISTS (SELECT 1 FROM public.achievements a WHERE a.creator_id=v_creator AND lower(a.title)=lower(x.title));

  INSERT INTO public.user_achievements(achievement_id,user_id,progress)
  SELECT a.id,p.id,0 FROM public.achievements a CROSS JOIN public.profiles p
  WHERE a.creator_id=v_creator AND a.participant_scope='both'
    AND NOT EXISTS (SELECT 1 FROM public.user_achievements ua WHERE ua.achievement_id=a.id AND ua.user_id=p.id);
END $$;

-- Cualquier logro que ya estuviera marcado como conseguido recibe 5 XP una sola vez.
UPDATE public.user_achievements ua
SET completed_at=COALESCE(ua.completed_at,now())
FROM public.achievements a
WHERE a.id=ua.achievement_id AND ua.progress>=a.goal_value AND ua.completed_at IS NULL;

INSERT INTO public.xp_transactions(user_id,amount,transaction_type,description,reference_id,award_key)
SELECT ua.user_id,5,'achievement','Recompensa retroactiva: '||a.title,ua.achievement_id,
       'achievement:'||ua.user_id::text||':'||ua.achievement_id::text
FROM public.user_achievements ua
JOIN public.achievements a ON a.id=ua.achievement_id
WHERE ua.completed_at IS NOT NULL
ON CONFLICT (award_key) WHERE award_key IS NOT NULL DO NOTHING;

SELECT 'LOGROS ACTIVOS' AS comprobacion,count(*) AS total FROM public.achievements WHERE is_active
UNION ALL
SELECT 'RECOMPENSAS DE LOGROS',count(*) FROM public.xp_transactions WHERE transaction_type='achievement';
