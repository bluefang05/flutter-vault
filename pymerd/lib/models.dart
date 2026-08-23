import 'dart:typed_data';

class Client {
  final int? id;
  final String name;
  final String phone;
  final String notes;
  final DateTime createdAt;

  const Client({
    this.id,
    required this.name,
    this.phone = '',
    this.notes = '',
    required this.createdAt,
  });

  factory Client.fromMap(Map<String, Object?> map) => Client(
        id: map['id'] as int?,
        name: map['name'] as String,
        phone: (map['phone'] as String?) ?? '',
        notes: (map['notes'] as String?) ?? '',
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'phone': phone,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
      };
}

class ServiceItem {
  final int? id;
  final String name;
  final int durationMinutes;
  final int priceCents;
  final int costCents;
  final bool homeService;
  final bool active;

  const ServiceItem({
    this.id,
    required this.name,
    required this.durationMinutes,
    required this.priceCents,
    this.costCents = 0,
    this.homeService = false,
    this.active = true,
  });

  factory ServiceItem.fromMap(Map<String, Object?> map) => ServiceItem(
        id: map['id'] as int?,
        name: map['name'] as String,
        durationMinutes: map['duration_minutes'] as int,
        priceCents: map['price_cents'] as int,
        costCents: (map['cost_cents'] as int?) ?? 0,
        homeService: (map['home_service'] as int? ?? 0) == 1,
        active: (map['active'] as int? ?? 1) == 1,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'duration_minutes': durationMinutes,
        'price_cents': priceCents,
        'cost_cents': costCents,
        'home_service': homeService ? 1 : 0,
        'active': active ? 1 : 0,
      };
}

class AppointmentItem {
  final int? id;
  final int clientId;
  final int serviceId;
  final DateTime startAt;
  final String status;
  final int agreedPriceCents;
  final int depositCents;
  final int balanceCents;
  final String location;
  final String notes;
  final String? clientName;
  final String? serviceName;

  const AppointmentItem({
    this.id,
    required this.clientId,
    required this.serviceId,
    required this.startAt,
    required this.status,
    required this.agreedPriceCents,
    required this.depositCents,
    required this.balanceCents,
    this.location = '',
    this.notes = '',
    this.clientName,
    this.serviceName,
  });

  factory AppointmentItem.fromMap(Map<String, Object?> map) => AppointmentItem(
        id: map['id'] as int?,
        clientId: map['client_id'] as int,
        serviceId: map['service_id'] as int,
        startAt: DateTime.parse(map['start_at'] as String),
        status: map['status'] as String,
        agreedPriceCents: map['agreed_price_cents'] as int,
        depositCents: map['deposit_cents'] as int,
        balanceCents: map['balance_cents'] as int,
        location: (map['location'] as String?) ?? '',
        notes: (map['notes'] as String?) ?? '',
        clientName: map['client_name'] as String?,
        serviceName: map['service_name'] as String?,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'client_id': clientId,
        'service_id': serviceId,
        'start_at': startAt.toIso8601String(),
        'status': status,
        'agreed_price_cents': agreedPriceCents,
        'deposit_cents': depositCents,
        'balance_cents': balanceCents,
        'location': location,
        'notes': notes,
      };
}

class MoneyTransaction {
  final int? id;
  final String type;
  final String description;
  final int amountCents;
  final DateTime date;
  final int? clientId;
  final int? appointmentId;
  final String paymentMethod;
  final String category;
  final String notes;
  final String? clientName;

  const MoneyTransaction({
    this.id,
    required this.type,
    required this.description,
    required this.amountCents,
    required this.date,
    this.clientId,
    this.appointmentId,
    this.paymentMethod = 'Efectivo',
    this.category = '',
    this.notes = '',
    this.clientName,
  });

