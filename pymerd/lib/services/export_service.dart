import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:excel/excel.dart';

import '../app_repository.dart';
import '../utils.dart';

class ExportService {
  final AppRepository repository;

  const ExportService(this.repository);

  Future<List<int>> buildExcel() async {
    final excel = Excel.createExcel();
    final settings = await repository.getAllSettings();
    final clients = await repository.getClients();
    final services = await repository.getServices(includeInactive: true);
    final appointments = await repository.getAppointments();
    final transactions = await repository.getTransactions();
    final products = await repository.getProducts(includeInactive: true);
    final movements = await repository.getInventoryMovements();
    final suppliers = await repository.getSuppliers(includeInactive: true);
    final prices = await repository.getSupplierPrices();
    final packages = await repository.getServicePackages();
    final sales = await repository.getSales();
    final now = DateTime.now();
    final totals = await repository.periodTotals(
      DateTime(now.year, now.month, 1),
      DateTime(now.year, now.month + 1, 0, 23, 59, 59),
    );

    final summary = excel['Resumen'];
    _append(summary, ['PYME RD', settings['business_name'] ?? 'Mi negocio']);
    _append(summary, ['Versión de exportación', '0.1.0 · revisión venta rápida']);
    _append(summary, ['Generado', DateTime.now().toIso8601String()]);
    _append(summary, ['Ingresos del mes', formatMoney(totals['income'] ?? 0)]);
    _append(summary, ['Gastos del mes', formatMoney(totals['expense'] ?? 0)]);
    _append(summary, ['Retiros personales', formatMoney(totals['withdrawal'] ?? 0)]);
    _append(summary, [
      'Resultado aproximado',
      formatMoney((totals['income'] ?? 0) - (totals['expense'] ?? 0)),
    ]);
    _append(summary, [
      'Valor aproximado del inventario',
      formatMoney(
        products.fold<int>(
          0,
          (sum, item) => sum + (item.stock * item.costCents).round(),
        ),
      ),
    ]);

    final clientsSheet = excel['Clientes'];
    _append(clientsSheet, ['ID', 'Nombre', 'Teléfono', 'Notas', 'Creado']);
    for (final item in clients) {
      _append(clientsSheet, [
        item.id,
        item.name,
        item.phone,
        item.notes,
        item.createdAt.toIso8601String(),
      ]);
    }

    final servicesSheet = excel['Servicios'];
    _append(servicesSheet, [
      'ID',
      'Servicio',
      'Duración',
      'Precio',
      'Costo estimado',
      'Costo de insumos configurados',
      'A domicilio',
      'Activo',
    ]);
    for (final item in services) {
      _append(servicesSheet, [
        item.id,
        item.name,
        item.durationMinutes,
        item.priceCents / 100,
        item.costCents / 100,
        item.id == null ? 0 : (await repository.serviceSupplyCost(item.id!)) / 100,
        item.homeService ? 'Sí' : 'No',
        item.active ? 'Sí' : 'No',
      ]);
    }

    final appointmentsSheet = excel['Citas'];
    _append(appointmentsSheet, [
      'ID',
      'Fecha',
      'Cliente',
      'Servicio',
      'Estado',
      'Precio acordado',
      'Anticipo',
      'Pendiente',
      'Lugar',
      'Notas',
    ]);
    for (final item in appointments) {
      _append(appointmentsSheet, [
        item.id,
        item.startAt.toIso8601String(),
        item.clientName,
        item.serviceName,
        item.status,
        item.agreedPriceCents / 100,
        item.depositCents / 100,
        item.balanceCents / 100,
        item.location,
        item.notes,
      ]);
    }

    final transactionsSheet = excel['Operaciones'];
    _append(transactionsSheet, [
      'ID',
      'Fecha',
      'Tipo',
      'Descripción',
      'Monto',
      'Cliente',
      'Método',
      'Categoría',
      'Notas',
    ]);
    for (final item in transactions) {
      _append(transactionsSheet, [
        item.id,
        item.date.toIso8601String(),
        item.type,
        item.description,
        item.amountCents / 100,
        item.clientName,
        item.paymentMethod,
        item.category,
        item.notes,
      ]);
    }

    final inventorySheet = excel['Inventario'];
    _append(inventorySheet, [
      'ID',
      'Artículo',
      'Tipo',
      'Unidad',
      'Existencia',
      'Mínimo',
      'Costo unitario',
      'Precio de venta',
      'Vencimiento',
      'Activo',
    ]);
    for (final item in products) {
      _append(inventorySheet, [
        item.id,
        item.name,
        item.kind,
        item.unit,
        item.stock,
        item.minimumStock,
        item.costCents / 100,
        item.salePriceCents / 100,
        item.expiryDate?.toIso8601String(),
        item.active ? 'Sí' : 'No',
      ]);
    }

    final movementsSheet = excel['Movimientos inventario'];
    _append(movementsSheet, [
      'ID',
      'Fecha',
      'Artículo',
      'Tipo',
      'Cantidad',
      'Costo total',
      'Referencia',
      'Notas',
    ]);
    for (final item in movements) {
      _append(movementsSheet, [
        item.id,
        item.date.toIso8601String(),
        item.productName,
        item.type,
        item.quantity,
        item.totalCostCents / 100,
        item.reference,
        item.notes,
      ]);
    }

    final suppliersSheet = excel['Proveedores'];
    _append(suppliersSheet, [
      'ID',
      'Nombre',
      'Teléfono',
      'WhatsApp',
      'Dirección',
      'Notas',
      'Activo',
    ]);
    for (final item in suppliers) {
      _append(suppliersSheet, [
        item.id,
        item.name,
        item.phone,
        item.whatsapp,
        item.address,
        item.notes,
        item.active ? 'Sí' : 'No',
      ]);
    }

    final pricesSheet = excel['Precios proveedores'];
    _append(pricesSheet, [
      'ID',
      'Fecha',
      'Proveedor',
      'Artículo',
      'Cantidad',
      'Precio',
      'Entrega',
      'Total efectivo',
      'Costo por unidad',
      'Notas',
    ]);
    for (final item in prices) {
      _append(pricesSheet, [
        item.id,
        item.recordedAt.toIso8601String(),
        item.supplierName,
        item.productName,
        item.quantity,
        item.priceCents / 100,
        item.deliveryCents / 100,
        item.effectiveTotalCents / 100,
        item.unitCostCents / 100,
        item.notes,
      ]);
    }

    final packagesSheet = excel['Paquetes'];
    _append(packagesSheet, [
      'ID',
      'Cliente',
      'Paquete',
      'Servicio',
      'Sesiones totales',
      'Sesiones usadas',
      'Sesiones pendientes',
      'Precio total',
      'Pagado',
      'Pendiente',
      'Vencimiento',
      'Estado',
    ]);
    for (final item in packages) {
      _append(packagesSheet, [
        item.id,
        item.clientName,
        item.name,
        item.serviceName,
        item.totalSessions,
        item.usedSessions,
        item.remainingSessions,
        item.totalCents / 100,
        item.paidCents / 100,
        item.balanceCents / 100,
        item.expiresAt?.toIso8601String(),
        item.status,
      ]);
    }

    final salesSheet = excel['Ventas'];
    _append(salesSheet, [
      'ID',
      'Fecha',
      'Cliente',
      'Subtotal',
      'Descuento',
      'Propina',
      'Total',
      'Pagado',
      'Pendiente',
      'Método',
      'Estado',
      'Notas',
    ]);
    final saleLinesSheet = excel['Detalle de ventas'];
    _append(saleLinesSheet, [
      'Venta ID',
      'Tipo',
      'Artículo',
      'Cantidad',
      'Precio unitario',
      'Costo unitario',
      'Total',
    ]);
    for (final sale in sales) {
      _append(salesSheet, [
        sale.id,
        sale.date.toIso8601String(),
        sale.clientName,
        sale.subtotalCents / 100,
        sale.discountCents / 100,
        sale.tipCents / 100,
        sale.totalCents / 100,
        sale.paidCents / 100,
        sale.balanceCents / 100,
        sale.paymentMethod,
        sale.status,
        sale.notes,
      ]);
      if (sale.id == null) continue;
      for (final line in await repository.getSaleLines(sale.id!)) {
        _append(saleLinesSheet, [
          sale.id,
          line.itemType,
          line.description,
          line.quantity,
          line.unitPriceCents / 100,
          line.unitCostCents / 100,
          line.totalCents / 100,
        ]);
      }
    }

    final consentsSheet = excel['Consentimientos'];
    _append(consentsSheet, [
      'ID',
      'Cliente',
      'Tipo',
      'Aceptado',
      'Guardar fotos',
      'Uso promocional',
      'Firmado por',
      'Fecha',
      'Notas',
    ]);
    final photosSheet = excel['Fotografías'];
    _append(photosSheet, [
      'ID',
      'Cliente',
      'Tipo',
      'Archivo',
      'Fecha',
      'Promoción autorizada',
      'Notas',
    ]);
    for (final client in clients) {
      if (client.id == null) continue;
      for (final consent in await repository.getConsents(client.id!)) {
        _append(consentsSheet, [
          consent.id,
          client.name,
          consent.type,
          consent.accepted ? 'Sí' : 'No',
          consent.allowPhotoStorage ? 'Sí' : 'No',
          consent.allowPromotion ? 'Sí' : 'No',
          consent.signedName,
          consent.date.toIso8601String(),
          consent.notes,
        ]);
      }
      for (final photo in await repository.getClientPhotos(client.id!)) {
        _append(photosSheet, [
          photo.id,
          client.name,
          photo.kind,
          photo.fileName,
          photo.date.toIso8601String(),
          photo.promotionAuthorized ? 'Sí' : 'No',
          photo.notes,
        ]);
      }
    }

    if (excel.tables.containsKey('Sheet1')) excel.delete('Sheet1');
    return excel.encode() ?? <int>[];
  }

