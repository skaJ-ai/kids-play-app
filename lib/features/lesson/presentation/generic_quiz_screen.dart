import 'package:flutter/material.dart';

import '../../../app/services/app_services.dart';
import '../../../app/ui/answer_feedback_overlay.dart';
import '../../../app/ui/audio_prompt_panel.dart';
import '../../../app/ui/kid_theme.dart';
import '../../../app/ui/playground_scaffold.dart';
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
      isMistakeReplay: widget.mistakeSymbols?.isNotEmpty ?? false,
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
              child: Text(widget.notEnoughItemsMessage ?? '퀴즈 문제가 아직 부족해요.'),
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
                        widget.category.quizPromptHeadline,
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
                      if (!isTight) ...[
                        SizedBox(height: isCompact ? 4 : 8),
                        Text(
                          widget.category.quizInstruction,
                          textAlign: TextAlign.center,
                          style:
                              (isCompact
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
                                      displayName: question.spoken,
                                      prompt: widget.category.promptFor(
                                        question.spoken,
                                      ),
                                      symbol: question.display,
                                      onReplay: controller.replayPrompt,
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        AudioPromptPanel(
                                          key: const Key('quiz-prompt-panel'),
                                          badge: '문제 듣기',
                                          title: widget.category.promptFor(
                                            question.spoken,
                                          ),
                                          subtitle: isCompact
                                              ? '스피커를 눌러 다시 들어봐요.'
                                              : '스피커를 누르면 문제를 다시 들을 수 있어요.',
                                          onReplay: controller.replayPrompt,
                                          compact: isCompact,
                                        ),
                                        SizedBox(height: isCompact ? 10 : 14),
                                        Expanded(
                                          child: ToyPanel(
                                            padding: EdgeInsets.all(
                                              isCompact ? 14 : 24,
                                            ),
                                            backgroundColor: KidPalette.white
                                                .withValues(alpha: 0.94),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: isCompact
                                                        ? 12
                                                        : 14,
                                                    vertical: isCompact ? 6 : 8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: KidPalette.creamWarm,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          999,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    widget
                                                        .category
                                                        .quizTargetBadge,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleSmall
                                                        ?.copyWith(
                                                          color: KidPalette
                                                              .coralDark,
                                                          fontWeight:
                                                              FontWeight.w900,
                                                        ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: isCompact ? 8 : 12,
                                                ),
                                                Text(
                                                  question.spoken,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style:
                                                      (isCompact
                                                              ? Theme.of(
                                                                      context,
                                                                    )
                                                                    .textTheme
                                                                    .titleSmall
                                                              : Theme.of(
                                                                      context,
                                                                    )
                                                                    .textTheme
                                                                    .titleMedium)
                                                          ?.copyWith(
                                                            color: KidPalette
                                                                .coralDark,
                                                            fontWeight:
                                                                FontWeight.w900,
                                                          ),
                                                ),
                                                SizedBox(
                                                  height: isCompact ? 6 : 10,
                                                ),
                                                Expanded(
                                                  child: Center(
                                                    child: FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      child: Text(
                                                        question.display,
                                                        style: TextStyle(
                                                          fontSize: isCompact
                                                              ? 86
                                                              : 118,
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          color:
                                                              KidPalette.navy,
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
                            SizedBox(
                              width: isTight ? 10 : (isCompact ? 14 : 18),
                            ),
                            Expanded(
                              flex: 5,
                              child: LayoutBuilder(
                                builder: (context, gridConstraints) {
                                  const crossAxisCount = 2;
                                  final mainAxisSpacing = isTight ? 12.0 : 16.0;
                                  final crossAxisSpacing = isTight
                                      ? 12.0
                                      : 16.0;
                                  final rowCount =
                                      (choices.length / crossAxisCount).ceil();
                                  final tileWidth =
                                      (gridConstraints.maxWidth -
                                          crossAxisSpacing) /
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
                                          onTap: () => controller.selectChoice(
                                            choices[i],
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
      tone: ToyPanelTone.warm,
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
          tone: ToyPanelTone.warm,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                category.quizSummaryTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 18),
              Text(
                '$totalQuestions문제 중 $correctCount문제 맞았어요!',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: KidPalette.navy),
              ),
              const SizedBox(height: 14),
              Text(
                sticker
                    ? category.quizStickerCopy
                    : category.quizStickerMissedCopy,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: KidPalette.coralDark),
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
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: KidPalette.navy),
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
