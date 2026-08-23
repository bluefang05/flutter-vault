import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import 'app_database.dart';
import 'models.dart';
import 'utils.dart';

class AppRepository extends ChangeNotifier {
  final AppDatabase _database = AppDatabase.instance;

  bool _initialized = false;
  bool get initialized => _initialized;

  Future<void> initialize() async {
    await _database.database;
    await _seedDefaults();
    _initialized = true;
  }

  Future<Database> get _db => _database.database;

  Future<void> _seedDefaults() async {
    final completed = (await getSetting('onboarding_complete')) == 'true';
    if (!completed) return;
    final businessType = await getSetting('business_type') ?? 'Negocio general';
    await _seedServicesForBusinessType(businessType);
  }

  Future<void> _seedServicesForBusinessType(String businessType) async {
    final db = await _db;
    final count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM services'),
        ) ??
        0;
    if (count > 0) return;

    final defaults = switch (businessType) {
      'Estética y masajes' => const [
          ServiceItem(
            name: 'Masaje relajante',
            durationMinutes: 60,
            priceCents: 180000,
            costCents: 35000,
            homeService: true,
          ),
          ServiceItem(
            name: 'Limpieza facial básica',
            durationMinutes: 60,
            priceCents: 150000,
            costCents: 42000,
          ),
        ],
      'Salón o barbería' => const [
          ServiceItem(
            name: 'Servicio principal',
            durationMinutes: 45,
            priceCents: 50000,
          ),
        ],
      _ => const [
          ServiceItem(
            name: 'Servicio o venta principal',
            durationMinutes: 30,
            priceCents: 10000,
          ),
        ],
    };

