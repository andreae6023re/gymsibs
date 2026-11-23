# GymSis · actualización XP y marca de app

## Cambios incluidos
- Nombre de la aplicación actualizado a GymSis (título, manifest y caché PWA).
- Duelo semanal: 20 XP por cada ejercicio ganado; 10 XP para cada participante en empate. No premia pasos ni natación como si fueran ejercicios.
- Rutina: 10 XP al finalizar una sesión, una sola vez por sesión.
- Pasos: 5 XP por día al registrar más de 8.000 pasos (8.000 exactos no cuentan), una sola vez por usuario y fecha.
- Identificadores de premio (`award_key`) para evitar duplicados.

## Instalación
1. En Supabase > SQL Editor, ejecutar `SUPABASE_GYMSIS_XP.sql` una sola vez.
2. Sustituir en GitHub los archivos del ZIP, conservando la estructura de raíz del repositorio.
3. Hacer commit y recargar GymSis. Si está instalada como PWA, cerrar y volver a abrir para actualizar la caché.

## Importante
- Los premios por rutinas y pasos empiezan a contar desde esta versión; no se recupera actividad anterior.
- El duelo concede XP al procesar el botón «CONCEDER PREMIO» en la pantalla Duelo. El índice único evita duplicar cada ejercicio/semana/participante.
- La migración no borra ni modifica los registros históricos.
- Los logros existentes se mantienen. La recuperación retroactiva de logros históricos y el cálculo automático de nuevos objetivos requieren una migración específica adicional; no se altera el progreso histórico en este paquete.


## GymSis v24.2 · Guardado de rutinas

Ejecuta `SUPABASE_GYMSIS_V24_2_RUTINAS.sql` en Supabase antes de publicar. Esta migración añade el vínculo único entre cada serie de rutina y el historial general para que las series se guarden una sola vez, y recupera series antiguas que sí estuvieran persistidas en Supabase. Consulta `README_GYMSIS_V24_2_RUTINAS.txt` para los detalles.
