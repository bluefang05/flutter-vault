import 'package:flutter/material.dart';
import '../state/settings_provider.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/section_header.dart';
import '../widgets/illustrations/conove_logo_painter.dart';
import '../core/constants/app_colors.dart';
import '../core/services/feedback_service.dart';
import '../core/services/storage_service.dart';

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
    return ListenableBuilder(
      listenable: _settings,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Ajustes y Accesibilidad'),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              // Visual Theme Section
              const SectionHeader(
                title: 'Tema Visual',
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

              // About ConoVe
              Center(
                child: Column(
                  children: [
                    const ConoVeLogoWidget(size: 40),
                    const SizedBox(height: 8),
                    const Text(
                      'ConoVe v1.0.0',
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
        );
      },
    );
  }
}