    final batch = db.batch();
    for (final service in defaults) {
      batch.insert('services', service.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<String?> getSetting(String key) async {
    final db = await _db;
    final rows = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first['value'] as String;
  }

  Future<Map<String, String>> getAllSettings() async {
    final db = await _db;
    final rows = await db.query('settings');
    return {
      for (final row in rows) row['key'] as String: row['value'] as String,
    };
  }

  Future<void> setSetting(
    String key,
    String value, {
    bool refresh = true,
  }) async {
    final db = await _db;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    if (refresh) notifyListeners();
  }

  Future<bool> isOnboardingComplete() async =>
      (await getSetting('onboarding_complete')) == 'true';

  Future<void> completeOnboarding({
    required String businessName,
    required String ownerName,
    required String businessType,
    required String workplace,
    required bool simpleMode,
  }) async {
    final db = await _db;
    await db.transaction((txn) async {
      Future<void> put(String key, String value) => txn.insert(
            'settings',
            {'key': key, 'value': value},
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
      await put('business_name', businessName);
      await put('owner_name', ownerName);
      await put('business_type', businessType);
      await put('workplace', workplace);
      await put('simple_mode', simpleMode.toString());
      await put('onboarding_complete', 'true');
    });
    await _seedServicesForBusinessType(businessType);
    notifyListeners();
  }

  Future<List<Client>> getClients() async {
    final db = await _db;
    final rows = await db.query('clients', orderBy: 'name COLLATE NOCASE ASC');
    return rows.map(Client.fromMap).toList();
  }

  Future<int> addClient(Client client) async {
    final db = await _db;
    final id = await db.insert('clients', client.toMap());
    notifyListeners();
    return id;
  }

  Future<void> updateClient(Client client) async {
    if (client.id == null) return;
    final db = await _db;
    await db.update(
      'clients',
      client.toMap(),
      where: 'id = ?',
      whereArgs: [client.id],
    );
    notifyListeners();
  }

  Future<List<ServiceItem>> getServices({bool includeInactive = false}) async {
    final db = await _db;
    final rows = await db.query(
      'services',
      where: includeInactive ? null : 'active = 1',
      orderBy: 'name COLLATE NOCASE ASC',
    );
    return rows.map(ServiceItem.fromMap).toList();
  }

  Future<int> addService(ServiceItem service) async {
    final db = await _db;
    final id = await db.insert('services', service.toMap());
    notifyListeners();
    return id;
  }

  Future<void> updateService(ServiceItem service) async {
    if (service.id == null) return;
    final db = await _db;
    await db.update(
      'services',
      service.toMap(),
      where: 'id = ?',
      whereArgs: [service.id],
    );
    notifyListeners();
  }

  Future<int> addAppointment(
    AppointmentItem appointment, {
    String depositPaymentMethod = 'Efectivo',
  }) async {
    final db = await _db;
    final id = await db.transaction<int>((txn) async {
      final appointmentId = await txn.insert(
        'appointments',
        appointment.toMap(),
      );
      if (appointment.depositCents > 0) {
        await txn.insert(
          'money_transactions',
          MoneyTransaction(
            type: 'income',
            description: 'Anticipo de cita',
            amountCents: appointment.depositCents,
            date: DateTime.now(),
            clientId: appointment.clientId,
            appointmentId: appointmentId,
            paymentMethod: depositPaymentMethod,
            category: 'Anticipo',
          ).toMap(),
        );
      }
      return appointmentId;
    });
    notifyListeners();
    return id;
  }

  Future<List<AppointmentItem>> getAppointments({
    DateTime? from,
    DateTime? to,
  }) async {
    final db = await _db;
    final clauses = <String>[];
    final args = <Object?>[];
    if (from != null) {
      clauses.add('a.start_at >= ?');
      args.add(from.toIso8601String());
    }
    if (to != null) {
      clauses.add('a.start_at <= ?');
      args.add(to.toIso8601String());
    }
    final rows = await db.rawQuery('''
      SELECT a.*, c.name AS client_name, s.name AS service_name
      FROM appointments a
      JOIN clients c ON c.id = a.client_id
      JOIN services s ON s.id = a.service_id
      ${clauses.isEmpty ? '' : 'WHERE ${clauses.join(' AND ')}'}
      ORDER BY a.start_at ASC
    ''', args);
    return rows.map(AppointmentItem.fromMap).toList();
  }

  Future<AppointmentItem?> getAppointment(int id) async {
    final db = await _db;
    final rows = await db.rawQuery('''
      SELECT a.*, c.name AS client_name, s.name AS service_name
      FROM appointments a
      JOIN clients c ON c.id = a.client_id
      JOIN services s ON s.id = a.service_id
      WHERE a.id = ?
      LIMIT 1
    ''', [id]);
    return rows.isEmpty ? null : AppointmentItem.fromMap(rows.first);
  }

  Future<void> updateAppointmentStatus(int id, String status) async {
    final db = await _db;
    await db.update(
      'appointments',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
    notifyListeners();
  }

  Future<void> rescheduleAppointment(int id, DateTime newDate) async {
    final db = await _db;
    await db.update(
      'appointments',
      {'start_at': newDate.toIso8601String(), 'status': 'pending'},
      where: 'id = ?',
      whereArgs: [id],
    );
    notifyListeners();
  }

  Future<void> _consumeServiceSupplies(
    Transaction txn,
    AppointmentItem appointment,
  ) async {
    if (appointment.id == null) return;

    // Esta actualización funciona como un seguro contra doble pulsación,
    // reintentos o reapertura accidental de una cita ya completada.
    final claimed = await txn.rawUpdate(
      'UPDATE appointments SET supplies_consumed = 1 '
      'WHERE id = ? AND supplies_consumed = 0',
      [appointment.id],
    );
    if (claimed == 0) return;

    final supplies = await txn.rawQuery('''
      SELECT ss.product_id, ss.quantity, p.name
      FROM service_supplies ss
      JOIN products p ON p.id = ss.product_id
      WHERE ss.service_id = ?
    ''', [appointment.serviceId]);
    for (final row in supplies) {
      final productId = row['product_id'] as int;
      final quantity = (row['quantity'] as num).toDouble();
      await txn.rawUpdate(
        'UPDATE products SET stock = stock - ? WHERE id = ?',
        [quantity, productId],
      );
      await txn.insert(
        'inventory_movements',
        InventoryMovement(
          productId: productId,
          type: 'service_use',
          quantity: -quantity,
          date: DateTime.now(),
          reference: 'Cita #${appointment.id}',
          notes: appointment.serviceName ?? 'Servicio completado',
        ).toMap(),
      );
    }
  }

  Future<void> registerAppointmentPayment({
    required AppointmentItem appointment,
    required int amountCents,
    required String paymentMethod,
    bool markCompleted = false,
  }) async {
    if (appointment.id == null || amountCents <= 0) return;
    final db = await _db;
    await db.transaction((txn) async {
      final newBalance =
          (appointment.balanceCents - amountCents).clamp(0, 1 << 62).toInt();
      await txn.update(
        'appointments',
        {
          'balance_cents': newBalance,
          if (markCompleted) 'status': 'completed',
        },
        where: 'id = ?',
        whereArgs: [appointment.id],
      );
      await txn.insert(
        'money_transactions',
        MoneyTransaction(
          type: 'income',
          description: markCompleted
              ? '${appointment.serviceName ?? 'Servicio'} completado'
              : 'Abono a ${appointment.serviceName ?? 'servicio'}',
          amountCents: amountCents,
          date: DateTime.now(),
          clientId: appointment.clientId,
          appointmentId: appointment.id,
          paymentMethod: paymentMethod,
          category: markCompleted ? 'Servicio' : 'Abono',
        ).toMap(),
      );
      if (markCompleted) {
        await _consumeServiceSupplies(txn, appointment);
      }
    });
    notifyListeners();
  }

  Future<void> completeAppointmentWithoutPayment(
    AppointmentItem appointment,
  ) async {
    if (appointment.id == null) return;
    final db = await _db;
    await db.transaction((txn) async {
      await txn.update(
        'appointments',
        {'status': 'completed'},
        where: 'id = ?',
        whereArgs: [appointment.id],
      );
      await _consumeServiceSupplies(txn, appointment);
    });
    notifyListeners();
  }

  Future<int> addTransaction(MoneyTransaction transaction) async {
    final db = await _db;
    final id = await db.insert('money_transactions', transaction.toMap());
    notifyListeners();
    return id;
  }

  Future<List<MoneyTransaction>> getTransactions({
    DateTime? from,
    DateTime? to,
    String? type,
    int? limit,
  }) async {
    final db = await _db;
    final clauses = <String>[];
    final args = <Object?>[];
    if (from != null) {
      clauses.add('t.date >= ?');
      args.add(from.toIso8601String());
    }
    if (to != null) {
      clauses.add('t.date <= ?');
      args.add(to.toIso8601String());
    }
    if (type != null) {
      clauses.add('t.type = ?');
      args.add(type);
    }
    final rows = await db.rawQuery('''
      SELECT t.*, c.name AS client_name
      FROM money_transactions t
      LEFT JOIN clients c ON c.id = t.client_id
      ${clauses.isEmpty ? '' : 'WHERE ${clauses.join(' AND ')}'}
      ORDER BY t.date DESC, t.id DESC
      ${limit == null ? '' : 'LIMIT $limit'}
    ''', args);
    return rows.map(MoneyTransaction.fromMap).toList();
  }

  Future<DashboardSummary> dashboardSummary(DateTime day) async {
    final db = await _db;
    final from = startOfDay(day).toIso8601String();
    final to = endOfDay(day).toIso8601String();
    final appointments = Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM appointments WHERE start_at BETWEEN ? AND ? AND status NOT IN (?, ?)',
            [from, to, 'cancelled', 'no_show'],
          ),
        ) ??
        0;
    Future<int> sumType(String type) async {
      final rows = await db.rawQuery(
        'SELECT COALESCE(SUM(amount_cents), 0) AS total FROM money_transactions WHERE type = ? AND date BETWEEN ? AND ?',
        [type, from, to],
      );
      return (rows.first['total'] as num?)?.toInt() ?? 0;
    }

    final pendingAppointmentRows = await db.rawQuery(
      'SELECT COALESCE(SUM(balance_cents), 0) AS total FROM appointments WHERE balance_cents > 0 AND status != ?',
      ['cancelled'],
    );
    final pendingSaleRows = await db.rawQuery(
      "SELECT COALESCE(SUM(total_cents - paid_cents), 0) AS total FROM sales WHERE paid_cents < total_cents AND status != 'cancelled'",
    );
    final pendingAppointments =
        (pendingAppointmentRows.first['total'] as num?)?.toInt() ?? 0;
    final pendingSales =
        (pendingSaleRows.first['total'] as num?)?.toInt() ?? 0;
    return DashboardSummary(
      todayAppointments: appointments,
      todayIncomeCents: await sumType('income'),
      todayExpenseCents: await sumType('expense'),
      pendingCents: pendingAppointments + pendingSales,
    );
  }

  Future<Map<String, int>> periodTotals(DateTime from, DateTime to) async {
    final db = await _db;
    Future<int> sum(String type) async {
      final rows = await db.rawQuery(
        'SELECT COALESCE(SUM(amount_cents), 0) AS total FROM money_transactions WHERE type = ? AND date BETWEEN ? AND ?',
        [type, from.toIso8601String(), to.toIso8601String()],
      );
      return (rows.first['total'] as num?)?.toInt() ?? 0;
    }

    return {
      'income': await sum('income'),
      'expense': await sum('expense'),
      'withdrawal': await sum('withdrawal'),
    };
  }

  Future<CashSession?> getOpenCashSession() async {
    final db = await _db;
    final rows = await db.query(
      'cash_sessions',
      where: 'closed_at IS NULL',
      orderBy: 'opened_at DESC',
      limit: 1,
    );
    return rows.isEmpty ? null : CashSession.fromMap(rows.first);
  }

  Future<void> openCash(int openingCents) async {
    final db = await _db;
    if (await getOpenCashSession() != null) return;
    await db.insert('cash_sessions', {
      'opened_at': DateTime.now().toIso8601String(),
      'opening_cents': openingCents,
      'note': '',
    });
    notifyListeners();
  }

  Future<int> expectedCash(CashSession session) async {
    final db = await _db;
    final rows = await db.rawQuery('''
      SELECT
        COALESCE(SUM(CASE WHEN type = 'income' AND payment_method = 'Efectivo' THEN amount_cents ELSE 0 END), 0) AS income,
        COALESCE(SUM(CASE WHEN type IN ('expense', 'withdrawal') AND payment_method = 'Efectivo' THEN amount_cents ELSE 0 END), 0) AS outflow
      FROM money_transactions
      WHERE date >= ?
    ''', [session.openedAt.toIso8601String()]);
    final income = (rows.first['income'] as num?)?.toInt() ?? 0;
    final outflow = (rows.first['outflow'] as num?)?.toInt() ?? 0;
    return session.openingCents + income - outflow;
  }

  Future<void> closeCash({
    required CashSession session,
    required int countedCents,
    String note = '',
  }) async {
    if (session.id == null) return;
    final db = await _db;
    final expected = await expectedCash(session);
    await db.update(
      'cash_sessions',
      {
        'closed_at': DateTime.now().toIso8601String(),
        'expected_cents': expected,
        'counted_cents': countedCents,
        'note': note,
      },
      where: 'id = ?',
      whereArgs: [session.id],
    );
    notifyListeners();
  }

  Future<List<ProductItem>> getProducts({bool includeInactive = false}) async {
    final db = await _db;
    final rows = await db.query(
      'products',
      where: includeInactive ? null : 'active = 1',
      orderBy: 'name COLLATE NOCASE ASC',
    );
    return rows.map(ProductItem.fromMap).toList();
  }

  Future<int> addProduct(ProductItem product) async {
    final db = await _db;
    final id = await db.transaction<int>((txn) async {
      final productId = await txn.insert('products', product.toMap());
      if (product.stock != 0) {
        await txn.insert(
          'inventory_movements',
          InventoryMovement(
            productId: productId,
            type: 'opening',
            quantity: product.stock,
            totalCostCents: (product.stock * product.costCents).round(),
            date: DateTime.now(),
            reference: 'Existencia inicial',
          ).toMap(),
        );
      }
      return productId;
    });
    notifyListeners();
    return id;
  }

  Future<void> updateProduct(ProductItem product) async {
    if (product.id == null) return;
    final db = await _db;
    await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
    notifyListeners();
  }

  Future<void> adjustProductStock({
    required ProductItem product,
    required double delta,
    required String reason,
  }) async {
    if (product.id == null || delta == 0) return;
    final db = await _db;
    await db.transaction((txn) async {
      await txn.rawUpdate(
        'UPDATE products SET stock = stock + ? WHERE id = ?',
        [delta, product.id],
      );
      await txn.insert(
        'inventory_movements',
        InventoryMovement(
          productId: product.id!,
          type: 'adjustment',
          quantity: delta,
          date: DateTime.now(),
          reference: 'Ajuste manual',
          notes: reason,
        ).toMap(),
      );
    });
    notifyListeners();
  }

  Future<void> recordProductPurchase({
    required ProductItem product,
    required double quantity,
    required int priceCents,
    required int deliveryCents,
    required String paymentMethod,
    int? supplierId,
    String notes = '',
  }) async {
    if (product.id == null || quantity <= 0 || priceCents <= 0) return;
    final db = await _db;
    final total = priceCents + deliveryCents;
    final unitCost = (total / quantity).round();
    await db.transaction((txn) async {
      await txn.rawUpdate(
        'UPDATE products SET stock = stock + ?, cost_cents = ? WHERE id = ?',
        [quantity, unitCost, product.id],
      );
      await txn.insert(
        'inventory_movements',
        InventoryMovement(
          productId: product.id!,
          type: 'purchase',
          quantity: quantity,
          totalCostCents: total,
          date: DateTime.now(),
          reference: supplierId == null ? 'Compra' : 'Compra a proveedor',
          notes: notes,
        ).toMap(),
      );
      if (supplierId != null) {
        await txn.insert(
          'supplier_prices',
          SupplierPrice(
            supplierId: supplierId,
            productId: product.id!,
            quantity: quantity,
            priceCents: priceCents,
            deliveryCents: deliveryCents,
            recordedAt: DateTime.now(),
            notes: notes,
          ).toMap(),
        );
      }
      await txn.insert(
        'money_transactions',
        MoneyTransaction(
          type: 'expense',
          description: 'Compra de ${product.name}',
          amountCents: total,
          date: DateTime.now(),
          paymentMethod: paymentMethod,
          category: 'Inventario',
          notes: notes,
        ).toMap(),
      );
    });
    notifyListeners();
  }

  Future<List<InventoryMovement>> getInventoryMovements({
    int? productId,
    int? limit,
  }) async {
    final db = await _db;
    final rows = await db.rawQuery('''
      SELECT m.*, p.name AS product_name
      FROM inventory_movements m
      JOIN products p ON p.id = m.product_id
      ${productId == null ? '' : 'WHERE m.product_id = ?'}
      ORDER BY m.date DESC, m.id DESC
      ${limit == null ? '' : 'LIMIT $limit'}
    ''', productId == null ? const [] : [productId]);
    return rows.map(InventoryMovement.fromMap).toList();
  }

  Future<int> lowStockCount() async {
    final db = await _db;
    return Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM products WHERE active = 1 AND minimum_stock > 0 AND stock <= minimum_stock',
          ),
        ) ??
        0;
  }

