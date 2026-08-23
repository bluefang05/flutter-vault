import 'package:flutter/material.dart';

import '../app_repository.dart';
import '../models.dart';
import '../utils.dart';
import '../widgets/common.dart';

class PackagesPage extends StatefulWidget {
  final AppRepository repository;

  const PackagesPage({super.key, required this.repository});

  @override
  State<PackagesPage> createState() => _PackagesPageState();
}

class _PackagesPageState extends State<PackagesPage> {
  bool _activeOnly = true;

  Future<void> _create() async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => PackageForm(repository: widget.repository),
    );
    if (saved == true) setState(() {});
  }

  Future<void> _details(ServicePackage package) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => PackageDetails(
        repository: widget.repository,
        package: package,
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paquetes de sesiones'),
        actions: [
          PopupMenuButton<bool>(
            initialValue: _activeOnly,
            onSelected: (value) => setState(() => _activeOnly = value),
            itemBuilder: (context) => const [
              PopupMenuItem(value: true, child: Text('Solo activos')),
              PopupMenuItem(value: false, child: Text('Todos')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _create,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo paquete'),
      ),
      body: FutureBuilder<List<ServicePackage>>(
        future: widget.repository.getServicePackages(activeOnly: _activeOnly),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? const <ServicePackage>[];
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.card_membership_outlined,
              title: 'No hay paquetes',
              message:
                  'Vende varias sesiones juntas y controla las usadas, pendientes y pagadas.',
              actionLabel: 'Crear paquete',
              onAction: _create,
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
                    leading: CircleAvatar(
                      child: Text('${item.remainingSessions}'),
                    ),
                    title: Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      '${item.clientName ?? 'Cliente'} · ${item.usedSessions}/${item.totalSessions} usadas\n${item.balanceCents > 0 ? 'Debe ${formatMoney(item.balanceCents)}' : 'Pagado completo'}',
                    ),
                    isThreeLine: true,
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

class PackageForm extends StatefulWidget {
  final AppRepository repository;

  const PackageForm({super.key, required this.repository});

  @override
  State<PackageForm> createState() => _PackageFormState();
}

class _PackageFormState extends State<PackageForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _sessions = TextEditingController(text: '5');
  final _total = TextEditingController();
  final _paid = TextEditingController(text: '0');
  List<Client> _clients = const [];
  List<ServiceItem> _services = const [];
  int? _clientId;
  int? _serviceId;
  DateTime? _expiresAt;
  String _paymentMethod = 'Efectivo';
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final clients = await widget.repository.getClients();
    final services = await widget.repository.getServices();
    if (!mounted) return;
    setState(() {
      _clients = clients;
      _services = services;
      _clientId = clients.isEmpty ? null : clients.first.id;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _sessions.dispose();
    _total.dispose();
    _paid.dispose();
    super.dispose();
  }

  Future<void> _pickExpiry() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 180)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date != null) setState(() => _expiresAt = date);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _clientId == null) return;
    final total = parseMoneyToCents(_total.text);
    final paid = parseMoneyToCents(_paid.text);
    if (paid > total) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El pago inicial supera el total.')),
      );
      return;
    }
    setState(() => _saving = true);
    await widget.repository.addServicePackage(
      ServicePackage(
        clientId: _clientId!,
        serviceId: _serviceId,
        name: _name.text.trim(),
        totalSessions: int.tryParse(_sessions.text) ?? 1,
        totalCents: total,
        paidCents: paid,
        expiresAt: _expiresAt,
        createdAt: DateTime.now(),
      ),
      paymentMethod: _paymentMethod,
    );
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
                      'Nuevo paquete',
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
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else if (_clients.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Primero crea al menos un cliente.'),
                  ),
                )
              else ...[
                DropdownButtonFormField<int>(
                  initialValue: _clientId,
                  decoration: const InputDecoration(labelText: 'Cliente'),
                  items: _clients
                      .map(
                        (item) => DropdownMenuItem(
                          value: item.id!,
                          child: Text(item.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _clientId = value),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int?>(
                  initialValue: _serviceId,
                  decoration: const InputDecoration(
                    labelText: 'Servicio asociado',
                    helperText: 'Déjalo general para usarlo en cualquier servicio.',
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Paquete general'),
                    ),
                    ..._services.map(
                      (item) => DropdownMenuItem<int?>(
                        value: item.id,
                        child: Text(item.name),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => _serviceId = value),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del paquete',
                    hintText: '5 masajes relajantes',
                  ),
                  validator: (value) => (value ?? '').trim().isEmpty
                      ? 'Escribe el nombre.'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _sessions,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Sesiones'),
                  validator: (value) => (int.tryParse(value ?? '') ?? 0) <= 0
                      ? 'Escribe una cantidad válida.'
                      : null,
                ),
                const SizedBox(height: 12),
                MoneyField(controller: _total, label: 'Precio total'),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _paid,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Pago inicial',
                    prefixText: 'RD\$ ',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _paymentMethod,
                  decoration: const InputDecoration(
                    labelText: 'Método del pago inicial',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Efectivo', child: Text('Efectivo')),
                    DropdownMenuItem(
                      value: 'Transferencia',
                      child: Text('Transferencia'),
                    ),
                    DropdownMenuItem(value: 'Tarjeta', child: Text('Tarjeta')),
                    DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                  ],
                  onChanged: (value) =>
                      setState(() => _paymentMethod = value ?? _paymentMethod),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _pickExpiry,
                  icon: const Icon(Icons.event_outlined),
                  label: Text(
                    _expiresAt == null
                        ? 'Agregar vencimiento'
                        : 'Vence ${formatDate(_expiresAt!)}',
                  ),
                ),
                const SizedBox(height: 16),
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
                    child: Text('Guardar paquete'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class PackageDetails extends StatefulWidget {
  final AppRepository repository;
  final ServicePackage package;

  const PackageDetails({
    super.key,
    required this.repository,
    required this.package,
  });

  @override
  State<PackageDetails> createState() => _PackageDetailsState();
}

class _PackageDetailsState extends State<PackageDetails> {
  late ServicePackage _package = widget.package;

  Future<void> _reload() async {
    final packages = await widget.repository.getServicePackages();
    final matches = packages.where((item) => item.id == _package.id);
    if (matches.isNotEmpty && mounted) setState(() => _package = matches.first);
  }

  Future<void> _payment() async {
    if (_package.balanceCents <= 0) return;
    final amount = TextEditingController(
      text: (_package.balanceCents / 100).toStringAsFixed(2),
    );
    String method = 'Efectivo';
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Registrar pago'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MoneyField(controller: amount, label: 'Monto recibido'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: method,
                decoration: const InputDecoration(labelText: 'Método'),
                items: const [
                  DropdownMenuItem(value: 'Efectivo', child: Text('Efectivo')),
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
      if (value > 0 && value <= _package.balanceCents) {
        await widget.repository.addPackagePayment(
          package: _package,
          amountCents: value,
          paymentMethod: method,
        );
        await _reload();
      }
    }
    amount.dispose();
  }

  Future<void> _consume() async {
    if (!_package.isUsable) return;
    final confirmed = await confirmAction(
      context,
      title: 'Usar una sesión',
      message:
          'Se descontará una sesión del paquete sin vincularla a una cita.',
      confirmLabel: 'Usar sesión',
    );
    if (!confirmed) return;
    await widget.repository.consumePackageSession(
      package: _package,
      notes: 'Consumo manual',
    );
    await _reload();
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
                    _package.name,
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
            Text(_package.clientName ?? 'Cliente'),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _PackageRow(
                      label: 'Servicio',
                      value: _package.serviceName ?? 'Cualquier servicio',
                    ),
                    _PackageRow(
                      label: 'Sesiones usadas',
                      value:
                          '${_package.usedSessions} de ${_package.totalSessions}',
                    ),
                    _PackageRow(
                      label: 'Sesiones disponibles',
                      value: '${_package.remainingSessions}',
                    ),
                    _PackageRow(
                      label: 'Precio total',
                      value: formatMoney(_package.totalCents),
                    ),
                    _PackageRow(
                      label: 'Pagado',
                      value: formatMoney(_package.paidCents),
                    ),
                    _PackageRow(
                      label: 'Pendiente',
                      value: formatMoney(_package.balanceCents),
                    ),
                    if (_package.expiresAt != null)
                      _PackageRow(
                        label: 'Vencimiento',
                        value: formatDate(_package.expiresAt!),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            if (_package.balanceCents > 0)
              FilledButton.icon(
                onPressed: _payment,
                icon: const Icon(Icons.add_card),
                label: const Text('Registrar pago'),
              ),
            if (_package.balanceCents > 0) const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _package.isUsable ? _consume : null,
              icon: const Icon(Icons.remove_circle_outline),
              label: const Text('Usar una sesión manualmente'),
            ),
            const SizedBox(height: 10),
            const Text(
              'Al completar una cita compatible también podrás descontar la sesión directamente desde la cita.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PackageRow extends StatelessWidget {
  final String label;
  final String value;

  const _PackageRow({required this.label, required this.value});

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
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
