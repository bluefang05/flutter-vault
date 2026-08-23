import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _open();
    return _database!;
  }

  Future<Database> _open() async {
    final root = await getDatabasesPath();
    final path = p.join(root, 'pymerd.db');
    return openDatabase(
      path,
      version: 4,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await _createCoreTables(db);
        await _createVersion2Tables(db);
        await _createVersion3Indexes(db);
        await _createVersion4Tables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createVersion2Tables(db);
        }
        if (oldVersion < 3) {
          await _upgradeToVersion3(db);
        }
        if (oldVersion < 4) {
          await _createVersion4Tables(db);
        }
      },
    );
  }

  Future<void> _createCoreTables(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS clients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL DEFAULT '',
        notes TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS services (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        duration_minutes INTEGER NOT NULL,
        price_cents INTEGER NOT NULL,
        cost_cents INTEGER NOT NULL DEFAULT 0,
        home_service INTEGER NOT NULL DEFAULT 0,
        active INTEGER NOT NULL DEFAULT 1
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS appointments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        client_id INTEGER NOT NULL,
        service_id INTEGER NOT NULL,
        start_at TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        agreed_price_cents INTEGER NOT NULL,
        deposit_cents INTEGER NOT NULL DEFAULT 0,
        balance_cents INTEGER NOT NULL DEFAULT 0,
        location TEXT NOT NULL DEFAULT '',
        notes TEXT NOT NULL DEFAULT '',
        supplies_consumed INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(client_id) REFERENCES clients(id) ON DELETE RESTRICT,
        FOREIGN KEY(service_id) REFERENCES services(id) ON DELETE RESTRICT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS money_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        description TEXT NOT NULL,
        amount_cents INTEGER NOT NULL,
        date TEXT NOT NULL,
        client_id INTEGER,
        appointment_id INTEGER,
        payment_method TEXT NOT NULL DEFAULT 'Efectivo',
        category TEXT NOT NULL DEFAULT '',
        notes TEXT NOT NULL DEFAULT '',
        FOREIGN KEY(client_id) REFERENCES clients(id) ON DELETE SET NULL,
        FOREIGN KEY(appointment_id) REFERENCES appointments(id) ON DELETE SET NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS cash_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        opened_at TEXT NOT NULL,
        closed_at TEXT,
        opening_cents INTEGER NOT NULL,
        expected_cents INTEGER,
        counted_cents INTEGER,
        note TEXT NOT NULL DEFAULT ''
      )
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_appointments_start ON appointments(start_at)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_transactions_date ON money_transactions(date)');
  }

  Future<void> _createVersion2Tables(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        kind TEXT NOT NULL DEFAULT 'supply',
        unit TEXT NOT NULL DEFAULT 'unidad',
        stock REAL NOT NULL DEFAULT 0,
        minimum_stock REAL NOT NULL DEFAULT 0,
        cost_cents INTEGER NOT NULL DEFAULT 0,
        sale_price_cents INTEGER NOT NULL DEFAULT 0,
        expiry_date TEXT,
        active INTEGER NOT NULL DEFAULT 1
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS suppliers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL DEFAULT '',
        whatsapp TEXT NOT NULL DEFAULT '',
        address TEXT NOT NULL DEFAULT '',
        notes TEXT NOT NULL DEFAULT '',
        active INTEGER NOT NULL DEFAULT 1
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS supplier_prices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        supplier_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity REAL NOT NULL,
        price_cents INTEGER NOT NULL,
        delivery_cents INTEGER NOT NULL DEFAULT 0,
        recorded_at TEXT NOT NULL,
        notes TEXT NOT NULL DEFAULT '',
        FOREIGN KEY(supplier_id) REFERENCES suppliers(id) ON DELETE CASCADE,
        FOREIGN KEY(product_id) REFERENCES products(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS inventory_movements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        quantity REAL NOT NULL,
        total_cost_cents INTEGER NOT NULL DEFAULT 0,
        date TEXT NOT NULL,
        reference TEXT NOT NULL DEFAULT '',
        notes TEXT NOT NULL DEFAULT '',
        FOREIGN KEY(product_id) REFERENCES products(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS service_supplies (
        service_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity REAL NOT NULL,
        PRIMARY KEY(service_id, product_id),
        FOREIGN KEY(service_id) REFERENCES services(id) ON DELETE CASCADE,
        FOREIGN KEY(product_id) REFERENCES products(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS service_packages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        client_id INTEGER NOT NULL,
        service_id INTEGER,
        name TEXT NOT NULL,
        total_sessions INTEGER NOT NULL,
        used_sessions INTEGER NOT NULL DEFAULT 0,
        total_cents INTEGER NOT NULL,
        paid_cents INTEGER NOT NULL DEFAULT 0,
        expires_at TEXT,
        status TEXT NOT NULL DEFAULT 'active',
        created_at TEXT NOT NULL,
        FOREIGN KEY(client_id) REFERENCES clients(id) ON DELETE CASCADE,
        FOREIGN KEY(service_id) REFERENCES services(id) ON DELETE SET NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS package_usages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        package_id INTEGER NOT NULL,
        appointment_id INTEGER,
        used_at TEXT NOT NULL,
        notes TEXT NOT NULL DEFAULT '',
        FOREIGN KEY(package_id) REFERENCES service_packages(id) ON DELETE CASCADE,
        FOREIGN KEY(appointment_id) REFERENCES appointments(id) ON DELETE SET NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS consents (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        client_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        text_version TEXT NOT NULL DEFAULT '1',
        accepted INTEGER NOT NULL DEFAULT 0,
        allow_photo_storage INTEGER NOT NULL DEFAULT 0,
        allow_promotion INTEGER NOT NULL DEFAULT 0,
        signed_name TEXT NOT NULL DEFAULT '',
        date TEXT NOT NULL,
        notes TEXT NOT NULL DEFAULT '',
        FOREIGN KEY(client_id) REFERENCES clients(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS client_photos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        client_id INTEGER NOT NULL,
        appointment_id INTEGER,
        kind TEXT NOT NULL,
        file_name TEXT NOT NULL,
        mime_type TEXT NOT NULL,
        bytes BLOB NOT NULL,
        date TEXT NOT NULL,
        promotion_authorized INTEGER NOT NULL DEFAULT 0,
        notes TEXT NOT NULL DEFAULT '',
        FOREIGN KEY(client_id) REFERENCES clients(id) ON DELETE CASCADE,
        FOREIGN KEY(appointment_id) REFERENCES appointments(id) ON DELETE SET NULL
      )
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_inventory_product ON inventory_movements(product_id, date)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_supplier_prices_product ON supplier_prices(product_id, recorded_at)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_packages_client ON service_packages(client_id, status)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_consents_client ON consents(client_id, date)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_photos_client ON client_photos(client_id, date)');
  }


  Future<void> _upgradeToVersion3(DatabaseExecutor db) async {
    final columns = await db.rawQuery('PRAGMA table_info(appointments)');
    final hasSuppliesConsumed = columns.any(
      (column) => column['name'] == 'supplies_consumed',
    );
    if (!hasSuppliesConsumed) {
      await db.execute(
        'ALTER TABLE appointments ADD COLUMN supplies_consumed INTEGER NOT NULL DEFAULT 0',
      );
    }
    await _createVersion3Indexes(db);
  }

  Future<void> _createVersion3Indexes(DatabaseExecutor db) async {
    await db.execute('''
      CREATE UNIQUE INDEX IF NOT EXISTS idx_package_usage_appointment
      ON package_usages(appointment_id)
      WHERE appointment_id IS NOT NULL
    ''');
  }

  Future<void> _createVersion4Tables(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        client_id INTEGER,
        date TEXT NOT NULL,
        subtotal_cents INTEGER NOT NULL,
        discount_cents INTEGER NOT NULL DEFAULT 0,
        tip_cents INTEGER NOT NULL DEFAULT 0,
        total_cents INTEGER NOT NULL,
        paid_cents INTEGER NOT NULL DEFAULT 0,
        payment_method TEXT NOT NULL DEFAULT 'Efectivo',
        status TEXT NOT NULL DEFAULT 'paid',
        notes TEXT NOT NULL DEFAULT '',
        FOREIGN KEY(client_id) REFERENCES clients(id) ON DELETE SET NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sale_lines (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id INTEGER NOT NULL,
        item_type TEXT NOT NULL,
        item_id INTEGER,
        description TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit_price_cents INTEGER NOT NULL,
        unit_cost_cents INTEGER NOT NULL DEFAULT 0,
        total_cents INTEGER NOT NULL,
        FOREIGN KEY(sale_id) REFERENCES sales(id) ON DELETE CASCADE
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sales_date ON sales(date)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sales_client ON sales(client_id, date)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sale_lines_sale ON sale_lines(sale_id)',
    );
  }

  Future<String> databasePath() async {
    final db = await database;
    return db.path;
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  Future<void> deleteDatabaseFile() async {
    final path = await databasePath();
    await close();
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}