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


## V22 · Auditoría UX
- Menú de navegación con fondo claro, texto oscuro de alto contraste, botones táctiles y desplazamiento interno.
- Tarjetas de Rutinas, Logros/XP, Recompensas y Step Battle con superficies claras y jerarquía legible.
- Campos y modales con contraste y foco visible.
- Caché PWA actualizada a gymsibs-v22.0.

## V22.1 · Selector de ejercicios en Rutinas
- Al añadir un ejercicio a una rutina, primero se elige el grupo muscular (por ejemplo, Pierna, Hombro o Tríceps) y después aparece un desplegable con los ejercicios activos registrados en el catálogo compartido.
- Se mantienen los campos de series, repeticiones, peso objetivo y descanso.
- El ejercicio se guarda vinculado a su ID real del catálogo (`exercise_id`), no como texto libre.


## V22.2 · Catálogo inicial de logros y recompensas
- Se añade `SUPABASE_GYMSIBS_V22.2_CARGAR_LOGROS_PREMIOS.sql` para cargar 18 logros personales, competitivos y compartidos, y 8 recompensas canjeables.
- El SQL es idempotente y no concede XP inicial ni marca logros como completados.
