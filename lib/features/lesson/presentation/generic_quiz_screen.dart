import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/services/app_services.dart';
import '../../../app/ui/answer_feedback_overlay.dart';
import '../../../app/ui/companion_pair.dart';
import '../../../app/ui/kid_theme.dart';
import '../../../app/ui/mascot_view.dart';
import '../../../app/ui/playground_scaffold.dart';
import '../../../app/ui/signal_light.dart';
import '../../../app/ui/tap_cooldown.dart';
import '../../../app/ui/toy_button.dart';
import '../../../app/ui/toy_panel.dart';
import '../application/quiz_controller.dart';
import '../data/lesson_content_loader.dart';
import '../domain/lesson.dart';
import '../domain/lesson_category.dart';
import '../domain/quiz_rules.dart';

class GenericQuizScreen extends StatefulWidget {
  const GenericQuizScreen({
    super.key,
    required this.loader,
    required this.category,
    required this.lessonId,
    this.mistakeSymbols,
    this.errorMessage,
    this.notEnoughItemsMessage,
    this.noMistakesMessage,
  });

  final LessonContentLoader loader;
  final LessonCategoryConfig category;
  final String lessonId;
  final List<String>? mistakeSymbols;
  final String? errorMessage;
  final String? notEnoughItemsMessage;
  final String? noMistakesMessage;

  @override
  State<GenericQuizScreen> createState() => _GenericQuizScreenState();
}

