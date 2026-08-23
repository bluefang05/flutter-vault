import 'package:flutter/material.dart';

import '../app_repository.dart';
import '../models.dart';
import '../services/native_file_service.dart';
import '../services/pdf_service.dart';
import '../utils.dart';
import '../widgets/common.dart';
import 'sales_page.dart';

class OperationsPage extends StatefulWidget {
  final AppRepository repository;

  const OperationsPage({super.key, required this.repository});

  @override
  State<OperationsPage> createState() => _OperationsPageState();
}

class _OperationsPageState extends State<OperationsPage> {
  Future<void> _newSale() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuickSalePage(repository: widget.repository),
      ),
    );
    setState(() {});
  }

  Future<void> _salesHistory() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SalesHistoryPage(repository: widget.repository),
      ),
    );
    setState(() {});
  }

  Future<void> _openForm(String type) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => TransactionForm(repository: widget.repository, type: type),
    );
    if (saved == true) setState(() {});
  }

  Future<void> _saveReceipt(MoneyTransaction transaction) async {
    final settings = await widget.repository.getAllSettings();
    final bytes = await PdfService.transactionReceipt(
      businessName: settings['business_name'] ?? 'Mi negocio',
      transaction: transaction,
    );
    final ok = await NativeFileService.saveBytes(
      fileName: 'recibo_${transaction.id ?? DateTime.now().millisecondsSinceEpoch}.pdf',
      mimeType: 'application/pdf',
      bytes: bytes,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Recibo guardado.' : 'No se guardó el recibo.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Operaciones',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  tooltip: 'Ventas y recibos',
                  onPressed: _salesHistory,
                  icon: const Icon(Icons.receipt_long_outlined),
                ),
                IconButton(
                  tooltip: 'Actualizar',
                  onPressed: () => setState(() {}),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _newSale,
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Nueva venta'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _openForm('income'),
                        icon: const Icon(Icons.add_card),
                        label: const Text('Otro ingreso'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _openForm('expense'),
                        icon: const Icon(Icons.receipt_long),
                        label: const Text('Gasto'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _openForm('withdrawal'),
                        icon: const Icon(Icons.account_balance_wallet_outlined),
                        label: const Text('Retiro'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: FutureBuilder<List<MoneyTransaction>>(
              future: widget.repository.getTransactions(limit: 100),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = snapshot.data ?? const <MoneyTransaction>[];
                if (items.isEmpty) {
                  return EmptyState(
                    icon: Icons.payments_outlined,
                    title: 'Todavía no hay movimientos',
                    message: 'Registra un cobro, un gasto o un retiro personal.',
                    actionLabel: 'Crear venta',
                    onAction: _newSale,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => setState(() {}),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final incoming = item.type == 'income';
                      final icon = incoming
                          ? Icons.south_west_rounded
                          : item.type == 'withdrawal'
                              ? Icons.account_balance_wallet_outlined
                              : Icons.north_east_rounded;
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(child: Icon(icon)),
                          title: Text(item.description),
                          subtitle: Text([
                            formatDateTime(item.date),
                            item.clientName,
                            item.paymentMethod,
                          ].whereType<String>().where((value) => value.isNotEmpty).join(' · ')),
                          trailing: Text(
                            '${incoming ? '+' : '-'}${formatMoney(item.amountCents)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: incoming ? Colors.green.shade700 : Colors.red.shade700,
                            ),
                          ),
                          onTap: incoming ? () => _saveReceipt(item) : null,
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
    );
  }
}

class TransactionForm extends StatefulWidget {
  final AppRepository repository;
  final String type;

  const TransactionForm({super.key, required this.repository, required this.type});

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String _paymentMethod = 'Efectivo';
  String _category = '';
  int? _clientId;
  bool _saving = false;

  bool get _isIncome => widget.type == 'income';

  String get _title {
    switch (widget.type) {
      case 'expense':
        return 'Registrar gasto';
      case 'withdrawal':
        return 'Registrar retiro personal';
      default:
        return 'Registrar cobro';
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await widget.repository.addTransaction(
      MoneyTransaction(
        type: widget.type,
        description: _descriptionController.text.trim(),
        amountCents: parseMoneyToCents(_amountController.text),
        date: DateTime.now(),
        clientId: _isIncome ? _clientId : null,
        paymentMethod: _paymentMethod,
        category: _category,
        notes: _notesController.text.trim(),
      ),
    );
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
                  Expanded(child: Text(_title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: _isIncome ? '¿Qué cobraste?' : widget.type == 'expense' ? '¿En qué gastaste?' : 'Motivo del retiro',
                ),
                validator: (value) => (value ?? '').trim().isEmpty ? 'Escribe una descripción.' : null,
              ),
              const SizedBox(height: 12),
              MoneyField(controller: _amountController, label: 'Monto'),
              const SizedBox(height: 12),
              if (_isIncome)
                FutureBuilder<List<Client>>(
                  future: widget.repository.getClients(),
                  builder: (context, snapshot) {
                    final clients = snapshot.data ?? const <Client>[];
                    return DropdownButtonFormField<int?>(
                      initialValue: _clientId,
                      decoration: const InputDecoration(labelText: 'Cliente', helperText: 'Opcional'),
                      items: [
                        const DropdownMenuItem<int?>(value: null, child: Text('Venta sin cliente')),
                        ...clients.map((client) => DropdownMenuItem<int?>(value: client.id, child: Text(client.name))),
                      ],
                      onChanged: (value) => setState(() => _clientId = value),
                    );
                  },
                ),
              if (_isIncome) const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _paymentMethod,
                decoration: const InputDecoration(labelText: 'Método de pago'),
                items: const [
                  DropdownMenuItem(value: 'Efectivo', child: Text('Efectivo')),
                  DropdownMenuItem(value: 'Transferencia', child: Text('Transferencia')),
                  DropdownMenuItem(value: 'Tarjeta', child: Text('Tarjeta')),
                  DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                ],
                onChanged: (value) => setState(() => _paymentMethod = value ?? _paymentMethod),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: _categories(widget.type)
                    .map((value) => DropdownMenuItem(value: value, child: Text(value.isEmpty ? 'Sin categoría' : value)))
                    .toList(),
                onChanged: (value) => setState(() => _category = value ?? ''),
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
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.save),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 13),
                  child: Text('Guardar operación'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _categories(String type) {
    if (type == 'income') return const ['', 'Servicio', 'Producto', 'Anticipo', 'Abono', 'Propina', 'Otro'];
    if (type == 'withdrawal') return const ['', 'Uso personal', 'Adelanto del propietario', 'Otro'];
    return const [
      '',
      'Insumos',
      'Transporte',
      'Alquiler',
      'Electricidad',
      'Agua',
      'Publicidad',
      'Limpieza',
      'Lavandería',
      'Mantenimiento',
      'Capacitación',
      'Impuestos',
      'Otro',
    ];
  }
}