import 'package:flutter/material.dart';
import '../data/scenario_database.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/badge_pill.dart';
import '../core/constants/app_colors.dart';
import '../core/services/feedback_service.dart';
import '../core/services/storage_service.dart';
import 'scenario_runner_screen.dart';

class ScenariosScreen extends StatefulWidget {
  const ScenariosScreen({super.key});

  @override
  State<ScenariosScreen> createState() => _ScenariosScreenState();
}

class _ScenariosScreenState extends State<ScenariosScreen> {
  List<String> _completedIds = [];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  void _loadProgress() {
    setState(() {
      _completedIds = StorageService.loadProgress().completedScenarioIds;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulador de Escenarios'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Banner intro
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.theater_comedy_rounded, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Entrena en situaciones reales de ventas, entrevistas y vida social. Toma decisiones y observa las consecuencias.',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // List of Scenarios
          for (final scenario in ScenarioDatabase.scenarios) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 14.0),
              child: AppCard(
                padding: const EdgeInsets.all(16),
                onTap: () {
                  FeedbackService.lightClick();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ScenarioRunnerScreen(scenario: scenario),
                    ),
                  ).then((_) => _loadProgress());
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        BadgePill(
                          text: scenario.domain,
                          color: AppColors.indigo,
                        ),
                        const Spacer(),
                        if (_completedIds.contains(scenario.id))
                          const BadgePill(
                            text: 'Completado',
                            icon: Icons.check_circle_rounded,
                            color: AppColors.success,
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      scenario.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      scenario.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.format_list_numbered_rounded, size: 16, color: AppColors.textMutedLight),
                        const SizedBox(width: 4),
                        Text(
                          '${scenario.steps.length} momentos de decisión',
                          style: TextStyle(fontSize: 12, color: AppColors.textMutedLight),
                        ),
                        const Spacer(),
                        const Text(
                          'Comenzar',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primary),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
