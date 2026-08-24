import 'package:flutter/material.dart';
import '../state/settings_provider.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/section_header.dart';
import '../widgets/illustrations/conove_logo_painter.dart';
import '../core/constants/app_colors.dart';
import '../core/services/feedback_service.dart';
import '../core/services/storage_service.dart';
import '../core/services/tts_service.dart';
import '../core/localization/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SettingsProvider _settings;

  @override
  void initState() {
    super.initState();
    _settings = SettingsProvider();
  }

  void _confirmResetProgress() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Reiniciar Progreso?'),
        content: const Text('Se borrarán tus puntos, racha, marcas de señales exploradas y marcadores.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              await StorageService.clearAll();
              if (ctx.mounted) {
                Navigator.pop(ctx);
              }
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Progreso reiniciado')),
              );
            },
            child: const Text('Reiniciar Todo'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: _settings,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text('${loc.settings} & Accesibilidad'),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
              // Visual Theme Section
              SectionHeader(
                title: loc.appearance,
                subtitle: 'Elige la apariencia que te resulte más cómoda',
              ),
              AppCard(
                padding: const EdgeInsets.all(12),
                child: Center(
                  child: SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text('Claro'),
                        icon: Icon(Icons.light_mode_rounded, size: 18),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text('Oscuro'),
                        icon: Icon(Icons.dark_mode_rounded, size: 18),
                      ),
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text('Auto'),
                        icon: Icon(Icons.brightness_auto_rounded, size: 18),
                      ),
                    ],
                    selected: {_settings.themeMode},
                    onSelectionChanged: (newSelection) {
                      FeedbackService.lightClick();
                      _settings.setThemeMode(newSelection.first);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Language Selector Section
              const SectionHeader(
                title: 'Idioma / Language',
                subtitle: 'Adopta el idioma del sistema o elige manualmente',
              ),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: _settings.languageCode,
                    isExpanded: true,
                    icon: const Icon(Icons.language_rounded, color: AppColors.primary),
                    items: const [
                      DropdownMenuItem(
                        value: null,
                        child: Row(
                          children: [
                            Text('🌐', style: TextStyle(fontSize: 18)),
                            SizedBox(width: 10),
                            Text('Automático (Idioma del Sistema)', style: TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'es',
                        child: Row(
                          children: [
                            Text('🇪🇸', style: TextStyle(fontSize: 18)),
                            SizedBox(width: 10),
                            Text('Español (Predeterminado)', style: TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'en',
                        child: Row(
                          children: [
                            Text('🇺🇸', style: TextStyle(fontSize: 18)),
                            SizedBox(width: 10),
                            Text('English', style: TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'fr',
                        child: Row(
                          children: [
                            Text('🇫🇷', style: TextStyle(fontSize: 18)),
                            SizedBox(width: 10),
                            Text('Français', style: TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'pt',
                        child: Row(
                          children: [
                            Text('🇧🇷', style: TextStyle(fontSize: 18)),
                            SizedBox(width: 10),
                            Text('Português', style: TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'de',
                        child: Row(
                          children: [
                            Text('🇩🇪', style: TextStyle(fontSize: 18)),
                            SizedBox(width: 10),
                            Text('Deutsch', style: TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (newLang) {
                      FeedbackService.lightClick();
                      _settings.setLanguageCode(newLang);
                      TtsService.updateLanguage(newLang ?? 'es');
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Accessibility / Sensory friendly
              const SectionHeader(
                title: 'Accesibilidad y Sensorialidad',
                subtitle: 'Ajustes diseñados para evitar sobrecarga sensorial',
              ),
              AppCard(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Modo Alto Contraste'),
                      subtitle: const Text('Bordes reforzados y texto de máxima legibilidad'),
                      value: _settings.isHighContrast,
                      onChanged: (val) {
                        FeedbackService.lightClick();
                        _settings.setHighContrast(val);
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Reducción de Movimiento'),
                      subtitle: const Text('Desactiva animaciones para evitar sobrecarga visual'),
                      value: _settings.isReduceMotion,
                      onChanged: (val) {
                        FeedbackService.lightClick();
                        _settings.setReduceMotion(val);
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Filtro Cálido (Descanso Ocular)'),
                      subtitle: const Text('Tinte sepia suave para reducir fatiga'),
                      value: _settings.isWarmFilter,
                      onChanged: (val) {
                        FeedbackService.lightClick();
                        _settings.setWarmFilter(val);
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Respuesta Háptica (Vibración)'),
                      subtitle: const Text('Vibración ligera al interactuar y confirmar'),
                      value: _settings.isHapticsEnabled,
                      onChanged: (val) {
                        FeedbackService.lightClick();
                        _settings.setHapticsEnabled(val);
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Efectos de Sonido (Audio UI)'),
                      subtitle: const Text('Sonidos suaves de acierto, error y confirmación'),
                      value: _settings.isSoundEffectsEnabled,
                      onChanged: (val) {
                        _settings.setSoundEffectsEnabled(val);
                        if (val) {
                          FeedbackService.neutral();
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // TTS Voice & Auto-Narration Section
              const SectionHeader(
                title: 'Lectura por Voz & Asistencia (TTS)',
                subtitle: 'Haz que la lectura sea 100% opcional escuchando el contenido',
              ),
              AppCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Modo Auto-Narración', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Lee automáticamente en voz alta preguntas, escenarios, tarjetas y explicaciones al entrar'),
                      value: _settings.isAutoNarration,
                      onChanged: (val) {
                        FeedbackService.lightClick();
                        _settings.setAutoNarration(val);
                        if (val) {
                          TtsService.speak('Modo de auto-narración activado. Ahora Gestura te leerá todo el contenido automáticamente.');
                        } else {
                          TtsService.stop();
                        }
                      },
                    ),
                    const Divider(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Velocidad de Lectura TTS:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                              Text(
                                '${(_settings.speechRate * 200).round()}%',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ],
                          ),
                          Slider(
                            value: _settings.speechRate,
                            min: 0.35,
                            max: 0.65,
                            divisions: 6,
                            label: '${(_settings.speechRate * 200).round()}%',
                            onChanged: (val) {
                              _settings.setSpeechRate(val);
                              TtsService.setSpeechRate(val);
                            },
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () {
                                FeedbackService.lightClick();
                                TtsService.speak('Esta es una prueba de velocidad de voz en Gestura.');
                              },
                              icon: const Icon(Icons.volume_up_rounded, size: 18),
                              label: const Text('Probar Voz'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Font Scaling
              const SectionHeader(
                title: 'Tamaño del Texto',
                subtitle: 'Aumenta el tamaño para leer con total comodidad',
              ),
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Escala:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('${(_settings.fontScale * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ],
                    ),
                    Slider(
                      value: _settings.fontScale,
                      min: 0.85,
                      max: 1.35,
                      divisions: 5,
                      label: '${(_settings.fontScale * 100).round()}%',
                      onChanged: (val) {
                        _settings.setFontScale(val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Reset Data
              const SectionHeader(
                title: 'Datos de la Aplicación',
              ),
              AppCard(
                padding: const EdgeInsets.all(8),
                child: ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                  title: const Text('Reiniciar Todo el Progreso', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
                  subtitle: const Text('Elimina historial de respuestas y marcas'),
                  onTap: _confirmResetProgress,
                ),
              ),
              const SizedBox(height: 24),

              // About Gestura
              Center(
                child: Column(
                  children: [
                    const GesturaLogoWidget(size: 40),
                    const SizedBox(height: 8),
                    const Text(
                      'Gestura v1.0.0',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Diseñado para comprender la comunicación no verbal\n100% Autónomo y sin conexión requerida.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  },
);
}
}
