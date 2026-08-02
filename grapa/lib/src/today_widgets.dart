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
