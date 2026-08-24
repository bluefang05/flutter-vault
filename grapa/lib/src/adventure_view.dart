part of '../main.dart';

class _AdventureWorldInfo {
  const _AdventureWorldInfo({
    required this.title,
    required this.subtitle,
    required this.scenarioAsset,
    required this.bossTitle,
  });

  final String title;
  final String subtitle;
  final String scenarioAsset;
  final String bossTitle;
}

const _adventureWorlds = [
  _AdventureWorldInfo(
    title: 'Bosque del Enfoque',
    subtitle: 'Comienza tu viaje forjando tus primeros hábitos.',
    scenarioAsset: ScenarioAssets.focusForest,
    bossTitle: 'Guarida de Saca Grapas',
  ),
  _AdventureWorldInfo(
    title: 'Montaña de la Disciplina',
    subtitle: 'Sube la cima de la constancia superando la pereza.',
    scenarioAsset: ScenarioAssets.disciplineMountain,
    bossTitle: 'Cima de la Victoria',
  ),
  _AdventureWorldInfo(
    title: 'Pantano de la Procrastinación',
    subtitle: 'Cruza las aguas de las distracciones y vence el desánimo.',
    scenarioAsset: ScenarioAssets.procrastinationSwamp,
    bossTitle: 'Templo del Enfoque',
  ),
];

class _AdventureView extends StatelessWidget {
  const _AdventureView({
    required this.coins,
    required this.completed,
    required this.total,
    required this.adventureDaysCompleted,
    required this.onOpenToday,
    required this.onClaimWorldChest,
  });

  final int coins;
  final int completed;
  final int total;
  final int adventureDaysCompleted;
  final VoidCallback onOpenToday;
  final VoidCallback onClaimWorldChest;

  @override
  Widget build(BuildContext context) {
    final worldIndex = (adventureDaysCompleted ~/ 7) % _adventureWorlds.length;
    final world = _adventureWorlds[worldIndex];
    final dayInWorld = adventureDaysCompleted % 7;
    final dayComplete = total > 0 && completed == total;
    final canClaimChest = dayInWorld == 6 && dayComplete;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MUNDO ${worldIndex + 1}: ${world.title.toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 12,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF7656D6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tu Aventura',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
            _Pill(assetPath: EconomyAssets.coin, text: '$coins'),
          ],
        ),
        Text(world.subtitle, style: const TextStyle(color: Color(0xFF81786C))),
        const SizedBox(height: 18),
        _AdventureProgressCard(
          completed: completed,
          total: total,
          dayInWorld: dayInWorld + 1,
          worldName: world.title,
        ),
        const SizedBox(height: 16),
        Container(
          height: 380,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: _assetImageForLogicalWidth(
                context,
                world.scenarioAsset,
                680,
              ),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: .22),
                BlendMode.darken,
              ),
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 20,
                left: 20,
                right: 20,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF201A25).withValues(alpha: .78),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      'ETAPA ${dayInWorld + 1} DE 7 · ${world.title.toUpperCase()}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
              ),
              CustomPaint(size: const Size(260, 270), painter: _PathPainter()),
              // 7 Nodes across the world map
              Positioned(
                bottom: 30,
                left: 35,
                child: _MapNode(
                  icon: Icons.home_rounded,
                  status: _nodeStatus(0, dayInWorld, dayComplete),
                  label: 'Día 1: Campamento',
                ),
              ),
              Positioned(
                bottom: 75,
                right: 45,
                child: _MapNode(
                  icon: Icons.directions_walk_rounded,
                  status: _nodeStatus(1, dayInWorld, dayComplete),
                  label: 'Día 2: Sendero',
                ),
              ),
              Positioned(
                bottom: 140,
                left: 65,
                child: _MapNode(
                  icon: Icons.bolt_rounded,
                  status: _nodeStatus(2, dayInWorld, dayComplete),
                  label: 'Día 3: Cascada',
                ),
              ),
              Positioned(
                bottom: 195,
                right: 60,
                child: _MapNode(
                  icon: Icons.shield_rounded,
                  status: _nodeStatus(3, dayInWorld, dayComplete),
                  label: 'Día 4: Paso Guerrero',
                ),
              ),
              Positioned(
                top: 95,
                left: 45,
                child: _MapNode(
                  icon: Icons.auto_awesome_rounded,
                  status: _nodeStatus(4, dayInWorld, dayComplete),
                  label: 'Día 5: Santuario',
                ),
              ),
              Positioned(
                top: 55,
                right: 50,
                child: _MapNode(
                  icon: Icons.military_tech_rounded,
                  status: _nodeStatus(5, dayInWorld, dayComplete),
                  label: 'Día 6: Faro de Constancia',
                ),
              ),
              Positioned(
                top: 40,
                left: 115,
                child: _MapNode(
                  icon: Icons.castle_rounded,
                  status: _nodeStatus(6, dayInWorld, dayComplete),
                  label: 'Día 7: ${world.bossTitle}',
                  isBoss: true,
                ),
              ),
              Positioned(
                right: 12,
                bottom: 10,
                child: Opacity(
                  opacity: dayComplete ? .85 : .65,
                  child: Image.asset(
                    SacaGrapaAssets.forProgress(dayInWorld / 6),
                    width: 78,
                    height: 78,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _InfoCard(
          assetPath: canClaimChest
              ? EconomyAssets.legendaryChest
              : EconomyAssets.rareChest,
          color: const Color(0xFF7656D6),
          title: canClaimChest
              ? '¡Cofre Legendario del Mundo listo!'
              : 'Día ${dayInWorld + 1} de 7: ${world.title}',
          subtitle: canClaimChest
              ? 'Has conquistado este capítulo. Abre el cofre para recibir +100 monedas.'
              : 'Completa las misiones diarias de hoy para avanzar al siguiente nodo del mundo.',
        ),
        const SizedBox(height: 14),
        if (canClaimChest)
          FilledButton.icon(
            onPressed: onClaimWorldChest,
            icon: Image.asset(
              EconomyAssets.legendaryChest,
              width: 24,
              height: 24,
            ),
            label: const Text('¡Abrir Cofre Legendario (+100 🪙)!'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF7656D6),
            ),
          )
        else
          FilledButton.icon(
            onPressed: onOpenToday,
            icon: Icon(total == 0 ? Icons.add_rounded : Icons.flag_rounded),
            label: Text(
              total == 0
                  ? 'Crear mi primera misión'
                  : 'Continuar misiones de hoy',
            ),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
      ],
    );
  }

  static _NodeState _nodeStatus(
    int nodeIndex,
    int dayInWorld,
    bool dayComplete,
  ) {
    if (nodeIndex < dayInWorld) return _NodeState.conquered;
    if (nodeIndex == dayInWorld) {
      return dayComplete ? _NodeState.conquered : _NodeState.active;
    }
    return _NodeState.locked;
  }
}

