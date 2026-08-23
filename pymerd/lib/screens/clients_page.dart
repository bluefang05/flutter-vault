import 'package:flutter/material.dart';

import '../app_repository.dart';
import '../models.dart';
import '../utils.dart';
import '../widgets/common.dart';
import 'client_records_page.dart';

class ClientsPage extends StatefulWidget {
  final AppRepository repository;

  const ClientsPage({super.key, required this.repository});

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  String _query = '';

  Future<void> _editClient([Client? client]) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => ClientForm(repository: widget.repository, client: client),
    );
    if (saved == true) setState(() {});
  }

  Future<void> _details(Client client) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => ClientDetails(repository: widget.repository, client: client, onEdit: () {
        Navigator.pop(context);
        _editClient(client);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _editClient(),
          icon: const Icon(Icons.person_add_alt_1),
          label: const Text('Nuevo cliente'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Clientes', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Buscar por nombre o teléfono',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Client>>(
                future: widget.repository.getClients(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final all = snapshot.data ?? const <Client>[];
                  final items = all.where((client) {
                    if (_query.isEmpty) return true;
                    return client.name.toLowerCase().contains(_query) || client.phone.toLowerCase().contains(_query);
                  }).toList();
                  if (all.isEmpty) {
                    return EmptyState(
                      icon: Icons.people_outline,
                      title: 'Todavía no hay clientes',
                      message: 'Guarda sus datos, notas e historial de citas.',
                      actionLabel: 'Crear cliente',
                      onAction: () => _editClient(),
                    );
                  }
                  if (items.isEmpty) {
                    return const EmptyState(
                      icon: Icons.search_off,
                      title: 'No encontramos coincidencias',
                      message: 'Prueba con otro nombre o número.',
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async => setState(() {}),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 2, 16, 96),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(child: Text(item.name.isEmpty ? '?' : item.name[0].toUpperCase())),
                            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                            subtitle: Text(item.phone.isEmpty ? 'Sin teléfono' : item.phone),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _details(item),
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

class ClientForm extends StatefulWidget {
  final AppRepository repository;
  final Client? client;

  const ClientForm({super.key, required this.repository, this.client});

  @override
  State<ClientForm> createState() => _ClientFormState();
}

class _ClientFormState extends State<ClientForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController = TextEditingController(text: widget.client?.name ?? '');
  late final TextEditingController _phoneController = TextEditingController(text: widget.client?.phone ?? '');
  late final TextEditingController _notesController = TextEditingController(text: widget.client?.notes ?? '');
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final client = Client(
      id: widget.client?.id,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      notes: _notesController.text.trim(),
      createdAt: widget.client?.createdAt ?? DateTime.now(),
    );
    if (client.id == null) {
      await widget.repository.addClient(client);
    } else {
      await widget.repository.updateClient(client);
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
                  Expanded(
                    child: Text(
                      widget.client == null ? 'Nuevo cliente' : 'Editar cliente',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                autofocus: widget.client == null,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) => (value ?? '').trim().isEmpty ? 'Escribe el nombre.' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Teléfono o WhatsApp'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                minLines: 3,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Notas',
                  hintText: 'Preferencias, indicaciones y observaciones del cliente.',
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.save),
                label: const Padding(padding: EdgeInsets.symmetric(vertical: 13), child: Text('Guardar cliente')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ClientDetails extends StatelessWidget {
  final AppRepository repository;
  final Client client;
  final VoidCallback onEdit;

  const ClientDetails({super.key, required this.repository, required this.client, required this.onEdit});

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
                CircleAvatar(radius: 25, child: Text(client.name[0].toUpperCase())),
                const SizedBox(width: 12),
                Expanded(child: Text(client.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
                IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.phone_outlined),
                      title: Text(client.phone.isEmpty ? 'Sin teléfono' : client.phone),
                    ),
                    if (client.notes.isNotEmpty)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.notes),
                        title: const Text('Notas'),
                        subtitle: Text(client.notes),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            FutureBuilder<List<AppointmentItem>>(
              future: repository.getAppointments(),
              builder: (context, snapshot) {
                final appointments = (snapshot.data ?? const <AppointmentItem>[])
                    .where((item) => item.clientId == client.id)
                    .toList();
                final pending = appointments.fold<int>(0, (sum, item) => sum + item.balanceCents);
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Resumen', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: _Metric(label: 'Citas', value: '${appointments.length}')),
                            Expanded(child: _Metric(label: 'Pendiente', value: formatMoney(pending))),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ClientRecordsPage(
                    repository: repository,
                    client: client,
                  ),
                ),
              ),
              icon: const Icon(Icons.fact_check_outlined),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Consentimientos y fotografías'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        Text(label),
      ],
    );
  }
}
