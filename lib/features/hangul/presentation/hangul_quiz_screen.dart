import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/services/tts_service.dart';
import '../../../app/ui/app_colors.dart';
import '../data/hangul_lesson_repository.dart';

class HangulQuizScreen extends StatefulWidget {
  const HangulQuizScreen({
    super.key,
    this.repository,
    this.lessonId = 'basic_consonants_1',
    this.ttsService,
  });

  final HangulLessonRepository? repository;
  final String lessonId;
  final TtsService? ttsService;

  @override
  State<HangulQuizScreen> createState() => _HangulQuizScreenState();
}

class _HangulQuizScreenState extends State<HangulQuizScreen>
    with SingleTickerProviderStateMixin {
  late final TtsService _tts;
  late Future<HangulLesson> _lessonFuture;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  int _questionIndex = 0;
  int _correctCount = 0;
  bool _isComplete = false;
  int? _selectedIndex;
  bool _isCorrect = false;
  Timer? _advanceTimer;

  @override
  void initState() {
    super.initState();
    _tts = widget.ttsService ?? DeviceTtsService.instance;
    _lessonFuture = _loadLesson();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: 0.0), weight: 1),
    ]).animate(_shakeController);
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    _shakeController.dispose();
    super.dispose();
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
      _selectedIndex = null;
      _lessonFuture = _loadLesson();
    });
  }

  void _speakQuestion(HangulCard card) {
    final name = card.label.split(',').first.trim();
    _tts.speak(name);
  }

  void _selectChoice({
    required int choiceIndex,
    required HangulCard choice,
    required HangulCard answer,
    required int totalQuestions,
  }) {
    if (_selectedIndex != null) return;

    final correct = choice.symbol == answer.symbol;
    setState(() {
      _selectedIndex = choiceIndex;
      _isCorrect = correct;
    });

    if (correct) {
      final name = answer.label.split(',').first.trim();
      _tts.speak(name);
      _advanceTimer = Timer(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        setState(() {
          _correctCount += 1;
          _selectedIndex = null;
          if (_questionIndex == totalQuestions - 1) {
            _isComplete = true;
          } else {
            _questionIndex += 1;
          }
        });
        if (!_isComplete) {
          _lessonFuture.then((lesson) {
            _speakQuestion(lesson.cards[_questionIndex]);
          });
        }
      });
    } else {
      _shakeController.forward(from: 0).then((_) {
        if (!mounted) return;
        setState(() => _selectedIndex = null);
        _lessonFuture.then((lesson) {
          _speakQuestion(lesson.cards[_questionIndex]);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.tayoLight,
      body: SafeArea(
        child: FutureBuilder<HangulLesson>(
          future: _lessonFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _HangulQuizLoadError(onRetry: _retryLoad);
            }
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.tayoBlue),
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
                  _selectedIndex = null;
                }),
              );
            }

            final question = lesson.cards[_questionIndex];
            final choices = _buildChoices(lesson.cards, _questionIndex);

            return _QuizBody(
              question: question,
              choices: choices,
              questionIndex: _questionIndex,
              totalQuestions: lesson.cards.length,
              selectedIndex: _selectedIndex,
              isCorrect: _isCorrect,
              shakeAnimation: _shakeAnimation,
              onSpeakerTap: () => _speakQuestion(question),
              onChoiceTap: (idx, card) => _selectChoice(
                choiceIndex: idx,
                choice: card,
                answer: question,
                totalQuestions: lesson.cards.length,
              ),
              onFirstBuild: () => _speakQuestion(question),
            );
          },
        ),
      ),
    );
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

class _QuizBody extends StatefulWidget {
  const _QuizBody({
    required this.question,
    required this.choices,
    required this.questionIndex,
    required this.totalQuestions,
    required this.selectedIndex,
    required this.isCorrect,
    required this.shakeAnimation,
    required this.onSpeakerTap,
    required this.onChoiceTap,
    required this.onFirstBuild,
  });

  final HangulCard question;
  final List<HangulCard> choices;
  final int questionIndex;
  final int totalQuestions;
  final int? selectedIndex;
  final bool isCorrect;
  final Animation<double> shakeAnimation;
  final VoidCallback onSpeakerTap;
  final void Function(int index, HangulCard card) onChoiceTap;
  final VoidCallback onFirstBuild;

  @override
  State<_QuizBody> createState() => _QuizBodyState();
}

class _QuizBodyState extends State<_QuizBody> {
  bool _firstBuildDone = false;