class _GenericQuizScreenState extends State<GenericQuizScreen> {
  late Future<Lesson> _lessonFuture;
  late AppServices _services;
  QuizController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _services = AppServicesScope.of(context);
  }

  @override
  void initState() {
    super.initState();
    _lessonFuture = widget.loader.loadLesson(widget.lessonId);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _retryLoad() {
    setState(() {
      _controller?.dispose();
      _controller = null;
      _lessonFuture = widget.loader.loadLesson(widget.lessonId);
    });
  }

  QuizController _ensureController(Lesson lesson, List<LessonItem> questions) {
    final existing = _controller;
    if (existing != null) {
      return existing;
    }
    final controller = QuizController(
      services: _services,
      category: widget.category,
      lessonId: widget.lessonId,
      questions: questions,
      pool: lesson.items,
    )..addListener(_onControllerChanged);
    _controller = controller;
    return controller;
  }

  void _onControllerChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  MascotState _mascotStateFor(QuizController controller) {
    if (!controller.feedbackVisible) {
      return MascotState.idle;
    }
    return controller.feedbackCorrect
        ? MascotState.correct
        : MascotState.wrong;
  }

  SignalLightState _signalStateFor(QuizController controller) {
    if (!controller.feedbackVisible) {
      return SignalLightState.idle;
    }
    return controller.feedbackCorrect
        ? SignalLightState.correct
        : SignalLightState.wrong;
  }

  _QuizChoiceFeedback _feedbackFor(QuizController controller, String symbol) {
    if (!controller.feedbackVisible ||
        controller.lastChoiceSymbol != symbol) {
      return _QuizChoiceFeedback.none;
    }
    return controller.feedbackCorrect
        ? _QuizChoiceFeedback.correctTapped
        : _QuizChoiceFeedback.wrongTapped;
  }

  @override
  Widget build(BuildContext context) {
    return PlaygroundScaffold(
      showRoad: true,
      child: FutureBuilder<Lesson>(
        future: _lessonFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _QuizLoadError(
              message: widget.errorMessage ?? '게임을 불러오지 못했어요.',
              onRetry: _retryLoad,
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final lesson = snapshot.data!;
          if (lesson.items.length < 4) {
            return Center(
              child: Text(
                widget.notEnoughItemsMessage ?? '퀴즈 문제가 아직 부족해요.',
              ),
            );
          }

          final questions = resolveQuizQuestions(
            lesson.items,
            mistakeSymbols: widget.mistakeSymbols,
          );
          if (questions.isEmpty) {
            return Center(
              child: Text(widget.noMistakesMessage ?? '다시 풀 오답이 없어요.'),
            );
          }

          final controller = _ensureController(lesson, questions);

          if (controller.isComplete) {
            return _QuizSummary(
              category: widget.category,
              totalQuestions: controller.totalQuestions,
              correctCount: controller.correctCount,
              onRestart: controller.restart,
            );
          }

          final question = controller.currentQuestion;
          final choices = controller.currentChoices;

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
                                  widget.category.quizHeaderLabel,
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
                              '${controller.questionIndex + 1} / ${controller.totalQuestions}',
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
                        widget.category.promptFor(question.spoken),
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
                      SizedBox(height: sectionGap),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 4,
                              child: _QuizMascotPanel(
                                mascotState: _mascotStateFor(controller),
                                signalState: _signalStateFor(controller),
                                spoken: question.spoken,
                                onReplay: controller.replayPrompt,
                                compact: isCompact,
                                tight: isTight,
                              ),
                            ),
                            SizedBox(
                              width: isTight ? 10 : (isCompact ? 14 : 18),
                            ),
                            Expanded(
                              flex: 5,
                              child: LayoutBuilder(
                                builder: (context, gridConstraints) {
                                  const crossAxisCount = 2;
                                  final mainAxisSpacing =
                                      isTight ? 12.0 : 16.0;
                                  final crossAxisSpacing =
                                      isTight ? 12.0 : 16.0;
                                  final rowCount =
                                      (choices.length / crossAxisCount).ceil();
                                  final tileWidth =
                                      (gridConstraints.maxWidth -
                                              crossAxisSpacing) /
                                          crossAxisCount;
                                  final tileHeight =
                                      (gridConstraints.maxHeight -
                                              (rowCount - 1) *
                                                  mainAxisSpacing) /
                                          rowCount;
                                  final childAspectRatio = tileHeight <= 0
                                      ? 1.0
                                      : tileWidth / tileHeight;

                                  return GridView.count(
                                    crossAxisCount: crossAxisCount,
                                    mainAxisSpacing: mainAxisSpacing,
                                    crossAxisSpacing: crossAxisSpacing,
                                    childAspectRatio: childAspectRatio,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    children: [
                                      for (var i = 0; i < choices.length; i++)
                                        _QuizChoiceTile(
                                          key: Key(
                                            'quiz-choice-${choices[i].symbol}',
                                          ),
                                          symbol: choices[i].display,
                                          compact: isCompact,
                                          accentIndex: i,
                                          disabled:
                                              controller.isResolvingChoice,
                                          feedback: _feedbackFor(
                                            controller,
                                            choices[i].symbol,
                                          ),
                                          onTap: () => controller
                                              .selectChoice(choices[i]),
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
                    visible: controller.feedbackVisible,
                    correct: controller.feedbackCorrect,
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
}

class _QuizMascotPanel extends StatelessWidget {
  const _QuizMascotPanel({
    required this.mascotState,
    required this.signalState,
    required this.spoken,
    required this.onReplay,
    required this.compact,
    required this.tight,
  });

  final MascotState mascotState;
  final SignalLightState signalState;
  final String spoken;
  final VoidCallback onReplay;
  final bool compact;
  final bool tight;

  @override
  Widget build(BuildContext context) {
    final mascotSize = tight ? 96.0 : (compact ? 132.0 : 184.0);
    final signalSize = tight ? 26.0 : (compact ? 34.0 : 44.0);
    final speakerSize = tight ? 44.0 : (compact ? 50.0 : 60.0);

    return ToyPanel(
      key: const Key('quiz-mascot-panel'),
      padding: EdgeInsets.all(tight ? 12 : (compact ? 16 : 22)),
      backgroundColor: KidPalette.creamWarm,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SignalLight(
            key: const Key('quiz-signal-light'),
            state: signalState,
            size: signalSize,
          ),
          SizedBox(width: tight ? 10 : 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Center(
                    child: CompanionPair(
                      key: const Key('quiz-companion'),
                      mascotKey: const Key('quiz-mascot'),
                      avatarKey: const Key('quiz-avatar'),
                      state: mascotState,
                      size: mascotSize,
                      onTap: onReplay,
                    ),
                  ),
                ),
                SizedBox(height: tight ? 6 : 10),
                Text(
                  spoken,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      (compact
                              ? Theme.of(context).textTheme.titleMedium
                              : Theme.of(context).textTheme.headlineSmall)
                          ?.copyWith(
                            color: KidPalette.coralDark,
                            fontWeight: FontWeight.w900,
                          ),
                ),
                SizedBox(height: tight ? 6 : 10),
                _SpeakerButton(
                  onReplay: onReplay,
                  size: speakerSize,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeakerButton extends StatelessWidget {
  const _SpeakerButton({required this.onReplay, required this.size});

  final VoidCallback onReplay;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const Key('quiz-replay-button'),
          borderRadius: BorderRadius.circular(size / 2),
          onTap: onReplay,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: KidPalette.white.withValues(alpha: 0.94),
              shape: BoxShape.circle,
              boxShadow: KidShadows.button,
            ),
            child: Icon(
              Icons.volume_up_rounded,
              color: KidPalette.coralDark,
              size: size * 0.55,
            ),
          ),
        ),
      ),
    );
  }
}

enum _QuizChoiceFeedback { none, correctTapped, wrongTapped }

class _QuizChoiceTile extends StatefulWidget {
  const _QuizChoiceTile({
    super.key,
    required this.symbol,
    required this.onTap,
    required this.accentIndex,
    required this.compact,
    required this.disabled,
    required this.feedback,
  });

  final String symbol;
  final VoidCallback onTap;
  final int accentIndex;
  final bool compact;
  final bool disabled;
  final _QuizChoiceFeedback feedback;

  @override
  State<_QuizChoiceTile> createState() => _QuizChoiceTileState();
}

class _QuizChoiceTileState extends State<_QuizChoiceTile>
    with TickerProviderStateMixin {
  late final AnimationController _wrong;
  late final AnimationController _correct;

  @override
  void initState() {
    super.initState();
    _wrong = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _correct = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
  }

  @override
  void didUpdateWidget(covariant _QuizChoiceTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.feedback != oldWidget.feedback) {
      switch (widget.feedback) {
        case _QuizChoiceFeedback.wrongTapped:
          _wrong.forward(from: 0);
        case _QuizChoiceFeedback.correctTapped:
          _correct.forward(from: 0);
        case _QuizChoiceFeedback.none:
          break;
      }
    }
  }

  @override
  void dispose() {
    _wrong.dispose();
    _correct.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = _paletteFor(widget.accentIndex);

    return Opacity(
      opacity: widget.disabled ? 0.88 : 1,
      child: AnimatedBuilder(
        animation: Listenable.merge([_wrong, _correct]),
        builder: (context, child) {
          // Wrong: 1.0→0.92→1.0 shrink over the full 220ms plus a 6px shake
          // that completes three cycles (sin 6π).
          final wrongT = _wrong.value;
          final wrongScale = 1 - 0.08 * (1 - (2 * wrongT - 1).abs());
          final shakeDx = wrongT == 0 || wrongT == 1
              ? 0.0
              : math.sin(wrongT * 6 * math.pi) * 6.0;

          // Correct: 1.0→1.08→1.0 bloom.
          final correctT = _correct.value;
          final correctScale = 1 + 0.08 * (1 - (2 * correctT - 1).abs());

          final scale = wrongT > 0 ? wrongScale : correctScale;

          return Transform.translate(
            offset: Offset(shakeDx, 0),
            child: Transform.scale(scale: scale, child: child),
          );
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: palette),
            borderRadius: BorderRadius.circular(widget.compact ? 26 : 32),
            boxShadow: KidShadows.button,
          ),
          child: Material(
            color: Colors.transparent,
            child: CooldownInkWell(
              borderRadius: BorderRadius.circular(widget.compact ? 26 : 32),
              onTap: widget.disabled ? null : widget.onTap,
              child: Stack(
                children: [
                  Positioned(
                    right: 16,
                    top: 16,
                    child: Container(
                      width: widget.compact ? 30 : 38,
                      height: widget.compact ? 30 : 38,
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
                        widget.symbol,
                        style: TextStyle(
                          fontSize: widget.compact ? 66 : 92,
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
    required this.category,
    required this.totalQuestions,
    required this.correctCount,
    required this.onRestart,
  });

  final LessonCategoryConfig category;
  final int totalQuestions;
  final int correctCount;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final sticker = earnedSticker(correctCount, totalQuestions);

    return Center(
      child: SizedBox(
        width: 560,
        child: ToyPanel(
          backgroundColor: KidPalette.creamWarm,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    MascotView(
                      key: const Key('quiz-summary-mascot'),
                      state: sticker
                          ? MascotState.missionClear
                          : MascotState.idle,
                      size: 160,
                    ),
                    if (sticker)
                      const Positioned(
                        top: 0,
                        right: 48,
                        child: _VictorySticker(
                          key: Key('quiz-summary-sticker'),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                category.quizSummaryTitle,
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
                sticker
                    ? category.quizStickerCopy
                    : category.quizStickerMissedCopy,
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

class _QuizLoadError extends StatelessWidget {
  const _QuizLoadError({required this.message, required this.onRetry});

  final String message;
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

class _VictorySticker extends StatefulWidget {
  const _VictorySticker({super.key});

  @override
  State<_VictorySticker> createState() => _VictoryStickerState();
}

class _VictoryStickerState extends State<_VictorySticker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _wiggle;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.55, curve: Curves.elasticOut),
    );
    _wiggle = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 1, curve: Curves.easeInOut),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final angle = (_wiggle.value * 2 - 1) * 0.08;
        return Transform.rotate(
          angle: angle,
          child: Transform.scale(
            scale: _scale.value,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: KidPalette.yellow,
                shape: BoxShape.circle,
                border: Border.all(
                  color: KidPalette.white,
                  width: 4,
                ),
                boxShadow: KidShadows.button,
              ),
              child: const Icon(
                Icons.star_rounded,
                color: KidPalette.coralDark,
                size: 60,
              ),
            ),
          ),
        );
      },
    );
  }
}
