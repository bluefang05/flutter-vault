import 'package:flutter/material.dart';

import '../app_repository.dart';
import '../models.dart';
import '../utils.dart';
import '../widgets/common.dart';

class AppointmentsPage extends StatefulWidget {
  final AppRepository repository;

  const AppointmentsPage({super.key, required this.repository});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  bool _upcomingOnly = true;

  Future<void> _newAppointment() async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => AppointmentForm(repository: widget.repository),
    );
    if (saved == true) setState(() {});
  }

  Future<void> _openAppointment(AppointmentItem appointment) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => AppointmentDetails(
        repository: widget.repository,
        appointment: appointment,
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final from = _upcomingOnly ? startOfDay(DateTime.now()) : null;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _newAppointment,
          icon: const Icon(Icons.add),
          label: const Text('Nueva cita'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Citas',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: true, label: Text('Próximas')),
                      ButtonSegment(value: false, label: Text('Todas')),
                    ],
                    selected: {_upcomingOnly},
                    onSelectionChanged: (value) => setState(() => _upcomingOnly = value.first),
                    showSelectedIcon: false,
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<AppointmentItem>>(
                future: widget.repository.getAppointments(from: from),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  var items = snapshot.data ?? const <AppointmentItem>[];
                  if (_upcomingOnly) {
                    items = items
                        .where((item) => item.status != 'cancelled' && item.status != 'completed' && item.status != 'no_show')
                        .toList();
                  }
                  if (items.isEmpty) {
                    return EmptyState(
                      icon: Icons.calendar_month_outlined,
                      title: _upcomingOnly ? 'No tienes citas próximas' : 'Todavía no hay citas',
                      message: 'Agenda el servicio, el cliente, el precio y cualquier anticipo recibido.',
                      actionLabel: 'Crear cita',
                      onAction: _newAppointment,
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async => setState(() {}),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final color = statusColor(context, item.status);
                        return Card(
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => _openAppointment(item),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 58,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Column(
                                      children: [
                                        Text('${item.startAt.day}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                        Text(formatTime(item.startAt), style: const TextStyle(fontSize: 10)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.clientName ?? 'Cliente', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                                        const SizedBox(height: 3),
                                        Text(item.serviceName ?? 'Servicio'),
                                        const SizedBox(height: 5),
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 4,
                                          children: [
                                            _Tag(label: statusLabel(item.status), color: color),
                                            if (item.balanceCents > 0)
                                              _Tag(label: 'Debe ${formatMoney(item.balanceCents)}', color: Colors.orange),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;

  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class AppointmentForm extends StatefulWidget {
  final AppRepository repository;

  const AppointmentForm({super.key, required this.repository});

  @override
  State<AppointmentForm> createState() => _AppointmentFormState();
}

class _AppointmentFormState extends State<AppointmentForm> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _depositController = TextEditingController(text: '0');
  String _depositMethod = 'Efectivo';
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  List<Client> _clients = const [];
  List<ServiceItem> _services = const [];
  int? _clientId;
  int? _serviceId;
  DateTime _dateTime = DateTime.now().add(const Duration(hours: 1));
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
      _serviceId = services.isEmpty ? null : services.first.id;
      if (services.isNotEmpty) _priceController.text = (services.first.priceCents / 100).toStringAsFixed(2);
      _loading = false;
    });
  }

  @override
  void dispose() {
    _priceController.dispose();
    _depositController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_dateTime));
    if (time == null) return;
    setState(() => _dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  Future<void> _quickClient() async {
    final name = TextEditingController();
    final phone = TextEditingController();
    final created = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cliente rápido'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, autofocus: true, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Nombre')),
            const SizedBox(height: 10),
            TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Teléfono')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, name.text.trim().isNotEmpty), child: const Text('Crear')),
        ],
      ),
    );
    if (created == true) {
      final id = await widget.repository.addClient(
        Client(name: name.text.trim(), phone: phone.text.trim(), createdAt: DateTime.now()),
      );
      await _load();
      if (mounted) setState(() => _clientId = id);
    }
    name.dispose();
    phone.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _clientId == null || _serviceId == null) return;
    final price = parseMoneyToCents(_priceController.text);
    final deposit = parseMoneyToCents(_depositController.text);
    if (deposit > price) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El anticipo no puede superar el precio acordado.')));
      return;
    }
    setState(() => _saving = true);
    await widget.repository.addAppointment(
      AppointmentItem(
        clientId: _clientId!,
        serviceId: _serviceId!,
        startAt: _dateTime,
        status: 'pending',
        agreedPriceCents: price,
        depositCents: deposit,
        balanceCents: price - deposit,
        location: _locationController.text.trim(),
        notes: _notesController.text.trim(),
      ),
      depositPaymentMethod: _depositMethod,
    );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18, 12, 18, MediaQuery.viewInsetsOf(context).bottom + 18),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text('Nueva cita', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
                        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_clients.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              const Expanded(child: Text('Primero crea el cliente que recibirá el servicio.')),
                              TextButton(onPressed: _quickClient, child: const Text('Crear')),
                            ],
                          ),
                        ),
                      )
                    else
                      DropdownButtonFormField<int>(
                        initialValue: _clientId,
                        decoration: const InputDecoration(labelText: 'Cliente'),
                        items: _clients.map((client) => DropdownMenuItem(value: client.id, child: Text(client.name))).toList(),
                        onChanged: (value) => setState(() => _clientId = value),
                      ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: _serviceId,
                      decoration: const InputDecoration(labelText: 'Servicio'),
                      items: _services.map((service) => DropdownMenuItem(value: service.id, child: Text(service.name))).toList(),
                      onChanged: (value) {
                        final service = _services.where((item) => item.id == value).first;
                        setState(() {
                          _serviceId = value;
                          _priceController.text = (service.priceCents / 100).toStringAsFixed(2);
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      tileColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Theme.of(context).dividerColor)),
                      leading: const Icon(Icons.event),
                      title: const Text('Fecha y hora'),
                      subtitle: Text(formatDateTime(_dateTime)),
                      trailing: const Icon(Icons.edit_calendar),
                      onTap: _pickDateTime,
                    ),
                    const SizedBox(height: 12),
                    MoneyField(controller: _priceController, label: 'Precio acordado'),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _depositController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Anticipo recibido', prefixText: 'RD\$ '),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _depositMethod,
                      decoration: const InputDecoration(labelText: 'Método del anticipo'),
                      items: const [
                        DropdownMenuItem(value: 'Efectivo', child: Text('Efectivo')),
                        DropdownMenuItem(value: 'Transferencia', child: Text('Transferencia')),
                        DropdownMenuItem(value: 'Tarjeta', child: Text('Tarjeta')),
                        DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                      ],
                      onChanged: (value) => setState(() => _depositMethod = value ?? _depositMethod),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _locationController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(labelText: 'Lugar', hintText: 'Local, domicilio o dirección'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(labelText: 'Notas', helperText: 'Opcional'),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: _saving || _clients.isEmpty || _services.isEmpty ? null : _save,
                      icon: _saving
                          ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.event_available),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 13),
                        child: Text('Guardar cita'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class AppointmentDetails extends StatefulWidget {
  final AppRepository repository;
  final AppointmentItem appointment;

  const AppointmentDetails({super.key, required this.repository, required this.appointment});

  @override
  State<AppointmentDetails> createState() => _AppointmentDetailsState();
}

class _AppointmentDetailsState extends State<AppointmentDetails> {
  late AppointmentItem _appointment = widget.appointment;

  Future<void> _reload() async {
    final item = await widget.repository.getAppointment(_appointment.id!);
    if (item != null && mounted) setState(() => _appointment = item);
  }

  Future<void> _status(String status) async {
    await widget.repository.updateAppointmentStatus(_appointment.id!, status);
    await _reload();
  }

  Future<void> _payment({required bool complete}) async {
    if (_appointment.balanceCents <= 0 && complete) {
      await widget.repository.completeAppointmentWithoutPayment(_appointment);
      await _reload();
      return;
    }
    final controller = TextEditingController(text: (_appointment.balanceCents / 100).toStringAsFixed(2));
    String method = 'Efectivo';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(complete ? 'Completar y cobrar' : 'Registrar abono'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MoneyField(controller: controller, label: 'Monto recibido'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: method,
                decoration: const InputDecoration(labelText: 'Método de pago'),
                items: const [
                  DropdownMenuItem(value: 'Efectivo', child: Text('Efectivo')),
                  DropdownMenuItem(value: 'Transferencia', child: Text('Transferencia')),
                  DropdownMenuItem(value: 'Tarjeta', child: Text('Tarjeta')),
                  DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                ],
                onChanged: (value) => setDialogState(() => method = value ?? method),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Guardar')),
          ],
        ),
      ),
    );
    if (confirmed == true) {
      final amount = parseMoneyToCents(controller.text);
      if (amount <= 0) return;
      if (amount > _appointment.balanceCents) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('El cobro supera el saldo pendiente. Registra la propina por separado.')),
          );
        }
        return;
      }
      await widget.repository.registerAppointmentPayment(
        appointment: _appointment,
        amountCents: amount,
        paymentMethod: method,
        markCompleted: complete,
      );
      await _reload();
    }
    controller.dispose();
  }

  Future<void> _usePackage() async {
    final packages = await widget.repository.getUsablePackages(
      clientId: _appointment.clientId,
      serviceId: _appointment.serviceId,
    );
    if (!mounted) return;
    if (packages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este cliente no tiene un paquete compatible con sesiones disponibles.')),
      );
      return;
    }
    ServicePackage selected = packages.first;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Usar sesión de paquete'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<ServicePackage>(
                initialValue: selected,
                decoration: const InputDecoration(labelText: 'Paquete'),
                items: packages
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text('${item.name} · ${item.remainingSessions} disponibles'),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setDialogState(() => selected = value ?? selected),
              ),
              const SizedBox(height: 12),
              const Text('La cita quedará completada, el saldo pasará a cero y se descontarán los insumos configurados.'),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Usar sesión')),
          ],
        ),
      ),
    );
    if (confirmed == true) {
      await widget.repository.consumePackageSession(
        package: selected,
        appointment: _appointment,
        notes: 'Aplicada desde la cita',
      );
      await _reload();
    }
  }

  Future<void> _reschedule() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _appointment.startAt,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_appointment.startAt));
    if (time == null) return;
    await widget.repository.rescheduleAppointment(
      _appointment.id!,
      DateTime(date.year, date.month, date.day, time.hour, time.minute),
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
                Expanded(child: Text(_appointment.clientName ?? 'Cita', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            Text(_appointment.serviceName ?? 'Servicio', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _DetailRow(icon: Icons.event, label: 'Fecha', value: formatDateTime(_appointment.startAt)),
                    _DetailRow(icon: Icons.flag_outlined, label: 'Estado', value: statusLabel(_appointment.status)),
                    _DetailRow(icon: Icons.payments_outlined, label: 'Precio', value: formatMoney(_appointment.agreedPriceCents)),
                    _DetailRow(icon: Icons.savings_outlined, label: 'Anticipo', value: formatMoney(_appointment.depositCents)),
                    _DetailRow(icon: Icons.pending_actions, label: 'Pendiente', value: formatMoney(_appointment.balanceCents)),
                    if (_appointment.location.isNotEmpty)
                      _DetailRow(icon: Icons.location_on_outlined, label: 'Lugar', value: _appointment.location),
                    if (_appointment.notes.isNotEmpty)
                      _DetailRow(icon: Icons.notes, label: 'Notas', value: _appointment.notes),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            if (_appointment.status != 'completed' && _appointment.status != 'cancelled') ...[
              FilledButton.icon(
                onPressed: () => _payment(complete: true),
                icon: const Icon(Icons.check_circle),
                label: const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Completar servicio y cobrar')),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _usePackage,
                icon: const Icon(Icons.card_membership_outlined),
                label: const Text('Descontar de un paquete'),
              ),
              const SizedBox(height: 8),
              if (_appointment.balanceCents > 0)
                OutlinedButton.icon(
                  onPressed: () => _payment(complete: false),
                  icon: const Icon(Icons.add_card),
                  label: const Text('Registrar abono'),
                ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _reschedule,
                icon: const Icon(Icons.edit_calendar),
                label: const Text('Reprogramar'),
              ),
              const SizedBox(height: 8),
              if (_appointment.status == 'pending')
                OutlinedButton.icon(
                  onPressed: () => _status('confirmed'),
                  icon: const Icon(Icons.verified_outlined),
                  label: const Text('Marcar confirmada'),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _status('no_show'),
                      icon: const Icon(Icons.person_off_outlined),
                      label: const Text('No asistió'),
                    ),
                  ),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () async {
                        if (await confirmAction(
                          context,
                          title: 'Cancelar cita',
                          message: 'La cita conservará su historial y cualquier anticipo registrado.',
                          confirmLabel: 'Cancelar cita',
                        )) {
                          await _status('cancelled');
                        }
                      },
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Cancelar'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          SizedBox(width: 72, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
