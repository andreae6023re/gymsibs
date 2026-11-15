# GYMSIBS V21.1

Incluye la base V20, icono actualizado de Ara y Andrea, y módulos nuevos conectados a las tablas V21 de Supabase: Rutinas (plantillas, sesiones y series), Logros personalizados, XP, catálogo y solicitud de recompensas, y Step Battle semanal.

## Instalación
1. Sustituye los archivos de la raíz del repositorio GitHub por el contenido de este ZIP.
2. No vuelvas a ejecutar `SUPABASE_GYMSIBS_V21.sql`: ya lo ejecutaste en tu proyecto.
3. Despliega y fuerza la actualización de la PWA (cerrar la app y volver a abrir).

## Notas
- Los registros históricos de `workouts`, `steps`, natación y Pilates se conservan.
- Rutinas y sesiones son individuales.
- Los pasos se siguen registrando en la tabla `steps`, admitiendo fechas pasadas y no futuras.
- Step Battle permite fijar objetivo y cerrar semana para calcular premios. Cerrar una semana es una acción manual e irreversible desde la interfaz.
- El saldo XP se calcula como suma de movimientos; los canjes descuentan XP mediante movimientos negativos.
- La concesión de XP y el cierre de Step Battle se realizan desde el cliente; para una competición resistente a manipulación conviene migrar esos cálculos a RPC seguras.
