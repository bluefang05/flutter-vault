import 'package:flutter/material.dart';

import '../app_repository.dart';
import '../utils.dart';

class ReportsPage extends StatefulWidget {
  final AppRepository repository;

  const ReportsPage({super.key, required this.repository});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  void _moveMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
  }

  String _monthLabel(DateTime date) {
    const names = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    return '${names[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final from = DateTime(_month.year, _month.month, 1);
    final to = DateTime(_month.year, _month.month + 1, 0, 23, 59, 59);
    return Scaffold(
      appBar: AppBar(title: const Text('Resumen del negocio')),
      body: FutureBuilder<Map<String, int>>(
        future: widget.repository.periodTotals(from, to),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final totals = snapshot.data ?? const <String, int>{};
          final income = totals['income'] ?? 0;
          final expense = totals['expense'] ?? 0;
          final withdrawal = totals['withdrawal'] ?? 0;
          final result = income - expense;
          final max = [income, expense, withdrawal].fold<int>(1, (value, item) => item > value ? item : value);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(onPressed: () => _moveMonth(-1), icon: const Icon(Icons.chevron_left)),
                  SizedBox(
                    width: 190,
                    child: Text(
                      _monthLabel(_month),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(onPressed: () => _moveMonth(1), icon: const Icon(Icons.chevron_right)),
                ],
              ),
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Resultado aproximado'),
                      const SizedBox(height: 4),
                      Text(
                        formatMoney(result),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: result >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                            ),
                      ),
                      const SizedBox(height: 6),
                      const Text('Ingresos menos gastos del negocio. Los retiros personales se muestran aparte.'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _ReportLine(label: 'Ingresos', value: income, max: max, icon: Icons.south_west_rounded),
              const SizedBox(height: 10),
              _ReportLine(label: 'Gastos', value: expense, max: max, icon: Icons.north_east_rounded),
              const SizedBox(height: 10),
              _ReportLine(label: 'Retiros personales', value: withdrawal, max: max, icon: Icons.account_balance_wallet_outlined),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Lectura rápida', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text(income == 0
                          ? 'Todavía no hay ingresos registrados en este período.'
                          : expense > income
                              ? 'Los gastos registrados superan los ingresos. Revisa si faltan cobros por registrar o si algún gasto fue realmente un retiro personal.'
                              : 'El negocio registra más ingresos que gastos en este período. Recuerda que esto no sustituye un estado financiero ni una declaración fiscal.'),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReportLine extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final IconData icon;

  const _ReportLine({required this.label, required this.value, required this.max, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 10),
                Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))),
                Text(formatMoney(value), style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: max <= 0 ? 0 : value / max, minHeight: 8, borderRadius: BorderRadius.circular(8)),
          ],
        ),
      ),
    );
  }
}
