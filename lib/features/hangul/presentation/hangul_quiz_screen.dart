import 'package:flutter/material.dart';

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
    return Scaffold(
      body: SafeArea(
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
                final outerPadding = isCompact ? 16.0 : 24.0;
                final titleGap = isCompact ? 6.0 : 8.0;
                final sectionGap = isCompact ? 12.0 : 20.0;
                final promptLineGap = isCompact ? 8.0 : 12.0;
                final promptAccentGap = isCompact ? 4.0 : 8.0;

                return Padding(
                  padding: EdgeInsets.all(outerPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '한글 게임',
                        textAlign: TextAlign.center,
                        style: (isCompact
                                ? Theme.of(context).textTheme.titleLarge
                                : Theme.of(context).textTheme.headlineMedium)
                            ?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF184A78),
                            ),
                      ),
                      SizedBox(height: titleGap),
                      Text(
                        '${_questionIndex + 1} / ${lesson.cards.length}',
                        textAlign: TextAlign.center,
                        style: (isCompact
                                ? Theme.of(context).textTheme.titleSmall
                                : Theme.of(context).textTheme.titleMedium)
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF35658F),
                            ),
                      ),
                      SizedBox(height: sectionGap),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF6D8),
                          borderRadius: BorderRadius.circular(isCompact ? 28 : 36),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isCompact ? 16 : 24,
                            vertical: isCompact ? 18 : 28,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '알맞은 글자를 콕 눌러봐!',
                                textAlign: TextAlign.center,
                                style: (isCompact
                                        ? Theme.of(context).textTheme.titleMedium
                                        : Theme.of(context).textTheme.titleLarge)
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFFF06275),
                                    ),
                              ),
                              SizedBox(height: promptLineGap),
                              Text(
                                _displayNameFor(question),
                                textAlign: TextAlign.center,
                                style: (isCompact
                                        ? Theme.of(context).textTheme.titleSmall
                                        : Theme.of(context).textTheme.titleMedium)
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF35658F),
                                    ),
                              ),
                              SizedBox(height: promptAccentGap),
                              Text(
                                _targetPromptFor(question),
                                textAlign: TextAlign.center,
                                style: (isCompact
                                        ? Theme.of(context).textTheme.titleLarge
                                        : Theme.of(context).textTheme.headlineSmall)
                                    ?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF184A78),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: sectionGap),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, gridConstraints) {
                            const crossAxisCount = 2;
                            const mainAxisSpacing = 16.0;
                            const crossAxisSpacing = 16.0;
                            final rowCount = (choices.length / crossAxisCount).ceil();
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
                                for (final choice in choices)
                                  FilledButton(
                                    onPressed: () => _selectChoice(
                                      choice: choice,
                                      answer: question,
                                      totalQuestions: lesson.cards.length,
                                    ),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: const Color(0xFF4B98FF),
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          isCompact ? 22 : 28,
                                        ),
                                      ),
                                    ),
                                    child: Center(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          choice.symbol,
                                          style: TextStyle(
                                            fontSize: isCompact ? 60 : 84,
                                            fontWeight: FontWeight.w900,
                                            height: 1,
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
                    ],
                  ),
                );
              },
            );
          },
        ),
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

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '한글 게임 끝!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF184A78),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFFFF6D8),
                borderRadius: BorderRadius.circular(36),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$totalQuestions문제 중 $correctCount문제 맞았어요!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF184A78),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      earnedSticker
                          ? '자동차 스티커 1개 획득!'
                          : '한 번 더 하면 스티커를 받을 수 있어!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFF06275),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 72,
            child: FilledButton(
              onPressed: onRestart,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF4B98FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                textStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              child: const Text('다시하기'),
            ),
          ),
        ],
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '한글 게임을 불러오지 못했어요.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: const Color(0xFF184A78),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 64,
              child: FilledButton(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF4B98FF),
                  foregroundColor: Colors.white,
                  textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text('다시 시도'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
