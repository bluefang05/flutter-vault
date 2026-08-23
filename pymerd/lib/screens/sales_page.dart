import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_repository.dart';
import '../models.dart';
import '../services/native_file_service.dart';
import '../services/pdf_service.dart';
import '../utils.dart';
import '../widgets/common.dart';

class QuickSalePage extends StatefulWidget {
  final AppRepository repository;

  const QuickSalePage({super.key, required this.repository});

  @override
  State<QuickSalePage> createState() => _QuickSalePageState();
}

class _QuickSalePageState extends State<QuickSalePage> {
  final _discount = TextEditingController(text: '0');
  final _tip = TextEditingController(text: '0');
  final _paid = TextEditingController(text: '0');
  final _notes = TextEditingController();
  List<Client> _clients = const [];
  List<ServiceItem> _services = const [];
  List<ProductItem> _products = const [];
  final List<_CartItem> _cart = [];
  int? _clientId;
  String _paymentMethod = 'Efectivo';
  bool _payInFull = true;
  bool _loading = true;
  bool _saving = false;

  int get _subtotal =>
      _cart.fold<int>(0, (sum, item) => sum + item.totalCents);
  int get _discountCents =>
      parseMoneyToCents(_discount.text).clamp(0, _subtotal).toInt();
  int get _tipCents => parseMoneyToCents(_tip.text).clamp(0, 1 << 62).toInt();
  int get _total => _subtotal - _discountCents + _tipCents;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      widget.repository.getClients(),
      widget.repository.getServices(),
      widget.repository.getProducts(),
    ]);
    if (!mounted) return;
    setState(() {
      _clients = results[0] as List<Client>;
      _services = results[1] as List<ServiceItem>;
      _products = (results[2] as List<ProductItem>)
          .where((item) => item.kind == 'sale')
          .toList();
      _loading = false;
    });
  }

  @override
  void dispose() {
    _discount.dispose();
    _tip.dispose();
    _paid.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _refreshTotals() => setState(() {});

  Future<void> _addService() async {
    if (_services.isEmpty) {
      _message('Primero crea un servicio en Más > Servicios y precios.');
      return;
    }
    var selectedId = _services.first.id!;
    final price = TextEditingController(
      text: (_services.first.priceCents / 100).toStringAsFixed(2),
    );
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Agregar servicio'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                initialValue: selectedId,
                decoration: const InputDecoration(labelText: 'Servicio'),
                items: _services
                    .map(
                      (item) => DropdownMenuItem(
                        value: item.id!,
                        child: Text(item.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  final service =
                      _services.firstWhere((item) => item.id == value);
                  setDialogState(() {
                    selectedId = value;
                    price.text =
                        (service.priceCents / 100).toStringAsFixed(2);
                  });
                },
              ),
              const SizedBox(height: 12),
              MoneyField(controller: price, label: 'Precio aplicado'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
    if (saved == true) {
      final service = _services.firstWhere((item) => item.id == selectedId);
      final unitPrice = parseMoneyToCents(price.text);
      if (unitPrice > 0) {
        setState(() {
          _cart.add(
            _CartItem(
              itemType: 'service',
              itemId: service.id!,
              description: service.name,
              quantity: 1,
              unitPriceCents: unitPrice,
              unitCostCents: service.costCents,
            ),
          );
        });
      }
    }
    price.dispose();
  }

  Future<void> _addProduct() async {
    if (_products.isEmpty) {
      _message(
        'Primero crea un artículo de tipo “Producto para vender” en Inventario.',
      );
      return;
    }
    var selectedId = _products.first.id!;
    final quantity = TextEditingController(text: '1');
    final price = TextEditingController(
      text: (_products.first.salePriceCents / 100).toStringAsFixed(2),
    );
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final selected =
              _products.firstWhere((item) => item.id == selectedId);
          return AlertDialog(
            title: const Text('Agregar producto'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: selectedId,
                    decoration: const InputDecoration(labelText: 'Producto'),
                    items: _products
                        .map(
                          (item) => DropdownMenuItem(
                            value: item.id!,
                            child: Text(item.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      final product =
                          _products.firstWhere((item) => item.id == value);
                      setDialogState(() {
                        selectedId = value;
                        price.text =
                            (product.salePriceCents / 100).toStringAsFixed(2);
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Disponible: ${formatSaleQuantity(selected.stock)} ${selected.unit}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: quantity,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Cantidad en ${selected.unit}',
                    ),
                  ),
                  const SizedBox(height: 12),
                  MoneyField(controller: price, label: 'Precio por unidad'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Agregar'),
              ),
            ],
          );
        },
      ),
    );
    if (saved == true) {
      final product = _products.firstWhere((item) => item.id == selectedId);
      final qty = parseSaleQuantity(quantity.text);
      final already = _cart
          .where(
            (item) =>
                item.itemType == 'product' && item.itemId == product.id,
          )
          .fold<double>(0, (sum, item) => sum + item.quantity);
      if (qty <= 0) {
        _message('Escribe una cantidad mayor que cero.');
      } else if (already + qty > product.stock + 0.000001) {
        _message('La cantidad supera la existencia disponible.');
      } else {
        final unitPrice = parseMoneyToCents(price.text);
        if (unitPrice > 0) {
          setState(() {
            _cart.add(
              _CartItem(
                itemType: 'product',
                itemId: product.id!,
                description: product.name,
                quantity: qty,
                unitPriceCents: unitPrice,
                unitCostCents: product.costCents,
                stockAvailable: product.stock,
                unit: product.unit,
              ),
            );
          });
        }
      }
    }
    quantity.dispose();
    price.dispose();
  }

  void _changeQuantity(int index, double delta) {
    final current = _cart[index];
    final next = current.quantity + delta;
    if (next <= 0) {
      setState(() => _cart.removeAt(index));
      return;
    }
    if (current.stockAvailable != null) {
      final otherQuantity = _cart
          .asMap()
          .entries
          .where(
            (entry) =>
                entry.key != index &&
                entry.value.itemType == 'product' &&
                entry.value.itemId == current.itemId,
          )
          .fold<double>(0, (sum, entry) => sum + entry.value.quantity);
      if (otherQuantity + next > current.stockAvailable! + 0.000001) {
        _message('No hay más existencia disponible.');
        return;
      }
    }
    setState(() => _cart[index] = current.copyWith(quantity: next));
  }

  Future<void> _save() async {
    if (_cart.isEmpty || _saving) return;
    final total = _total;
    final paid = _payInFull ? total : parseMoneyToCents(_paid.text);
    if (paid > total) {
      _message('El monto recibido no puede superar el total.');
      return;
    }
    setState(() => _saving = true);
    try {
      final id = await widget.repository.createSale(
        clientId: _clientId,
        lines: _cart.map((item) => item.toSaleLine()).toList(),
        discountCents: _discountCents,
        tipCents: _tipCents,
        paidCents: paid,
        paymentMethod: _paymentMethod,
        notes: _notes.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SaleDetailsPage(
            repository: widget.repository,
            saleId: id,
          ),
        ),
      );
    } catch (error) {
      _message('$error');
      if (mounted) setState(() => _saving = false);
    }
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva venta')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
              children: [
                DropdownButtonFormField<int?>(
                  initialValue: _clientId,
                  decoration: const InputDecoration(
                    labelText: 'Cliente',
                    helperText: 'Opcional',
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Venta sin cliente'),
                    ),
                    ..._clients.map(
                      (item) => DropdownMenuItem<int?>(
                        value: item.id,
                        child: Text(item.name),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => _clientId = value),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _addService,
                        icon: const Icon(Icons.spa_outlined),
                        label: const Text('Servicio'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _addProduct,
                        icon: const Icon(Icons.shopping_bag_outlined),
                        label: const Text('Producto'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Detalle de la venta',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (_cart.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: Text(
                        'Agrega un servicio o un producto para comenzar.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  Card(
                    child: Column(
                      children: [
                        for (var index = 0; index < _cart.length; index++) ...[
                          _CartTile(
                            item: _cart[index],
                            onRemove: () =>
                                setState(() => _cart.removeAt(index)),
                            onMinus: () => _changeQuantity(index, -1),
                            onPlus: () => _changeQuantity(index, 1),
                          ),
                          if (index < _cart.length - 1)
                            const Divider(height: 1),
                        ],
                      ],
                    ),
                  ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _OptionalMoneyField(
                        controller: _discount,
                        label: 'Descuento',
                        onChanged: _refreshTotals,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _OptionalMoneyField(
                        controller: _tip,
                        label: 'Propina',
                        onChanged: _refreshTotals,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _TotalsCard(
                  subtotal: _subtotal,
                  discount: _discountCents,
                  tip: _tipCents,
                  total: _total,
                ),
                const SizedBox(height: 14),
                SwitchListTile(
                  value: _payInFull,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Cobrar el total ahora'),
                  subtitle: const Text(
                    'Desactívalo para registrar un abono o dejar la venta a crédito.',
                  ),
                  onChanged: (value) => setState(() => _payInFull = value),
                ),
                if (!_payInFull) ...[
                  const SizedBox(height: 8),
                  _OptionalMoneyField(
                    controller: _paid,
                    label: 'Monto recibido ahora',
                    helperText: 'Puede ser 0 para dejar todo pendiente.',
                    onChanged: _refreshTotals,
                  ),
                ],
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _paymentMethod,
                  decoration: const InputDecoration(labelText: 'Método de pago'),
                  items: const [
                    DropdownMenuItem(
                      value: 'Efectivo',
                      child: Text('Efectivo'),
                    ),
                    DropdownMenuItem(
                      value: 'Transferencia',
                      child: Text('Transferencia'),
                    ),
                    DropdownMenuItem(
                      value: 'Tarjeta',
                      child: Text('Tarjeta'),
                    ),
                    DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                  ],
                  onChanged: (value) => setState(
                    () => _paymentMethod = value ?? _paymentMethod,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _notes,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Notas',
                    helperText: 'Opcional',
                  ),
                ),
              ],
            ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton.icon(
            onPressed: _cart.isEmpty || _saving ? null : _save,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_circle_outline),
            label: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text('Guardar venta · ${formatMoney(_total)}'),
            ),
          ),
        ),
      ),
    );
  }
}

class SalesHistoryPage extends StatefulWidget {
  final AppRepository repository;

  const SalesHistoryPage({super.key, required this.repository});

  @override
  State<SalesHistoryPage> createState() => _SalesHistoryPageState();
}

class _SalesHistoryPageState extends State<SalesHistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ventas y recibos')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => QuickSalePage(repository: widget.repository),
            ),
          );
          setState(() {});
        },
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Nueva venta'),
      ),
      body: FutureBuilder<List<SaleRecord>>(
        future: widget.repository.getSales(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final sales = snapshot.data ?? const <SaleRecord>[];
          if (sales.isEmpty) {
            return EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Todavía no hay ventas detalladas',
              message:
                  'Las nuevas ventas conservarán sus artículos, descuentos, propinas, pagos y saldo.',
              actionLabel: 'Crear venta',
              onAction: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        QuickSalePage(repository: widget.repository),
                  ),
                );
                setState(() {});
              },
            );
          }
          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              itemCount: sales.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final sale = sales[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('#${sale.id ?? ''}'),
                    ),
                    title: Text(
                      sale.clientName ?? 'Venta sin cliente',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${formatDateTime(sale.date)} · ${saleStatusLabel(sale.status)}${sale.balanceCents > 0 ? '\nPendiente ${formatMoney(sale.balanceCents)}' : ''}',
                    ),
                    isThreeLine: sale.balanceCents > 0,
                    trailing: Text(
                      formatMoney(sale.totalCents),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SaleDetailsPage(
                            repository: widget.repository,
                            saleId: sale.id!,
                          ),
                        ),
                      );
                      setState(() {});
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class SaleDetailsPage extends StatefulWidget {
  final AppRepository repository;
  final int saleId;

  const SaleDetailsPage({
    super.key,
    required this.repository,
    required this.saleId,
  });

  @override
  State<SaleDetailsPage> createState() => _SaleDetailsPageState();
}

