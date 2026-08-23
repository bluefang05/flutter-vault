import 'package:flutter/material.dart';
import '../models/user_progress.dart';
import '../models/category.dart';
import '../data/gesture_database.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/section_header.dart';
import '../core/constants/app_colors.dart';
import '../core/services/storage_service.dart';
import '../core/services/feedback_service.dart';
import '../widgets/illustrations/competence_radar_painter.dart';
import 'gesture_detail_screen.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late UserProgress _progress;
  late List<String> _bookmarks;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _progress = StorageService.loadProgress();
      _bookmarks = StorageService.getBookmarks();
    });
  }

  Map<String, double> _calculateCategoryScores() {
    final explored = _progress.exploredGestureIds;
    final totalQuizzes = _progress.totalQuizzesTaken;
    final accuracy = _progress.averageQuizAccuracy / 100.0;

    double calcScore(CategoryType cat) {
      final totalInCat = GestureDatabase.getByCategory(cat).length;
      if (totalInCat == 0) return 0.2;
      final exploredInCat = GestureDatabase.getByCategory(cat).where((g) => explored.contains(g.id)).length;
      final exploreRatio = exploredInCat / totalInCat;
      final quizBonus = totalQuizzes > 0 ? (accuracy * 0.4) : 0.1;
      return (exploreRatio * 0.6 + quizBonus).clamp(0.15, 1.0);
    }

    return {
      'Rostro': calcScore(CategoryType.expresionesFaciales),
      'Voz': calcScore(CategoryType.factoresParalinguisticos),
      'Cuerpo': calcScore(CategoryType.lenguajeCorporal),
      'Espacio': calcScore(CategoryType.proxemica),
      'Entorno': calcScore(CategoryType.entornoApariencia),
      'Digital': calcScore(CategoryType.comunicacionDigital),
    };
  }

  String _getRankTitle(int points) {
    if (points >= 500) return 'Maestro Decodificador';
    if (points >= 300) return 'Analista Experto';
    if (points >= 150) return 'Observador Atento';
    return 'Iniciado en Comunicación';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalGestures = GestureDatabase.items.length;
    final exploredCount = _progress.exploredGestureIds.length;
    final exploredRatio = totalGestures > 0 ? (exploredCount / totalGestures).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Progreso y Maestría'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Rank Banner
          AppCard(
            color: isDark ? const Color(0xFF134E4A) : AppColors.primaryContainer,
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.military_tech_rounded, color: Colors.white, size: 34),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getRankTitle(_progress.totalPoints),
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_progress.totalPoints} puntos acumulados',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white70 : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3-Stat Grid
          Row(
            children: [
              Expanded(
                child: AppCard(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      const Icon(Icons.local_fire_department_rounded, color: AppColors.accent, size: 26),
                      const SizedBox(height: 4),
                      Text(
                        '${_progress.currentStreak} días',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      const Text('Racha Activa', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppCard(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 26),
                      const SizedBox(height: 4),
                      Text(
                        '${_progress.averageQuizAccuracy.round()}%',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      const Text('Precisión Quiz', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppCard(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      const Icon(Icons.theater_comedy_rounded, color: AppColors.indigo, size: 26),
                      const SizedBox(height: 4),
                      Text(
                        '${_progress.completedScenarioIds.length}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      const Text('Escenarios', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Explored Gestures Bar
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Señales y Gestos Explorados', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800)),
                    Text('$exploredCount de $totalGestures', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: exploredRatio,
                    minHeight: 8,
                    backgroundColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Radar Chart: Radar de Competencias No Verbales
          const SectionHeader(
            title: 'Radar de Competencias No Verbales',
            subtitle: 'Tu nivel de dominio en las 6 dimensiones de la comunicación',
          ),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            child: Center(
              child: SizedBox(
                width: 280,
                height: 260,
                child: CustomPaint(
                  painter: CompetenceRadarPainter(
                    scores: _calculateCategoryScores(),
                    isDark: isDark,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Bookmarked Gestures Section
          SectionHeader(
            title: 'Señales Guardadas (${_bookmarks.length})',
            subtitle: 'Tus señales destacadas para repaso',
          ),
          const SizedBox(height: 8),

          if (_bookmarks.isEmpty)
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No tienes señales guardadas aún.\nToca el ícono de marcador en cualquier señal para guardarla aquí.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.5, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                ),
              ),
            )
          else
            for (final bookmarkId in _bookmarks) ...[
              Builder(builder: (context) {
                final item = GestureDatabase.getById(bookmarkId);
                if (item == null) return const SizedBox.shrink();
                final cat = CategoryInfo.getInfo(item.category);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    onTap: () {
                      FeedbackService.lightClick();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GestureDetailScreen(gestureId: item.id),
                        ),
                      ).then((_) => _loadData());
                    },
                    child: Row(
                      children: [
                        Icon(cat.icon, size: 20, color: cat.primaryColor),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey),
                      ],
                    ),
                  ),
                );
              }),
            ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
