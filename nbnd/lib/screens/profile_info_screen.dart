import 'package:flutter/material.dart';

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
                Text(body),
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
              onSeekHelp: () => _showTextSheet(t.seekHelp, t.seekHelpBody),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    super.key,
    required this.type,
    required this.onSources,
    required this.onSeekHelp,
  });

  final NeuroType type;
  final VoidCallback onSources;
  final VoidCallback onSeekHelp;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
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
            _InfoSection(title: t.whatItIs, body: t.profileWhatItIs(type)),
            _InfoSection(
              title: t.howItCanFeel,
              body: '${t.profileHowItCanFeel(type)}\n\n${t.everyPersonDiffers}',
            ),
            _InfoSection(
              title: t.whatItDoesNotMean,
              body: t.profileWhatItDoesNotMean(type),
            ),
            _InfoSection(
              title: t.nbndRepresentation,
              body:
                  '${t.playableMetaphorNote}\n\n${t.profileNbndRepresentation(type)}',
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
                OutlinedButton.icon(
                  onPressed: onSeekHelp,
                  icon: const Icon(Icons.volunteer_activism_rounded),
                  label: Text(t.seekHelp),
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