  void _append(Sheet sheet, List<Object?> values) {
    sheet.appendRow(
      values.map<CellValue?>((value) {
        if (value == null) return TextCellValue('');
        if (value is int) return IntCellValue(value);
        if (value is double) return DoubleCellValue(value);
        if (value is bool) return BoolCellValue(value);
        return TextCellValue(value.toString());
      }).toList(),
    );
  }

  Future<Uint8List> buildBackupZip() async {
    final json = await repository.exportAllDataAsJson();
    final jsonBytes = utf8.encode(json);
    final info = utf8.encode(
      'PYME RD 0.1.0 · revisión venta rápida - Respaldo local\n'
      'Incluye ventas detalladas, operaciones, inventario, proveedores, paquetes, consentimientos y fotografías.\n'
      'No lo compartas con personas no autorizadas.\n',
    );
    final archive = Archive()
      ..addFile(ArchiveFile('pymerd_backup.json', jsonBytes.length, jsonBytes))
      ..addFile(ArchiveFile('LEEME.txt', info.length, info));
    final encoded = ZipEncoder().encode(archive);
    if (encoded == null) {
      throw StateError('No fue posible crear el respaldo ZIP.');
    }
    return Uint8List.fromList(encoded);
  }

  Future<void> restoreBackupZip(Uint8List bytes) async {
    final archive = ZipDecoder().decodeBytes(bytes);
    final entry = archive.files
        .where((file) => file.name == 'pymerd_backup.json')
        .firstOrNull;
    if (entry == null) {
      throw const FormatException(
        'El ZIP no contiene un respaldo de PYME RD.',
      );
    }
    final content = entry.content;
    if (content is! List<int>) {
      throw const FormatException('El respaldo contiene datos no válidos.');
    }
    final decoded = jsonDecode(utf8.decode(content));
    await repository.restoreAllData(
      Map<String, Object?>.from(decoded as Map),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}