  @override
  Widget build(BuildContext context) {
    if (!_firstBuildDone) {
      _firstBuildDone = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onFirstBuild();
      });
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _QuizHeader(
            questionIndex: widget.questionIndex,
            totalQuestions: widget.totalQuestions,
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(
                  flex: 35,
                  child: _SpeakerCard(onTap: widget.onSpeakerTap),
                ),
                const SizedBox(width: 12),
                Flexible(
                  flex: 65,
                  child: _ChoiceGrid(
                    choices: widget.choices,
                    selectedIndex: widget.selectedIndex,
                    isCorrect: widget.isCorrect,
                    shakeAnimation: widget.shakeAnimation,
                    onChoiceTap: widget.onChoiceTap,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────────

class _QuizHeader extends StatelessWidget {
  const _QuizHeader({
    required this.questionIndex,
    required this.totalQuestions,
  });

  final int questionIndex;
  final int totalQuestions;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '한글 게임',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.tayoDark,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.tayoBlue.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${questionIndex + 1} / $totalQuestions',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.tayoDark,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Speaker card ───────────────────────────────────────────────────────────────

class _SpeakerCard extends StatelessWidget {
  const _SpeakerCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.tayoBlue, AppColors.tayoDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.tayoBlue.withValues(alpha: 0.45),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.volume_up_rounded,
            color: Colors.white,
            size: 72,
          ),
        ),
      ),
    );
  }
}

// ── Choice grid ────────────────────────────────────────────────────────────────

class _ChoiceGrid extends StatelessWidget {
  const _ChoiceGrid({
    required this.choices,
    required this.selectedIndex,
    required this.isCorrect,
    required this.shakeAnimation,
    required this.onChoiceTap,
  });

  final List<HangulCard> choices;
  final int? selectedIndex;
  final bool isCorrect;
  final Animation<double> shakeAnimation;
  final void Function(int index, HangulCard card) onChoiceTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const crossAxisCount = 2;
        const spacing = 10.0;
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
                index: i,
                selectedIndex: selectedIndex,
                isCorrect: isCorrect,
                shakeAnimation: shakeAnimation,
                onTap: () => onChoiceTap(i, choices[i]),
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
    required this.index,
    required this.selectedIndex,
    required this.isCorrect,
    required this.shakeAnimation,
    required this.onTap,
  });

  final HangulCard card;
  final int index;
  final int? selectedIndex;
  final bool isCorrect;
  final Animation<double> shakeAnimation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedIndex == index;
    final showCorrect = isSelected && isCorrect;
    final showWrong = isSelected && !isCorrect;

    Widget tile = FilledButton(
      onPressed: selectedIndex == null ? onTap : null,
      style: FilledButton.styleFrom(
        backgroundColor: showCorrect
            ? AppColors.tayoSuccess
            : showWrong
                ? AppColors.tayoError
                : Colors.white,
        foregroundColor:
            showCorrect || showWrong ? Colors.white : AppColors.navy,
        disabledBackgroundColor: showCorrect
            ? AppColors.tayoSuccess
            : showWrong
                ? AppColors.tayoError
                : Colors.white,
        disabledForegroundColor:
            showCorrect || showWrong ? Colors.white : AppColors.navy,
        padding: EdgeInsets.zero,
        elevation: 5,
        shadowColor: AppColors.shadowMid,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: showCorrect
                ? AppColors.tayoSuccess
                : showWrong
                    ? AppColors.tayoError
                    : AppColors.tayoBlue.withValues(alpha: 0.3),
            width: 2.5,
          ),
        ),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            card.symbol,
            style: const TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ),
      ),
    );

    if (showWrong) {
      tile = AnimatedBuilder(
        animation: shakeAnimation,
        builder: (context, child) => Transform.translate(
          offset: Offset(shakeAnimation.value, 0),
          child: child,
        ),
        child: tile,
      );
    }

    return tile;
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
              color: AppColors.tayoDark,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: AppColors.tayoBlue, width: 3),
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
                        color: AppColors.tayoDark,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 14,
                        backgroundColor:
                            AppColors.tayoBlue.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.tayoBlue,
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
                        color: earnedSticker
                            ? AppColors.tayoSuccess
                            : AppColors.midBlue,
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
                colors: [AppColors.tayoBlue, AppColors.tayoDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppColors.tayoBlue.withValues(alpha: 0.4),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
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
                color: AppColors.tayoDark,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 60,
              child: FilledButton(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.tayoBlue,
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
