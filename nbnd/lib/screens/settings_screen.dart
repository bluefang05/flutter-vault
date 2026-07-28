import 'package:flutter/material.dart';

import '../models/game_settings.dart';
import '../l10n/app_localizations.dart';
import '../services/app_storage.dart';
import 'profile_info_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.settings});

  final GameSettings settings;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AppStorage _storage = AppStorage.instance;
  late GameSettings _settings = widget.settings;

  Future<void> _save() async {
    await _storage.setMany(<String, Object?>{
      'haptics': _settings.haptics,
      'reduced_flashes': _settings.reducedFlashes,
      'practice_mode': _settings.practiceMode,
      'show_ad_placeholder': _settings.showAdPlaceholder,
    });
    if (mounted) Navigator.of(context).pop(_settings);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.settings)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          SwitchListTile.adaptive(
            value: _settings.haptics,
            onChanged: (bool value) {
              setState(() => _settings = _settings.copyWith(haptics: value));
            },
            title: Text(t.vibration),
            subtitle: Text(t.hapticsDescription),
          ),
          SwitchListTile.adaptive(
            value: _settings.reducedFlashes,
            onChanged: (bool value) {
              setState(
                () => _settings = _settings.copyWith(reducedFlashes: value),
              );
            },
            title: Text(t.reducedFlashes),
            subtitle: Text(t.reducedFlashesDescription),
          ),
          SwitchListTile.adaptive(
            value: _settings.practiceMode,
            onChanged: (bool value) {
              setState(
                () => _settings = _settings.copyWith(practiceMode: value),
              );
            },
            title: Text(t.practiceMode),
            subtitle: Text(t.practiceModeDescription),
          ),
          SwitchListTile.adaptive(
            value: _settings.showAdPlaceholder,
            onChanged: (bool value) {
              setState(
                () => _settings = _settings.copyWith(showAdPlaceholder: value),
              );
            },
            title: Text(t.showAdSpace),
            subtitle: Text(t.adSpaceDescription),
          ),
          const SizedBox(height: 12),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(t.aboutTitle),
            childrenPadding: const EdgeInsets.only(bottom: 12),
            children: <Widget>[
              Align(alignment: Alignment.centerLeft, child: Text(t.aboutBody)),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  t.aboutThanks,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) =>
                            const ProfileInfoScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.info_outline_rounded),
                  label: Text(t.learnProfiles),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: _save, child: Text(t.save)),
        ],
      ),
    );
  }
}
