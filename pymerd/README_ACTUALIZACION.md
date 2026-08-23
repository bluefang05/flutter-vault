# PYME RD 0.1.0 — estabilización previa a Play Store

Aplicar sobre el proyecto existente. No borra la base de datos.

Cambios:

- Versión pública inicial `0.1.0+1`.
- Android mínimo fijado explícitamente en API 21.
- Migración de base de datos 2 → 3.
- Evita descontar dos veces los insumos de una misma cita.
- Evita consumir dos paquetes para la misma cita.
- Permite seleccionar el tipo de negocio durante la configuración inicial.
- Retira de la interfaz pública los botones de cargar y borrar datos de prueba.
- Actualiza la información visible de versión.

La migración conserva los datos existentes.
