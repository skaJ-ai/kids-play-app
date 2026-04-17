import 'package:flutter/material.dart';

import '../../../app/services/app_services.dart';
import '../../../app/ui/audio_prompt_panel.dart';
import '../../../app/ui/kid_theme.dart';
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
    this.loadingLabelOverride,
  });

  final LessonContentLoader loader;
  final LessonCategoryConfig category;
  final String lessonId;
  final String? errorMessage;
  final String? emptyMessage;

  /// Optional override for the text below the title when rendering a long
  /// card intro. Defaults to [LessonCategoryConfig.learnSubtitle].
  final String? loadingLabelOverride;

  @override
  State<GenericLearnScreen> createState() => _GenericLearnScreenState();
}

class _GenericLearnScreenState extends State<GenericLearnScreen> {
  late Future<Lesson> _lessonFuture;
  late AppServices _services;
  bool _didLoadLesson = false;
  int _currentIndex = 0;
  String? _lastPromptKey;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _services = AppServicesScope.of(context);
    if (!_didLoadLesson) {
      _didLoadLesson = true;
      _lessonFuture = _loadLesson();
    }
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
      _lastPromptKey = null;
      _lessonFuture = _loadLesson();
    });
  }

  Future<void> _replayPrompt(LessonItem item) async {
    await _speakIfEnabled(item.label);
  }

  Future<void> _speakIfEnabled(String text) async {
    final snapshot = await _services.progressStore.loadSnapshot();
    if (!snapshot.voicePromptsEnabled) {
      return;
    }
    await _services.speechCueService.speak(text, locale: 'ko-KR');
  }

  void _queuePrompt(LessonItem item) {
    final promptKey = '${widget.lessonId}:${item.symbol}:$_currentIndex';
    if (_lastPromptKey == promptKey) {
      return;
    }
    _lastPromptKey = promptKey;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _replayPrompt(item);
    });
  }

  Future<void> _moveToCard(Lesson lesson, int nextIndex) async {
    final boundedIndex = nextIndex.clamp(0, lesson.items.length - 1);
    setState(() {
      _currentIndex = boundedIndex;
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
          _queuePrompt(item);

          return LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 420;

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
                  SizedBox(height: compact ? 10 : 18),
                  Text(
                    lesson.title,
                    textAlign: TextAlign.center,
                    style: compact
                        ? Theme.of(context).textTheme.titleLarge
                        : Theme.of(context).textTheme.headlineMedium,
                  ),
                  if (!compact) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.category.learnSubtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                  SizedBox(height: compact ? 10 : 22),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: ToyPanel(
                            padding: EdgeInsets.all(compact ? 12 : 24),
                            backgroundColor: KidPalette.creamWarm,
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  item.symbol,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayLarge
                                      ?.copyWith(
                                        fontSize: compact ? 136 : 180,
                                        fontWeight: FontWeight.w900,
                                        color: KidPalette.navy,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: compact ? 12 : 18),
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AudioPromptPanel(
                                badge: '이름 듣기',
                                title: item.label,
                                subtitle: compact
                                    ? widget.category.learnSubtitleCompact
                                    : '스피커를 누르면 이름을 다시 들을 수 있어요.',
                                onReplay: () => _replayPrompt(item),
                                compact: compact,
                              ),
                              SizedBox(height: compact ? 6 : 14),
                              Expanded(
                                child: ToyPanel(
                                  tone: ToyPanelTone.lilac,
                                  padding: EdgeInsets.all(compact ? 12 : 24),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        compact ? '천천히!' : '천천히 해봐!',
                                        style:
                                            (compact
                                                    ? Theme.of(
                                                        context,
                                                      ).textTheme.titleMedium
                                                    : Theme.of(
                                                        context,
                                                      ).textTheme.titleLarge)
                                                ?.copyWith(
                                                  color: KidPalette.coralDark,
                                                ),
                                      ),
                                      SizedBox(height: compact ? 6 : 12),
                                      Expanded(
                                        child: SingleChildScrollView(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          child: Text(
                                            item.hint,
                                            maxLines: compact ? 3 : 4,
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                (compact
                                                        ? Theme.of(
                                                            context,
                                                          ).textTheme.titleSmall
                                                        : Theme.of(context)
                                                              .textTheme
                                                              .titleMedium)
                                                    ?.copyWith(
                                                      color: KidPalette.navy,
                                                    ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: compact ? 6 : 14),
                              ToyButton(
                                label: isLast ? '처음부터' : '다음',
                                icon: isLast
                                    ? Icons.refresh_rounded
                                    : Icons.arrow_forward_rounded,
                                density: compact
                                    ? ToyButtonDensity.compact
                                    : ToyButtonDensity.regular,
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