class _SaleDetailsPageState extends State<SaleDetailsPage> {
  Future<_SaleDetailsData> _load() async {
    final sale = await widget.repository.getSale(widget.saleId);
    if (sale == null) throw StateError('La venta ya no existe.');
    final lines = await widget.repository.getSaleLines(widget.saleId);
    return _SaleDetailsData(sale: sale, lines: lines);
  }

  Future<void> _saveReceipt(SaleRecord sale, List<SaleLine> lines) async {
    final settings = await widget.repository.getAllSettings();
    final bytes = await PdfService.saleReceipt(
      businessName: settings['business_name'] ?? 'Mi negocio',
      sale: sale,
      lines: lines,
    );
    final ok = await NativeFileService.saveBytes(
      fileName: 'venta_${sale.id}.pdf',
      mimeType: 'application/pdf',
      bytes: bytes,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Recibo guardado.' : 'No se guardó.')),
    );
  }

  Future<void> _payment(SaleRecord sale) async {
    if (sale.balanceCents <= 0) return;
    final amount = TextEditingController(
      text: (sale.balanceCents / 100).toStringAsFixed(2),
    );
    var method = 'Efectivo';
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Registrar abono'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MoneyField(controller: amount, label: 'Monto recibido'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: method,
                decoration: const InputDecoration(labelText: 'Método'),
                items: const [
                  DropdownMenuItem(
                    value: 'Efectivo',
                    child: Text('Efectivo'),
                  ),
                  DropdownMenuItem(
                    value: 'Transferencia',
                    child: Text('Transferencia'),
                  ),
                  DropdownMenuItem(value: 'Tarjeta', child: Text('Tarjeta')),
                  DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                ],
                onChanged: (value) =>
                    setDialogState(() => method = value ?? method),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
    if (saved == true) {
      final value = parseMoneyToCents(amount.text);
      if (value <= 0 || value > sale.balanceCents) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Revisa el monto del abono.')),
          );
        }
      } else {
        await widget.repository.registerSalePayment(
          sale: sale,
          amountCents: value,
          paymentMethod: method,
        );
        setState(() {});
      }
    }
    amount.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Venta #${widget.saleId}')),
      body: FutureBuilder<_SaleDetailsData>(
        future: _load(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          final data = snapshot.data!;
          final sale = data.sale;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _SaleRow(
                        label: 'Fecha',
                        value: formatDateTime(sale.date),
                      ),
                      _SaleRow(
                        label: 'Cliente',
                        value: sale.clientName ?? 'Sin cliente',
                      ),
                      _SaleRow(
                        label: 'Estado',
                        value: saleStatusLabel(sale.status),
                      ),
                      _SaleRow(
                        label: 'Método',
                        value: sale.paymentMethod,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    for (var index = 0; index < data.lines.length; index++) ...[
                      ListTile(
                        title: Text(data.lines[index].description),
                        subtitle: Text(
                          '${formatSaleQuantity(data.lines[index].quantity)} × ${formatMoney(data.lines[index].unitPriceCents)}',
                        ),
                        trailing: Text(
                          formatMoney(data.lines[index].totalCents),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (index < data.lines.length - 1)
                        const Divider(height: 1),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _TotalsCard(
                subtotal: sale.subtotalCents,
                discount: sale.discountCents,
                tip: sale.tipCents,
                total: sale.totalCents,
                paid: sale.paidCents,
              ),
              if (sale.notes.isNotEmpty) ...[
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(sale.notes),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => _saveReceipt(sale, data.lines),
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Guardar recibo detallado'),
                ),
              ),
              if (sale.balanceCents > 0) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _payment(sale),
                  icon: const Icon(Icons.add_card),
                  label: Text(
                    'Registrar abono · debe ${formatMoney(sale.balanceCents)}',
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _CartItem {
  final String itemType;
  final int itemId;
  final String description;
  final double quantity;
  final int unitPriceCents;
  final int unitCostCents;
  final double? stockAvailable;
  final String unit;

  const _CartItem({
    required this.itemType,
    required this.itemId,
    required this.description,
    required this.quantity,
    required this.unitPriceCents,
    required this.unitCostCents,
    this.stockAvailable,
    this.unit = 'unidad',
  });

  int get totalCents => (quantity * unitPriceCents).round();

  _CartItem copyWith({double? quantity}) => _CartItem(
        itemType: itemType,
        itemId: itemId,
        description: description,
        quantity: quantity ?? this.quantity,
        unitPriceCents: unitPriceCents,
        unitCostCents: unitCostCents,
        stockAvailable: stockAvailable,
        unit: unit,
      );

  SaleLine toSaleLine() => SaleLine(
        itemType: itemType,
        itemId: itemId,
        description: description,
        quantity: quantity,
        unitPriceCents: unitPriceCents,
        unitCostCents: unitCostCents,
        totalCents: totalCents,
      );
}

class _CartTile extends StatelessWidget {
  final _CartItem item;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onRemove;

  const _CartTile({
    required this.item,
    required this.onMinus,
    required this.onPlus,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${formatSaleQuantity(item.quantity)} ${item.itemType == 'product' ? item.unit : ''} × ${formatMoney(item.unitPriceCents)}',
                ),
                Text(
                  formatMoney(item.totalCents),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(onPressed: onMinus, icon: const Icon(Icons.remove_circle)),
          IconButton(onPressed: onPlus, icon: const Icon(Icons.add_circle)),
          IconButton(onPressed: onRemove, icon: const Icon(Icons.delete_outline)),
        ],
      ),
    );
  }
}

class _OptionalMoneyField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? helperText;
  final VoidCallback onChanged;

  const _OptionalMoneyField({
    required this.controller,
    required this.label,
    this.helperText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
      ],
      decoration: InputDecoration(
        labelText: label,
        prefixText: 'RD\$ ',
        helperText: helperText,
      ),
      onChanged: (_) => onChanged(),
    );
  }
}

class _TotalsCard extends StatelessWidget {
  final int subtotal;
  final int discount;
  final int tip;
  final int total;
  final int? paid;

  const _TotalsCard({
    required this.subtotal,
    required this.discount,
    required this.tip,
    required this.total,
    this.paid,
  });

  @override
  Widget build(BuildContext context) {
    final balance = paid == null ? null : total - paid!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _SaleRow(label: 'Subtotal', value: formatMoney(subtotal)),
            if (discount > 0)
              _SaleRow(label: 'Descuento', value: '-${formatMoney(discount)}'),
            if (tip > 0) _SaleRow(label: 'Propina', value: formatMoney(tip)),
            const Divider(),
            _SaleRow(
              label: 'Total',
              value: formatMoney(total),
              important: true,
            ),
            if (paid != null) ...[
              _SaleRow(label: 'Pagado', value: formatMoney(paid!)),
              _SaleRow(
                label: 'Pendiente',
                value: formatMoney(balance!.clamp(0, 1 << 62).toInt()),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SaleRow extends StatelessWidget {
  final String label;
  final String value;
  final bool important;

  const _SaleRow({
    required this.label,
    required this.value,
    this.important = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: important ? FontWeight.w800 : FontWeight.w600,
                fontSize: important ? 18 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaleDetailsData {
  final SaleRecord sale;
  final List<SaleLine> lines;

  const _SaleDetailsData({required this.sale, required this.lines});
}

String saleStatusLabel(String status) {
  switch (status) {
    case 'paid':
      return 'Pagada';
    case 'partial':
      return 'Pago parcial';
    case 'credit':
      return 'A crédito';
    case 'cancelled':
      return 'Cancelada';
    default:
      return status;
  }
}

String formatSaleQuantity(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

double parseSaleQuantity(String raw) =>
    double.tryParse(raw.trim().replaceAll(',', '.')) ?? 0;
