# GYMSIBS V22.6 – XP por ejercicio, rutinas y logros

## Cambios
- Duelo: 20 XP por cada ejercicio ganado y 10 XP para cada participante por cada ejercicio empatado. Los premios de la semana cerrada se calculan automáticamente al iniciar sesión; el botón del duelo permite reintentar la concesión si se han añadido registros tardíos. Los ejercicios sin datos comparables no conceden XP.
- Rutinas: 10 XP al finalizar una sesión de rutina; guardar y salir no concede XP.
- Logros: catálogo ampliado; cada logro desbloqueado concede 5 XP.
- Sincronización automática de progreso y desbloqueo de logros con el historial de cada perfil.
- Recompensas idempotentes mediante `award_key`, para evitar cobros duplicados al repetir acciones o recargar la app.
- Se conservan los registros y el historial existentes.

## Actualización
1. En Supabase > SQL Editor, ejecutar una vez `SUPABASE_GYMSIBS_V22.5_XP_LOGROS.sql`.
2. Sustituir en GitHub los archivos `index.html` y `sw.js` por los de este ZIP.
3. Añadir también `SUPABASE_GYMSIBS_V22.5_XP_LOGROS.sql` al repositorio (opcional, como copia del script ejecutado).
4. Hacer commit y recargar la PWA. Si aparece una versión antigua, cerrar la app y abrirla de nuevo.

No se borran ni modifican entrenamientos, rutinas, series ni perfiles. El SQL añade una clave de idempotencia y el nuevo tipo de transacción `routine_complete`.

## Nota sobre logros retroactivos
El SQL concede 5 XP a todos los logros que ya estén marcados como completados en `user_achievements`. Al iniciar sesión, la app calcula además los logros históricos verificables con los registros disponibles para ese perfil y concede sus 5 XP una sola vez. Cada persona debe iniciar sesión al menos una vez para que se sincronicen sus logros calculados a partir de su historial privado de rutinas.


## XP diario por pasos (V22.6)
- Cada perfil recibe 5 XP por cada día con más de 8.000 pasos (8.001 o más).
- El premio se concede una sola vez por usuario y fecha mediante `award_key`.
- Al iniciar sesión se recuperan también los días históricos ya registrados que superen el umbral.
- Al guardar o actualizar los pasos de un día, se concede el premio si el valor supera 8.000.
- El SQL V22.5 actualiza la restricción de `transaction_type` para admitir `daily_steps_goal`.
