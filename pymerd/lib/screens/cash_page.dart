import 'package:flutter/material.dart';

import '../app_repository.dart';
import '../models.dart';
import '../utils.dart';
import '../widgets/common.dart';

class CashPage extends StatefulWidget {
  final AppRepository repository;

  const CashPage({super.key, required this.repository});

  @override
  State<CashPage> createState() => _CashPageState();
}

class _CashPageState extends State<CashPage> {
  Future<void> _openCash() async {
    final controller = TextEditingController(text: '0');
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abrir caja'),
        content: MoneyField(controller: controller, label: 'Efectivo inicial'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Abrir')),
        ],
      ),
    );
    if (accepted == true) {
      await widget.repository.openCash(parseMoneyToCents(controller.text));
      setState(() {});
    }
    controller.dispose();
  }

  Future<void> _closeCash(CashSession session) async {
    final expected = await widget.repository.expectedCash(session);
    final countedController = TextEditingController(text: (expected / 100).toStringAsFixed(2));
    final noteController = TextEditingController();
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar caja'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('La aplicación espera ${formatMoney(expected)} en efectivo.'),
              const SizedBox(height: 12),
              MoneyField(controller: countedController, label: 'Efectivo contado'),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Explicación o nota', helperText: 'Opcional'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Cerrar caja')),
        ],
      ),
    );
    if (accepted == true) {
      await widget.repository.closeCash(
        session: session,
        countedCents: parseMoneyToCents(countedController.text),
        note: noteController.text.trim(),
      );
      setState(() {});
    }
    countedController.dispose();
    noteController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Caja del día')),
      body: FutureBuilder<CashSession?>(
        future: widget.repository.getOpenCashSession(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final session = snapshot.data;
          if (session == null) {
            return EmptyState(
              icon: Icons.point_of_sale_outlined,
              title: 'La caja está cerrada',
              message: 'Abre la caja con el efectivo inicial para que PYME RD calcule cuánto debería haber al final.',
              actionLabel: 'Abrir caja',
              onAction: _openCash,
            );
          }
          return FutureBuilder<int>(
            future: widget.repository.expectedCash(session),
            builder: (context, expectedSnapshot) {
              final expected = expectedSnapshot.data ?? session.openingCents;
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(Icons.lock_open_rounded, size: 48, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(height: 12),
                          Text('Caja abierta', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                          Text('Desde ${formatDateTime(session.openedAt)}'),
                          const SizedBox(height: 20),
                          _CashMetric(label: 'Monto inicial', value: formatMoney(session.openingCents)),
                          const Divider(height: 24),
                          _CashMetric(label: 'Efectivo esperado ahora', value: formatMoney(expected), important: true),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Solo se suman cobros en efectivo y se restan gastos o retiros registrados en efectivo. Las transferencias y tarjetas no forman parte del dinero físico de la caja.',
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: () => _closeCash(session),
                    icon: const Icon(Icons.lock_outline),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 13),
                      child: Text('Contar y cerrar caja'),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _CashMetric extends StatelessWidget {
  final String label;
  final String value;
  final bool important;

  const _CashMetric({required this.label, required this.value, this.important = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Text(
          value,
          style: (important ? Theme.of(context).textTheme.headlineSmall : Theme.of(context).textTheme.titleMedium)
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
