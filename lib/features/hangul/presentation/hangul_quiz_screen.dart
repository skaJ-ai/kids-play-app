import 'package:flutter/material.dart';

import '../../../app/ui/app_colors.dart';
import '../data/hangul_lesson_repository.dart';

// Quiz choice colour pairs — (background, foreground)
const _kChoiceStyles = [
  (AppColors.choiceA, AppColors.choiceAText),
  (AppColors.choiceB, AppColors.choiceBText),
  (AppColors.choiceC, AppColors.choiceCText),
  (AppColors.choiceD, AppColors.choiceDText),
];

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
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: FutureBuilder<HangulLesson>(
          future: _lessonFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _HangulQuizLoadError(onRetry: _retryLoad);
            }
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.hangulBottom),
              );
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
                return _QuizBody(
                  question: question,
                  choices: choices,
                  questionIndex: _questionIndex,
                  totalQuestions: lesson.cards.length,
                  isCompact: isCompact,
                  onChoiceTap: (choice) => _selectChoice(
                    choice: choice,
                    answer: question,
                    totalQuestions: lesson.cards.length,
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
    final distractors =
        cards.where((card) => card.symbol != answer.symbol).toList();
    final startIndex =
        distractors.isEmpty ? 0 : questionIndex % distractors.length;
    final rotatedDistractors = [
      ...distractors.skip(startIndex),
      ...distractors.take(startIndex),
    ];
    final choices = rotatedDistractors.take(3).toList(growable: true);
    choices.insert(questionIndex % 4, answer);
    return choices;
  }
}

// ── Quiz body ──────────────────────────────────────────────────────────────────

class _QuizBody extends StatelessWidget {
  const _QuizBody({
    required this.question,
    required this.choices,
    required this.questionIndex,
    required this.totalQuestions,
    required this.isCompact,
    required this.onChoiceTap,
  });

  final HangulCard question;
  final List<HangulCard> choices;
  final int questionIndex;
  final int totalQuestions;
  final bool isCompact;
  final void Function(HangulCard) onChoiceTap;

  String get _displayName => question.label.split(',').first.trim();
  String get _targetPrompt => "'${question.symbol}' 글자를 찾아봐!";

  @override
  Widget build(BuildContext context) {
    final outerPad = isCompact ? 12.0 : 20.0;
    final gap = isCompact ? 8.0 : 14.0;

    return Padding(
      padding: EdgeInsets.all(outerPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          _QuizHeader(
            questionIndex: questionIndex,
            totalQuestions: totalQuestions,
            isCompact: isCompact,
          ),
          SizedBox(height: gap),
          // Prompt card
          _PromptCard(
            displayName: _displayName,
            targetPrompt: _targetPrompt,
            isCompact: isCompact,
          ),
          SizedBox(height: gap),
          // Choice grid
          Expanded(
            child: _ChoiceGrid(
              choices: choices,
              isCompact: isCompact,
              onChoiceTap: onChoiceTap,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quiz header ────────────────────────────────────────────────────────────────

class _QuizHeader extends StatelessWidget {
  const _QuizHeader({
    required this.questionIndex,
    required this.totalQuestions,
    required this.isCompact,
  });

  final int questionIndex;
  final int totalQuestions;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '한글 게임',
          style: TextStyle(
            fontSize: isCompact ? 16 : 22,
            fontWeight: FontWeight.w900,
            color: AppColors.navy,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.alphabetBottom.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${questionIndex + 1} / $totalQuestions',
            style: TextStyle(
              fontSize: isCompact ? 13 : 16,
              fontWeight: FontWeight.w800,
              color: AppColors.alphabetBottom,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Prompt card ────────────────────────────────────────────────────────────────

class _PromptCard extends StatelessWidget {
  const _PromptCard({
    required this.displayName,
    required this.targetPrompt,
    required this.isCompact,
  });

  final String displayName;
  final String targetPrompt;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 14 : 20,
        vertical: isCompact ? 10 : 14,
      ),
      decoration: BoxDecoration(
        color: AppColors.creamCard,
        borderRadius: BorderRadius.circular(isCompact ? 18 : 24),
        border: Border.all(color: AppColors.hangulTop, width: 2.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '알맞은 글자를 콕 눌러봐!',
                  style: TextStyle(
                    fontSize: isCompact ? 13 : 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.coral,
                  ),
                ),
                SizedBox(height: isCompact ? 3 : 5),
                Text(
                  targetPrompt,
                  style: TextStyle(
                    fontSize: isCompact ? 15 : 19,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navy,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: isCompact ? 40 : 50,
            height: isCompact ? 40 : 50,
            decoration: BoxDecoration(
              color: AppColors.hangulTop.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              displayName.isNotEmpty ? displayName[0] : '',
              style: TextStyle(
                fontSize: isCompact ? 22 : 28,
                fontWeight: FontWeight.w900,
                color: AppColors.navy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Choice grid ────────────────────────────────────────────────────────────────

class _ChoiceGrid extends StatelessWidget {
  const _ChoiceGrid({
    required this.choices,
    required this.isCompact,
    required this.onChoiceTap,
  });

  final List<HangulCard> choices;
  final bool isCompact;
  final void Function(HangulCard) onChoiceTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const crossAxisCount = 2;
        const spacing = 12.0;
        final rowCount = (choices.length / crossAxisCount).ceil();
        final tileWidth =
            (constraints.maxWidth - spacing) / crossAxisCount;
        final tileHeight =
            (constraints.maxHeight - (rowCount - 1) * spacing) / rowCount;
        final childAspectRatio =
            tileHeight <= 0 ? 1.0 : tileWidth / tileHeight;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          childAspectRatio: childAspectRatio,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (int i = 0; i < choices.length; i++)
              _ChoiceTile(
                card: choices[i],
                colorIndex: i,
                isCompact: isCompact,
                onTap: () => onChoiceTap(choices[i]),
              ),
          ],
        );
      },
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.card,
    required this.colorIndex,
    required this.isCompact,
    required this.onTap,
  });

  final HangulCard card;
  final int colorIndex;
  final bool isCompact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _kChoiceStyles[colorIndex % _kChoiceStyles.length];
    return FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        padding: EdgeInsets.zero,
        elevation: 6,
        shadowColor: AppColors.shadowMid,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isCompact ? 20 : 26),
        ),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            card.symbol,
            style: TextStyle(
              fontSize: isCompact ? 60 : 84,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Quiz summary ───────────────────────────────────────────────────────────────

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
    final ratio = totalQuestions > 0 ? correctCount / totalQuestions : 0.0;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '한글 게임 끝!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
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
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      earnedSticker ? '🎉' : '😊',
                      style: const TextStyle(fontSize: 64),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$totalQuestions문제 중 $correctCount문제 맞았어요!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 14,
                        backgroundColor: AppColors.hangulTop.withValues(alpha: 0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.hangulBottom,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      earnedSticker
                          ? '자동차 스티커 1개 획득!'
                          : '한 번 더 하면 스티커를 받을 수 있어!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: earnedSticker ? AppColors.coral : AppColors.midBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFAA00), Color(0xFFFF7043)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x55FF7043),
                  blurRadius: 14,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: onRestart,
                child: const Center(
                  child: Text(
                    '다시하기',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
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

// ── Error state ────────────────────────────────────────────────────────────────

class _HangulQuizLoadError extends StatelessWidget {
  const _HangulQuizLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('😥', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            const Text(
              '한글 게임을 불러오지 못했어요.',
              textAlign: TextAlign.center,
              style: TextStyle(
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
