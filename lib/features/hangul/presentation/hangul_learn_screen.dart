import 'package:flutter/material.dart';

import '../../../app/ui/app_colors.dart';
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
      backgroundColor: AppColors.cream,
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
              return const Center(
                child: CircularProgressIndicator(color: AppColors.hangulBottom),
              );
            }

            final lesson = snapshot.data!;
            if (lesson.cards.isEmpty) {
              return const Center(child: Text('준비 중인 한글 카드예요.'));
            }

            final card = lesson.cards[_currentCardIndex];
            final isLastCard = _currentCardIndex == lesson.cards.length - 1;

            return LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxHeight < 420;
                return Padding(
                  padding: EdgeInsets.all(isCompact ? 14 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _LearnHeader(
                        lesson: lesson,
                        currentIndex: _currentCardIndex,
                        isCompact: isCompact,
                      ),
                      SizedBox(height: isCompact ? 10 : 16),
                      Expanded(
                        child: _SymbolCard(card: card, isCompact: isCompact),
                      ),
                      SizedBox(height: isCompact ? 10 : 16),
                      _NextButton(
                        isLastCard: isLastCard,
                        isCompact: isCompact,
                        onTap: () => setState(() {
                          if (isLastCard) {
                            _currentCardIndex = 0;
                          } else {
                            _currentCardIndex += 1;
                          }
                        }),
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
}

// ── Header ─────────────────────────────────────────────────────────────────────

class _LearnHeader extends StatelessWidget {
  const _LearnHeader({
    required this.lesson,
    required this.currentIndex,
    required this.isCompact,
  });

  final HangulLesson lesson;
  final int currentIndex;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '한글 학습',
                style: TextStyle(
                  fontSize: isCompact ? 16 : 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.navy,
                ),
              ),
              Text(
                lesson.title,
                style: TextStyle(
                  fontSize: isCompact ? 13 : 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.coral,
                ),
              ),
            ],
          ),
        ),
        // Progress pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.hangulBottom.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${currentIndex + 1} / ${lesson.cards.length}',
            style: TextStyle(
              fontSize: isCompact ? 14 : 16,
              fontWeight: FontWeight.w800,
              color: AppColors.hangulBottom,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Symbol card ────────────────────────────────────────────────────────────────

class _SymbolCard extends StatelessWidget {
  const _SymbolCard({required this.card, required this.isCompact});

  final HangulCard card;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.creamCard,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.hangulTop, width: 3),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 16 : 24),
        child: Row(
          children: [
            // Symbol (left or top depending on space)
            Expanded(
              flex: 4,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    card.symbol,
                    style: TextStyle(
                      fontSize: isCompact ? 110 : 140,
                      fontWeight: FontWeight.w900,
                      color: AppColors.navy,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: 2,
              margin: EdgeInsets.symmetric(vertical: isCompact ? 8 : 16),
              color: AppColors.hangulTop,
            ),
            // Label + hint (right side)
            Expanded(
              flex: 5,
              child: Padding(
                padding: EdgeInsets.only(left: isCompact ? 12 : 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.hangulBottom,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        card.label,
                        style: TextStyle(
                          fontSize: isCompact ? 17 : 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: isCompact ? 10 : 14),
                    Text(
                      card.hint,
                      style: TextStyle(
                        fontSize: isCompact ? 13 : 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.midBlue,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Next button ────────────────────────────────────────────────────────────────

class _NextButton extends StatelessWidget {
  const _NextButton({
    required this.isLastCard,
    required this.isCompact,
    required this.onTap,
  });

  final bool isLastCard;
  final bool isCompact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isCompact ? 52 : 64,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.alphabetTop, AppColors.alphabetBottom],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isCompact ? 18 : 22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x554B98FF),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(isCompact ? 18 : 22),
          onTap: onTap,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isLastCard ? '처음부터' : '다음',
                  style: TextStyle(
                    fontSize: isCompact ? 18 : 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                if (!isLastCard)
                  Text(
                    '  →',
                    style: TextStyle(
                      fontSize: isCompact ? 18 : 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Error state ────────────────────────────────────────────────────────────────

class _HangulLoadError extends StatelessWidget {
  const _HangulLoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '😥',
              style: TextStyle(fontSize: 56),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 60,
              child: FilledButton(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.alphabetBottom,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text('다시 시도'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
