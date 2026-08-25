import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/category.dart';
import '../data/quiz_database.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/badge_pill.dart';
import '../widgets/common/section_header.dart';
import '../core/services/feedback_service.dart';
import 'quiz_runner_screen.dart';
import 'flash_quiz_screen.dart';
import 'incongruence_detector_screen.dart';
import 'buyer_temperature_screen.dart';

class QuizHubScreen extends StatelessWidget {
  const QuizHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zona de Práctica'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 640;
          final isWide = constraints.maxWidth >= 960;
          final catColumns = isWide ? 3 : (isTablet ? 2 : 1);

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1050),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // Mode 1: Visual Image-Grid Quiz (Featured!)
                  AppCard(
                    color: isDark ? const Color(0xFF134E4A) : AppColors.primaryContainer,
                    borderSide: BorderSide(
                      color: isDark ? AppColors.primaryLight : AppColors.primary,
                      width: 1.8,
                    ),
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            BadgePill(
                              text: 'Modo Destacado',
                              icon: Icons.auto_awesome_rounded,
                              color: AppColors.primaryDark,
                              backgroundColor: Colors.white.withValues(alpha: 0.8),
                            ),
                            const Spacer(),
                            const Icon(Icons.grid_view_rounded, color: AppColors.primaryDark),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Test de Reconocimiento Visual (Con Imágenes)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Elige la tarjeta visual correcta entre 4 opciones con ilustraciones de microexpresiones, posturas y proxémica.',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.play_circle_filled_rounded),
                          label: const Text('Iniciar Test Visual'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
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
                  const SizedBox(height: 14),

                  // Practice Modes Grid on Tablet
                  if (isTablet)
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 2.1,
                      children: [
                        // Mode: Incongruence Detector (Autism / Calibration Focus)
                        AppCard(
                          color: isDark ? const Color(0xFF312E81).withValues(alpha: 0.35) : const Color(0xFFEEF2FF),
                          padding: const EdgeInsets.all(16),
                          onTap: () {
                            FeedbackService.lightClick();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const IncongruenceDetectorScreen()),
                            );
                          },
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.psychology_alt_rounded, color: Color(0xFF6366F1), size: 26),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Detector de Incongruencias',
                                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '¿Palabras vs cuerpo? Descifra la verdad.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded, color: Color(0xFF6366F1)),
                            ],
                          ),
                        ),

                        // Mode: Buyer Temperature (Sales Focus)
                        AppCard(
                          color: isDark ? const Color(0xFF451A03).withValues(alpha: 0.35) : const Color(0xFFFFFBEB),
                          padding: const EdgeInsets.all(16),
                          onTap: () {
                            FeedbackService.lightClick();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const BuyerTemperatureScreen()),
                            );
                          },
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD97706).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.thermostat_rounded, color: Color(0xFFD97706), size: 26),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Termómetro de Ventas',
                                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Mide la receptividad y detecta el cierre.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded, color: Color(0xFFD97706)),
                            ],
                          ),
                        ),

                        // Mode: Flash Contrarreloj
                        AppCard(
                          color: isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7),
                          padding: const EdgeInsets.all(16),
                          onTap: () {
                            FeedbackService.lightClick();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const FlashQuizScreen()),
                            );
                          },
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.flash_on_rounded, color: AppColors.accent, size: 26),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          'Modo Flash',
                                          style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                                        ),
                                        const SizedBox(width: 6),
                                        BadgePill(text: '3 seg', color: AppColors.accent),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Entrena reflejos en 3s.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded, color: AppColors.accent),
                            ],
                          ),
                        ),

                        // Mode: Sales & Workplace Quiz
                        AppCard(
                          color: isDark ? const Color(0xFF1E1B4B) : const Color(0xFFEEF2FF),
                          padding: const EdgeInsets.all(16),
                          onTap: () {
                            FeedbackService.lightClick();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => QuizRunnerScreen(
                                  title: 'Ventas y Negociación',
                                  questions: QuizDatabase.questions,
                                ),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.indigo.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.business_center_rounded, color: AppColors.indigo, size: 26),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Ventas y Negociación',
                                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Preguntas de cierre y objeciones.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded, color: AppColors.indigo),
                            ],
                          ),
                        ),
                      ],
                    )
                  else ...[
                    // Mobile Stack
                    AppCard(
                      color: isDark ? const Color(0xFF312E81).withValues(alpha: 0.35) : const Color(0xFFEEF2FF),
                      padding: const EdgeInsets.all(16),
                      onTap: () {
                        FeedbackService.lightClick();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const IncongruenceDetectorScreen()),
                        );
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.psychology_alt_rounded, color: Color(0xFF6366F1), size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Detector de Incongruencias',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Aprende a detectar cuándo las palabras ocultan una emoción o molestia.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: Color(0xFF6366F1)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppCard(
                      color: isDark ? const Color(0xFF451A03).withValues(alpha: 0.35) : const Color(0xFFFFFBEB),
                      padding: const EdgeInsets.all(16),
                      onTap: () {
                        FeedbackService.lightClick();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const BuyerTemperatureScreen()),
                        );
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD97706).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.thermostat_rounded, color: Color(0xFFD97706), size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Termómetro de Negociación',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Calibra la temperatura de compra y conoce la táctica de cierre óptima.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: Color(0xFFD97706)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppCard(
                      color: isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7),
                      padding: const EdgeInsets.all(16),
                      onTap: () {
                        FeedbackService.lightClick();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FlashQuizScreen()),
                        );
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.flash_on_rounded, color: AppColors.accent, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'Modo Flash Contrarreloj',
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                                    ),
                                    const SizedBox(width: 6),
                                    BadgePill(text: '3 seg', color: AppColors.accent),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'La imagen desaparece en 3s: entrena tus reflejos para captar microexpresiones fugaces en vivo.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: AppColors.accent),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    AppCard(
                      color: isDark ? const Color(0xFF1E1B4B) : const Color(0xFFEEF2FF),
                      padding: const EdgeInsets.all(16),
                      onTap: () {
                        FeedbackService.lightClick();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QuizRunnerScreen(
                              title: 'Ventas y Negociación',
                              questions: QuizDatabase.questions,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.indigo.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.business_center_rounded, color: AppColors.indigo, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Test para Ventas y Negociación',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Preguntas prácticas para detectar objeciones y señales de compra.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: AppColors.indigo),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Categorías Específicas
                  const SectionHeader(
                    title: 'Quizzes por Categoría',
                    subtitle: 'Entrena un área específica a tu propio ritmo',
                  ),
                  const SizedBox(height: 8),

                  if (isTablet)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: catColumns,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: isWide ? 2.6 : 2.3,
                      ),
                      itemCount: CategoryInfo.allCategories.length,
                      itemBuilder: (context, index) {
                        final cat = CategoryInfo.allCategories[index];
                        return AppCard(
                          padding: const EdgeInsets.all(14),
                          onTap: () {
                            FeedbackService.lightClick();
                            final qList = QuizDatabase.getByCategory(cat.type);
                            final questions = qList.isNotEmpty ? qList : QuizDatabase.questions;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => QuizRunnerScreen(
                                  title: cat.title,
                                  questions: questions,
                                ),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: cat.primaryColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(cat.icon, color: cat.primaryColor, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      cat.title,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      cat.chapterReference,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                            ],
                          ),
                        );
                      },
                    )
                  else
                    for (final cat in CategoryInfo.allCategories) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: AppCard(
                          padding: const EdgeInsets.all(14),
                          onTap: () {
                            FeedbackService.lightClick();
                            final qList = QuizDatabase.getByCategory(cat.type);
                            final questions = qList.isNotEmpty ? qList : QuizDatabase.questions;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => QuizRunnerScreen(
                                  title: cat.title,
                                  questions: questions,
                                ),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: cat.primaryColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(cat.icon, color: cat.primaryColor, size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cat.title,
                                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      cat.chapterReference,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
