import 'package:flutter/material.dart';

import '../app_repository.dart';
import '../models.dart';
import '../utils.dart';
import '../widgets/common.dart';
import 'inventory_page.dart';

class SuppliersPage extends StatefulWidget {
  final AppRepository repository;

  const SuppliersPage({super.key, required this.repository});

  @override
  State<SuppliersPage> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends State<SuppliersPage> {
  Future<void> _edit([SupplierItem? supplier]) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => SupplierForm(
        repository: widget.repository,
        supplier: supplier,
      ),
    );
    if (saved == true) setState(() {});
  }

  Future<void> _details(SupplierItem supplier) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => SupplierDetails(
        repository: widget.repository,
        supplier: supplier,
        onEdit: () {
          Navigator.pop(context);
          _edit(supplier);
        },
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Proveedores')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(),
        icon: const Icon(Icons.add_business),
        label: const Text('Nuevo proveedor'),
      ),
      body: FutureBuilder<List<SupplierItem>>(
        future: widget.repository.getSuppliers(includeInactive: true),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? const <SupplierItem>[];
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.local_shipping_outlined,
              title: 'No hay proveedores',
              message:
                  'Guarda sus contactos y compara los precios que ofrecen.',
              actionLabel: 'Crear proveedor',
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
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.local_shipping_outlined),
                    ),
                    title: Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      item.whatsapp.isNotEmpty
                          ? 'WhatsApp: ${item.whatsapp}'
                          : item.phone.isNotEmpty
                              ? item.phone
                              : 'Sin teléfono',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _details(item),
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

class SupplierForm extends StatefulWidget {
  final AppRepository repository;
  final SupplierItem? supplier;

  const SupplierForm({
    super.key,
    required this.repository,
    this.supplier,
  });

  @override
  State<SupplierForm> createState() => _SupplierFormState();
}

class _SupplierFormState extends State<SupplierForm> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.supplier?.name ?? '');
  late final _phone = TextEditingController(text: widget.supplier?.phone ?? '');
  late final _whatsapp =
      TextEditingController(text: widget.supplier?.whatsapp ?? '');
  late final _address =
      TextEditingController(text: widget.supplier?.address ?? '');
  late final _notes = TextEditingController(text: widget.supplier?.notes ?? '');
  late bool _active = widget.supplier?.active ?? true;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _whatsapp.dispose();
    _address.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final supplier = SupplierItem(
      id: widget.supplier?.id,
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      whatsapp: _whatsapp.text.trim(),
      address: _address.text.trim(),
      notes: _notes.text.trim(),
      active: _active,
    );
    if (supplier.id == null) {
      await widget.repository.addSupplier(supplier);
    } else {
      await widget.repository.updateSupplier(supplier);
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
                      widget.supplier == null
                          ? 'Nuevo proveedor'
                          : 'Editar proveedor',
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
                autofocus: widget.supplier == null,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) => (value ?? '').trim().isEmpty
                    ? 'Escribe el nombre.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Teléfono'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _whatsapp,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'WhatsApp'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _address,
                decoration: const InputDecoration(labelText: 'Dirección'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notes,
                minLines: 2,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Notas',
                  hintText: 'Días de entrega, compra mínima, crédito…',
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _active,
                title: const Text('Proveedor activo'),
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
                  child: Text('Guardar proveedor'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SupplierDetails extends StatefulWidget {
  final AppRepository repository;
  final SupplierItem supplier;
  final VoidCallback onEdit;

  const SupplierDetails({
    super.key,
    required this.repository,
    required this.supplier,
    required this.onEdit,
  });

  @override
  State<SupplierDetails> createState() => _SupplierDetailsState();
}

class _SupplierDetailsState extends State<SupplierDetails> {
  Future<void> _addPrice() async {
    final products = await widget.repository.getProducts();
    if (!mounted) return;
    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero crea un artículo en Inventario.'),
        ),
      );
      return;
    }
    int productId = products.first.id!;
    final quantity = TextEditingController(text: '1');
    final price = TextEditingController();
    final delivery = TextEditingController(text: '0');
    final notes = TextEditingController();
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Registrar precio ofrecido'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: productId,
                  decoration: const InputDecoration(labelText: 'Artículo'),
                  items: products
                      .map(
                        (item) => DropdownMenuItem(
                          value: item.id!,
                          child: Text(item.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setDialogState(
                    () => productId = value ?? productId,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: quantity,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Cantidad ofrecida'),
                ),
                const SizedBox(height: 12),
                MoneyField(controller: price, label: 'Precio'),
                const SizedBox(height: 12),
                TextField(
                  controller: delivery,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Entrega o transporte',
                    prefixText: 'RD\$ ',
                  ),
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
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
    if (saved == true) {
      final qty = parseQuantity(quantity.text);
      final amount = parseMoneyToCents(price.text);
      if (qty > 0 && amount > 0) {
        await widget.repository.addSupplierPrice(
          SupplierPrice(
            supplierId: widget.supplier.id!,
            productId: productId,
            quantity: qty,
            priceCents: amount,
            deliveryCents: parseMoneyToCents(delivery.text),
            recordedAt: DateTime.now(),
            notes: notes.text.trim(),
          ),
        );
        setState(() {});
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
                    widget.supplier.name,
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
            if (widget.supplier.phone.isNotEmpty ||
                widget.supplier.whatsapp.isNotEmpty ||
                widget.supplier.address.isNotEmpty ||
                widget.supplier.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      if (widget.supplier.phone.isNotEmpty)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.phone_outlined),
                          title: Text(widget.supplier.phone),
                        ),
                      if (widget.supplier.whatsapp.isNotEmpty)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.chat_outlined),
                          title: Text(widget.supplier.whatsapp),
                          subtitle: const Text('WhatsApp'),
                        ),
                      if (widget.supplier.address.isNotEmpty)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.location_on_outlined),
                          title: Text(widget.supplier.address),
                        ),
                      if (widget.supplier.notes.isNotEmpty)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.notes),
                          title: Text(widget.supplier.notes),
                        ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: _addPrice,
              icon: const Icon(Icons.price_change_outlined),
              label: const Text('Registrar precio ofrecido'),
            ),
            const SizedBox(height: 14),
            Text(
              'Historial de precios',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<SupplierPrice>>(
              future: widget.repository.getSupplierPrices(
                supplierId: widget.supplier.id,
              ),
              builder: (context, snapshot) {
                final prices = snapshot.data ?? const <SupplierPrice>[];
                if (prices.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Todavía no hay precios registrados.'),
                    ),
                  );
                }
                return Column(
                  children: prices
                      .map(
                        (price) => Card(
                          child: ListTile(
                            title: Text(price.productName ?? 'Artículo'),
                            subtitle: Text(
                              '${formatQuantity(price.quantity)} ${price.unit ?? ''} · ${formatDate(price.recordedAt)}${price.notes.isEmpty ? '' : '\n${price.notes}'}',
                            ),
                            isThreeLine: price.notes.isNotEmpty,
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  formatMoney(price.effectiveTotalCents),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${formatMoney(price.unitCostCents.round())}/unidad',
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
