import 'package:flutter/material.dart';

import '../../../app/audio/audio_cue.dart';
import '../../../app/services/app_services.dart';
import '../../../app/ui/kid_theme.dart';
import '../../../app/ui/play_feedback_layer.dart';
import '../../../app/ui/play_choice_card.dart';
import '../../../app/ui/play_prompt_panel.dart';
import '../../../app/ui/playground_scaffold.dart';
import '../../../app/ui/toy_button.dart';
import '../../../app/ui/toy_panel.dart';
import '../data/hangul_lesson_repository.dart';

class HangulQuizScreen extends StatefulWidget {
  const HangulQuizScreen({
    super.key,
    this.repository,
    this.lessonId = 'basic_consonants_1',
    this.mistakeSymbols,
  });

  final HangulLessonRepository? repository;
  final String lessonId;
  final List<String>? mistakeSymbols;

  @override
  State<HangulQuizScreen> createState() => _HangulQuizScreenState();
}

class _HangulQuizScreenState extends State<HangulQuizScreen> {
  late Future<HangulLesson> _lessonFuture;
  late AppServices _services;
  int _questionIndex = 0;
  int _correctCount = 0;
  bool _isComplete = false;
  bool _feedbackVisible = false;
  bool _feedbackCorrect = false;
  bool _isResolvingChoice = false;
  List<String> _recentMistakes = const [];
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

  Future<HangulLesson> _loadLesson() {
    return (widget.repository ?? HangulLessonRepository()).loadLesson(
      widget.lessonId,
    );
  }

  void _retryLoad() {
    setState(() {
      _questionIndex = 0;
      _correctCount = 0;
      _isComplete = false;
      _feedbackVisible = false;
      _feedbackCorrect = false;
      _isResolvingChoice = false;
      _recentMistakes = const [];
      _lastPromptKey = null;
      _lessonFuture = _loadLesson();
    });
  }

  Future<void> _speakIfEnabled(HangulCard question, String text) async {
    final snapshot = await _services.progressStore.loadSnapshot();
    if (!snapshot.voicePromptsEnabled) {
      return;
    }
    await _services.audioService.playPrompt(
      AudioPromptRequest(
        categoryId: 'hangul',
        lessonId: widget.lessonId,
        symbol: question.symbol,
        fallbackText: text,
      ),
    );
  }

  Future<void> _replayQuestion(HangulCard question) async {
    await _speakIfEnabled(question, _targetPromptFor(question));
  }

