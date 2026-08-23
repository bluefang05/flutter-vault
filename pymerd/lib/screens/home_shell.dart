import 'package:flutter/material.dart';

import '../app_repository.dart';
import '../widgets/pyme_ad_banner.dart';
import 'appointments_page.dart';
import 'clients_page.dart';
import 'dashboard_page.dart';
import 'more_page.dart';
import 'operations_page.dart';

class HomeShell extends StatefulWidget {
  final AppRepository repository;

  const HomeShell({super.key, required this.repository});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  late final List<Widget> _pages = [
    DashboardPage(repository: widget.repository, navigateTo: _navigateTo),
    OperationsPage(repository: widget.repository),
    AppointmentsPage(repository: widget.repository),
    ClientsPage(repository: widget.repository),
    MorePage(repository: widget.repository),
  ];

  void _navigateTo(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.repository,
      builder: (context, _) => Scaffold(
        body: IndexedStack(index: _index, children: _pages),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: _navigateTo,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: const [
                NavigationDestination(icon: Icon(Icons.today_outlined), selectedIcon: Icon(Icons.today), label: 'Hoy'),
                NavigationDestination(icon: Icon(Icons.payments_outlined), selectedIcon: Icon(Icons.payments), label: 'Operaciones'),
                NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Citas'),
                NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Clientes'),
                NavigationDestination(icon: Icon(Icons.more_horiz), label: 'Más'),
              ],
            ),
            PymeAdBanner(visible: _index == 0 || _index == 2 || _index == 3),
          ],
        ),
      ),
    );
  }
}