import 'package:flutter/material.dart';

import '../../../app/services/app_services.dart';
import '../../../app/ui/answer_feedback_overlay.dart';
import '../../../app/ui/audio_prompt_panel.dart';
import '../../../app/ui/kid_theme.dart';
import '../../../app/ui/playground_scaffold.dart';
import '../../../app/ui/tap_cooldown.dart';
import '../../../app/ui/toy_button.dart';
import '../../../app/ui/toy_panel.dart';
import '../data/alphabet_lesson_repository.dart';

class AlphabetQuizScreen extends StatefulWidget {
  const AlphabetQuizScreen({
    super.key,
    this.repository,
    this.lessonId = 'alphabet_letters_1',
  });

  final AlphabetLessonRepository? repository;
  final String lessonId;

  @override
  State<AlphabetQuizScreen> createState() => _AlphabetQuizScreenState();
}

class _AlphabetQuizScreenState extends State<AlphabetQuizScreen> {
  late Future<AlphabetLesson> _lessonFuture;
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

  Future<AlphabetLesson> _loadLesson() {
    return (widget.repository ?? AlphabetLessonRepository()).loadLesson(
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

  Future<void> _speakIfEnabled(String text) async {
    final snapshot = await _services.progressStore.loadSnapshot();
    if (!snapshot.voicePromptsEnabled) {
      return;
    }
    await _services.speechCueService.speak(text, locale: 'ko-KR');
  }

  Future<void> _replayQuestion(AlphabetCard question) async {
    await _speakIfEnabled(_targetPromptFor(question));
  }

  void _queuePrompt(AlphabetCard question) {
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
      child: FutureBuilder<AlphabetLesson>(
        future: _lessonFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _AlphabetQuizLoadError(onRetry: _retryLoad);
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final lesson = snapshot.data!;
          if (lesson.cards.length < 4) {
            return const Center(child: Text('퀴즈 카드가 아직 부족해요.'));
          }

          if (_isComplete) {
            return _QuizSummary(
              totalQuestions: lesson.cards.length,
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

          final question = lesson.cards[_questionIndex];
          final choices = _buildChoices(lesson.cards, _questionIndex);
          _queuePrompt(question);

          return LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxHeight < 420;
              final isTight = constraints.maxHeight <= 360;
              final sectionGap = isTight ? 10.0 : (isCompact ? 14.0 : 20.0);
              final headerHorizontalPadding = isCompact ? 12.0 : 16.0;
              final headerVerticalPadding = isCompact ? 6.0 : 10.0;
              final headerIconSize = isCompact ? 18.0 : 24.0;

              return Stack(
                children: [
                  Column(
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
                                  '알파벳 게임',
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
                              '${_questionIndex + 1} / ${lesson.cards.length}',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: KidPalette.coralDark,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isTight ? 8 : (isCompact ? 12 : 18)),
                      Text(
                        '알맞은 알파벳을 찾아보자!',
                        textAlign: TextAlign.center,
                        style: (isTight
                                ? Theme.of(context).textTheme.titleLarge
                                : (isCompact
                                      ? Theme.of(context).textTheme.headlineSmall
                                      : Theme.of(context).textTheme.headlineMedium))
                            ?.copyWith(color: KidPalette.navy),
                      ),
                      if (!isTight) ...[
                        SizedBox(height: isCompact ? 4 : 8),
                        Text(
                          '차근차근 보고, 정답을 콕 눌러봐요.',
                          textAlign: TextAlign.center,
                          style: (isCompact
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
                              child: isTight
                                  ? _TightQuizPromptPanel(
                                      displayName: _displayNameFor(question),
                                      prompt: _targetPromptFor(question),
                                      symbol: question.symbol,
                                      onReplay: () => _replayQuestion(question),
                                    )
                                  : Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        AudioPromptPanel(
                                          key: const Key('quiz-prompt-panel'),
                                          badge: '문제 듣기',
                                          title: _targetPromptFor(question),
                                          subtitle: isCompact
                                              ? '스피커를 눌러 다시 들어봐요.'
                                              : '스피커를 누르면 문제를 다시 들을 수 있어요.',
                                          onReplay: () => _replayQuestion(question),
                                          compact: isCompact,
                                        ),
                                        SizedBox(height: isCompact ? 10 : 14),
                                        Expanded(
                                          child: ToyPanel(
                                            padding: EdgeInsets.all(isCompact ? 14 : 24),
                                            backgroundColor: KidPalette.white.withValues(
                                              alpha: 0.94,
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: isCompact ? 12 : 14,
                                                    vertical: isCompact ? 6 : 8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: KidPalette.creamWarm,
                                                    borderRadius: BorderRadius.circular(999),
                                                  ),
                                                  child: Text(
                                                    '찾아볼 알파벳',
                                                    style: Theme.of(context).textTheme.titleSmall
                                                        ?.copyWith(
                                                          color: KidPalette.coralDark,
                                                          fontWeight: FontWeight.w900,
                                                        ),
                                                  ),
                                                ),
                                                SizedBox(height: isCompact ? 8 : 12),
                                                Text(
                                                  _displayNameFor(question),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: (isCompact
                                                          ? Theme.of(context).textTheme.titleSmall
                                                          : Theme.of(context).textTheme.titleMedium)
                                                      ?.copyWith(
                                                        color: KidPalette.coralDark,
                                                        fontWeight: FontWeight.w900,
                                                      ),
                                                ),
                                                SizedBox(height: isCompact ? 6 : 10),
                                                Expanded(
                                                  child: Center(
                                                    child: FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      child: Text(
                                                        question.symbol,
                                                        style: TextStyle(
                                                          fontSize: isCompact ? 86 : 118,
                                                          fontWeight: FontWeight.w900,
                                                          color: KidPalette.navy,
                                                          height: 1,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
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
                                      (gridConstraints.maxWidth - crossAxisSpacing) /
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
                                        _QuizChoiceTile(
                                          key: Key('quiz-choice-${choices[i].symbol}'),
                                          symbol: choices[i].symbol,
                                          compact: isCompact,
                                          accentIndex: i,
                                          disabled: _isResolvingChoice,
                                          onTap: () => _selectChoice(
                                            choice: choices[i],
                                            answer: question,
                                            totalQuestions: lesson.cards.length,
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
                  AnswerFeedbackOverlay(
                    visible: _feedbackVisible,
                    correct: _feedbackCorrect,
                    compact: isCompact,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _selectChoice({
    required AlphabetCard choice,
    required AlphabetCard answer,
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

    if (settings.voicePromptsEnabled) {
      await services.speechCueService.speak(
        isCorrect ? '딩동댕' : '다시 해보자',
        locale: 'ko-KR',
        rate: 0.46,
        pitch: isCorrect ? 1.08 : 0.94,
      );
    }

    await Future<void>.delayed(
      Duration(milliseconds: settings.effectsEnabled ? 650 : 220),
    );

    final isLastQuestion = _questionIndex == totalQuestions - 1;
    if (isLastQuestion) {
      final earnedSticker =
          nextCorrectCount >= (totalQuestions * 0.8).ceil();
      if (earnedSticker) {
        await services.progressStore.addStickers(1);
      }
      await services.progressStore.recordQuizResult(
        lessonId: 'alphabet:${widget.lessonId}',
        correctCount: nextCorrectCount,
        totalQuestions: totalQuestions,
        recentMistakes: nextMistakes,
      );
      if (!mounted) {
        return;
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

  List<AlphabetCard> _buildChoices(List<AlphabetCard> cards, int questionIndex) {
    final answer = cards[questionIndex];
    final distractors = cards.where((card) => card.symbol != answer.symbol).toList();
    final startIndex = distractors.isEmpty ? 0 : questionIndex % distractors.length;
    final rotatedDistractors = [
      ...distractors.skip(startIndex),
      ...distractors.take(startIndex),
    ];
    final choices = rotatedDistractors.take(3).toList(growable: true);
    choices.insert(questionIndex % 4, answer);
    return choices;
  }

  String _displayNameFor(AlphabetCard question) {
    return question.label.split(',').first.trim();
  }

  String _targetPromptFor(AlphabetCard question) {
    return "'${question.symbol}' 글자를 찾아봐!";
  }
}

class _TightQuizPromptPanel extends StatelessWidget {
  const _TightQuizPromptPanel({
    required this.displayName,
    required this.prompt,
    required this.symbol,
    required this.onReplay,
  });

  final String displayName;
  final String prompt;
  final String symbol;
  final VoidCallback onReplay;

  @override
  Widget build(BuildContext context) {
    return ToyPanel(
      key: const Key('quiz-prompt-panel'),
      padding: const EdgeInsets.all(12),
      backgroundColor: KidPalette.creamWarm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  prompt,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: KidPalette.navy,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: onReplay,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: KidPalette.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: KidShadows.button,
                    ),
                    child: const Icon(
                      Icons.volume_up_rounded,
                      color: KidPalette.coralDark,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: KidPalette.coralDark,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  symbol,
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    color: KidPalette.navy,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizChoiceTile extends StatelessWidget {
  const _QuizChoiceTile({
    super.key,
    required this.symbol,
    required this.onTap,
    required this.accentIndex,
    required this.compact,
    required this.disabled,
  });

  final String symbol;
  final VoidCallback onTap;
  final int accentIndex;
  final bool compact;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final palette = _paletteFor(accentIndex);

    return Opacity(
      opacity: disabled ? 0.88 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: palette),
          borderRadius: BorderRadius.circular(compact ? 26 : 32),
          boxShadow: KidShadows.button,
        ),
        child: Material(
          color: Colors.transparent,
          child: CooldownInkWell(
            borderRadius: BorderRadius.circular(compact ? 26 : 32),
            onTap: disabled ? null : onTap,
            child: Stack(
              children: [
                Positioned(
                  right: 16,
                  top: 16,
                  child: Container(
                    width: compact ? 30 : 38,
                    height: compact ? 30 : 38,
                    decoration: BoxDecoration(
                      color: KidPalette.white.withValues(alpha: 0.24),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  left: 18,
                  top: 16,
                  child: Text(
                    '콕!',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: KidPalette.white.withValues(alpha: 0.92),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      symbol,
                      style: TextStyle(
                        fontSize: compact ? 66 : 92,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        color: KidPalette.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _paletteFor(int index) {
    switch (index % 4) {
      case 0:
        return const [KidPalette.blue, KidPalette.blueDark];
      case 1:
        return const [KidPalette.coral, KidPalette.coralDark];
      case 2:
        return const [KidPalette.mint, KidPalette.mintDark];
      default:
        return const [KidPalette.lilac, Color(0xFFA28CF5)];
    }
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
                '알파벳 게임 끝!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 18),
              Text(
                '$totalQuestions문제 중 $correctCount문제 맞았어요!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: KidPalette.navy,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                earnedSticker
                    ? '자동차 스티커 1개 획득!'
                    : '한 번 더 하면 스티커를 받을 수 있어!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: KidPalette.coralDark,
                ),
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

class _AlphabetQuizLoadError extends StatelessWidget {
  const _AlphabetQuizLoadError({required this.onRetry});

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
                '알파벳 게임을 불러오지 못했어요.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: KidPalette.navy,
                ),
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