  factory MoneyTransaction.fromMap(Map<String, Object?> map) => MoneyTransaction(
        id: map['id'] as int?,
        type: map['type'] as String,
        description: map['description'] as String,
        amountCents: map['amount_cents'] as int,
        date: DateTime.parse(map['date'] as String),
        clientId: map['client_id'] as int?,
        appointmentId: map['appointment_id'] as int?,
        paymentMethod: (map['payment_method'] as String?) ?? 'Efectivo',
        category: (map['category'] as String?) ?? '',
        notes: (map['notes'] as String?) ?? '',
        clientName: map['client_name'] as String?,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'type': type,
        'description': description,
        'amount_cents': amountCents,
        'date': date.toIso8601String(),
        'client_id': clientId,
        'appointment_id': appointmentId,
        'payment_method': paymentMethod,
        'category': category,
        'notes': notes,
      };
}

class DashboardSummary {
  final int todayAppointments;
  final int todayIncomeCents;
  final int todayExpenseCents;
  final int pendingCents;

  const DashboardSummary({
    required this.todayAppointments,
    required this.todayIncomeCents,
    required this.todayExpenseCents,
    required this.pendingCents,
  });
}

class CashSession {
  final int? id;
  final DateTime openedAt;
  final DateTime? closedAt;
  final int openingCents;
  final int? expectedCents;
  final int? countedCents;
  final String note;

  const CashSession({
    this.id,
    required this.openedAt,
    this.closedAt,
    required this.openingCents,
    this.expectedCents,
    this.countedCents,
    this.note = '',
  });

  factory CashSession.fromMap(Map<String, Object?> map) => CashSession(
        id: map['id'] as int?,
        openedAt: DateTime.parse(map['opened_at'] as String),
        closedAt: map['closed_at'] == null
            ? null
            : DateTime.parse(map['closed_at'] as String),
        openingCents: map['opening_cents'] as int,
        expectedCents: map['expected_cents'] as int?,
        countedCents: map['counted_cents'] as int?,
        note: (map['note'] as String?) ?? '',
      );
}

class ProductItem {
  final int? id;
  final String name;
  final String kind;
  final String unit;
  final double stock;
  final double minimumStock;
  final int costCents;
  final int salePriceCents;
  final DateTime? expiryDate;
  final bool active;

  const ProductItem({
    this.id,
    required this.name,
    this.kind = 'supply',
    this.unit = 'unidad',
    this.stock = 0,
    this.minimumStock = 0,
    this.costCents = 0,
    this.salePriceCents = 0,
    this.expiryDate,
    this.active = true,
  });

  bool get isLowStock => active && minimumStock > 0 && stock <= minimumStock;

  factory ProductItem.fromMap(Map<String, Object?> map) => ProductItem(
        id: map['id'] as int?,
        name: map['name'] as String,
        kind: (map['kind'] as String?) ?? 'supply',
        unit: (map['unit'] as String?) ?? 'unidad',
        stock: (map['stock'] as num? ?? 0).toDouble(),
        minimumStock: (map['minimum_stock'] as num? ?? 0).toDouble(),
        costCents: (map['cost_cents'] as int?) ?? 0,
        salePriceCents: (map['sale_price_cents'] as int?) ?? 0,
        expiryDate: map['expiry_date'] == null
            ? null
            : DateTime.tryParse(map['expiry_date'] as String),
        active: (map['active'] as int? ?? 1) == 1,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'kind': kind,
        'unit': unit,
        'stock': stock,
        'minimum_stock': minimumStock,
        'cost_cents': costCents,
        'sale_price_cents': salePriceCents,
        'expiry_date': expiryDate?.toIso8601String(),
        'active': active ? 1 : 0,
      };
}

class InventoryMovement {
  final int? id;
  final int productId;
  final String type;
  final double quantity;
  final int totalCostCents;
  final DateTime date;
  final String reference;
  final String notes;
  final String? productName;

  const InventoryMovement({
    this.id,
    required this.productId,
    required this.type,
    required this.quantity,
    this.totalCostCents = 0,
    required this.date,
    this.reference = '',
    this.notes = '',
    this.productName,
  });

