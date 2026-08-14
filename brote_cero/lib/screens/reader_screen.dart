import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/story.dart';
import '../services/content_repository.dart';
import '../services/progress_store.dart';

class StoryLoaderScreen extends StatefulWidget {
  const StoryLoaderScreen({super.key, required this.storyId});

  final String storyId;

  @override
  State<StoryLoaderScreen> createState() => _StoryLoaderScreenState();
}

class _StoryLoaderScreenState extends State<StoryLoaderScreen> {
  late Future<StoryData> _future;

  @override
  void initState() {
    super.initState();
    _future = ContentRepository.instance.loadStory(widget.storyId);
  }

  void _retry() {
    setState(
        () => _future = ContentRepository.instance.loadStory(widget.storyId));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StoryData>(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<StoryData> snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.warning_amber_rounded, size: 42),
                    const SizedBox(height: 16),
                    const Text(
                      'No se pudo cargar la historia.',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: _retry,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('REINTENTAR'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return ReaderScreen(story: snapshot.data!);
      },
    );
  }
}

class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key, required this.story});

  final StoryData story;

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen>
    with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  Timer? _saveDebounce;
  ReadingPosition? _position;
  int _visiblePageIndex = 0;
  bool _chromeVisible = false;
  bool _restored = false;
  double _lastViewportWidth = 0;
  List<double> _pageHeights = const <double>[];
  List<double> _pageStarts = const <double>[];
  final Set<int> _precachedIndexes = <int>{};

  double get _progress {
    return (_position ?? ReadingPosition.start(widget.story.id))
        .overallProgress(widget.story.pages.length);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_handleScroll);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _restoreProgress();
  }

  Future<void> _restoreProgress() async {
    final saved = await ProgressStore.loadPosition(
      widget.story.id,
      pageIds: widget.story.pages.map((StoryPageData page) => page.id).toList(),
    );
    if (!mounted) return;
    setState(() {
      _position = saved;
      _visiblePageIndex = saved.pageIndex;
    });
    _restoreScrollAfterLayout(saved);
  }

  void _restoreScrollAfterLayout(ReadingPosition saved) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 80), () {
        if (!mounted || !_scrollController.hasClients || _restored) return;
        if (_pageStarts.isEmpty || _pageHeights.isEmpty) {
          _restoreScrollAfterLayout(saved);
          return;
        }
        _restored = true;
        final index = saved.pageIndex.clamp(0, widget.story.pages.length - 1);
        final target = _pageStarts[index] +
            (_pageHeights[index] * saved.offsetWithinPage.clamp(0.0, 1.0));
        final max = _scrollController.position.maxScrollExtent;
        _scrollController.jumpTo(target.clamp(0.0, max).toDouble());
        _precacheWindow(index);
      });
    });
  }

  void _recalculateLayout(double viewportWidth) {
    if (viewportWidth <= 0 || viewportWidth == _lastViewportWidth) return;
    _lastViewportWidth = viewportWidth;

    final heights = <double>[
      for (final page in widget.story.pages) viewportWidth / page.aspectRatio,
    ];
    var total = 0.0;
    final starts = <double>[];
    for (final height in heights) {
      starts.add(total);
      total += height;
    }
    _pageHeights = heights;
    _pageStarts = starts;
  }

  void _handleScroll() {
    if (!_scrollController.hasClients || _pageStarts.isEmpty) return;
    final next = calculateReadingPosition(
      story: widget.story,
      pageStarts: _pageStarts,
      pageHeights: _pageHeights,
      scrollOffset: _scrollController.offset,
    );
    if (next.pageIndex != _visiblePageIndex && mounted) {
      setState(() => _visiblePageIndex = next.pageIndex);
      _precacheWindow(next.pageIndex);
    }
    _position = next;
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 350), _saveProgress);
  }

  void _precacheWindow(int index) {
    if (!mounted) return;
    for (var i = index + 1; i <= index + 2; i += 1) {
      if (i >= widget.story.pages.length || !_precachedIndexes.add(i)) continue;
      unawaited(
          precacheImage(AssetImage(widget.story.pages[i].asset), context));
    }
  }

  Future<void> _saveProgress() {
    final position = _position ??
        ReadingPosition.start(
          widget.story.id,
          firstPageId:
              widget.story.pages.isEmpty ? null : widget.story.pages.first.id,
        );
    return ProgressStore.savePosition(
      position,
      pageCount: widget.story.pages.length,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_saveProgress());
    }
  }

  void _toggleChrome() {
    setState(() => _chromeVisible = !_chromeVisible);
  }

  Future<void> _closeReader() async {
    await _saveProgress();
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _onPopInvoked(bool didPop, Object? result) async {
    if (!didPop) return;
    await _saveProgress();
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _openZoom(StoryPageData page) {
    Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 180),
        reverseTransitionDuration: const Duration(milliseconds: 150),
        pageBuilder: (_, __, ___) => _ZoomPage(page: page),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    unawaited(_saveProgress());
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: _onPopInvoked,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            _recalculateLayout(constraints.maxWidth);
            return Stack(
              children: <Widget>[
                CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: <Widget>[
                    SliverList.builder(
                      itemCount: widget.story.pages.length,
                      itemBuilder: (BuildContext context, int index) {
                        final page = widget.story.pages[index];
                        return _ReaderPage(
                          page: page,
                          onTap: _toggleChrome,
                          onDoubleTap: () => _openZoom(page),
                        );
                      },
                    ),
                    SliverToBoxAdapter(
                      child: _Ending(
                        story: widget.story,
                        onClose: _closeReader,
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 3,
                    backgroundColor: Colors.transparent,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: IgnorePointer(
                    ignoring: !_chromeVisible,
                    child: AnimatedOpacity(
                      opacity: _chromeVisible ? 1 : 0,
                      duration: const Duration(milliseconds: 160),
                      child: SafeArea(
                        bottom: false,
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.76),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Row(
                            children: <Widget>[
                              IconButton(
                                tooltip: 'Salir del lector',
                                onPressed: _closeReader,
                                icon: const Icon(Icons.arrow_back_rounded),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    const Text(
                                      'BROTE CERO',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    Text(
                                      widget.story.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white60,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  '${_visiblePageIndex + 1} / ${widget.story.pages.length}',
                                  style: const TextStyle(
                                    fontFeatures: <FontFeature>[
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

ReadingPosition calculateReadingPosition({
  required StoryData story,
  required List<double> pageStarts,
  required List<double> pageHeights,
  required double scrollOffset,
}) {
  if (story.pages.isEmpty || pageStarts.isEmpty || pageHeights.isEmpty) {
    return ReadingPosition.start(story.id);
  }

  var index = 0;
  for (var i = 0; i < pageStarts.length; i += 1) {
    final start = pageStarts[i];
    final end = start + pageHeights[i];
    if (scrollOffset >= start && scrollOffset < end) {
      index = i;
      break;
    }
    if (scrollOffset >= end) {
      index = i;
    }
  }

  final offset = pageHeights[index] <= 0
      ? 0.0
      : ((scrollOffset - pageStarts[index]) / pageHeights[index])
          .clamp(0.0, 1.0)
          .toDouble();
  final page = story.pages[index];
  return ReadingPosition(
    storyId: story.id,
    pageId: page.id,
    pageIndex: index,
    offsetWithinPage: offset,
  );
}

class _ReaderPage extends StatelessWidget {
  const _ReaderPage({
    required this.page,
    required this.onTap,
    required this.onDoubleTap,
  });

  final StoryPageData page;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      child: AspectRatio(
        aspectRatio: page.aspectRatio,
        child: Image.asset(
          page.asset,
          width: double.infinity,
          fit: BoxFit.fill,
          gaplessPlayback: true,
          filterQuality: FilterQuality.medium,
          frameBuilder: (
            BuildContext context,
            Widget child,
            int? frame,
            bool wasSynchronouslyLoaded,
          ) {
            if (wasSynchronouslyLoaded) return child;
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 180),
              child: child,
            );
          },
        ),
      ),
    );
  }
}

class _Ending extends StatelessWidget {
  const _Ending({required this.story, required this.onClose});

  final StoryData story;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF090A0A),
      padding: const EdgeInsets.fromLTRB(28, 64, 28, 56),
      child: Column(
        children: <Widget>[
          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: const Text(
              '0',
              style: TextStyle(fontSize: 31, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'HISTORIA COMPLETADA',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            story.title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white60),
          ),
          const SizedBox(height: 28),
          OutlinedButton.icon(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded),
            label: const Text('CERRAR'),
          ),
          const SizedBox(height: 28),
          const Text(
            'BROTE CERO',
            style: TextStyle(
              color: Colors.white24,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoomPage extends StatelessWidget {
  const _ZoomPage({required this.page});

  final StoryPageData page;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 5,
              boundaryMargin: const EdgeInsets.all(80),
              child: Center(
                child: AspectRatio(
                  aspectRatio: page.aspectRatio,
                  child: Image.asset(page.asset, fit: BoxFit.contain),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.72),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  tooltip: 'Cerrar zoom',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
