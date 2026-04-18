import 'package:flutter/material.dart';

import '../../../app/services/app_services.dart';
import '../../../app/ui/kid_theme.dart';
import '../../../app/ui/play_feedback_layer.dart';
import '../../../app/ui/play_choice_card.dart';
import '../../../app/ui/play_prompt_panel.dart';
import '../../../app/ui/playground_scaffold.dart';
import '../../../app/ui/toy_button.dart';
import '../../../app/ui/toy_panel.dart';
import '../data/numbers_lesson_repository.dart';
import 'numbers_quiz_session.dart';

class NumbersQuizScreen extends StatefulWidget {
  const NumbersQuizScreen({
    super.key,
    this.repository,
    this.lessonId = 'numbers_count_1',
    this.mistakeSymbols,
  });

  final NumbersLessonRepository? repository;
  final String lessonId;
  final List<String>? mistakeSymbols;

  @override
  State<NumbersQuizScreen> createState() => _NumbersQuizScreenState();
}

class _NumbersQuizScreenState extends State<NumbersQuizScreen> {
  late Future<NumbersLesson> _lessonFuture;
  late AppServices _services;
  NumbersQuizSession? _session;
  bool _feedbackVisible = false;
  bool _feedbackCorrect = false;
  bool _isResolvingChoice = false;
  String? _lastPromptKey;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _services = AppServicesScope.of(context);
  }

  @override
  void initState() {
    super.initState();
    _lessonFuture = _loadLesson();
  }

  @override
  void didUpdateWidget(covariant NumbersQuizScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_sameMistakeReplayFilter(
      oldWidget.mistakeSymbols,
      widget.mistakeSymbols,
    )) {
      return;
    }
    _session = null;
    _feedbackVisible = false;
    _feedbackCorrect = false;
    _isResolvingChoice = false;
    _lastPromptKey = null;
  }

  Future<NumbersLesson> _loadLesson() {
    return (widget.repository ?? NumbersLessonRepository()).loadLesson(
      widget.lessonId,
    );
  }

  void _retryLoad() {
    setState(() {
      _session = null;
      _feedbackVisible = false;
      _feedbackCorrect = false;
      _isResolvingChoice = false;
      _lastPromptKey = null;
      _lessonFuture = _loadLesson();
    });
  }

  Future<void> _speakIfEnabled(String text) async {
    final snapshot = await _services.progressStore.loadSnapshot();
    if (!snapshot.voicePromptsEnabled) {
      return;
    }
    await _services.speechCueService.speak(text, locale: 'ko-KR');
  }

  Future<void> _replayQuestion(NumbersCard question) async {
    await _speakIfEnabled(_targetPromptFor(question));
  }

  void _queuePrompt(NumbersCard question) {
    final session = _session;
    if (session == null) {
      return;
    }
    final promptKey =
        '${widget.lessonId}:${question.symbol}:${session.questionIndex}';
    if (_lastPromptKey == promptKey) {
      return;
    }
    _lastPromptKey = promptKey;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _replayQuestion(question);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PlaygroundScaffold(
      showRoad: true,
      child: FutureBuilder<NumbersLesson>(
        future: _lessonFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _NumbersQuizLoadError(onRetry: _retryLoad);
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final lesson = snapshot.data!;
          if (lesson.cards.length < 4) {
            return const Center(child: Text('퀴즈 카드가 아직 부족해요.'));
          }

          final session = _session ??= NumbersQuizSession.start(
            cards: lesson.cards,
            mistakeSymbols: widget.mistakeSymbols,
          );
          if (session.totalQuestions == 0) {
            return const Center(child: Text('다시 풀 오답이 없어요.'));
          }

          if (session.isComplete) {
            return _QuizSummary(
              totalQuestions: session.totalQuestions,
              correctCount: session.correctCount,
              onRestart: () => setState(() {
                _session = session.restart();
                _feedbackVisible = false;
                _feedbackCorrect = false;
                _isResolvingChoice = false;
                _lastPromptKey = null;
              }),
            );
          }

          final question = session.currentQuestion;
          final choices = session.currentChoices();
          _queuePrompt(question);

          return LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxHeight < 420;
              final isTight = constraints.maxHeight <= 360;
              final sectionGap = isTight ? 10.0 : (isCompact ? 14.0 : 20.0);
              final headerHorizontalPadding = isCompact ? 12.0 : 16.0;
              final headerVerticalPadding = isCompact ? 6.0 : 10.0;
              final headerIconSize = isCompact ? 18.0 : 24.0;

              return PlayFeedbackLayer(
                visible: _feedbackVisible,
                correct: _feedbackCorrect,
                compact: isCompact,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: headerHorizontalPadding,
                            vertical: headerVerticalPadding,
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
                                Icons.videogame_asset_rounded,
                                color: KidPalette.navy,
                                size: headerIconSize,
                              ),
                              SizedBox(width: isCompact ? 6 : 8),
                              Text(
                                '숫자 게임',
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
                            horizontal: headerHorizontalPadding,
                            vertical: headerVerticalPadding,
                          ),
                          decoration: BoxDecoration(
                            color: KidPalette.white.withValues(alpha: 0.94),
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: KidShadows.panel,
                          ),
                          child: Text(
                            '${session.questionIndex + 1} / ${session.totalQuestions}',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: KidPalette.coralDark,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isTight ? 8 : (isCompact ? 12 : 18)),
                    Text(
                      '알맞은 숫자를 찾아보자!',
                      textAlign: TextAlign.center,
                      style:
                          (isTight
                                  ? Theme.of(context).textTheme.titleLarge
                                  : (isCompact
                                        ? Theme.of(
                                            context,
                                          ).textTheme.headlineSmall
                                        : Theme.of(
                                            context,
                                          ).textTheme.headlineMedium))
                              ?.copyWith(color: KidPalette.navy),
                    ),
                    if (!isTight) ...[
                      SizedBox(height: isCompact ? 4 : 8),
                      Text(
                        '차근차근 보고, 맞는 숫자를 콕 눌러봐요.',
                        textAlign: TextAlign.center,
                        style:
                            (isCompact
                                    ? Theme.of(context).textTheme.titleSmall
                                    : Theme.of(context).textTheme.titleMedium)
                                ?.copyWith(color: KidPalette.body),
                      ),
                    ],
                    SizedBox(height: sectionGap),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: PlayPromptPanel(
                              key: const Key('quiz-prompt-panel'),
                              displayName: _displayNameFor(question),
                              prompt: _targetPromptFor(question),
                              symbol: question.symbol,
                              targetLabel: '찾아볼 숫자',
                              onReplay: () => _replayQuestion(question),
                              compact: isCompact,
                              tight: isTight,
                            ),
                          ),
                          SizedBox(width: isTight ? 10 : (isCompact ? 14 : 18)),
                          Expanded(
                            flex: 5,
                            child: LayoutBuilder(
                              builder: (context, gridConstraints) {
                                const crossAxisCount = 2;
                                final mainAxisSpacing = isTight ? 12.0 : 16.0;
                                final crossAxisSpacing = isTight ? 12.0 : 16.0;
                                final rowCount =
                                    (choices.length / crossAxisCount).ceil();
                                final tileWidth =
                                    (gridConstraints.maxWidth -
                                        crossAxisSpacing) /
                                    crossAxisCount;
                                final tileHeight =
                                    (gridConstraints.maxHeight -
                                        (rowCount - 1) * mainAxisSpacing) /
                                    rowCount;
                                final childAspectRatio = tileHeight <= 0
                                    ? 1.0
                                    : tileWidth / tileHeight;

                                return GridView.count(
                                  crossAxisCount: crossAxisCount,
                                  mainAxisSpacing: mainAxisSpacing,
                                  crossAxisSpacing: crossAxisSpacing,
                                  childAspectRatio: childAspectRatio,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: [
                                    for (var i = 0; i < choices.length; i++)
                                      PlayChoiceCard(
                                        key: Key(
                                          'quiz-choice-${choices[i].symbol}',
                                        ),
                                        symbol: choices[i].symbol,
                                        compact: isCompact,
                                        accentIndex: i,
                                        disabled: _isResolvingChoice,
                                        onTap: () =>
                                            _selectChoice(choice: choices[i]),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _selectChoice({required NumbersCard choice}) async {
    if (_isResolvingChoice) {
      return;
    }

    final session = _session;
    if (session == null) {
      return;
    }

    final services = AppServicesScope.of(context);
    final settings = await services.progressStore.loadSnapshot();
    if (!mounted || !identical(_session, session)) {
      return;
    }
    final result = session.answer(choice);
    final nextSession = result.session;

    setState(() {
      _feedbackCorrect = result.isCorrect;
      _feedbackVisible = settings.effectsEnabled;
      _isResolvingChoice = true;
    });

    if (settings.voicePromptsEnabled) {
      await services.speechCueService.speak(
        result.isCorrect ? '딩동댕' : '다시 해보자',
        locale: 'ko-KR',
        rate: 0.46,
        pitch: result.isCorrect ? 1.08 : 0.94,
      );
    }

    await Future<void>.delayed(
      Duration(milliseconds: settings.effectsEnabled ? 650 : 220),
    );

    if (!mounted || !identical(_session, session)) {
      return;
    }

    if (nextSession.isComplete) {
      if (nextSession.earnedSticker) {
        await services.progressStore.addStickers(1);
        if (!mounted || !identical(_session, session)) {
          return;
        }
      }
      await services.progressStore.recordQuizResult(
        lessonId: 'numbers:${widget.lessonId}',
        correctCount: nextSession.correctCount,
        totalQuestions: nextSession.totalQuestions,
        recentMistakes: nextSession.recentMistakes,
      );
      if (!mounted || !identical(_session, session)) {
        return;
      }
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _session = nextSession;
      _feedbackVisible = false;
      _isResolvingChoice = false;
    });
  }

  String _displayNameFor(NumbersCard question) {
    return question.label.split(',').first.trim();
  }

  String _targetPromptFor(NumbersCard question) {
    return "'${question.symbol}' 숫자를 찾아봐!";
  }

  bool _sameMistakeReplayFilter(List<String>? previous, List<String>? next) {
    final previousSet = previous == null ? <String>{} : previous.toSet();
    final nextSet = next == null ? <String>{} : next.toSet();
    return previousSet.length == nextSet.length &&
        previousSet.containsAll(nextSet);
  }
}

class _QuizSummary extends StatelessWidget {
  const _QuizSummary({
    required this.totalQuestions,
    required this.correctCount,
    required this.onRestart,
  });

  final int totalQuestions;
  final int correctCount;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final earnedSticker = correctCount >= (totalQuestions * 0.8).ceil();

    return Center(
      child: SizedBox(
        width: 560,
        child: ToyPanel(
          backgroundColor: KidPalette.creamWarm,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '숫자 게임 끝!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 18),
              Text(
                '$totalQuestions문제 중 $correctCount문제 맞았어요!',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: KidPalette.navy),
              ),
              const SizedBox(height: 14),
              Text(
                earnedSticker ? '자동차 스티커 1개 획득!' : '한 번 더 하면 스티커를 받을 수 있어!',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: KidPalette.coralDark),
              ),
              const SizedBox(height: 22),
              ToyButton(
                label: '다시하기',
                icon: Icons.refresh_rounded,
                onPressed: onRestart,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumbersQuizLoadError extends StatelessWidget {
  const _NumbersQuizLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 520,
        child: ToyPanel(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '숫자 게임을 불러오지 못했어요.',
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
