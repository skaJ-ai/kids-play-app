import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/audio/audio_cue.dart';
import '../../../app/services/app_services.dart';
import '../../../app/ui/companion_pair.dart';
import '../../../app/ui/kid_theme.dart';
import '../../../app/ui/mascot_view.dart';
import '../../../app/ui/playground_scaffold.dart';
import '../../../app/ui/toy_button.dart';
import '../../../app/ui/toy_panel.dart';
import '../data/lesson_content_loader.dart';
import '../domain/lesson.dart';
import '../domain/lesson_category.dart';

class GenericLearnScreen extends StatefulWidget {
  const GenericLearnScreen({
    super.key,
    required this.loader,
    required this.category,
    required this.lessonId,
    this.errorMessage,
    this.emptyMessage,
  });

  final LessonContentLoader loader;
  final LessonCategoryConfig category;
  final String lessonId;
  final String? errorMessage;
  final String? emptyMessage;

  @override
  State<GenericLearnScreen> createState() => _GenericLearnScreenState();
}

class _GenericLearnScreenState extends State<GenericLearnScreen> {
  late Future<Lesson> _lessonFuture;
  late AppServices _services;
  bool _didLoadLesson = false;
  int _currentIndex = 0;
  MascotState _mascotState = MascotState.idle;
  bool _pulsing = false;
  Timer? _mascotResetTimer;
  Timer? _pulseResetTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _services = AppServicesScope.of(context);
    if (!_didLoadLesson) {
      _didLoadLesson = true;
      _lessonFuture = _loadLesson();
    }
  }

  @override
  void dispose() {
    _mascotResetTimer?.cancel();
    _pulseResetTimer?.cancel();
    super.dispose();
  }

  Future<Lesson> _loadLesson() async {
    final lesson = await widget.loader.loadLesson(widget.lessonId);
    if (lesson.items.isEmpty) {
      _currentIndex = 0;
      return lesson;
    }

    final snapshot = await _services.progressStore.loadSnapshot();
    final savedIndex = snapshot
        .progressFor(widget.category.progressIdFor(widget.lessonId))
        .lastViewedIndex;
    _currentIndex = savedIndex.clamp(0, lesson.items.length - 1);
    return lesson;
  }

  void _retryLoad() {
    setState(() {
      _currentIndex = 0;
      _lessonFuture = _loadLesson();
    });
  }

  Future<void> _playPromptIfEnabled(PromptCue cue) async {
    final snapshot = await _services.progressStore.loadSnapshot();
    if (!snapshot.voicePromptsEnabled) {
      return;
    }
    await _services.audioService.play(cue);
  }

  PromptCue _promptCueFor(LessonItem item, int itemIndex) {
    final slug = _promptSlugFor(item.symbol, itemIndex);
    return PromptCue(
      AudioCueRef(
        assetPath:
            'assets/generated/audio/voice/prompts/${widget.category.id}/${widget.lessonId}_$slug.mp3',
        fallbackText: item.spoken,
      ),
    );
  }

  String _promptSlugFor(String symbol, int itemIndex) {
    final slug = symbol
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^a-z0-9_-]'), '');
    if (slug.isEmpty) {
      return 'item_${itemIndex + 1}';
    }
    return slug;
  }

  void _onGlyphTap(LessonItem item) {
    _mascotResetTimer?.cancel();
    _pulseResetTimer?.cancel();
    setState(() {
      _mascotState = MascotState.correct;
      _pulsing = true;
    });
    _playPromptIfEnabled(_promptCueFor(item, _currentIndex));

    _pulseResetTimer = Timer(const Duration(milliseconds: 160), () {
      if (!mounted) return;
      setState(() => _pulsing = false);
    });
    _mascotResetTimer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() => _mascotState = MascotState.idle);
    });
  }

  Future<void> _moveToCard(Lesson lesson, int nextIndex) async {
    final boundedIndex = nextIndex.clamp(0, lesson.items.length - 1);
    _mascotResetTimer?.cancel();
    _pulseResetTimer?.cancel();
    setState(() {
      _currentIndex = boundedIndex;
      _mascotState = MascotState.idle;
      _pulsing = false;
    });
    await _services.progressStore.recordLessonIndex(
      lessonId: widget.category.progressIdFor(widget.lessonId),
      lastViewedIndex: boundedIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlaygroundScaffold(
      showRoad: true,
      child: FutureBuilder<Lesson>(
        future: _lessonFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _LearnLoadError(
              message: widget.errorMessage ?? '세트를 불러오지 못했어요.',
              onRetry: _retryLoad,
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final lesson = snapshot.data!;
          if (lesson.items.isEmpty) {
            return Center(
              child: Text(widget.emptyMessage ?? '준비 중인 세트예요.'),
            );
          }

          final item = lesson.items[_currentIndex];
          final isLast = _currentIndex == lesson.items.length - 1;

          return LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 420;
              final mascotSize = compact ? 120.0 : 180.0;
              final glyphFontSize = compact ? 148.0 : 200.0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      _HeaderPill(
                        icon: widget.category.learnHeaderIcon,
                        label: widget.category.learnHeaderLabel,
                        compact: compact,
                      ),
                      const Spacer(),
                      _HeaderPill(
                        label:
                            '${_currentIndex + 1} / ${lesson.items.length}',
                        compact: compact,
                        labelColor: KidPalette.coralDark,
                      ),
                    ],
                  ),
                  SizedBox(height: compact ? 8 : 14),
                  Text(
                    lesson.title,
                    textAlign: TextAlign.center,
                    style: compact
                        ? Theme.of(context).textTheme.titleLarge
                        : Theme.of(context).textTheme.headlineMedium,
                  ),
                  SizedBox(height: compact ? 10 : 20),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 5,
                          child: _GlyphCard(
                            display: item.display,
                            fontSize: glyphFontSize,
                            pulsing: _pulsing,
                            compact: compact,
                            onTap: () => _onGlyphTap(item),
                          ),
                        ),
                        SizedBox(width: compact ? 12 : 20),
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Center(
                                  child: CompanionPair(
                                    key: const Key('learn-companion'),
                                    mascotKey: const Key('learn-mascot'),
                                    avatarKey: const Key('learn-avatar'),
                                    state: _mascotState,
                                    size: mascotSize,
                                    onTap: () => _onGlyphTap(item),
                                  ),
                                ),
                              ),
                              SizedBox(height: compact ? 6 : 10),
                              Text(
                                item.spoken,
                                key: const Key('learn-spoken-caption'),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style:
                                    (compact
                                            ? Theme.of(
                                                context,
                                              ).textTheme.titleLarge
                                            : Theme.of(
                                                context,
                                              ).textTheme.headlineSmall)
                                        ?.copyWith(
                                          color: KidPalette.coralDark,
                                          fontWeight: FontWeight.w900,
                                        ),
                              ),
                              SizedBox(height: compact ? 8 : 14),
                              ToyButton(
                                key: const Key('learn-next-button'),
                                label: isLast ? '처음부터' : '다음',
                                icon: isLast
                                    ? Icons.refresh_rounded
                                    : Icons.arrow_forward_rounded,
                                height: compact ? 50 : 72,
                                onPressed: () => _moveToCard(
                                  lesson,
                                  isLast ? 0 : _currentIndex + 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _GlyphCard extends StatelessWidget {
  const _GlyphCard({
    required this.display,
    required this.fontSize,
    required this.pulsing,
    required this.compact,
    required this.onTap,
  });

  final String display;
  final double fontSize;
  final bool pulsing;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$display 소리 듣기',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const Key('learn-glyph-card'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(compact ? 28 : 36),
          child: AnimatedScale(
            scale: pulsing ? 1.07 : 1.0,
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            child: ToyPanel(
              padding: EdgeInsets.all(compact ? 14 : 28),
              backgroundColor: KidPalette.creamWarm,
              child: Stack(
                children: [
                  Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        display,
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: fontSize,
                              fontWeight: FontWeight.w900,
                              color: KidPalette.navy,
                              height: 1,
                            ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: compact ? 4 : 10,
                    right: compact ? 4 : 10,
                    child: Container(
                      width: compact ? 38 : 52,
                      height: compact ? 38 : 52,
                      decoration: BoxDecoration(
                        color: KidPalette.white.withValues(alpha: 0.92),
                        shape: BoxShape.circle,
                        boxShadow: KidShadows.button,
                      ),
                      child: Icon(
                        Icons.volume_up_rounded,
                        color: KidPalette.coralDark,
                        size: compact ? 22 : 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({
    this.icon,
    required this.label,
    required this.compact,
    this.labelColor,
  });

  final IconData? icon;
  final String label;
  final bool compact;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 16,
        vertical: compact ? 6 : 10,
      ),
      decoration: BoxDecoration(
        color: KidPalette.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(999),
        boxShadow: KidShadows.panel,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: KidPalette.navy,
              size: compact ? 18 : 24,
            ),
            SizedBox(width: compact ? 6 : 8),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: labelColor ?? KidPalette.navy,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }
}

class _LearnLoadError extends StatelessWidget {
  const _LearnLoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 440,
        child: ToyPanel(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: KidPalette.navy),
              ),
              const SizedBox(height: 20),
              ToyButton(
                label: '다시 시도',
                icon: Icons.refresh_rounded,
                onPressed: onRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
