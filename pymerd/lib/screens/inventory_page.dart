import 'package:flutter/material.dart';

import '../app_repository.dart';
import '../models.dart';
import '../utils.dart';
import '../widgets/common.dart';

class InventoryPage extends StatefulWidget {
  final AppRepository repository;

  const InventoryPage({super.key, required this.repository});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  bool _showMovements = false;

  Future<void> _edit([ProductItem? product]) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => ProductForm(
        repository: widget.repository,
        product: product,
      ),
    );
    if (saved == true) setState(() {});
  }

  Future<void> _details(ProductItem product) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => ProductDetails(
        repository: widget.repository,
        product: product,
        onChanged: () => setState(() {}),
        onEdit: () {
          Navigator.pop(context);
          _edit(product);
        },
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario e insumos'),
        actions: [
          IconButton(
            tooltip: _showMovements ? 'Ver existencias' : 'Ver movimientos',
            onPressed: () => setState(() => _showMovements = !_showMovements),
            icon: Icon(_showMovements ? Icons.inventory_2 : Icons.history),
          ),
        ],
      ),
      floatingActionButton: _showMovements
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _edit(),
              icon: const Icon(Icons.add),
              label: const Text('Nuevo artículo'),
            ),
      body: _showMovements ? _movements() : _products(),
    );
  }

  Widget _products() {
    return FutureBuilder<List<ProductItem>>(
      future: widget.repository.getProducts(includeInactive: true),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snapshot.data ?? const <ProductItem>[];
        if (items.isEmpty) {
          return EmptyState(
            icon: Icons.inventory_2_outlined,
            title: 'Todavía no hay inventario',
            message:
                'Registra aceites, cremas, materiales desechables o productos para vender.',
            actionLabel: 'Crear artículo',
            onAction: () => _edit(),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = items[index];
              final color = item.isLowStock ? Colors.orange : null;
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color?.withValues(alpha: 0.12),
                    child: Icon(
                      item.kind == 'sale'
                          ? Icons.shopping_bag_outlined
                          : Icons.science_outlined,
                      color: color,
                    ),
                  ),
                  title: Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '${formatQuantity(item.stock)} ${item.unit} · Costo ${formatMoney(item.costCents)} por ${item.unit}',
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (item.isLowStock)
                        const Text(
                          'Existencia baja',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      else
                        Text(item.active ? 'Activo' : 'Inactivo'),
                      const Icon(Icons.chevron_right, size: 18),
                    ],
                  ),
                  onTap: () => _details(item),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _movements() {
    return FutureBuilder<List<InventoryMovement>>(
      future: widget.repository.getInventoryMovements(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snapshot.data ?? const <InventoryMovement>[];
        if (items.isEmpty) {
          return const EmptyState(
            icon: Icons.history,
            title: 'No hay movimientos',
            message:
                'Las compras, ajustes y consumos de servicios aparecerán aquí.',
          );
        }
        return RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final item = items[index];
              final positive = item.quantity >= 0;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  child: Icon(
                    positive ? Icons.add : Icons.remove,
                    color: positive ? Colors.green : Colors.red,
                  ),
                ),
                title: Text(item.productName ?? 'Artículo'),
                subtitle: Text(
                  '${inventoryMovementLabel(item.type)} · ${formatDateTime(item.date)}${item.notes.isEmpty ? '' : '\n${item.notes}'}',
                ),
                isThreeLine: item.notes.isNotEmpty,
                trailing: Text(
                  '${positive ? '+' : ''}${formatQuantity(item.quantity)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: positive ? Colors.green : Colors.red,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class ProductForm extends StatefulWidget {
  final AppRepository repository;
  final ProductItem? product;

  const ProductForm({
    super.key,
    required this.repository,
    this.product,
  });

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.product?.name ?? '');
  late final _unit = TextEditingController(text: widget.product?.unit ?? 'unidad');
  late final _stock = TextEditingController(
    text: widget.product == null ? '0' : formatQuantity(widget.product!.stock),
  );
  late final _minimum = TextEditingController(
    text: widget.product == null
        ? '0'
        : formatQuantity(widget.product!.minimumStock),
  );
  late final _cost = TextEditingController(
    text: widget.product == null
        ? '0'
        : (widget.product!.costCents / 100).toStringAsFixed(2),
  );
  late final _salePrice = TextEditingController(
    text: widget.product == null
        ? '0'
        : (widget.product!.salePriceCents / 100).toStringAsFixed(2),
  );
  late String _kind = widget.product?.kind ?? 'supply';
  late bool _active = widget.product?.active ?? true;
  late DateTime? _expiry;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _expiry = widget.product?.expiryDate;
  }

  @override
  void dispose() {
    _name.dispose();
    _unit.dispose();
    _stock.dispose();
    _minimum.dispose();
    _cost.dispose();
    _salePrice.dispose();
    super.dispose();
  }

  Future<void> _pickExpiry() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _expiry ?? DateTime.now().add(const Duration(days: 180)),
      firstDate: DateTime.now().subtract(const Duration(days: 3650)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date != null) setState(() => _expiry = date);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final product = ProductItem(
      id: widget.product?.id,
      name: _name.text.trim(),
      kind: _kind,
      unit: _unit.text.trim(),
      stock: widget.product?.stock ?? parseQuantity(_stock.text),
      minimumStock: parseQuantity(_minimum.text),
      costCents: parseMoneyToCents(_cost.text),
      salePriceCents: parseMoneyToCents(_salePrice.text),
      expiryDate: _expiry,
      active: _active,
    );
    if (product.id == null) {
      await widget.repository.addProduct(product);
    } else {
      await widget.repository.updateProduct(product);
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        18,
        12,
        18,
        MediaQuery.viewInsetsOf(context).bottom + 18,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.product == null
                          ? 'Nuevo artículo'
                          : 'Editar artículo',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _name,
                autofocus: widget.product == null,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) => (value ?? '').trim().isEmpty
                    ? 'Escribe el nombre.'
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _kind,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: const [
                  DropdownMenuItem(
                    value: 'supply',
                    child: Text('Insumo utilizado en servicios'),
                  ),
                  DropdownMenuItem(
                    value: 'sale',
                    child: Text('Producto para vender'),
                  ),
                ],
                onChanged: (value) => setState(() => _kind = value ?? _kind),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _unit,
                decoration: const InputDecoration(
                  labelText: 'Unidad de medida',
                  hintText: 'unidad, ml, gramo, par…',
                ),
                validator: (value) => (value ?? '').trim().isEmpty
                    ? 'Escribe la unidad.'
                    : null,
              ),
              if (widget.product == null) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _stock,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration:
                      const InputDecoration(labelText: 'Existencia inicial'),
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _minimum,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Alerta de existencia baja',
                  helperText: 'Escribe 0 para no mostrar alerta.',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cost,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Costo por ${_unit.text.isEmpty ? 'unidad' : _unit.text}',
                  prefixText: 'RD\$ ',
                ),
              ),
              if (_kind == 'sale') ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _salePrice,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Precio de venta',
                    prefixText: 'RD\$ ',
                  ),
                ),
              ],
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickExpiry,
                icon: const Icon(Icons.event_outlined),
                label: Text(
                  _expiry == null
                      ? 'Agregar fecha de vencimiento'
                      : 'Vence ${formatDate(_expiry!)}',
                ),
              ),
              if (_expiry != null)
                TextButton(
                  onPressed: () => setState(() => _expiry = null),
                  child: const Text('Quitar vencimiento'),
                ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _active,
                title: const Text('Artículo activo'),
                onChanged: (value) => setState(() => _active = value),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 13),
                  child: Text('Guardar artículo'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductDetails extends StatefulWidget {
  final AppRepository repository;
  final ProductItem product;
  final VoidCallback onChanged;
  final VoidCallback onEdit;

  const ProductDetails({
    super.key,
    required this.repository,
    required this.product,
    required this.onChanged,
    required this.onEdit,
  });

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  late ProductItem _product = widget.product;

  Future<void> _reload() async {
    final products = await widget.repository.getProducts(includeInactive: true);
    final match = products.where((item) => item.id == _product.id);
    if (match.isNotEmpty && mounted) setState(() => _product = match.first);
    widget.onChanged();
  }

  Future<void> _adjust() async {
    final quantity = TextEditingController();
    final reason = TextEditingController();
    bool add = true;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Ajustar existencia'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('Agregar')),
                  ButtonSegment(value: false, label: Text('Descontar')),
                ],
                selected: {add},
                onSelectionChanged: (value) =>
                    setDialogState(() => add = value.first),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: quantity,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Cantidad en ${_product.unit}'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reason,
                decoration: const InputDecoration(
                  labelText: 'Razón',
                  hintText: 'Conteo físico, daño, uso interno…',
                ),
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
      final value = parseQuantity(quantity.text);
      if (value > 0) {
        await widget.repository.adjustProductStock(
          product: _product,
          delta: add ? value : -value,
          reason: reason.text.trim().isEmpty
              ? 'Ajuste manual'
              : reason.text.trim(),
        );
        await _reload();
      }
    }
    quantity.dispose();
    reason.dispose();
  }

  Future<void> _purchase() async {
    final suppliers = await widget.repository.getSuppliers();
    if (!mounted) return;
    final quantity = TextEditingController();
    final price = TextEditingController();
    final delivery = TextEditingController(text: '0');
    final notes = TextEditingController();
    int? supplierId;
    String method = 'Efectivo';
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Comprar ${_product.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: quantity,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration:
                      InputDecoration(labelText: 'Cantidad en ${_product.unit}'),
                ),
                const SizedBox(height: 12),
                MoneyField(controller: price, label: 'Precio de la compra'),
                const SizedBox(height: 12),
                TextField(
                  controller: delivery,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Transporte o entrega',
                    prefixText: 'RD\$ ',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int?>(
                  initialValue: supplierId,
                  decoration: const InputDecoration(labelText: 'Proveedor'),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Sin proveedor'),
                    ),
                    ...suppliers.map(
                      (item) => DropdownMenuItem<int?>(
                        value: item.id,
                        child: Text(item.name),
                      ),
                    ),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => supplierId = value),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: method,
                  decoration: const InputDecoration(labelText: 'Método de pago'),
                  items: const [
                    DropdownMenuItem(value: 'Efectivo', child: Text('Efectivo')),
                    DropdownMenuItem(
                      value: 'Transferencia',
                      child: Text('Transferencia'),
                    ),
                    DropdownMenuItem(value: 'Tarjeta', child: Text('Tarjeta')),
                    DropdownMenuItem(value: 'Crédito', child: Text('Crédito')),
                    DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => method = value ?? method),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notes,
                  decoration: const InputDecoration(labelText: 'Notas'),
                ),
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
              child: const Text('Registrar compra'),
            ),
          ],
        ),
      ),
    );
    if (saved == true) {
      final qty = parseQuantity(quantity.text);
      final amount = parseMoneyToCents(price.text);
      if (qty > 0 && amount > 0) {
        await widget.repository.recordProductPurchase(
          product: _product,
          quantity: qty,
          priceCents: amount,
          deliveryCents: parseMoneyToCents(delivery.text),
          paymentMethod: method,
          supplierId: supplierId,
          notes: notes.text.trim(),
        );
        await _reload();
      }
    }
    quantity.dispose();
    price.dispose();
    delivery.dispose();
    notes.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _product.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(onPressed: widget.onEdit, icon: const Icon(Icons.edit)),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _InfoRow(
                      label: 'Existencia',
                      value: '${formatQuantity(_product.stock)} ${_product.unit}',
                    ),
                    _InfoRow(
                      label: 'Costo unitario',
                      value: formatMoney(_product.costCents),
                    ),
                    _InfoRow(
                      label: 'Valor estimado',
                      value: formatMoney(
                        (_product.stock * _product.costCents).round(),
                      ),
                    ),
                    if (_product.expiryDate != null)
                      _InfoRow(
                        label: 'Vencimiento',
                        value: formatDate(_product.expiryDate!),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: _purchase,
              icon: const Icon(Icons.shopping_cart_checkout),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Registrar compra'),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _adjust,
              icon: const Icon(Icons.tune),
              label: const Text('Ajustar existencia'),
            ),
            const SizedBox(height: 14),
            FutureBuilder<List<InventoryMovement>>(
              future: widget.repository.getInventoryMovements(
                productId: _product.id,
                limit: 10,
              ),
              builder: (context, snapshot) {
                final items = snapshot.data ?? const <InventoryMovement>[];
                if (items.isEmpty) return const SizedBox.shrink();
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Últimos movimientos',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...items.map(
                          (item) => ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(inventoryMovementLabel(item.type)),
                            subtitle: Text(formatDateTime(item.date)),
                            trailing: Text(
                              '${item.quantity >= 0 ? '+' : ''}${formatQuantity(item.quantity)}',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

String formatQuantity(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}

double parseQuantity(String raw) =>
    double.tryParse(raw.trim().replaceAll(',', '.')) ?? 0;

String inventoryMovementLabel(String type) {
  switch (type) {
    case 'purchase':
      return 'Compra';
    case 'service_use':
      return 'Usado en servicio';
    case 'sale':
      return 'Vendido';
    case 'opening':
      return 'Existencia inicial';
    case 'adjustment':
      return 'Ajuste';
    default:
      return type;
  }
}