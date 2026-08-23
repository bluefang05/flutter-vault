import 'package:flutter/material.dart';

import '../app_repository.dart';
import '../models.dart';
import '../utils.dart';
import '../widgets/common.dart';

class DashboardPage extends StatefulWidget {
  final AppRepository repository;
  final ValueChanged<int> navigateTo;

  const DashboardPage({super.key, required this.repository, required this.navigateTo});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            FutureBuilder<Map<String, String>>(
              future: widget.repository.getAllSettings(),
              builder: (context, snapshot) {
                final business = snapshot.data?['business_name'] ?? 'Mi negocio';
                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Buenos días', style: Theme.of(context).textTheme.bodyLarge),
                          Text(
                            business,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      radius: 24,
                      child: Text(business.isEmpty ? 'P' : business[0].toUpperCase()),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 18),
            FutureBuilder<DashboardSummary>(
              future: widget.repository.dashboardSummary(today),
              builder: (context, snapshot) {
                final summary = snapshot.data ?? const DashboardSummary(
                  todayAppointments: 0,
                  todayIncomeCents: 0,
                  todayExpenseCents: 0,
                  pendingCents: 0,
                );
                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.35,
                  children: [
                    SummaryCard(
                      label: 'Citas de hoy',
                      value: '${summary.todayAppointments}',
                      icon: Icons.calendar_today,
                      onTap: () => widget.navigateTo(2),
                    ),
                    SummaryCard(
                      label: 'Ingresos de hoy',
                      value: formatMoney(summary.todayIncomeCents),
                      icon: Icons.south_west_rounded,
                      onTap: () => widget.navigateTo(1),
                    ),
                    SummaryCard(
                      label: 'Gastos de hoy',
                      value: formatMoney(summary.todayExpenseCents),
                      icon: Icons.north_east_rounded,
                      onTap: () => widget.navigateTo(1),
                    ),
                    SummaryCard(
                      label: 'Pendiente por cobrar',
                      value: formatMoney(summary.pendingCents),
                      icon: Icons.pending_actions,
                      onTap: () => widget.navigateTo(2),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 18),
            Text('Acciones rápidas', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => widget.navigateTo(2),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 13),
                      child: Text('Nueva cita'),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => widget.navigateTo(1),
                    icon: const Icon(Icons.point_of_sale),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 13),
                      child: Text('Cobrar'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Text('Próximas citas', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            FutureBuilder<List<AppointmentItem>>(
              future: widget.repository.getAppointments(from: startOfDay(today)),
              builder: (context, snapshot) {
                final items = (snapshot.data ?? const <AppointmentItem>[])
                    .where((item) => item.status != 'cancelled' && item.status != 'completed')
                    .take(5)
                    .toList();
                if (items.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          const Icon(Icons.event_available_outlined),
                          const SizedBox(width: 12),
                          const Expanded(child: Text('No tienes citas próximas registradas.')),
                          TextButton(onPressed: () => widget.navigateTo(2), child: const Text('Agregar')),
                        ],
                      ),
                    ),
                  );
                }
                return Card(
                  child: Column(
                    children: [
                      for (var index = 0; index < items.length; index++) ...[
                        ListTile(
                          leading: CircleAvatar(child: Text(formatTime(items[index].startAt).split(':').first)),
                          title: Text(items[index].clientName ?? 'Cliente'),
                          subtitle: Text('${items[index].serviceName ?? 'Servicio'} · ${formatDateTime(items[index].startAt)}'),
                          trailing: items[index].balanceCents > 0
                              ? Text(formatMoney(items[index].balanceCents), style: const TextStyle(fontWeight: FontWeight.bold))
                              : const Icon(Icons.check_circle_outline),
                          onTap: () => widget.navigateTo(2),
                        ),
                        if (index < items.length - 1) const Divider(height: 1),
                      ],
                    ],
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