  Future<List<SupplierItem>> getSuppliers({bool includeInactive = false}) async {
    final db = await _db;
    final rows = await db.query(
      'suppliers',
      where: includeInactive ? null : 'active = 1',
      orderBy: 'name COLLATE NOCASE ASC',
    );
    return rows.map(SupplierItem.fromMap).toList();
  }

  Future<int> addSupplier(SupplierItem supplier) async {
    final db = await _db;
    final id = await db.insert('suppliers', supplier.toMap());
    notifyListeners();
    return id;
  }

  Future<void> updateSupplier(SupplierItem supplier) async {
    if (supplier.id == null) return;
    final db = await _db;
    await db.update(
      'suppliers',
      supplier.toMap(),
      where: 'id = ?',
      whereArgs: [supplier.id],
    );
    notifyListeners();
  }

  Future<int> addSupplierPrice(SupplierPrice price) async {
    final db = await _db;
    final id = await db.insert('supplier_prices', price.toMap());
    notifyListeners();
    return id;
  }

  Future<List<SupplierPrice>> getSupplierPrices({
    int? supplierId,
    int? productId,
  }) async {
    final db = await _db;
    final clauses = <String>[];
    final args = <Object?>[];
    if (supplierId != null) {
      clauses.add('sp.supplier_id = ?');
      args.add(supplierId);
    }
    if (productId != null) {
      clauses.add('sp.product_id = ?');
      args.add(productId);
    }
    final rows = await db.rawQuery('''
      SELECT sp.*, s.name AS supplier_name, p.name AS product_name, p.unit AS unit
      FROM supplier_prices sp
      JOIN suppliers s ON s.id = sp.supplier_id
      JOIN products p ON p.id = sp.product_id
      ${clauses.isEmpty ? '' : 'WHERE ${clauses.join(' AND ')}'}
      ORDER BY sp.recorded_at DESC, sp.id DESC
    ''', args);
    return rows.map(SupplierPrice.fromMap).toList();
  }

