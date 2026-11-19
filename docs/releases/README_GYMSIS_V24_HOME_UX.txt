GYMSIS V24 · REDISEÑO UX DE HOME

Cambios:
- Nueva home tipo dashboard, manteniendo la estética comic/pop de GymSis y su paleta de colores.
- Jerarquía más clara: bienvenida y XP, acción principal para empezar a entrenar, resumen semanal, duelo, accesos rápidos, actividad reciente y movimiento semanal.
- Accesos rápidos organizados en tarjetas grandes y fáciles de pulsar desde móvil.
- El acceso «Logros y XP» de la home abre exactamente la misma pantalla `v21achievements` que el menú lateral. Se elimina así la discrepancia con la pantalla antigua de logros.
- Acceso directo a rutinas, progreso, calendario, pasos, natación, pilates y catálogo de ejercicios.
- Se actualiza la versión de caché del service worker para forzar la descarga de la nueva home.

Instalación:
1. Sustituir los archivos del repositorio por los incluidos en este ZIP, manteniendo la estructura de raíz.
2. Hacer commit y esperar a que GitHub Pages publique los cambios.
3. Cerrar completamente la PWA y volver a abrirla. Si sigue mostrando la versión anterior, recargar la web una vez.

No requiere cambios en Supabase ni ejecutar SQL.
