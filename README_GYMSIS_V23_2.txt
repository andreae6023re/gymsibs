GymSis v23.2 – Corrección del apartado Duelo

Cambios:
- Fechas ISO calculadas con fecha local (no UTC), para evitar que en España el lunes se convierta en domingo y desplace el rango semanal.
- Carga paginada de Supabase para no quedarse en el límite habitual de 1.000 filas.
- Al abrir Duelo se vuelven a consultar los datos de Supabase, para reflejar los últimos pesos registrados por ambas participantes.
- Se muestran todos los ejercicios que tengan al menos un registro en la semana, incluso si uno de los perfiles no ha registrado todavía ese ejercicio.
- Los ejercicios archivados después de entrenarlos siguen apareciendo en el duelo de su semana.
- Si falta el registro de una participante, se indica «Falta un registro» y no se adjudica una victoria incorrecta.
- Actualización de caché PWA a gymsis-v23-2.

No requiere cambios SQL.

Actualización: sustituir los archivos del repositorio por los de este ZIP y publicar en GitHub Pages. Después cerrar completamente la PWA y abrirla de nuevo.