  factory InventoryMovement.fromMap(Map<String, Object?> map) => InventoryMovement(
        id: map['id'] as int?,
        productId: map['product_id'] as int,
        type: map['type'] as String,
        quantity: (map['quantity'] as num).toDouble(),
        totalCostCents: (map['total_cost_cents'] as int?) ?? 0,
        date: DateTime.parse(map['date'] as String),
        reference: (map['reference'] as String?) ?? '',
        notes: (map['notes'] as String?) ?? '',
        productName: map['product_name'] as String?,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'product_id': productId,
        'type': type,
        'quantity': quantity,
        'total_cost_cents': totalCostCents,
        'date': date.toIso8601String(),
        'reference': reference,
        'notes': notes,
      };
}

class SupplierItem {
  final int? id;
  final String name;
  final String phone;
  final String whatsapp;
  final String address;
  final String notes;
  final bool active;

  const SupplierItem({
    this.id,
    required this.name,
    this.phone = '',
    this.whatsapp = '',
    this.address = '',
    this.notes = '',
    this.active = true,
  });

  factory SupplierItem.fromMap(Map<String, Object?> map) => SupplierItem(
        id: map['id'] as int?,
        name: map['name'] as String,
        phone: (map['phone'] as String?) ?? '',
        whatsapp: (map['whatsapp'] as String?) ?? '',
        address: (map['address'] as String?) ?? '',
        notes: (map['notes'] as String?) ?? '',
        active: (map['active'] as int? ?? 1) == 1,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'phone': phone,
        'whatsapp': whatsapp,
        'address': address,
        'notes': notes,
        'active': active ? 1 : 0,
      };
}

class SupplierPrice {
  final int? id;
  final int supplierId;
  final int productId;
  final double quantity;
  final int priceCents;
  final int deliveryCents;
  final DateTime recordedAt;
  final String notes;
  final String? supplierName;
  final String? productName;
  final String? unit;

  const SupplierPrice({
    this.id,
    required this.supplierId,
    required this.productId,
    required this.quantity,
    required this.priceCents,
    this.deliveryCents = 0,
    required this.recordedAt,
    this.notes = '',
    this.supplierName,
    this.productName,
    this.unit,
  });

  int get effectiveTotalCents => priceCents + deliveryCents;
  double get unitCostCents => quantity <= 0 ? 0 : effectiveTotalCents / quantity;

  factory SupplierPrice.fromMap(Map<String, Object?> map) => SupplierPrice(
        id: map['id'] as int?,
        supplierId: map['supplier_id'] as int,
        productId: map['product_id'] as int,
        quantity: (map['quantity'] as num).toDouble(),
        priceCents: map['price_cents'] as int,
        deliveryCents: (map['delivery_cents'] as int?) ?? 0,
        recordedAt: DateTime.parse(map['recorded_at'] as String),
        notes: (map['notes'] as String?) ?? '',
        supplierName: map['supplier_name'] as String?,
        productName: map['product_name'] as String?,
        unit: map['unit'] as String?,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'supplier_id': supplierId,
        'product_id': productId,
        'quantity': quantity,
        'price_cents': priceCents,
        'delivery_cents': deliveryCents,
        'recorded_at': recordedAt.toIso8601String(),
        'notes': notes,
      };
}

class ServiceSupply {
  final int serviceId;
  final int productId;
  final double quantity;
  final String? productName;
  final String? unit;
  final int productCostCents;

  const ServiceSupply({
    required this.serviceId,
    required this.productId,
    required this.quantity,
    this.productName,
    this.unit,
    this.productCostCents = 0,
  });

  int get estimatedCostCents => (quantity * productCostCents).round();

  factory ServiceSupply.fromMap(Map<String, Object?> map) => ServiceSupply(
        serviceId: map['service_id'] as int,
        productId: map['product_id'] as int,
        quantity: (map['quantity'] as num).toDouble(),
        productName: map['product_name'] as String?,
        unit: map['unit'] as String?,
        productCostCents: (map['product_cost_cents'] as int?) ?? 0,
      );

  Map<String, Object?> toMap() => {
        'service_id': serviceId,
        'product_id': productId,
        'quantity': quantity,
      };
}

class ServicePackage {
  final int? id;
  final int clientId;
  final int? serviceId;
  final String name;
  final int totalSessions;
  final int usedSessions;
  final int totalCents;
  final int paidCents;
  final DateTime? expiresAt;
  final String status;
  final DateTime createdAt;
  final String? clientName;
  final String? serviceName;

