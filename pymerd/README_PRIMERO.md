# PYME RD 0.2.0 — actualización sobre la versión que ya corre

Este ZIP debe extraerse encima del proyecto `pymerd` existente. La migración de SQLite conserva clientes, citas, servicios, cobros, gastos y caja de la versión 0.1.0.

## Aplicación desde PowerShell

Dentro de:

```powershell
C:\Users\manue\OneDrive\Desktop\proyectos\flutter\pymerd
```

ejecuta:

```powershell
Expand-Archive "$env:USERPROFILE\Downloads\PYMERD_0.2.0_actualizacion_flutter.zip" -DestinationPath . -Force
Set-ExecutionPolicy -Scope Process Bypass
.\ACTUALIZAR_PYMERD_0_2_0.ps1
flutter run --release
```

## Añadido en 0.2.0

- Inventario de insumos y productos.
- Existencia mínima y alertas de nivel bajo.
- Compras que aumentan inventario y registran el gasto.
- Ajustes por conteo, pérdida, daño o uso interno.
- Vencimiento de productos.
- Proveedores, WhatsApp, dirección y notas.
- Historial de precios y costo efectivo incluyendo entrega.
- Insumos vinculados a cada servicio.
- Descuento automático de insumos al completar una cita.
- Paquetes de sesiones, pagos, saldos y vencimientos.
- Uso de una sesión directamente desde la cita.
- Consentimientos separados para servicio, fotos y promoción.
- Fotografías locales de antes, después y seguimiento.
- Excel ampliado con inventario, proveedores, paquetes y consentimientos.
- Respaldo ZIP versión 2 compatible con respaldos anteriores.
- Canal Android para guardar, abrir y seleccionar imágenes restaurado.

## Límites conscientes

- Las fotografías se guardan en SQLite para esta etapa de prueba y tienen un límite de 8 MB cada una.
- No hay cámara integrada todavía; se selecciona una imagen del dispositivo.
- No hay facturación electrónica oficial ni conexión con DGII.
- La publicidad sigue siendo una franja visual de prueba para conservar Android API 21.
- La firma `release` continúa usando temporalmente la firma de depuración.
