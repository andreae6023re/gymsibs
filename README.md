# GYMSIBS V10.4 — COMPARATIVA REPARADA

La comparativa semanal se calcula por ID de usuario y ejercicio, usando el mayor peso guardado en Supabase durante la semana actual.

Tras registrar un entrenamiento, la app vuelve a leer los entrenamientos compartidos desde Supabase antes de mostrar el resultado, evitando comparativas con datos locales desactualizados.

No cambia el esquema de Supabase.
