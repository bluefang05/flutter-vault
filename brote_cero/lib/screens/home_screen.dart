import 'package:flutter/material.dart';

import '../models/story.dart';
import '../services/content_repository.dart';
import '../services/progress_store.dart';
import 'reader_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<StorySummary>? _stories;
  UpdateManifest? _update;
  final Map<String, double> _progress = <String, double>{};
  final Map<String, bool> _completed = <String, bool>{};
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final catalog = await ContentRepository.instance.loadCatalog();
      final update = await ContentRepository.instance.loadUpdateManifest();

      final positions = await Future.wait(
        catalog.stories.map(
          (StorySummary story) => ProgressStore.loadPosition(
            story.id,
            pageIds: <String>[
              for (var i = 1; i <= story.pageCount; i += 1)
                '${story.id}-${i.toString().padLeft(3, '0')}',
            ],
          ),
        ),
      );
      final completedValues = await Future.wait(
        catalog.stories
            .map((StorySummary story) => ProgressStore.isCompleted(story.id)),
      );

      if (!mounted) return;
      setState(() {
        _stories = catalog.stories;
        _update = update;
        _error = null;
        _progress.clear();
        _completed.clear();
        for (var i = 0; i < catalog.stories.length; i++) {
          _progress[catalog.stories[i].id] =
              positions[i].overallProgress(catalog.stories[i].pageCount);
          _completed[catalog.stories[i].id] = completedValues[i];
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error);
    }
  }

  Future<void> _openReader(StorySummary story) async {
    if (_completed[story.id] ?? false) {
      await ProgressStore.reset(story.id);
    }
    if (!mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => StoryLoaderScreen(storyId: story.id),
      ),
    );
    await _load();
  }

  Future<void> _resetProgress(StorySummary story) async {
    await ProgressStore.reset(story.id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final stories = _stories;
    if (stories == null) {
      if (_error != null) {
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.warning_amber_rounded, size: 42),
                  const SizedBox(height: 16),
                  const Text(
                    'No se pudo cargar el catalogo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _load,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('REINTENTAR'),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 36),
              sliver: SliverList.list(
                children: <Widget>[
                  const _BrandHeader(),
                  const SizedBox(height: 24),
                  Row(
                    children: <Widget>[
                      const Expanded(
                        child: Text(
                          'ARCHIVOS RECUPERADOS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.6,
                            color: Colors.white60,
                          ),
                        ),
                      ),
                      Text(
                        '${stories.length}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  for (final story in stories) ...<Widget>[
                    _StoryEntry(
                      story: story,
                      progress: _progress[story.id] ?? 0,
                      completed: _completed[story.id] ?? false,
                      onOpen: () => _openReader(story),
                      onReset: () => _resetProgress(story),
                    ),
                    const SizedBox(height: 22),
                  ],
                  if (_update?.available ?? false)
                    _UpdateCard(
                      manifest: _update!,
                      onTap: () => _showUpdateDialog(_update!),
                    ),
                  const SizedBox(height: 26),
                  Text(
                    'Contenido 1.1  ·  Lector 1.1',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.42),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showUpdateDialog(UpdateManifest manifest) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(manifest.headline),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Contenido ${manifest.latestContentVersion}'),
              const SizedBox(height: 12),
              Text(manifest.body),
              const SizedBox(height: 16),
              ...manifest.items.map(
                (String item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('• $item'),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ENTENDIDO'),
            ),
          ],
        );
      },
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24),
          ),
          alignment: Alignment.center,
          child: const Text(
            '0',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'BROTE CERO',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.2,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Historias de un mundo infectado.',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StoryEntry extends StatelessWidget {
  const _StoryEntry({
    required this.story,
    required this.progress,
    required this.completed,
    required this.onOpen,
    required this.onReset,
  });

  final StorySummary story;
  final double progress;
  final bool completed;
  final VoidCallback onOpen;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();
    final primaryLabel = completed
        ? 'LEER DE NUEVO'
        : progress > 0.01
            ? 'CONTINUAR · $percent%'
            : 'LEER';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _StoryCard(story: story),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: onOpen,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            primaryLabel,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ),
        if (progress > 0.01) ...<Widget>[
          const SizedBox(height: 9),
          Row(
            children: <Widget>[
              Expanded(
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 3,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: onReset,
                child: const Text('Reiniciar'),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.story});

  final StorySummary story;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white10),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.asset(
                    story.cover,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Colors.transparent,
                          Color(0xE5090A0A),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    story.archiveLabel.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.6,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    story.title,
                    style: const TextStyle(
                      fontSize: 25,
                      height: 1.05,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${story.estimatedMinutes} min  ·  Horror  ·  Supervivencia',
                    style: const TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpdateCard extends StatelessWidget {
  const _UpdateCard({required this.manifest, required this.onTap});

  final UpdateManifest manifest;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.55),
          ),
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        ),
        child: Row(
          children: <Widget>[
            const Icon(Icons.system_update_alt_rounded),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    manifest.headline.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Contenido ${manifest.latestContentVersion}',
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}