  Future<List<ServiceSupply>> getServiceSupplies(int serviceId) async {
    final db = await _db;
    final rows = await db.rawQuery('''
      SELECT ss.*, p.name AS product_name, p.unit AS unit, p.cost_cents AS product_cost_cents
      FROM service_supplies ss
      JOIN products p ON p.id = ss.product_id
      WHERE ss.service_id = ?
      ORDER BY p.name COLLATE NOCASE
    ''', [serviceId]);
    return rows.map(ServiceSupply.fromMap).toList();
  }

  Future<void> setServiceSupplies(
    int serviceId,
    List<ServiceSupply> supplies,
  ) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete(
        'service_supplies',
        where: 'service_id = ?',
        whereArgs: [serviceId],
      );
      for (final supply in supplies.where((item) => item.quantity > 0)) {
        await txn.insert('service_supplies', supply.toMap());
      }
    });
    notifyListeners();
  }

  Future<int> serviceSupplyCost(int serviceId) async {
    final supplies = await getServiceSupplies(serviceId);
    return supplies.fold<int>(
      0,
      (sum, item) => sum + item.estimatedCostCents,
    );
  }

  Future<List<ServicePackage>> getServicePackages({
    int? clientId,
    bool activeOnly = false,
  }) async {
    final db = await _db;
    final clauses = <String>[];
    final args = <Object?>[];
    if (clientId != null) {
      clauses.add('p.client_id = ?');
      args.add(clientId);
    }
    if (activeOnly) {
      clauses.add("p.status = 'active'");
    }
    final rows = await db.rawQuery('''
      SELECT p.*, c.name AS client_name, s.name AS service_name
      FROM service_packages p
      JOIN clients c ON c.id = p.client_id
      LEFT JOIN services s ON s.id = p.service_id
      ${clauses.isEmpty ? '' : 'WHERE ${clauses.join(' AND ')}'}
      ORDER BY p.created_at DESC, p.id DESC
    ''', args);
    return rows.map(ServicePackage.fromMap).toList();
  }

  Future<List<ServicePackage>> getUsablePackages({
    required int clientId,
    required int serviceId,
  }) async {
    final items = await getServicePackages(clientId: clientId, activeOnly: true);
    return items
        .where(
          (item) => item.isUsable &&
              (item.serviceId == null || item.serviceId == serviceId),
        )
        .toList();
  }

  Future<int> addServicePackage(
    ServicePackage package, {
    String paymentMethod = 'Efectivo',
  }) async {
    final db = await _db;
    final id = await db.transaction<int>((txn) async {
      final packageId = await txn.insert('service_packages', package.toMap());
      if (package.paidCents > 0) {
        await txn.insert(
          'money_transactions',
          MoneyTransaction(
            type: 'income',
            description: 'Pago inicial de paquete: ${package.name}',
            amountCents: package.paidCents,
            date: DateTime.now(),
            clientId: package.clientId,
            paymentMethod: paymentMethod,
            category: 'Paquete',
          ).toMap(),
        );
      }
      return packageId;
    });
    notifyListeners();
    return id;
  }

  Future<void> addPackagePayment({
    required ServicePackage package,
    required int amountCents,
    required String paymentMethod,
  }) async {
    if (package.id == null || amountCents <= 0) return;
    final db = await _db;
    final applied = amountCents.clamp(0, package.balanceCents).toInt();
    await db.transaction((txn) async {
      await txn.rawUpdate(
        'UPDATE service_packages SET paid_cents = paid_cents + ? WHERE id = ?',
        [applied, package.id],
      );
      await txn.insert(
        'money_transactions',
        MoneyTransaction(
          type: 'income',
          description: 'Abono a paquete: ${package.name}',
          amountCents: applied,
          date: DateTime.now(),
          clientId: package.clientId,
          paymentMethod: paymentMethod,
          category: 'Paquete',
        ).toMap(),
      );
    });
    notifyListeners();
  }

  Future<void> consumePackageSession({
    required ServicePackage package,
    AppointmentItem? appointment,
    String notes = '',
  }) async {
    if (package.id == null) return;
    final db = await _db;
    await db.transaction((txn) async {
      if (appointment?.id != null) {
        final existingUsage = Sqflite.firstIntValue(
              await txn.rawQuery(
                'SELECT COUNT(*) FROM package_usages WHERE appointment_id = ?',
                [appointment!.id],
              ),
            ) ??
            0;
        if (existingUsage > 0) {
          throw StateError('Esta cita ya consumió una sesión de paquete.');
        }
      }
      final rows = await txn.query(
        'service_packages',
        where: 'id = ?',
        whereArgs: [package.id],
        limit: 1,
      );
      if (rows.isEmpty) throw StateError('El paquete ya no existe.');
      final current = ServicePackage.fromMap(rows.first);
      if (!current.isUsable) {
        throw StateError('Este paquete no tiene sesiones disponibles.');
      }
      final used = current.usedSessions + 1;
      await txn.update(
        'service_packages',
        {
          'used_sessions': used,
          if (used >= current.totalSessions) 'status': 'completed',
        },
        where: 'id = ?',
        whereArgs: [current.id],
      );
      await txn.insert('package_usages', {
        'package_id': current.id,
        'appointment_id': appointment?.id,
        'used_at': DateTime.now().toIso8601String(),
        'notes': notes,
      });
      if (appointment?.id != null) {
        await txn.update(
          'appointments',
          {'status': 'completed', 'balance_cents': 0},
          where: 'id = ?',
          whereArgs: [appointment!.id],
        );
        await _consumeServiceSupplies(txn, appointment);
      }
    });
    notifyListeners();
  }

  Future<int> addConsent(ConsentRecord consent) async {
    final db = await _db;
    final id = await db.insert('consents', consent.toMap());
    notifyListeners();
    return id;
  }

  Future<List<ConsentRecord>> getConsents(int clientId) async {
    final db = await _db;
    final rows = await db.query(
      'consents',
      where: 'client_id = ?',
      whereArgs: [clientId],
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(ConsentRecord.fromMap).toList();
  }

  Future<int> addClientPhoto(ClientPhoto photo) async {
    if (photo.bytes.length > 8 * 1024 * 1024) {
      throw StateError('La imagen supera el límite de 8 MB.');
    }
    final db = await _db;
    final id = await db.insert('client_photos', photo.toMap());
    notifyListeners();
    return id;
  }

  Future<List<ClientPhoto>> getClientPhotos(int clientId) async {
    final db = await _db;
    final rows = await db.query(
      'client_photos',
      where: 'client_id = ?',
      whereArgs: [clientId],
      orderBy: 'date DESC, id DESC',
    );
    return rows.map((row) {
      final map = Map<String, Object?>.from(row);
      map['bytes'] = Uint8List.fromList(List<int>.from(row['bytes'] as List));
      return ClientPhoto.fromMap(map);
    }).toList();
  }

  Future<void> deleteClientPhoto(int id) async {
    final db = await _db;
    await db.delete('client_photos', where: 'id = ?', whereArgs: [id]);
    notifyListeners();
  }

  Future<int> createSale({
    int? clientId,
    required List<SaleLine> lines,
    int discountCents = 0,
    int tipCents = 0,
    required int paidCents,
    required String paymentMethod,
    String notes = '',
  }) async {
    if (lines.isEmpty) {
      throw StateError('Agrega al menos un artículo a la venta.');
    }
    final subtotal = lines.fold<int>(0, (sum, line) => sum + line.totalCents);
    final safeDiscount = discountCents.clamp(0, subtotal).toInt();
    final safeTip = tipCents.clamp(0, 1 << 62).toInt();
    final total = subtotal - safeDiscount + safeTip;
    if (total <= 0) {
      throw StateError('El total de la venta debe ser mayor que cero.');
    }
    if (paidCents < 0 || paidCents > total) {
      throw StateError('El monto recibido no puede superar el total.');
    }

    final db = await _db;
    final saleId = await db.transaction<int>((txn) async {
      for (final line in lines.where((item) => item.itemType == 'product')) {
        if (line.itemId == null) continue;
        final rows = await txn.query(
          'products',
          columns: ['stock', 'name'],
          where: 'id = ? AND active = 1',
          whereArgs: [line.itemId],
          limit: 1,
        );
        if (rows.isEmpty) {
          throw StateError('Uno de los productos ya no está disponible.');
        }
        final stock = (rows.first['stock'] as num).toDouble();
        if (stock + 0.000001 < line.quantity) {
          throw StateError(
            'No hay existencia suficiente de ${rows.first['name']}.',
          );
        }
      }

      final status = paidCents >= total
          ? 'paid'
          : paidCents > 0
              ? 'partial'
              : 'credit';
      final id = await txn.insert(
        'sales',
        SaleRecord(
          clientId: clientId,
          date: DateTime.now(),
          subtotalCents: subtotal,
          discountCents: safeDiscount,
          tipCents: safeTip,
          totalCents: total,
          paidCents: paidCents,
          paymentMethod: paymentMethod,
          status: status,
          notes: notes,
        ).toMap(),
      );

      for (final line in lines) {
        await txn.insert(
          'sale_lines',
          SaleLine(
            saleId: id,
            itemType: line.itemType,
            itemId: line.itemId,
            description: line.description,
            quantity: line.quantity,
            unitPriceCents: line.unitPriceCents,
            unitCostCents: line.unitCostCents,
            totalCents: line.totalCents,
          ).toMap(),
        );
        if (line.itemType == 'product' && line.itemId != null) {
          await txn.rawUpdate(
            'UPDATE products SET stock = stock - ? WHERE id = ?',
            [line.quantity, line.itemId],
          );
          await txn.insert(
            'inventory_movements',
            InventoryMovement(
              productId: line.itemId!,
              type: 'sale',
              quantity: -line.quantity,
              totalCostCents: (line.quantity * line.unitCostCents).round(),
              date: DateTime.now(),
              reference: 'Venta #$id',
              notes: line.description,
            ).toMap(),
          );
        }
      }

      if (paidCents > 0) {
        await txn.insert(
          'money_transactions',
          MoneyTransaction(
            type: 'income',
            description: 'Venta #$id',
            amountCents: paidCents,
            date: DateTime.now(),
            clientId: clientId,
            paymentMethod: paymentMethod,
            category: 'Venta',
            notes: notes,
          ).toMap(),
        );
      }
      return id;
    });
    notifyListeners();
    return saleId;
  }

  Future<List<SaleRecord>> getSales({int? limit}) async {
    final db = await _db;
    final rows = await db.rawQuery('''
      SELECT s.*, c.name AS client_name
      FROM sales s
      LEFT JOIN clients c ON c.id = s.client_id
      ORDER BY s.date DESC, s.id DESC
      ${limit == null ? '' : 'LIMIT $limit'}
    ''');
    return rows.map(SaleRecord.fromMap).toList();
  }

  Future<SaleRecord?> getSale(int id) async {
    final db = await _db;
    final rows = await db.rawQuery('''
      SELECT s.*, c.name AS client_name
      FROM sales s
      LEFT JOIN clients c ON c.id = s.client_id
      WHERE s.id = ?
      LIMIT 1
    ''', [id]);
    return rows.isEmpty ? null : SaleRecord.fromMap(rows.first);
  }

  Future<List<SaleLine>> getSaleLines(int saleId) async {
    final db = await _db;
    final rows = await db.query(
      'sale_lines',
      where: 'sale_id = ?',
      whereArgs: [saleId],
      orderBy: 'id ASC',
    );
    return rows.map(SaleLine.fromMap).toList();
  }

  Future<void> registerSalePayment({
    required SaleRecord sale,
    required int amountCents,
    required String paymentMethod,
  }) async {
    if (sale.id == null || amountCents <= 0) return;
    final applied = amountCents.clamp(0, sale.balanceCents).toInt();
    if (applied <= 0) return;
    final db = await _db;
    await db.transaction((txn) async {
      final newPaid = sale.paidCents + applied;
      await txn.update(
        'sales',
        {
          'paid_cents': newPaid,
          'payment_method': paymentMethod,
          'status': newPaid >= sale.totalCents ? 'paid' : 'partial',
        },
        where: 'id = ?',
        whereArgs: [sale.id],
      );
      await txn.insert(
        'money_transactions',
        MoneyTransaction(
          type: 'income',
          description: 'Abono a venta #${sale.id}',
          amountCents: applied,
          date: DateTime.now(),
          clientId: sale.clientId,
          paymentMethod: paymentMethod,
          category: 'Abono de venta',
        ).toMap(),
      );
    });
    notifyListeners();
  }

  Future<Map<String, Object?>> exportAllData() async {
    final db = await _db;
    Future<List<Map<String, Object?>>> table(String name) => db.query(name);
    final photos = await db.query('client_photos');
    final encodedPhotos = photos.map((raw) {
      final row = Map<String, Object?>.from(raw);
      final bytes = List<int>.from(row.remove('bytes') as List);
      row['bytes_base64'] = base64Encode(bytes);
      return row;
    }).toList();
    return {
      'format': 'PYMERD_BACKUP',
      'version': 4,
      'created_at': DateTime.now().toIso8601String(),
      'settings': await table('settings'),
      'clients': await table('clients'),
      'services': await table('services'),
      'appointments': await table('appointments'),
      'money_transactions': await table('money_transactions'),
      'sales': await table('sales'),
      'sale_lines': await table('sale_lines'),
      'cash_sessions': await table('cash_sessions'),
      'products': await table('products'),
      'suppliers': await table('suppliers'),
      'supplier_prices': await table('supplier_prices'),
      'inventory_movements': await table('inventory_movements'),
      'service_supplies': await table('service_supplies'),
      'service_packages': await table('service_packages'),
      'package_usages': await table('package_usages'),
      'consents': await table('consents'),
      'client_photos': encodedPhotos,
    };
  }

  Future<void> restoreAllData(Map<String, Object?> backup) async {
    if (backup['format'] != 'PYMERD_BACKUP') {
      throw const FormatException(
        'Este archivo no es un respaldo válido de PYME RD.',
      );
    }
    final db = await _db;
    await db.transaction((txn) async {
      for (final table in [
        'client_photos',
        'sale_lines',
        'sales',
        'consents',
        'package_usages',
        'service_packages',
        'service_supplies',
        'supplier_prices',
        'inventory_movements',
        'money_transactions',
        'appointments',
        'cash_sessions',
        'suppliers',
        'products',
        'clients',
        'services',
        'settings',
      ]) {
        await txn.delete(table);
      }

      Future<void> insertRows(String table, Object? rawRows) async {
        final rows = (rawRows as List? ?? const []).cast<Map>();
        for (final row in rows) {
          await txn.insert(table, Map<String, Object?>.from(row));
        }
      }

      await insertRows('settings', backup['settings']);
      await insertRows('clients', backup['clients']);
      await insertRows('services', backup['services']);
      await insertRows('products', backup['products']);
      await insertRows('suppliers', backup['suppliers']);
      await insertRows('appointments', backup['appointments']);
      await insertRows('sales', backup['sales']);
      await insertRows('sale_lines', backup['sale_lines']);
      await insertRows('money_transactions', backup['money_transactions']);
      await insertRows('cash_sessions', backup['cash_sessions']);
      await insertRows('supplier_prices', backup['supplier_prices']);
      await insertRows('inventory_movements', backup['inventory_movements']);
      await insertRows('service_supplies', backup['service_supplies']);
      await insertRows('service_packages', backup['service_packages']);
      await insertRows('package_usages', backup['package_usages']);
      await insertRows('consents', backup['consents']);

      final photos = (backup['client_photos'] as List? ?? const []).cast<Map>();
      for (final raw in photos) {
        final row = Map<String, Object?>.from(raw);
        final encoded = row.remove('bytes_base64') as String?;
        if (encoded == null) continue;
        row['bytes'] = base64Decode(encoded);
        await txn.insert('client_photos', row);
      }
    });
    await _seedDefaults();
    notifyListeners();
  }

  Future<String> exportAllDataAsJson() async =>
      jsonEncode(await exportAllData());

  Future<void> clearDemoData() async {
    final db = await _db;
    await db.transaction((txn) async {
      for (final table in [
        'client_photos',
        'sale_lines',
        'sales',
        'consents',
        'package_usages',
        'service_packages',
        'service_supplies',
        'supplier_prices',
        'inventory_movements',
        'money_transactions',
        'appointments',
        'cash_sessions',
        'suppliers',
        'products',
        'clients',
      ]) {
        await txn.delete(table);
      }
    });
    notifyListeners();
  }
}