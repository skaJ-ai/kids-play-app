import 'package:flutter/material.dart';

import '../../../app/ui/kid_theme.dart';
import '../../../app/ui/playground_scaffold.dart';
import '../../../app/ui/toy_button.dart';
import '../../../app/ui/toy_panel.dart';
import '../data/hangul_lesson_repository.dart';

class HangulQuizScreen extends StatefulWidget {
  const HangulQuizScreen({
    super.key,
    this.repository,
    this.lessonId = 'basic_consonants_1',
  });

  final HangulLessonRepository? repository;
  final String lessonId;

  @override
  State<HangulQuizScreen> createState() => _HangulQuizScreenState();
}

class _HangulQuizScreenState extends State<HangulQuizScreen> {
  late Future<HangulLesson> _lessonFuture;
  int _questionIndex = 0;
  int _correctCount = 0;
  bool _isComplete = false;

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
      _lessonFuture = _loadLesson();
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

          if (_isComplete) {
            return _QuizSummary(
              totalQuestions: lesson.cards.length,
              correctCount: _correctCount,
              onRestart: () => setState(() {
                _questionIndex = 0;
                _correctCount = 0;
                _isComplete = false;
              }),
            );
          }

          final question = lesson.cards[_questionIndex];
          final choices = _buildChoices(lesson.cards, _questionIndex);

          return LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxHeight < 420;
              final sectionGap = isCompact ? 14.0 : 20.0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: KidPalette.white.withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: KidShadows.panel,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.videogame_asset_rounded,
                              color: KidPalette.navy,
                            ),
                            const SizedBox(width: 8),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
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
                  SizedBox(height: isCompact ? 14 : 18),
                  Text(
                    '알맞은 글자를 찾아보자!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  SizedBox(height: isCompact ? 6 : 8),
                  Text(
                    '차근차근 보고, 정답을 콕 눌러봐요.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: sectionGap),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: ToyPanel(
                            key: const Key('quiz-prompt-panel'),
                            padding: EdgeInsets.all(isCompact ? 14 : 24),
                            backgroundColor: KidPalette.creamWarm,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isCompact ? 12 : 14,
                                    vertical: isCompact ? 6 : 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: KidPalette.white.withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    '찾아볼 글자',
                                    style: Theme.of(context).textTheme.titleSmall
                                        ?.copyWith(
                                          color: KidPalette.coralDark,
                                          fontWeight: FontWeight.w900,
                                        ),
                                  ),
                                ),
                                SizedBox(height: isCompact ? 10 : 18),
                                Text(
                                  _displayNameFor(question),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: (isCompact
                                          ? Theme.of(context).textTheme.titleMedium
                                          : Theme.of(context).textTheme.headlineSmall)
                                      ?.copyWith(color: KidPalette.coralDark),
                                ),
                                SizedBox(height: isCompact ? 8 : 12),
                                Text(
                                  _targetPromptFor(question),
                                  maxLines: isCompact ? 2 : 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: (isCompact
                                          ? Theme.of(context).textTheme.titleMedium
                                          : Theme.of(context).textTheme.headlineSmall)
                                      ?.copyWith(color: KidPalette.navy),
                                ),
                                if (!isCompact) ...[
                                  const SizedBox(height: 18),
                                  Text(
                                    '아래 네 개 중에서 정답을 골라봐!',
                                    style: Theme.of(context).textTheme.titleMedium
                                        ?.copyWith(color: KidPalette.body),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: isCompact ? 14 : 18),
                        Expanded(
                          flex: 5,
                          child: LayoutBuilder(
                            builder: (context, gridConstraints) {
                              const crossAxisCount = 2;
                              const mainAxisSpacing = 16.0;
                              const crossAxisSpacing = 16.0;
                              final rowCount = (choices.length / crossAxisCount)
                                  .ceil();
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
              );
            },
          );
        },
      ),
    );
  }

  void _selectChoice({
    required HangulCard choice,
    required HangulCard answer,
    required int totalQuestions,
  }) {
    setState(() {
      if (choice.symbol == answer.symbol) {
        _correctCount += 1;
      }

      if (_questionIndex == totalQuestions - 1) {
        _isComplete = true;
        return;
      }

      _questionIndex += 1;
    });
  }

  List<HangulCard> _buildChoices(List<HangulCard> cards, int questionIndex) {
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

  String _displayNameFor(HangulCard question) {
    return question.label.split(',').first.trim();
  }

  String _targetPromptFor(HangulCard question) {
    return "'${question.symbol}' 글자를 찾아봐!";
  }
}

class _QuizChoiceTile extends StatelessWidget {
  const _QuizChoiceTile({
    super.key,
    required this.symbol,
    required this.onTap,
    required this.accentIndex,
    required this.compact,
  });

  final String symbol;
  final VoidCallback onTap;
  final int accentIndex;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = _paletteFor(accentIndex);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: palette),
        borderRadius: BorderRadius.circular(compact ? 26 : 32),
        boxShadow: KidShadows.button,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(compact ? 26 : 32),
          onTap: onTap,
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
                '한글 게임 끝!',
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
