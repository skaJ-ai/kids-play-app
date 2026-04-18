import 'package:flutter/material.dart';

import '../../../app/services/app_services.dart';
import '../../../app/ui/audio_prompt_panel.dart';
import '../../../app/ui/kid_theme.dart';
import '../../../app/ui/playground_scaffold.dart';
import '../../../app/ui/toy_button.dart';
import '../../../app/ui/toy_panel.dart';
import '../data/numbers_lesson_repository.dart';

class NumbersLearnScreen extends StatefulWidget {
  const NumbersLearnScreen({
    super.key,
    this.repository,
    this.lessonId = 'numbers_count_1',
  });

  final NumbersLessonRepository? repository;
  final String lessonId;

  @override
  State<NumbersLearnScreen> createState() => _NumbersLearnScreenState();
}

class _NumbersLearnScreenState extends State<NumbersLearnScreen> {
  late Future<NumbersLesson> _lessonFuture;
  late AppServices _services;
  bool _didLoadLesson = false;
  int _currentCardIndex = 0;
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

  Future<NumbersLesson> _loadLesson() async {
    final lesson = await (widget.repository ?? NumbersLessonRepository())
        .loadLesson(widget.lessonId);
    if (lesson.cards.isEmpty) {
      _currentCardIndex = 0;
      return lesson;
    }

    final snapshot = await _services.progressStore.loadSnapshot();
    final savedIndex = snapshot
        .progressFor('numbers:${widget.lessonId}')
        .lastViewedIndex;
    _currentCardIndex = savedIndex.clamp(0, lesson.cards.length - 1);
    return lesson;
  }

  void _retryLoad() {
    setState(() {
      _currentCardIndex = 0;
      _lastPromptKey = null;
      _lessonFuture = _loadLesson();
    });
  }

  Future<void> _replayPrompt(NumbersCard card) async {
    await _speakIfEnabled(card.label);
  }

  Future<void> _speakIfEnabled(String text) async {
    final snapshot = await _services.progressStore.loadSnapshot();
    if (!snapshot.voicePromptsEnabled) {
      return;
    }
    await _services.speechCueService.speak(text, locale: 'ko-KR');
  }

  void _queuePrompt(NumbersCard card) {
    final promptKey = '${widget.lessonId}:${card.symbol}:$_currentCardIndex';
    if (_lastPromptKey == promptKey) {
      return;
    }
    _lastPromptKey = promptKey;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _replayPrompt(card);
    });
  }

  Future<void> _moveToCard(NumbersLesson lesson, int nextIndex) async {
    final boundedIndex = nextIndex.clamp(0, lesson.cards.length - 1);
    setState(() {
      _currentCardIndex = boundedIndex;
    });
    await _services.progressStore.recordLessonIndex(
      lessonId: 'numbers:${widget.lessonId}',
      lastViewedIndex: boundedIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlaygroundScaffold(
      showRoad: true,
      child: FutureBuilder<NumbersLesson>(
        future: _lessonFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _NumbersLoadError(
              message: '숫자 카드를 불러오지 못했어요.',
              onRetry: _retryLoad,
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final lesson = snapshot.data!;
          if (lesson.cards.isEmpty) {
            return const Center(child: Text('준비 중인 숫자 카드예요.'));
          }

          final card = lesson.cards[_currentCardIndex];
          final isLastCard = _currentCardIndex == lesson.cards.length - 1;
          _queuePrompt(card);

          return LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 420;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
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
                            Icon(
                              Icons.school_rounded,
                              color: KidPalette.navy,
                              size: compact ? 18 : 24,
                            ),
                            SizedBox(width: compact ? 6 : 8),
                            Text(
                              '숫자 학습',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    color: KidPalette.navy,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: compact ? 12 : 16,
                          vertical: compact ? 6 : 10,
                        ),
                        decoration: BoxDecoration(
                          color: KidPalette.white.withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: KidShadows.panel,
                        ),
                        child: Text(
                          '${_currentCardIndex + 1} / ${lesson.cards.length}',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: KidPalette.coralDark,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
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
                      '큰 숫자를 보고, 숫자 이름을 따라 말해봐요.',
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
                            key: const ValueKey('numbersLearnSymbolPanel'),
                            padding: EdgeInsets.all(compact ? 12 : 24),
                            tone: ToyPanelTone.warm,
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  card.symbol,
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
                                badge: '숫자 듣기',
                                title: card.label,
                                subtitle: compact
                                    ? '스피커를 눌러 다시 들어봐요.'
                                    : '스피커를 누르면 숫자 이름을 다시 들을 수 있어요.',
                                onReplay: () => _replayPrompt(card),
                                compact: compact,
                              ),
                              SizedBox(height: compact ? 6 : 14),
                              Expanded(
                                child: ToyPanel(
                                  key: const ValueKey(
                                    'numbersLearnEncouragementPanel',
                                  ),
                                  padding: EdgeInsets.all(compact ? 12 : 24),
                                  tone: ToyPanelTone.lilac,
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
                                            card.hint,
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
                                label: isLastCard ? '처음부터' : '다음',
                                icon: isLastCard
                                    ? Icons.refresh_rounded
                                    : Icons.arrow_forward_rounded,
                                height: compact ? 50 : 72,
                                onPressed: () => _moveToCard(
                                  lesson,
                                  isLastCard ? 0 : _currentCardIndex + 1,
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

class _NumbersLoadError extends StatelessWidget {
  const _NumbersLoadError({required this.message, required this.onRetry});

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
