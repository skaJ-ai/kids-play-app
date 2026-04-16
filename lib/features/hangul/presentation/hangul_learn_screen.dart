import 'package:flutter/material.dart';

import '../../../app/ui/kid_theme.dart';
import '../../../app/ui/playground_scaffold.dart';
import '../../../app/ui/toy_button.dart';
import '../../../app/ui/toy_panel.dart';
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
    return PlaygroundScaffold(
      showRoad: true,
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
                              '한글 학습',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
                      '큰 글자를 먼저 보고, 이름도 천천히 따라 말해봐요.',
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
                                  card.symbol,
                                  style: Theme.of(context).textTheme.displayLarge
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
                              ToyPanel(
                                padding: EdgeInsets.all(compact ? 12 : 24),
                                backgroundColor: KidPalette.white.withValues(alpha: 0.94),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '이름',
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        color: KidPalette.coralDark,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    SizedBox(height: compact ? 6 : 10),
                                    Text(
                                      card.label,
                                      maxLines: compact ? 2 : 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: (compact
                                              ? Theme.of(context).textTheme.titleLarge
                                              : Theme.of(context).textTheme.headlineSmall)
                                          ?.copyWith(
                                            color: KidPalette.navy,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: compact ? 8 : 16),
                              Expanded(
                                child: ToyPanel(
                                  padding: EdgeInsets.all(compact ? 12 : 24),
                                  backgroundColor: KidPalette.lilac.withValues(alpha: 0.75),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        compact ? '천천히!' : '천천히 해봐!',
                                        style: (compact
                                                ? Theme.of(context).textTheme.titleMedium
                                                : Theme.of(context).textTheme.titleLarge)
                                            ?.copyWith(
                                              color: KidPalette.coralDark,
                                            ),
                                      ),
                                      SizedBox(height: compact ? 8 : 14),
                                      Text(
                                        card.hint,
                                        maxLines: compact ? 2 : 4,
                                        overflow: TextOverflow.ellipsis,
                                        style: (compact
                                                ? Theme.of(context).textTheme.titleSmall
                                                : Theme.of(context).textTheme.titleMedium)
                                            ?.copyWith(
                                              color: KidPalette.navy,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: compact ? 8 : 16),
                              ToyButton(
                                label: isLastCard ? '처음부터' : '다음',
                                icon: isLastCard
                                    ? Icons.refresh_rounded
                                    : Icons.arrow_forward_rounded,
                                height: compact ? 54 : 76,
                                onPressed: () => setState(() {
                                  if (isLastCard) {
                                    _currentCardIndex = 0;
                                    return;
                                  }
                                  _currentCardIndex += 1;
                                }),
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

class _HangulLoadError extends StatelessWidget {
  const _HangulLoadError({required this.message, required this.onRetry});

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
