GYMSIS V24.1 · AUDITORÍA Y CORRECCIONES

CORRECCIONES INCLUIDAS
1. HOME / DUELO: la tarjeta de la home ahora calcula los resultados con previousWeekRange(), igual que la pantalla de Duelo. Antes la home usaba weekRange() (semana en curso) y la pantalla de Duelo usaba previousWeekRange() (última semana cerrada), por eso podían aparecer marcadores distintos, por ejemplo 0-1 frente a 2-2.
2. LOGROS PERSONALES: los logros clásicos de duelo ahora se calculan solo para el usuario conectado. Antes la pantalla mostraba insignias de Ara y de Andrea a ambas cuentas, con el estado de desbloqueo basado en las victorias de cada persona; por eso Ara podía ver logros de Andrea como desbloqueados.
3. MARCAS PERSONALES: los logros de 40/50/100/150 kg ahora se calculan con los registros del usuario conectado, no con el máximo global de las dos personas.
4. NAVEGACIÓN: las rutas antiguas 'achievements' y nuevas 'v21achievements' abren la misma pantalla de Insignias y XP.
5. CACHÉ: nueva versión de caché PWA para forzar que se descargue esta corrección.

AUDITORÍA ESTÁTICA REALIZADA
- Autenticación y selección de perfil: Ara y Andrea se identifican por el ID de Ara y el nombre del perfil de Supabase; Sergio se bloquea explícitamente.
- Entrenamientos y marcas: los registros se cargan desde workouts y se ordenan/filtran por fecha. El duelo compara ejercicios solo si ambas participantes tienen peso positivo registrado.
- Duelo: el detalle usa la última semana cerrada; pasos y natación también forman parte de las pruebas del duelo.
- Logros y XP: el saldo XP y las insignias de base de datos se filtran por user_id del usuario conectado. Los logros clásicos estaban mezclando estados de ambas personas; corregido.
- Rutinas: las rutinas se filtran por user_id. Las sesiones completadas registran XP con una clave idempotente basada en la sesión.
- Pasos: el premio de 5 XP se concede al superar 8.000 pasos, con clave por usuario y fecha.
- Navegación: la home y el menú abren ahora la misma pantalla de logros.

LIMITACIONES DE ESTA AUDITORÍA
- Es una auditoría estática del ZIP v24 y de las consultas SQL incluidas; no se ha conectado a la instancia real de Supabase ni se han podido inspeccionar los registros privados en producción.
- No se han modificado filas de Supabase ni se ha ejecutado SQL. Si existen filas de user_achievements asignadas al user_id equivocado en la base de datos, esta versión evita mostrarlas en la cuenta incorrecta, pero no cambia esos datos persistidos.
- Algunas funciones dependen de las políticas RLS y de que las tablas de Supabase tengan el esquema esperado; no es posible certificar su funcionamiento en producción sin ejecutar pruebas con ambas cuentas.

INSTALACIÓN
Sustituir los archivos del repositorio por el contenido del ZIP, publicar y cerrar completamente la PWA antes de volver a abrirla. No requiere SQL.