  void _queuePrompt(HangulCard question) {
    final promptKey = '${widget.lessonId}:${question.symbol}:$_questionIndex';
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
      child: FutureBuilder<HangulLesson>(
        future: _lessonFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _HangulQuizLoadError(onRetry: _retryLoad);
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final lesson = snapshot.data!;
          if (lesson.cards.length < 4) {
            return const Center(child: Text('퀴즈 카드가 아직 부족해요.'));
          }

          final quizCards = _resolvedQuizCards(lesson.cards);
          if (quizCards.isEmpty) {
            return const Center(child: Text('다시 풀 오답이 없어요.'));
          }

          if (_isComplete) {
            return _QuizSummary(
              totalQuestions: quizCards.length,
              correctCount: _correctCount,
              onRestart: () => setState(() {
                _questionIndex = 0;
                _correctCount = 0;
                _isComplete = false;
                _feedbackVisible = false;
                _feedbackCorrect = false;
                _isResolvingChoice = false;
                _recentMistakes = const [];
                _lastPromptKey = null;
              }),
            );
          }

          final question = quizCards[_questionIndex];
          final choices = _buildChoices(lesson.cards, question, _questionIndex);
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
                                '한글 게임',
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
                            '${_questionIndex + 1} / ${quizCards.length}',
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
                      '알맞은 글자를 찾아보자!',
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
                        '차근차근 보고, 정답을 콕 눌러봐요.',
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
                              targetLabel: '찾아볼 글자',
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
                                        onTap: () => _selectChoice(
                                          choice: choices[i],
                                          answer: question,
                                          totalQuestions: quizCards.length,
                                        ),
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

  Future<void> _selectChoice({
    required HangulCard choice,
    required HangulCard answer,
    required int totalQuestions,
  }) async {
    if (_isResolvingChoice) {
      return;
    }

    final services = AppServicesScope.of(context);
    final settings = await services.progressStore.loadSnapshot();
    final isCorrect = choice.symbol == answer.symbol;
    final nextCorrectCount = isCorrect ? _correctCount + 1 : _correctCount;
    final nextMistakes = isCorrect
        ? _recentMistakes
        : <String>[..._recentMistakes, answer.symbol];

    setState(() {
      _correctCount = nextCorrectCount;
      _recentMistakes = nextMistakes;
      _feedbackCorrect = isCorrect;
      _feedbackVisible = settings.effectsEnabled;
      _isResolvingChoice = true;
    });

    if (settings.effectsEnabled) {
      await services.audioService.playCue(
        AudioCue(
          type: isCorrect ? AudioCueType.success : AudioCueType.error,
          assetKey: isCorrect
              ? 'audio/sfx/success.ogg'
              : 'audio/sfx/error.ogg',
          fallbackText: isCorrect ? '딩동댕' : '다시 해보자',
          pitch: isCorrect ? 1.08 : 0.94,
        ),
      );
    }

    await Future<void>.delayed(
      Duration(milliseconds: settings.effectsEnabled ? 650 : 220),
    );

    final isLastQuestion = _questionIndex == totalQuestions - 1;
    if (isLastQuestion) {
      final lessonProgressKey = 'hangul:${widget.lessonId}';
      final earnedSticker = nextCorrectCount >= (totalQuestions * 0.8).ceil();
      final rewardEarnedAt = earnedSticker ? DateTime.now() : null;
      await services.progressStore.recordCompletedQuiz(
        lessonId: lessonProgressKey,
        correctCount: nextCorrectCount,
        totalQuestions: totalQuestions,
        recentMistakes: nextMistakes,
        stickersEarned: earnedSticker ? 1 : 0,
        rewardEarnedAt: rewardEarnedAt,
      );
      if (!mounted) {
        return;
      }
      if (settings.effectsEnabled && earnedSticker) {
        try {
          await services.audioService.playCue(
            const AudioCue(
              type: AudioCueType.reward,
              assetKey: 'audio/sfx/reward.ogg',
              fallbackText: '스티커 하나 획득!',
              pitch: 1.12,
            ),
          );
        } catch (_) {}
        if (!mounted) {
          return;
        }
      }
      setState(() {
        _feedbackVisible = false;
        _isResolvingChoice = false;
        _isComplete = true;
      });
      return;
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _questionIndex += 1;
      _feedbackVisible = false;
      _isResolvingChoice = false;
    });
  }

  List<HangulCard> _buildChoices(
    List<HangulCard> cards,
    HangulCard answer,
    int questionIndex,
  ) {
    final distractors = cards
        .where((card) => card.symbol != answer.symbol)
        .toList();
    final startIndex = distractors.isEmpty
        ? 0
        : questionIndex % distractors.length;
    final rotatedDistractors = [
      ...distractors.skip(startIndex),
      ...distractors.take(startIndex),
    ];
    final choices = rotatedDistractors.take(3).toList(growable: true);
    choices.insert(questionIndex % 4, answer);
    return choices;
  }

  List<HangulCard> _resolvedQuizCards(List<HangulCard> cards) {
    final symbols = widget.mistakeSymbols;
    if (symbols == null || symbols.isEmpty) {
      return cards;
    }

    return cards
        .where((card) => symbols.contains(card.symbol))
        .toList(growable: false);
  }

  String _displayNameFor(HangulCard question) {
    return question.label.split(',').first.trim();
  }

  String _targetPromptFor(HangulCard question) {
    return "'${question.symbol}' 글자를 찾아봐!";
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
                '한글 게임 끝!',
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

class _HangulQuizLoadError extends StatelessWidget {
  const _HangulQuizLoadError({required this.onRetry});

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
                '한글 게임을 불러오지 못했어요.',
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
