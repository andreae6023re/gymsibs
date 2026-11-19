# GymSis

Aplicación web instalable (PWA) para registrar entrenamientos, rutinas, ejercicios, pasos, natación, pilates, progreso, logros y duelo entre Ara y Andrea.

## Archivos principales

- `index.html`: aplicación y lógica de interfaz.
- `manifest.webmanifest`: configuración de la PWA.
- `service-worker.js`: caché offline y actualización de la aplicación.
- `favicon-32.png`, `icon-192.png`, `icon-512.png`, `apple-touch-icon.png`: iconos utilizados por navegador e instalación.

## Documentación y SQL

Los historiales de versiones y las migraciones SQL se conservan en `docs/`:
- `docs/releases/`: notas de versiones.
- `docs/supabase/`: scripts SQL históricos y de configuración.

Antes de ejecutar una migración, comprueba su versión y las instrucciones correspondientes. No ejecutes scripts antiguos como si fueran una actualización nueva.

## Publicación

La aplicación se sirve desde la raíz del repositorio. Mantén en la raíz `index.html`, `manifest.webmanifest`, `service-worker.js` y los cuatro iconos. El service worker precarga únicamente estos recursos, evitando fallos de instalación por referencias a archivos antiguos.
