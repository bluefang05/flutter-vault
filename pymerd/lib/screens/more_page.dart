import 'package:flutter/material.dart';

import '../app_repository.dart';
import '../services/export_service.dart';
import '../services/native_file_service.dart';
import '../utils.dart';
import '../widgets/common.dart';
import 'cash_page.dart';
import 'inventory_page.dart';
import 'packages_page.dart';
import 'reports_page.dart';
import 'sales_page.dart';
import 'services_page.dart';
import 'suppliers_page.dart';

class MorePage extends StatefulWidget {
  final AppRepository repository;

  const MorePage({super.key, required this.repository});

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  bool _busy = false;

  Future<void> _exportExcel() async {
    setState(() => _busy = true);
    try {
      final bytes = await ExportService(widget.repository).buildExcel();
      final stamp = DateTime.now().toIso8601String().substring(0, 10);
      final ok = await NativeFileService.saveBytes(
        fileName: 'PYMERD_$stamp.xlsx',
        mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        bytes: bytes,
      );
      _message(ok ? 'Excel guardado correctamente.' : 'No se guardó el archivo.');
    } catch (error) {
      _message('No se pudo crear el Excel: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _backup() async {
    setState(() => _busy = true);
    try {
      final bytes = await ExportService(widget.repository).buildBackupZip();
      final stamp = DateTime.now().toIso8601String().replaceAll(':', '-').substring(0, 19);
      final ok = await NativeFileService.saveBytes(
        fileName: 'PYMERD_respaldo_$stamp.zip',
        mimeType: 'application/zip',
        bytes: bytes,
      );
      _message(ok ? 'Respaldo ZIP guardado.' : 'No se guardó el respaldo.');
    } catch (error) {
      _message('No se pudo crear el respaldo: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    final confirmed = await confirmAction(
      context,
      title: 'Restaurar respaldo',
      message: 'La información actual será reemplazada por la contenida en el respaldo seleccionado.',
      confirmLabel: 'Seleccionar respaldo',
    );
    if (!confirmed) return;
    setState(() => _busy = true);
    try {
      final bytes = await NativeFileService.pickBytes();
      if (bytes == null) return;
      await ExportService(widget.repository).restoreBackupZip(bytes);
      _message('Respaldo restaurado correctamente.');
    } catch (error) {
      _message('No se pudo restaurar: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _businessSettings() async {
    final settings = await widget.repository.getAllSettings();
    if (!mounted) return;
    final business = TextEditingController(text: settings['business_name'] ?? '');
    final owner = TextEditingController(text: settings['owner_name'] ?? '');
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Datos del negocio'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: business, decoration: const InputDecoration(labelText: 'Nombre del negocio')),
              const SizedBox(height: 10),
              TextField(controller: owner, decoration: const InputDecoration(labelText: 'Propietario')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, business.text.trim().isNotEmpty), child: const Text('Guardar')),
        ],
      ),
    );
    if (saved == true) {
      await widget.repository.setSetting('business_name', business.text.trim(), refresh: false);
      await widget.repository.setSetting('owner_name', owner.text.trim());
      setState(() {});
    }
    business.dispose();
    owner.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            children: [
              Text('Más', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              FutureBuilder<Map<String, String>>(
                future: widget.repository.getAllSettings(),
                builder: (context, snapshot) {
                  final settings = snapshot.data ?? const <String, String>{};
                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.storefront)),
                      title: Text(settings['business_name'] ?? 'Mi negocio', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(settings['business_type'] ?? 'Estética y masajes'),
                      trailing: const Icon(Icons.edit_outlined),
                      onTap: _businessSettings,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _SectionTitle('Administración'),
              Card(
                child: Column(
                  children: [
                    _MenuTile(
                      icon: Icons.receipt_long_outlined,
                      title: 'Ventas y recibos',
                      subtitle: 'Detalle de artículos, pagos, saldos y recibos PDF.',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SalesHistoryPage(repository: widget.repository))),
                    ),
                    const Divider(height: 1),
                    _MenuTile(
                      icon: Icons.spa_outlined,
                      title: 'Servicios y precios',
                      subtitle: 'Duración, precio, costo y servicio a domicilio.',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ServicesPage(repository: widget.repository))),
                    ),
                    const Divider(height: 1),
                    _MenuTile(
                      icon: Icons.inventory_2_outlined,
                      title: 'Inventario e insumos',
                      subtitle: 'Existencias, compras, vencimientos y consumo por servicio.',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => InventoryPage(repository: widget.repository))),
                    ),
                    const Divider(height: 1),
                    _MenuTile(
                      icon: Icons.local_shipping_outlined,
                      title: 'Proveedores y precios',
                      subtitle: 'Contactos, ofertas e historial de precios.',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SuppliersPage(repository: widget.repository))),
                    ),
                    const Divider(height: 1),
                    _MenuTile(
                      icon: Icons.card_membership_outlined,
                      title: 'Paquetes de sesiones',
                      subtitle: 'Sesiones vendidas, usadas, pendientes y pagadas.',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PackagesPage(repository: widget.repository))),
                    ),
                    const Divider(height: 1),
                    _MenuTile(
                      icon: Icons.point_of_sale_outlined,
                      title: 'Caja del día',
                      subtitle: 'Apertura, efectivo esperado y cierre.',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CashPage(repository: widget.repository))),
                    ),
                    const Divider(height: 1),
                    _MenuTile(
                      icon: Icons.analytics_outlined,
                      title: 'Resumen del negocio',
                      subtitle: 'Ingresos, gastos, retiros y resultado aproximado.',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReportsPage(repository: widget.repository))),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionTitle('Archivos y respaldo'),
              Card(
                child: Column(
                  children: [
                    _MenuTile(
                      icon: Icons.table_view_outlined,
                      title: 'Exportar a Excel',
                      subtitle: 'Crea un libro con resumen, clientes, citas y operaciones.',
                      onTap: _exportExcel,
                    ),
                    const Divider(height: 1),
                    _MenuTile(
                      icon: Icons.archive_outlined,
                      title: 'Crear respaldo ZIP',
                      subtitle: 'Guarda toda la información para restaurarla después.',
                      onTap: _backup,
                    ),
                    const Divider(height: 1),
                    _MenuTile(
                      icon: Icons.restore,
                      title: 'Restaurar respaldo',
                      subtitle: 'Reemplaza los datos actuales usando un ZIP de PYME RD.',
                      onTap: _restore,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionTitle('Información'),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PYME RD 0.1.0 · revisión venta rápida', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('Gestión local para pequeños negocios dominicanos. El negocio puede configurarse por actividad.'),
                      SizedBox(height: 10),
                      Text('Los recibos generados son documentos comerciales internos. La aplicación no emite comprobantes fiscales electrónicos oficiales ni presenta declaraciones ante la DGII.'),
                      SizedBox(height: 10),
                      Text('Tus registros permanecen en el dispositivo, salvo los archivos que exportes voluntariamente.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_busy)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black26,
                child: Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          CircularProgressIndicator(),
                          SizedBox(width: 14),
                          Text('Procesando archivo…'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}