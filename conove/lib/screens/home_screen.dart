import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/category.dart';
import '../data/gesture_database.dart';
import '../data/quiz_database.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/badge_pill.dart';
import '../widgets/common/section_header.dart';
import '../widgets/illustrations/conove_logo_painter.dart';
import '../core/services/feedback_service.dart';
import 'decoder_screen.dart';
import 'quiz_runner_screen.dart';
import 'progress_screen.dart';
import 'compare_screen.dart';
import 'decision_tree_screen.dart';
import 'cheat_sheet_screen.dart';

class HomeScreen extends StatelessWidget {
  final ValueChanged<int> onNavigateToTab;

  const HomeScreen({super.key, required this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const ConoVeLogoWidget(size: 36),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ConoVe',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                ),
                Text(
                  'Comunicación No Verbal',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights_rounded),
            tooltip: 'Mi Progreso',
            onPressed: () {
              FeedbackService.lightClick();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProgressScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Hero Card: Decodificador Rápido
          AppCard(
            color: isDark ? const Color(0xFF134E4A) : AppColors.primaryContainer,
            borderSide: BorderSide(
              color: isDark ? AppColors.primaryLight.withValues(alpha: 0.5) : AppColors.primaryLight,
              width: 1.5,
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    BadgePill(
                      text: 'Buscador de campo',
                      color: AppColors.primaryDark,
                      backgroundColor: Colors.white.withValues(alpha: 0.8),
                    ),
                    const Spacer(),
                    const Icon(Icons.troubleshoot_rounded, color: AppColors.primaryDark),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '¿Viste un gesto y no sabes qué significa?',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Filtra por parte del cuerpo (ojos, boca, brazos, silencios) y descifra la intención oculta en segundos.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  icon: const Icon(Icons.search_rounded, size: 18),
                  label: const Text('Abrir Decodificador en Vivo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(44),
                  ),
                  onPressed: () {
                    FeedbackService.lightClick();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DecoderScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Daily Image Quiz Banner
          AppCard(
            color: isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.psychology_rounded, color: AppColors.accent, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Entrenamiento Visual Rápido',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Aprende a diferenciar microexpresiones con imágenes.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filled(
                  style: IconButton.styleFrom(backgroundColor: AppColors.accent),
                  icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                  onPressed: () {
                    FeedbackService.lightClick();
                    final imageQuestions = QuizDatabase.getImageCardQuestions();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizRunnerScreen(
                          title: 'Test Visual de Microexpresiones',
                          questions: imageQuestions.isNotEmpty ? imageQuestions : QuizDatabase.questions,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Comparador Visual A/B Banner
          AppCard(
            color: isDark ? const Color(0xFF1E1B4B) : const Color(0xFFEEF2FF),
            padding: const EdgeInsets.all(16),
            onTap: () {
              FeedbackService.lightClick();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CompareScreen()),
              );
            },
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.purple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.compare_arrows_rounded, color: AppColors.purple, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Comparador Visual A/B',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Compara cara a cara gestos que se confunden fácilmente.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.purple),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Árbol de Decisión Social Banner
          AppCard(
            color: isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5),
            padding: const EdgeInsets.all(16),
            onTap: () {
              FeedbackService.lightClick();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DecisionTreeScreen()),
              );
            },
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.account_tree_rounded, color: AppColors.success, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Árbol de Decisión Social',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Regla: Si veo X ➔ Significa Y ➔ Hago Z en 3 clics.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.success),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Guía de Bolsillo (Cheat Sheet) Banner
          AppCard(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
            padding: const EdgeInsets.all(16),
            onTap: () {
              FeedbackService.lightClick();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CheatSheetScreen()),
              );
            },
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.bolt_rounded, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Guía de Bolsillo (Cheat Sheet)',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '20 señales críticas de venta y cierre para consultar en 30s.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Categorías del Manual
          SectionHeader(
            title: 'Explorar por Categoría',
            subtitle: 'Basado en "Descifrando a los neurotípicos"',
            trailing: TextButton(
              onPressed: () => onNavigateToTab(1),
              child: const Text('Ver Todo'),
            ),
          ),
          const SizedBox(height: 6),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.15,
            ),
            itemCount: CategoryInfo.allCategories.length,
            itemBuilder: (context, index) {
              final cat = CategoryInfo.allCategories[index];
              final count = GestureDatabase.getByCategory(cat.type).length;

              return AppCard(
                padding: const EdgeInsets.all(14),
                onTap: () {
                  FeedbackService.lightClick();
                  onNavigateToTab(1); // Nav to dictionary
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: cat.primaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(cat.icon, color: cat.primaryColor, size: 22),
                    ),
                    const Spacer(),
                    Text(
                      cat.title,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$count señales explicadas',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Sales & Negotiation Spotlight
          AppCard(
            color: isDark ? const Color(0xFF1E1B4B) : const Color(0xFFEEF2FF),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.indigo.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.handshake_rounded, color: AppColors.indigo, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Simulador de Ventas y Negociación',
                        style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Aprende a leer al cliente y cerrar acuerdos.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => onNavigateToTab(3), // Nav to Scenarios
                  child: const Text('Entrenar'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
