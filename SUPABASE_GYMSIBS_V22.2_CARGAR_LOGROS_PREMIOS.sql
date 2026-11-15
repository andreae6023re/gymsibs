-- GYMSIBS V22.2 · Catálogo inicial de logros y recompensas
-- Ejecutar UNA VEZ en Supabase > SQL Editor. Es idempotente: no duplica títulos ya cargados.
-- Crea el catálogo para Ara y Andrea; no concede XP ni marca logros como completados.

DO $$
DECLARE
  v_creator uuid;
BEGIN
  -- Se usa un perfil existente como creador del catálogo compartido.
  SELECT id INTO v_creator
  FROM public.profiles
  WHERE lower(name) LIKE '%andrea%' OR lower(name) LIKE '%ara%'
  ORDER BY CASE WHEN lower(name) LIKE '%andrea%' THEN 0 ELSE 1 END, created_at
  LIMIT 1;

  IF v_creator IS NULL THEN
    SELECT id INTO v_creator FROM public.profiles ORDER BY created_at LIMIT 1;
  END IF;

  IF v_creator IS NULL THEN
    RAISE EXCEPTION 'No hay perfiles en public.profiles. Inicia sesión en GYMSIBS para crear los perfiles y vuelve a ejecutar este SQL.';
  END IF;

  -- LOGROS PERSONALES: constancia, progreso, variedad y marcas.
  INSERT INTO public.achievements
    (creator_id,title,description,category,goal_type,goal_value,xp_reward,participant_scope,is_active)
  SELECT v_creator, x.title,x.description,x.category,'manual',x.goal_value,x.xp,'both',true
  FROM (VALUES
    ('Primera sesión','Completa tu primer entrenamiento.','personal',1,20),
    ('Constancia inicial','Completa 3 entrenamientos.','personal',3,30),
    ('Rutina establecida','Completa 10 entrenamientos.','personal',10,60),
    ('Imparable','Completa 25 entrenamientos.','personal',25,120),
    ('Mes en movimiento','Entrena en 8 días distintos durante un mes.','personal',8,70),
    ('Exploradora','Prueba 10 ejercicios diferentes.','personal',10,50),
    ('Progreso real','Mejora tu marca en un ejercicio.','personal',1,40),
    ('Primer récord','Registra una nueva mejor marca personal.','personal',1,50),
    ('Versátil','Entrena 3 grupos musculares diferentes en una semana.','personal',3,40),
    ('Equilibrio','Completa 3 sesiones de movilidad o Pilates.','personal',3,40),
    -- LOGROS COMPETITIVOS
    ('Primera victoria','Gana tu primer duelo semanal.','competitive',1,30),
    ('Racha ganadora','Gana 3 duelos semanales.','competitive',3,75),
    ('Reina del duelo','Gana 10 duelos semanales.','competitive',10,150),
    ('Comeback','Gana un duelo después de haber perdido el anterior.','competitive',1,50),
    -- LOGROS COMPARTIDOS
    ('Equipo en marcha','Entre las dos completáis 10 entrenamientos.','shared',10,40),
    ('A por todas','Entre las dos completáis 25 entrenamientos.','shared',25,80),
    ('Step Team','Las dos alcanzáis el objetivo semanal de pasos.','shared',1,30),
    ('Reto compartido','Completad juntas vuestro primer reto personalizado.','shared',1,40)
  ) AS x(title,description,category,goal_value,xp)
  WHERE NOT EXISTS (
    SELECT 1 FROM public.achievements a
    WHERE a.creator_id=v_creator AND lower(a.title)=lower(x.title)
  );

  -- Inicializa el progreso a cero para los perfiles Ara y Andrea, sin tocar logros previos.
  INSERT INTO public.user_achievements(achievement_id,user_id,progress)
  SELECT a.id,p.id,0
  FROM public.achievements a
  CROSS JOIN public.profiles p
  WHERE a.creator_id=v_creator
    AND (lower(p.name) LIKE '%andrea%' OR lower(p.name) LIKE '%ara%')
    AND a.participant_scope='both'
    AND NOT EXISTS (
      SELECT 1 FROM public.user_achievements ua
      WHERE ua.achievement_id=a.id AND ua.user_id=p.id
    );

  -- PREMIOS CANJEABLES. Los costes son orientativos y se descuentan al solicitar el canje.
  INSERT INTO public.rewards(creator_id,title,description,xp_cost,is_active)
  SELECT v_creator,x.title,x.description,x.cost,true
  FROM (VALUES
    ('Elegir la cena','La ganadora elige la cena de una noche.',100),
    ('Desayuno especial','Desayuno preparado o invitado por la otra.',150),
    ('Tarde de capricho','Una tarde para hacer un plan elegido por ti.',250),
    ('Masaje de recuperación','Un masaje relajante después de entrenar.',300),
    ('Plan de fin de semana','Elegir una actividad o plan para el fin de semana.',400),
    ('Equipamiento fitness','Aportación para comprar un accesorio deportivo.',500),
    ('Día sin tareas','La otra persona se encarga de una tarea acordada.',350),
    ('Premio sorpresa','La otra persona prepara una sorpresa dentro del presupuesto acordado.',600)
  ) AS x(title,description,cost)
  WHERE NOT EXISTS (
    SELECT 1 FROM public.rewards r
    WHERE r.creator_id=v_creator AND lower(r.title)=lower(x.title)
  );
END $$;

-- Resumen para verificar qué ha quedado cargado.
SELECT 'LOGROS' AS tipo, count(*) AS total
FROM public.achievements
WHERE title IN ('Primera sesión','Constancia inicial','Rutina establecida','Imparable','Mes en movimiento','Exploradora','Progreso real','Primer récord','Versátil','Equilibrio','Primera victoria','Racha ganadora','Reina del duelo','Comeback','Equipo en marcha','A por todas','Step Team','Reto compartido')
UNION ALL
SELECT 'PREMIOS', count(*)
FROM public.rewards
WHERE title IN ('Elegir la cena','Desayuno especial','Tarde de capricho','Masaje de recuperación','Plan de fin de semana','Equipamiento fitness','Día sin tareas','Premio sorpresa');
