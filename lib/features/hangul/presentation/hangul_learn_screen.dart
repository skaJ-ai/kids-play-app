import 'package:flutter/material.dart';

import '../data/hangul_lesson_repository.dart';

class HangulLearnScreen extends StatefulWidget {
  const HangulLearnScreen({
    super.key,
    this.repository,
    this.lessonId = 'basic_consonants_1',
  });

  final HangulLessonRepository? repository;
  final String lessonId;

  @override
  State<HangulLearnScreen> createState() => _HangulLearnScreenState();
}

class _HangulLearnScreenState extends State<HangulLearnScreen> {
  late Future<HangulLesson> _lessonFuture;
  int _currentCardIndex = 0;

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
      _currentCardIndex = 0;
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
              return _HangulLoadError(
                message: '한글 카드를 불러오지 못했어요.',
                onRetry: _retryLoad,
              );
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final lesson = snapshot.data!;
            if (lesson.cards.isEmpty) {
              return const Center(child: Text('준비 중인 한글 카드예요.'));
            }

            final card = lesson.cards[_currentCardIndex];
            final isLastCard = _currentCardIndex == lesson.cards.length - 1;

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '한글 학습',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF184A78),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lesson.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFF06275),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${_currentCardIndex + 1} / ${lesson.cards.length}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF35658F),
                    ),
                  ),
                  const SizedBox(height: 20),
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
                              card.symbol,
                              style: Theme.of(context).textTheme.displayLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF184A78),
                                  ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              card.label,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFFF06275),
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              card.hint,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: const Color(0xFF35658F),
                                    fontWeight: FontWeight.w700,
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
                      onPressed: () => setState(() {
                        if (isLastCard) {
                          _currentCardIndex = 0;
                          return;
                        }
                        _currentCardIndex += 1;
                      }),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF4B98FF),
                        foregroundColor: Colors.white,
                        textStyle: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(isLastCard ? '처음부터' : '다음'),
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
}

class _HangulLoadError extends StatelessWidget {
  const _HangulLoadError({required this.message, required this.onRetry});

  final String message;
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
              message,
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
