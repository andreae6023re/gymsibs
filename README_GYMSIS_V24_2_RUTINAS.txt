GYMSIS V24.2 · FIX DE GUARDADO DE RUTINAS Y AUDITORÍA

CAMBIO PRINCIPAL
- Al guardar o finalizar una rutina, cada serie con peso y repeticiones mayores que cero se sincroniza también con la tabla workouts.
- Así aparece en Mi progreso, calendario, marcas personales y duelo, además de conservarse en workout_sessions / workout_session_sets.
- Cada serie se vincula mediante routine_session_set_id y un índice único, de modo que reintentar el guardado no duplica entrenamientos.
- Las sesiones guardadas ahora aparecen en un historial visible dentro de Rutinas, con fecha, estado, ejercicios y series con datos.
- La migración recupera automáticamente las series de sesiones antiguas que sí estuvieran guardadas en Supabase, incluyendo los intentos anteriores, y las incorpora al historial general sin duplicarlas.
- Las sesiones incompletas se pueden volver a abrir para continuar o revisar.
- El inicio de rutina crea todas las series en una única operación; si falla, elimina la sesión vacía en vez de abrir una sesión incompleta.
- El guardado muestra errores concretos y no cierra la pantalla si falla.
- Se evita el doble clic de guardar y se usa fecha local para evitar el desfase UTC de día.

INSTALACIÓN
1. Ejecutar SUPABASE_GYMSIS_V24_2_RUTINAS.sql en Supabase SQL Editor.
2. Sustituir los archivos del repositorio por los de este ZIP y hacer commit.
3. Cerrar completamente la PWA y volver a abrirla tras publicar.

AUDITORÍA
Se ha revisado estáticamente el flujo de autenticación, carga principal, entrenamientos manuales, rutinas/sesiones, series, logros, XP, pasos, natación, navegación, calendario, duelo, service worker y SQL incluido. Se han corregido los fallos detectados en el guardado de rutinas y fechas locales. No se ha podido ejecutar una prueba end-to-end contra el proyecto Supabase de producción; las políticas RLS y el esquema real deben validarse al ejecutar la migración.

IMPORTANTE SOBRE LOS TRES INTENTOS ANTERIORES
Las sesiones/series que sí llegaran a guardarse en workout_sessions y workout_session_sets aparecerán ahora en el historial. Los valores que nunca llegaron a Supabase no pueden recuperarse desde el navegador ni reconstruirse automáticamente.
