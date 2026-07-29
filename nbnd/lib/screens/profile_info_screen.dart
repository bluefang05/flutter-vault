import 'package:flutter/material.dart';

import '../game/powers/neuro_power_profile.dart';
import '../l10n/app_localizations.dart';
import '../models/neuro_type.dart';
import '../widgets/neuro_profile_icon.dart';

class ProfileInfoScreen extends StatefulWidget {
  const ProfileInfoScreen({super.key, this.initialType});

  final NeuroType? initialType;

  @override
  State<ProfileInfoScreen> createState() => _ProfileInfoScreenState();
}

class _ProfileInfoScreenState extends State<ProfileInfoScreen> {
  late NeuroType _selected = widget.initialType ?? NeuroType.values.first;

  void _showTextSheet(String title, String body) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Flexible(child: SingleChildScrollView(child: Text(body))),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(AppLocalizations.of(context).close),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    final NeuroType type = _selected;
    return Scaffold(
      appBar: AppBar(title: Text(t.learnProfiles)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
        children: <Widget>[
          Text(
            t.profilesIntro,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 88,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: NeuroType.values.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (BuildContext context, int index) {
                final NeuroType item = NeuroType.values[index];
                final bool selected = item == type;
                return Tooltip(
                  message: t.neuroTypeName(item),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(38),
                    onTap: () => setState(() => _selected = item),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: NeuroProfileIcon(
                        neuroType: item,
                        size: selected ? 70 : 62,
                        selected: selected,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _ProfileCard(
              key: ValueKey<NeuroType>(type),
              type: type,
              onSources: () => _showTextSheet(
                t.sources,
                '${t.profileSources(type)}\n\n${t.educationalDisclaimer}',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({super.key, required this.type, required this.onSources});

  final NeuroType type;
  final VoidCallback onSources;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    final NeuroPowerProfile profile = NeuroPowerProfile.forType(type);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                NeuroProfileIcon(neuroType: type, size: 72, selected: true),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        t.neuroTypeName(type),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${t.powerName(type)} · ${type.code}',
                        style: Theme.of(
                          context,
                        ).textTheme.labelLarge?.copyWith(color: type.color),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _PowerSummary(type: type, profile: profile),
            _InfoSection(
              title: t.nbndRepresentation,
              body:
                  '${t.profileNbndRepresentation(type)}\n\n${t.playableMetaphorNote}',
            ),
            _InfoSection(title: t.whatItIs, body: t.profileWhatItIs(type)),
            _InfoSection(
              title: t.howItCanFeel,
              body: '${t.profileHowItCanFeel(type)}\n\n${t.everyPersonDiffers}',
            ),
            _InfoSection(
              title: t.whatItDoesNotMean,
              body: t.profileWhatItDoesNotMean(type),
            ),
            _InfoSection(title: t.communityVoices, body: t.communityVoicesBody),
            Text(
              t.educationalDisclaimer,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: <Widget>[
                OutlinedButton.icon(
                  onPressed: onSources,
                  icon: const Icon(Icons.menu_book_rounded),
                  label: Text(t.sources),
                ),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.sports_esports_rounded),
                  label: Text(t.backToMenu),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PowerSummary extends StatelessWidget {
  const _PowerSummary({required this.type, required this.profile});

  final NeuroType type;
  final NeuroPowerProfile profile;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: type.color.withValues(alpha: .09),
          border: Border.all(color: type.color.withValues(alpha: .34)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.auto_awesome_rounded, color: type.color, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${t.power} · ${t.powerName(type)}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: type.color,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(t.neuroDescription(type)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _PowerStat(
                    icon: Icons.speed_rounded,
                    label: t.speed,
                    value: _levelLabel(
                      context,
                      profile.playerSpeed,
                      lowLimit: 3.05,
                      highLimit: 3.7,
                    ),
                    color: type.color,
                  ),
                  _PowerStat(
                    icon: Icons.restaurant_rounded,
                    label: t.reserve,
                    value: t.spoonsCount(profile.maxSpoonHalves ~/ 2),
                    color: type.color,
                  ),
                  _PowerStat(
                    icon: Icons.timer_rounded,
                    label: t.cooldown,
                    value:
                        '${profile.cooldown.toStringAsFixed(profile.cooldown % 1 == 0 ? 0 : 1)} s',
                    color: type.color,
                  ),
                  _PowerStat(
                    icon: Icons.radar_rounded,
                    label: t.randomness,
                    value: _patternLabel(context, profile.patternRandomness),
                    color: type.color,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _levelLabel(
    BuildContext context,
    double value, {
    required double lowLimit,
    required double highLimit,
  }) {
    final AppLocalizations t = AppLocalizations.of(context);
    if (value < lowLimit) return t.low;
    if (value >= highLimit) return t.high;
    return t.medium;
  }

  String _patternLabel(BuildContext context, double randomness) {
    final AppLocalizations t = AppLocalizations.of(context);
    if (randomness <= .2) return t.low;
    if (randomness >= .6) return t.high;
    return t.medium;
  }
}

class _PowerStat extends StatelessWidget {
  const _PowerStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(icon, color: color, size: 17),
            ),
            const SizedBox(width: 6),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(body),
        ],
      ),
    );
  }
}