  const ServicePackage({
    this.id,
    required this.clientId,
    this.serviceId,
    required this.name,
    required this.totalSessions,
    this.usedSessions = 0,
    required this.totalCents,
    this.paidCents = 0,
    this.expiresAt,
    this.status = 'active',
    required this.createdAt,
    this.clientName,
    this.serviceName,
  });

  int get remainingSessions => (totalSessions - usedSessions).clamp(0, 1 << 30).toInt();
  int get balanceCents => (totalCents - paidCents).clamp(0, 1 << 62).toInt();
  bool get isUsable => status == 'active' && remainingSessions > 0 &&
      (expiresAt == null || expiresAt!.isAfter(DateTime.now()));

  factory ServicePackage.fromMap(Map<String, Object?> map) => ServicePackage(
        id: map['id'] as int?,
        clientId: map['client_id'] as int,
        serviceId: map['service_id'] as int?,
        name: map['name'] as String,
        totalSessions: map['total_sessions'] as int,
        usedSessions: (map['used_sessions'] as int?) ?? 0,
        totalCents: map['total_cents'] as int,
        paidCents: (map['paid_cents'] as int?) ?? 0,
        expiresAt: map['expires_at'] == null
            ? null
            : DateTime.tryParse(map['expires_at'] as String),
        status: (map['status'] as String?) ?? 'active',
        createdAt: DateTime.parse(map['created_at'] as String),
        clientName: map['client_name'] as String?,
        serviceName: map['service_name'] as String?,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'client_id': clientId,
        'service_id': serviceId,
        'name': name,
        'total_sessions': totalSessions,
        'used_sessions': usedSessions,
        'total_cents': totalCents,
        'paid_cents': paidCents,
        'expires_at': expiresAt?.toIso8601String(),
        'status': status,
        'created_at': createdAt.toIso8601String(),
      };
}

class ConsentRecord {
  final int? id;
  final int clientId;
  final String type;
  final String textVersion;
  final bool accepted;
  final bool allowPhotoStorage;
  final bool allowPromotion;
  final String signedName;
  final DateTime date;
  final String notes;

  const ConsentRecord({
    this.id,
    required this.clientId,
    required this.type,
    required this.textVersion,
    required this.accepted,
    this.allowPhotoStorage = false,
    this.allowPromotion = false,
    this.signedName = '',
    required this.date,
    this.notes = '',
  });

  factory ConsentRecord.fromMap(Map<String, Object?> map) => ConsentRecord(
        id: map['id'] as int?,
        clientId: map['client_id'] as int,
        type: map['type'] as String,
        textVersion: (map['text_version'] as String?) ?? '1',
        accepted: (map['accepted'] as int? ?? 0) == 1,
        allowPhotoStorage: (map['allow_photo_storage'] as int? ?? 0) == 1,
        allowPromotion: (map['allow_promotion'] as int? ?? 0) == 1,
        signedName: (map['signed_name'] as String?) ?? '',
        date: DateTime.parse(map['date'] as String),
        notes: (map['notes'] as String?) ?? '',
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'client_id': clientId,
        'type': type,
        'text_version': textVersion,
        'accepted': accepted ? 1 : 0,
        'allow_photo_storage': allowPhotoStorage ? 1 : 0,
        'allow_promotion': allowPromotion ? 1 : 0,
        'signed_name': signedName,
        'date': date.toIso8601String(),
        'notes': notes,
      };
}

class ClientPhoto {
  final int? id;
  final int clientId;
  final int? appointmentId;
  final String kind;
  final String fileName;
  final String mimeType;
  final List<int> bytes;
  final DateTime date;
  final bool promotionAuthorized;
  final String notes;

  const ClientPhoto({
    this.id,
    required this.clientId,
    this.appointmentId,
    required this.kind,
    required this.fileName,
    required this.mimeType,
    required this.bytes,
    required this.date,
    this.promotionAuthorized = false,
    this.notes = '',
  });

