import 'package:flutter/material.dart';

import '../app_repository.dart';
import '../models.dart';
import '../utils.dart';
import '../widgets/common.dart';

class ServicesPage extends StatefulWidget {
  final AppRepository repository;

  const ServicesPage({super.key, required this.repository});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  Future<void> _edit([ServiceItem? service]) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => ServiceForm(repository: widget.repository, service: service),
    );
    if (saved == true) setState(() {});
  }

  Future<void> _recipe(ServiceItem service) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => ServiceRecipeSheet(
        repository: widget.repository,
        service: service,
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Servicios'), actions: [IconButton(onPressed: () => _edit(), icon: const Icon(Icons.add))]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo servicio'),
      ),
      body: FutureBuilder<List<ServiceItem>>(
        future: widget.repository.getServices(includeInactive: true),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? const <ServiceItem>[];
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.spa_outlined,
              title: 'No hay servicios',
              message: 'Crea los servicios que ofreces, con duración, precio y costo aproximado.',
              actionLabel: 'Crear servicio',
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
                final margin = item.priceCents - item.costCents;
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Icon(item.homeService ? Icons.directions_car_outlined : Icons.spa_outlined)),
                    title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text('${item.durationMinutes} min · Costo ${formatMoney(item.costCents)} · Margen aprox. ${formatMoney(margin)}'),
                    trailing: IconButton(
                      tooltip: 'Insumos del servicio',
                      onPressed: () => _recipe(item),
                      icon: const Icon(Icons.inventory_2_outlined),
                    ),
                    onTap: () => _edit(item),
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

class ServiceForm extends StatefulWidget {
  final AppRepository repository;
  final ServiceItem? service;

  const ServiceForm({super.key, required this.repository, this.service});

  @override
  State<ServiceForm> createState() => _ServiceFormState();
}

class _ServiceFormState extends State<ServiceForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController = TextEditingController(text: widget.service?.name ?? '');
  late final TextEditingController _durationController = TextEditingController(text: '${widget.service?.durationMinutes ?? 60}');
  late final TextEditingController _priceController = TextEditingController(
    text: widget.service == null ? '' : (widget.service!.priceCents / 100).toStringAsFixed(2),
  );
  late final TextEditingController _costController = TextEditingController(
    text: widget.service == null ? '0' : (widget.service!.costCents / 100).toStringAsFixed(2),
  );
  late bool _homeService = widget.service?.homeService ?? false;
  late bool _active = widget.service?.active ?? true;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final service = ServiceItem(
      id: widget.service?.id,
      name: _nameController.text.trim(),
      durationMinutes: int.tryParse(_durationController.text.trim()) ?? 60,
      priceCents: parseMoneyToCents(_priceController.text),
      costCents: parseMoneyToCents(_costController.text),
      homeService: _homeService,
      active: _active,
    );
    if (service.id == null) {
      await widget.repository.addService(service);
    } else {
      await widget.repository.updateService(service);
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18, 12, 18, MediaQuery.viewInsetsOf(context).bottom + 18),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: Text(widget.service == null ? 'Nuevo servicio' : 'Editar servicio', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                autofocus: widget.service == null,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Nombre del servicio'),
                validator: (value) => (value ?? '').trim().isEmpty ? 'Escribe el nombre.' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Duración', suffixText: 'minutos'),
                validator: (value) => (int.tryParse(value ?? '') ?? 0) <= 0 ? 'Escribe una duración válida.' : null,
              ),
              const SizedBox(height: 12),
              MoneyField(controller: _priceController, label: 'Precio de venta'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _costController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Costo aproximado',
                  prefixText: 'RD\$ ',
                  helperText: 'Insumos y otros costos directos estimados.',
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                value: _homeService,
                contentPadding: EdgeInsets.zero,
                title: const Text('Disponible a domicilio'),
                onChanged: (value) => setState(() => _homeService = value),
              ),
              SwitchListTile(
                value: _active,
                contentPadding: EdgeInsets.zero,
                title: const Text('Servicio activo'),
                onChanged: (value) => setState(() => _active = value),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.save),
                label: const Padding(padding: EdgeInsets.symmetric(vertical: 13), child: Text('Guardar servicio')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ServiceRecipeSheet extends StatefulWidget {
  final AppRepository repository;
  final ServiceItem service;

  const ServiceRecipeSheet({
    super.key,
    required this.repository,
    required this.service,
  });

  @override
  State<ServiceRecipeSheet> createState() => _ServiceRecipeSheetState();
}

class _ServiceRecipeSheetState extends State<ServiceRecipeSheet> {
  List<ProductItem> _products = const [];
  final Map<int, TextEditingController> _controllers = {};
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final products = (await widget.repository.getProducts())
        .where((item) => item.kind == 'supply')
        .toList();
    final current = await widget.repository.getServiceSupplies(widget.service.id!);
    final quantities = {for (final item in current) item.productId: item.quantity};
    for (final product in products) {
      final value = quantities[product.id];
      _controllers[product.id!] = TextEditingController(
        text: value == null || value == 0 ? '' : _formatQuantity(value),
      );
    }
    if (mounted) {
      setState(() {
        _products = products;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final supplies = <ServiceSupply>[];
    for (final product in _products) {
      final quantity = double.tryParse(
            (_controllers[product.id]?.text ?? '').trim().replaceAll(',', '.'),
          ) ??
          0;
      if (quantity > 0) {
        supplies.add(
          ServiceSupply(
            serviceId: widget.service.id!,
            productId: product.id!,
            quantity: quantity,
          ),
        );
      }
    }
    await widget.repository.setServiceSupplies(widget.service.id!, supplies);
    if (mounted) Navigator.pop(context);
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Insumos: ${widget.service.name}',
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
            const SizedBox(height: 6),
            const Text(
              'Al completar una cita, estas cantidades se descontarán automáticamente del inventario.',
            ),
            const SizedBox(height: 14),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_products.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Primero crea insumos en Más > Inventario e insumos.',
                  ),
                ),
              )
            else ...[
              ..._products.map(
                (product) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextField(
                    controller: _controllers[product.id],
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: product.name,
                      suffixText: product.unit,
                      helperText:
                          'Disponible: ${_formatQuantity(product.stock)} ${product.unit}',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
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
                  child: Text('Guardar insumos del servicio'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _formatQuantity(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}
