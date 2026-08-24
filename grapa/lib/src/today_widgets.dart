part of '../main.dart';

class _EmptyMissions extends StatelessWidget {
  const _EmptyMissions();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(Icons.playlist_add_rounded, size: 34, color: Color(0xFF7656D6)),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Aún no tienes misiones diarias. Añade la primera para comenzar.',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.progress,
    required this.completed,
    required this.total,
  });

  final double progress;
  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final isComplete = total > 0 && completed == total;
    final message = total == 0
        ? 'Añade tu primera misión\npara comenzar la aventura.'
        : completed == 0
        ? 'Hoy empieza una nueva aventura.\nElige tu primera misión.'
        : !isComplete
        ? '¡Así se hace!\nCada misión nos hace más fuertes.'
        : '¡Día conquistado!\nSaca Grapas no tuvo oportunidad.';
    return Container(
      height: 220,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFE9DFFC),
        image: DecorationImage(
          image: _assetImageForLogicalWidth(
            context,
            ScenarioAssets.cleanMissionPath,
            680,
          ),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.white.withValues(alpha: .34),
            BlendMode.srcATop,
          ),
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            bottom: 8,
            width: 145,
            height: 180,
            child: _GrapaActionScene(progress: progress),
          ),
          Positioned(
            left: 16,
            top: 16,
            bottom: 26,
            width: 190,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F5EC).withValues(alpha: .92),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'GRAPA DICE',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF684CB5),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 14.5,
                      height: 1.25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 12,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.white.withValues(alpha: .8),
                color: const Color(0xFF7656D6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GrapaActionScene extends StatelessWidget {
  const _GrapaActionScene({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 178,
      height: 205,
      child: Opacity(
        opacity: progress == 0 ? .9 : 1,
        child: Image.asset(
          GrapaActionAssets.forProgress(progress),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _SacaGrapaLaughAnimation extends StatefulWidget {
  const _SacaGrapaLaughAnimation({required this.size});

  final double size;

  @override
  State<_SacaGrapaLaughAnimation> createState() =>
      _SacaGrapaLaughAnimationState();
}

class _SacaGrapaLaughAnimationState extends State<_SacaGrapaLaughAnimation> {
  Timer? _timer;
  int _frame = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 110), (_) {
      if (!mounted) return;
      setState(() {
        _frame = (_frame + 1) % SacaGrapaAssets.laughFrames.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      SacaGrapaAssets.laughFrames[_frame],
      width: widget.size,
      height: widget.size,
      fit: BoxFit.contain,
    );
  }
}

class _RewardSnackContent extends StatelessWidget {
  const _RewardSnackContent({
    required this.rewardGranted,
    required this.rewardAmount,
  });

  final bool rewardGranted;
  final int rewardAmount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 42,
          height: 42,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(EffectAssets.missionCompleted, fit: BoxFit.cover),
              Image.asset(
                EconomyAssets.coin,
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            rewardGranted
                ? '¡Misión completada!  +$rewardAmount monedas'
                : 'Misión completada. Límite diario alcanzado.',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _MissionTile extends StatelessWidget {
  const _MissionTile({
    required this.mission,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Mission mission;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: mission.done ? const Color(0xFFF0ECE4) : const Color(0xFFFFFCF6),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: mission.done
                      ? const Color(0xFF7656D6)
                      : mission.color.withValues(alpha: .22),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: mission.done
                    ? const Icon(Icons.check_rounded, color: Colors.white)
                    : Padding(
                        padding: const EdgeInsets.all(5),
                        child: Image.asset(
                          mission.categoryAsset,
                          fit: BoxFit.contain,
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mission.title,
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        decoration: mission.done
                            ? TextDecoration.lineThrough
                            : null,
                        color: mission.done ? const Color(0xFF8A8378) : null,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      mission.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8A8378),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Opciones de misión',
                icon: const Icon(Icons.more_vert_rounded),
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Editar')),
                  PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.assetPath, required this.text});
  final String assetPath;
  final String text;

  @override
  Widget build(BuildContext context) {
    final isBrandBadge = assetPath == UiBrandingAssets.streakBadge;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isBrandBadge ? 6 : 10,
        vertical: isBrandBadge ? 4 : 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF6),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE2DBD0)),
      ),
      child: Row(
        children: [
          Image.asset(
            assetPath,
            width: isBrandBadge ? 28 : 18,
            height: isBrandBadge ? 28 : 18,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _WeeklyStreakRow extends StatelessWidget {
  const _WeeklyStreakRow({
    required this.completedDatesHistory,
    required this.todayDone,
  });

  final Set<String> completedDatesHistory;
  final bool todayDone;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    const dayNames = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEADBCE)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (index) {
          final date = monday.add(Duration(days: index));
          final dateKey = '${date.year}-${date.month}-${date.day}';
          final isToday =
              date.day == now.day &&
              date.month == now.month &&
              date.year == now.year;
          final isDone =
              completedDatesHistory.contains(dateKey) || (isToday && todayDone);
          final isFuture = date.isAfter(DateTime(now.year, now.month, now.day));

          return Column(
            children: [
              Text(
                dayNames[index],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isToday
                      ? const Color(0xFF7656D6)
                      : const Color(0xFF8A8378),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isDone
                      ? const Color(0xFFFFF2D6)
                      : isToday
                      ? const Color(0xFFEDE7FA)
                      : const Color(0xFFF3EFE9),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isToday
                        ? const Color(0xFF7656D6)
                        : isDone
                        ? const Color(0xFFF5B041)
                        : Colors.transparent,
                    width: isToday ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: isDone
                      ? Image.asset(
                          UiBrandingAssets.streakBadge,
                          width: 22,
                          height: 22,
                          fit: BoxFit.contain,
                        )
                      : isToday
                      ? Text(
                          '${date.day}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF7656D6),
                          ),
                        )
                      : Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isFuture
                                ? const Color(0xFFCCC5B9)
                                : const Color(0xFF8A8378),
                          ),
                        ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _FocusDuelBanner extends StatelessWidget {
  const _FocusDuelBanner({required this.onStartDuel});

  final VoidCallback onStartDuel;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF2E243D),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onStartDuel,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFF473A5E)),
          ),
          child: Row(
            children: [
              Image.asset(
                GrapaAssets.determined,
                width: 54,
                height: 54,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⏱️ Duelo de Enfoque',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Sesión de concentración para derrotar a Saca Grapas.',
                      style: TextStyle(
                        color: Color(0xFFD3CBE8),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.play_circle_fill_rounded,
                color: Color(0xFFF5B041),
                size: 34,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FocusDuelSheet extends StatefulWidget {
  const _FocusDuelSheet({required this.missions, required this.onCompleteDuel});

  final List<Mission> missions;
  final void Function(int minutes, Mission? mission) onCompleteDuel;

  @override
  State<_FocusDuelSheet> createState() => _FocusDuelSheetState();
}

class _FocusDuelSheetState extends State<_FocusDuelSheet> {
  int _selectedMinutes = 15;
  Mission? _selectedMission;
  bool _isRunning = false;
  bool _isVictory = false;
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final pending = widget.missions.where((m) => !m.done).toList();
    if (pending.isNotEmpty) _selectedMission = pending.first;
    _remainingSeconds = _selectedMinutes * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startDuel() {
    setState(() {
      _isRunning = true;
      _isVictory = false;
      _remainingSeconds = _selectedMinutes * 60;
    });
    HapticFeedback.mediumImpact();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        if (mounted) setState(() => _remainingSeconds -= 1);
      } else {
        _timer?.cancel();
        if (mounted) {
          setState(() {
            _isRunning = false;
            _isVictory = true;
          });
          HapticFeedback.heavyImpact();
        }
      }
    });
  }

  void _cancelDuel() {
    _timer?.cancel();
    HapticFeedback.lightImpact();
    Navigator.pop(context);
  }

  String _formatTime(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final pendingMissions = widget.missions.where((m) => !m.done).toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFCF6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4CDC1),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_isVictory) ...[
                Image.asset(
                  SacaGrapaAssets.defeated,
                  height: 110,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 12),
                const Text(
                  '¡Saca Grapas ha sido derrotado!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  'Completaste $_selectedMinutes min de concentración profunda.\n¡Has ganado +15 monedas de bonificación!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF80776D),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      widget.onCompleteDuel(_selectedMinutes, _selectedMission);
                      Navigator.pop(context);
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFF7656D6),
                    ),
                    child: const Text(
                      '¡Reclamar victoria (+15 🪙)!',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ] else if (_isRunning) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      GrapaAssets.determined,
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 16),
                    Image.asset(
                      SacaGrapaAssets.temptingProcrastination,
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  _formatTime(_remainingSeconds),
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: Color(0xFF493D36),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Mantén tu mente enfocada. ¡No cedas a la distracción!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF80776D),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  onPressed: _cancelDuel,
                  child: const Text('Rendirse por ahora'),
                ),
              ] else ...[
                Image.asset(
                  SacaGrapaAssets.temptingProcrastination,
                  height: 90,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Duelo de Enfoque Pomodoro',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Elige la duración y la misión que vas a realizar para vencer la procrastinación.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF80776D),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Tiempo de concentración:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [15, 25, 45].map((mins) {
                    final isSelected = _selectedMinutes == mins;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: ChoiceChip(
                        label: Text('$mins min'),
                        selected: isSelected,
                        onSelected: (_) => setState(() {
                          _selectedMinutes = mins;
                          _remainingSeconds = mins * 60;
                        }),
                      ),
                    );
                  }).toList(),
                ),
                if (pendingMissions.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Asociar a misión pendiente:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Mission?>(
                    initialValue: _selectedMission,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Enfoque libre'),
                      ),
                      ...pendingMissions.map(
                        (m) => DropdownMenuItem(value: m, child: Text(m.title)),
                      ),
                    ],
                    onChanged: (val) => setState(() => _selectedMission = val),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _startDuel,
                    icon: const Icon(Icons.bolt_rounded),
                    label: const Text('¡Comenzar Duelo!'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