  factory ClientPhoto.fromMap(Map<String, Object?> map) => ClientPhoto(
        id: map['id'] as int?,
        clientId: map['client_id'] as int,
        appointmentId: map['appointment_id'] as int?,
        kind: map['kind'] as String,
        fileName: (map['file_name'] as String?) ?? 'foto',
        mimeType: (map['mime_type'] as String?) ?? 'image/jpeg',
        bytes: List<int>.from(map['bytes'] as List),
        date: DateTime.parse(map['date'] as String),
        promotionAuthorized: (map['promotion_authorized'] as int? ?? 0) == 1,
        notes: (map['notes'] as String?) ?? '',
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'client_id': clientId,
        'appointment_id': appointmentId,
        'kind': kind,
        'file_name': fileName,
        'mime_type': mimeType,
        'bytes': Uint8List.fromList(bytes),
        'date': date.toIso8601String(),
        'promotion_authorized': promotionAuthorized ? 1 : 0,
        'notes': notes,
      };
}
class SaleRecord {
  final int? id;
  final int? clientId;
  final DateTime date;
  final int subtotalCents;
  final int discountCents;
  final int tipCents;
  final int totalCents;
  final int paidCents;
  final String paymentMethod;
  final String status;
  final String notes;
  final String? clientName;

  const SaleRecord({
    this.id,
    this.clientId,
    required this.date,
    required this.subtotalCents,
    this.discountCents = 0,
    this.tipCents = 0,
    required this.totalCents,
    required this.paidCents,
    this.paymentMethod = 'Efectivo',
    this.status = 'paid',
    this.notes = '',
    this.clientName,
  });

  int get balanceCents =>
      (totalCents - paidCents).clamp(0, 1 << 62).toInt();

  factory SaleRecord.fromMap(Map<String, Object?> map) => SaleRecord(
        id: map['id'] as int?,
        clientId: map['client_id'] as int?,
        date: DateTime.parse(map['date'] as String),
        subtotalCents: map['subtotal_cents'] as int,
        discountCents: (map['discount_cents'] as int?) ?? 0,
        tipCents: (map['tip_cents'] as int?) ?? 0,
        totalCents: map['total_cents'] as int,
        paidCents: (map['paid_cents'] as int?) ?? 0,
        paymentMethod: (map['payment_method'] as String?) ?? 'Efectivo',
        status: (map['status'] as String?) ?? 'paid',
        notes: (map['notes'] as String?) ?? '',
        clientName: map['client_name'] as String?,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'client_id': clientId,
        'date': date.toIso8601String(),
        'subtotal_cents': subtotalCents,
        'discount_cents': discountCents,
        'tip_cents': tipCents,
        'total_cents': totalCents,
        'paid_cents': paidCents,
        'payment_method': paymentMethod,
        'status': status,
        'notes': notes,
      };
}

class SaleLine {
  final int? id;
  final int? saleId;
  final String itemType;
  final int? itemId;
  final String description;
  final double quantity;
  final int unitPriceCents;
  final int unitCostCents;
  final int totalCents;

  const SaleLine({
    this.id,
    this.saleId,
    required this.itemType,
    this.itemId,
    required this.description,
    required this.quantity,
    required this.unitPriceCents,
    this.unitCostCents = 0,
    required this.totalCents,
  });

  factory SaleLine.fromMap(Map<String, Object?> map) => SaleLine(
        id: map['id'] as int?,
        saleId: map['sale_id'] as int?,
        itemType: map['item_type'] as String,
        itemId: map['item_id'] as int?,
        description: map['description'] as String,
        quantity: (map['quantity'] as num).toDouble(),
        unitPriceCents: map['unit_price_cents'] as int,
        unitCostCents: (map['unit_cost_cents'] as int?) ?? 0,
        totalCents: map['total_cents'] as int,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        if (saleId != null) 'sale_id': saleId,
        'item_type': itemType,
        'item_id': itemId,
        'description': description,
        'quantity': quantity,
        'unit_price_cents': unitPriceCents,
        'unit_cost_cents': unitCostCents,
        'total_cents': totalCents,
      };
}
