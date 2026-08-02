part of '../main.dart';

class _AdventureView extends StatelessWidget {
  const _AdventureView({
    required this.coins,
    required this.completed,
    required this.total,
    required this.onOpenToday,
  });
  final int coins;
  final int completed;
  final int total;
  final VoidCallback onOpenToday;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;
    final dayComplete = total > 0 && completed == total;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      children: [
        const Text(
          'Tu aventura',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
        ),
        const Text(
          'Convierte cada día en una nueva región.',
          style: TextStyle(color: Color(0xFF81786C)),
        ),
        const SizedBox(height: 18),
        _AdventureProgressCard(
          completed: completed,
          total: total,
          coins: coins,
        ),
        const SizedBox(height: 16),
        Container(
          height: 350,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: _assetImageForLogicalWidth(
                context,
                ScenarioAssets.adventureForProgress(progress),
                680,
              ),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: .10),
                BlendMode.darken,
              ),
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 26,
                child: Text(
                  'SENDERO DE LA CONSTANCIA',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              CustomPaint(size: const Size(230, 250), painter: _PathPainter()),
              Positioned(
                bottom: 42,
                left: 55,
                child: _MapNode(
                  icon: Icons.home_rounded,
                  unlocked: true,
                  label: 'Campamento inicial',
                ),
              ),
              Positioned(
                bottom: 120,
                right: 58,
                child: _MapNode(
                  icon: Icons.flag_rounded,
                  unlocked: completed >= 1,
                  label: 'Primera misión',
                ),
              ),
              Positioned(
                top: 70,
                left: 62,
                child: _MapNode(
                  icon: Icons.castle_rounded,
                  unlocked: dayComplete,
                  label: 'Región conquistada',
                ),
              ),
              Positioned(
                right: 12,
                bottom: 10,
                child: Opacity(
                  opacity: dayComplete ? .78 : .58,
                  child: Image.asset(
                    SacaGrapaAssets.forProgress(progress),
                    width: dayComplete ? 96 : 82,
                    height: dayComplete ? 96 : 82,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _InfoCard(
          assetPath: dayComplete
              ? EconomyAssets.legendaryChest
              : EconomyAssets.commonChest,
          color: const Color(0xFF7656D6),
          title: dayComplete
              ? '¡Región conquistada!'
              : total == 0
              ? 'Prepara tu expedición'
              : 'Próxima recompensa',
          subtitle: dayComplete
              ? 'El Bosque del Enfoque ya es tuyo.'
              : total == 0
              ? 'Crea una misión para abrir el primer sendero.'
              : 'Completa ${total - completed} ${total - completed == 1 ? 'misión' : 'misiones'} para abrir el cofre.',
        ),
        if (!dayComplete) ...[
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onOpenToday,
            icon: Icon(total == 0 ? Icons.add_rounded : Icons.flag_rounded),
            label: Text(
              total == 0 ? 'Crear mi primera misión' : 'Continuar misiones',
            ),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ],
    );
  }
}

class _AdventureProgressCard extends StatelessWidget {
  const _AdventureProgressCard({
    required this.completed,
    required this.total,
    required this.coins,
  });

  final int completed;
  final int total;
  final int coins;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;
    final percent = (progress * 100).round();
    final status = total == 0
        ? 'Sin ruta todavía'
        : progress == 1
        ? 'Región completada'
        : progress == 0
        ? 'La expedición comienza aquí'
        : 'Avanzando por el sendero';

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
                  status,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _Pill(assetPath: EconomyAssets.coin, text: '$coins'),
            ],
          ),
          const SizedBox(height: 12),
          Semantics(
            label: '$percent por ciento de la aventura completado',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: const Color(0xFFE8E0D5),
                color: const Color(0xFF7656D6),
              ),
            ),
          ),
          const SizedBox(height: 9),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$completed de $total misiones',
                style: const TextStyle(
                  color: Color(0xFF81786C),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '$percent%',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
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
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(35, 225)
      ..cubicTo(190, 210, 190, 145, 115, 132)
      ..cubicTo(35, 115, 65, 60, 180, 28);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapNode extends StatelessWidget {
  const _MapNode({
    required this.icon,
    required this.unlocked,
    required this.label,
  });
  final IconData icon;
  final bool unlocked;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label, ${unlocked ? 'desbloqueado' : 'bloqueado'}',
      child: Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          color: unlocked ? const Color(0xFFFFFCF6) : const Color(0xFFBBB6AD),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          unlocked ? icon : Icons.lock_rounded,
          color: unlocked ? const Color(0xFF7656D6) : Colors.white,
        ),
      ),
    );
  }
}
