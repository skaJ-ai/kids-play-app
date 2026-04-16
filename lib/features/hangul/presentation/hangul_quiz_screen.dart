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

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '한글 게임',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF184A78),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_questionIndex + 1} / ${lesson.cards.length}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF35658F),
                    ),
                  ),
                  const SizedBox(height: 20),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF6D8),
                      borderRadius: BorderRadius.circular(36),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 28,
                      ),
                      child: Column(
                        children: [
                          Text(
                            '알맞은 글자를 콕 눌러봐!',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFF06275),
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${question.label}을 찾아봐!',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF184A78),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 2.1,
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              textStyle: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            child: Text(choice.symbol),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
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
