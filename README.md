# GYMSIBS V19.0 · Ara y Andrea

- Solo Ara y Andrea aparecen como perfiles disponibles y participan en los duelos.
- Se ha actualizado el icono de la app con la ilustración conjunta de Ara y Andrea.
- La pantalla de carga usa la nueva ilustración de Neo-City.
- El avatar de Andrea usa la nueva imagen individual.
- Se mantienen los registros históricos de Sergio en Supabase, pero no se muestran ni cuentan en los duelos. Su cuenta no se elimina.
- Se mantienen pasos con fechas anteriores, natación y Pilates (Pilates no puntúa en los duelos).

## Publicación
Sube el contenido de este ZIP a la raíz del repositorio de GitHub y sustituye los archivos existentes. No hace falta ejecutar SQL nuevo.


## V16 · Resumen diario de entrenamiento
- Resumen por fecha con ejercicios, pasos, natación y Pilates.
- Edición de peso, repeticiones y fecha de cada ejercicio.
- Alta rápida de ejercicios en fechas anteriores.
- Estado diferenciando entrenamiento registrado, descanso marcado y día sin registros.


## V17 · Gestión de ejercicios y nueva portada
- Se puede editar el nombre y el grupo de cada ejercicio.
- Se puede eliminar un ejercicio del catálogo mediante archivado (active=false), sin borrar los entrenamientos históricos asociados.
- Los ejercicios archivados dejan de aparecer al elegir un ejercicio para entrenar, pero sus nombres siguen disponibles en el historial.
- Nueva ilustración de Ara y Andrea en la pantalla de carga, el logotipo interno y el icono de la app.
- No requiere cambios en el esquema SQL; la tabla exercises debe permitir UPDATE del campo active.


## V18
- Añadida la categoría **Bíceps** al selector de grupo muscular al crear y editar ejercicios.


## V19 · Nuevo icono de la aplicación
- Sustituido el icono PWA, favicon y acceso directo de iOS por la nueva imagen proporcionada.
- Actualizada la caché del service worker para forzar la descarga del nuevo icono.
- No requiere cambios en Supabase ni ejecución de SQL.


## V20 · Portada de carga y contraste
- Sustituida la imagen de la pantalla de carga por la nueva ilustración de Ara y Andrea.
- Conservado el icono de aplicación actualizado en V19.
- Rediseñadas las tarjetas de puntuación del apartado Duelo con fondos claros, nombres y etiquetas legibles y puntuaciones de alto contraste.
- Reforzado el contraste de los detalles de cada prueba y del historial de duelos.
- Actualizada la caché del service worker a V20.
- Sin cambios en el esquema de Supabase; no requiere ejecutar SQL.
