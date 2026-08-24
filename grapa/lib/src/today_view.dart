part of '../main.dart';

class _TodayView extends StatelessWidget {
  const _TodayView({
    required this.missions,
    required this.completed,
    required this.coins,
    required this.streak,
    required this.dailyRewardsEarned,
    required this.maxDailyReward,
    required this.completedDatesHistory,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.onAdd,
    required this.onStartFocusDuel,
  });

  final List<Mission> missions;
  final int completed;
  final int coins;
  final int streak;
  final int dailyRewardsEarned;
  final int maxDailyReward;
  final Set<String> completedDatesHistory;
  final ValueChanged<int> onToggle;
  final ValueChanged<int> onEdit;
  final ValueChanged<int> onDelete;
  final VoidCallback onAdd;
  final VoidCallback onStartFocusDuel;

  String get _todayLabel {
    const weekdays = [
      'LUNES',
      'MARTES',
      'MIÉRCOLES',
      'JUEVES',
      'VIERNES',
      'SÁBADO',
      'DOMINGO',
    ];
    const months = [
      'ENERO',
      'FEBRERO',
      'MARZO',
      'ABRIL',
      'MAYO',
      'JUNIO',
      'JULIO',
      'AGOSTO',
      'SEPTIEMBRE',
      'OCTUBRE',
      'NOVIEMBRE',
      'DICIEMBRE',
    ];
    final now = DateTime.now();
    return '${weekdays[now.weekday - 1]}, ${now.day} DE ${months[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = missions.isEmpty ? 0.0 : completed / missions.length;
    final dailyRewardRemaining = maxDailyReward - dailyRewardsEarned;
    final todayDone = missions.isNotEmpty && completed == missions.length;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          sliver: SliverList.list(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _todayLabel,
                          style: const TextStyle(
                            fontSize: 11,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF81786C),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                UiBrandingAssets.appIcon,
                                width: 42,
                                height: 42,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Grapa',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF493D36),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Tu aventura de hoy',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF5C5148),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _Pill(
                    assetPath: UiBrandingAssets.streakBadge,
                    text: '$streak',
                  ),
                  const SizedBox(width: 8),
                  _Pill(assetPath: EconomyAssets.coin, text: '$coins'),
                ],
              ),
              const SizedBox(height: 20),
              _HeroCard(
                progress: progress,
                completed: completed,
                total: missions.length,
              ),
              const SizedBox(height: 14),
              _WeeklyStreakRow(
                completedDatesHistory: completedDatesHistory,
                todayDone: todayDone,
              ),
              const SizedBox(height: 12),
              _FocusDuelBanner(onStartDuel: onStartFocusDuel),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Misiones de hoy',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$completed/${missions.length} listas',
                        style: const TextStyle(
                          color: Color(0xFF81786C),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        dailyRewardRemaining > 0
                            ? '$dailyRewardRemaining monedas hoy'
                            : 'tope diario alcanzado',
                        style: const TextStyle(
                          color: Color(0xFF9A6A13),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: missions.isEmpty
              ? const SliverToBoxAdapter(child: _EmptyMissions())
              : SliverList.separated(
                  itemCount: missions.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _MissionTile(
                    mission: missions[index],
                    onTap: () => onToggle(index),
                    onEdit: () => onEdit(index),
                    onDelete: () => onDelete(index),
                  ),
                ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          sliver: SliverToBoxAdapter(
            child: OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Añadir una misión diaria'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                side: const BorderSide(color: Color(0xFFD7D0C4)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