enum _NodeState { conquered, active, locked }

class _AdventureProgressCard extends StatelessWidget {
  const _AdventureProgressCard({
    required this.completed,
    required this.total,
    required this.dayInWorld,
    required this.worldName,
  });

  final int completed;
  final int total;
  final int dayInWorld;
  final String worldName;

  @override
  Widget build(BuildContext context) {
    final worldProgress = (dayInWorld - 1) / 7;
    final percent =
        ((worldProgress + (total > 0 ? (completed / total) / 7 : 0)) * 100)
            .round()
            .clamp(0, 100);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF6),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE4DBCF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Día $dayInWorld de 7 en $worldName',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '$percent%',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF7656D6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 10,
              backgroundColor: const Color(0xFFE8E0D5),
              color: const Color(0xFF7656D6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            total == 0
                ? 'Sin misiones configuradas hoy.'
                : '$completed de $total misiones completadas hoy.',
            style: const TextStyle(
              color: Color(0xFF81786C),
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _PathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: .75)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(45, 240)
      ..cubicTo(190, 220, 180, 160, 75, 140)
      ..cubicTo(10, 120, 200, 100, 130, 45);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapNode extends StatelessWidget {
  const _MapNode({
    required this.icon,
    required this.status,
    required this.label,
    this.isBoss = false,
  });

  final IconData icon;
  final _NodeState status;
  final String label;
  final bool isBoss;

  @override
  Widget build(BuildContext context) {
    final isConquered = status == _NodeState.conquered;
    final isActive = status == _NodeState.active;

    return Semantics(
      label: label,
      child: Container(
        width: isBoss ? 54 : 44,
        height: isBoss ? 54 : 44,
        decoration: BoxDecoration(
          color: isConquered
              ? const Color(0xFF7656D6)
              : isActive
              ? const Color(0xFFFFFCF6)
              : const Color(0xFFBBB6AD),
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive ? const Color(0xFFF0C75E) : Colors.white,
            width: isActive ? 3.5 : 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? const Color(0x66F0C75E)
                  : const Color(0x33000000),
              blurRadius: isActive ? 10 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          isConquered
              ? Icons.check_rounded
              : isActive
              ? icon
              : Icons.lock_rounded,
          size: isBoss ? 26 : 20,
          color: isConquered
              ? Colors.white
              : isActive
              ? const Color(0xFF7656D6)
              : Colors.white,
        ),
      ),
    );
  }
}
