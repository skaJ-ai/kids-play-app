import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/services/app_services.dart';
import '../../../app/services/progress_store.dart';
import '../../../app/ui/kid_theme.dart';
import '../../../app/ui/playground_scaffold.dart';
import '../../../app/ui/toy_button.dart';
import '../../../app/ui/toy_panel.dart';
import '../../alphabet/presentation/alphabet_quiz_screen.dart';
import '../../hangul/presentation/hangul_quiz_screen.dart';
import '../../numbers/presentation/numbers_quiz_screen.dart';
import '../domain/avatar_expression.dart';
import '../domain/avatar_photo_snapshot.dart';
import 'avatar_crop_screen.dart';
import 'widgets/avatar_expression_card.dart';

typedef LessonRetryRouteOpener =
    Future<void> Function(
      BuildContext context,
      String lessonId,
      List<String> mistakes,
    );

class AvatarSetupScreen extends StatefulWidget {
  const AvatarSetupScreen({super.key, this.onOpenLessonRetry});

  final LessonRetryRouteOpener? onOpenLessonRetry;

  @override
  State<AvatarSetupScreen> createState() => _AvatarSetupScreenState();
}

class _AvatarSetupScreenState extends State<AvatarSetupScreen> {
  Future<_AvatarSetupViewData>? _screenDataFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _screenDataFuture ??= _loadScreenData();
  }

  Future<_AvatarSetupViewData> _loadScreenData() async {
    final services = AppServicesScope.of(context);
    final progressFuture = services.progressStore.loadSnapshot();
    final avatarPhotoFuture = services.avatarPhotoService.loadSnapshot();

    return _AvatarSetupViewData(
      progress: await progressFuture,
      avatarPhotos: await avatarPhotoFuture,
    );
  }

  Future<void> _refreshScreenData() async {
    setState(() {
      _screenDataFuture = _loadScreenData();
    });
  }

  Future<void> _toggleVoicePrompts(bool enabled) async {
    await AppServicesScope.of(
      context,
    ).progressStore.setVoicePromptsEnabled(enabled);
    await _refreshScreenData();
  }

  Future<void> _toggleEffects(bool enabled) async {
    await AppServicesScope.of(context).progressStore.setEffectsEnabled(enabled);
    await _refreshScreenData();
  }

  Future<void> _toggleBgm(bool enabled) async {
    await AppServicesScope.of(context).progressStore.setBgmEnabled(enabled);
    await _refreshScreenData();
  }

  Future<void> _resetProgress() async {
    final services = AppServicesScope.of(context);
    await services.speechCueService.stop();
    await services.progressStore.reset();
    await _refreshScreenData();
  }

  Future<void> _adjustLessonIndex(String lessonId, int delta) async {
    final services = AppServicesScope.of(context);
    final snapshot = await services.progressStore.loadSnapshot();
    final current = snapshot.progressFor(lessonId);
    final metadata = _lessonMetadataFor(lessonId);
    final nextIndex = (current.lastViewedIndex + delta).clamp(
      0,
      metadata.cardCount - 1,
    );

    if (nextIndex == current.lastViewedIndex) {
      return;
    }

    await services.progressStore.recordLessonIndex(
      lessonId: lessonId,
      lastViewedIndex: nextIndex,
    );
    await _refreshScreenData();
  }

  Future<void> _setLessonUnlocked(String lessonId, bool unlocked) async {
    await AppServicesScope.of(
      context,
    ).progressStore.setLessonUnlocked(lessonId, unlocked);
    await _refreshScreenData();
  }

  Future<void> _clearLessonMistakes(String lessonId) async {
    final services = AppServicesScope.of(context);
    final snapshot = await services.progressStore.loadSnapshot();
    final current = snapshot.progressFor(lessonId);
    if (current.recentMistakes.isEmpty) {
      return;
    }

    final totalQuestions = current.totalQuestions == 0
        ? _lessonMetadataFor(lessonId).cardCount
        : current.totalQuestions;

    await services.progressStore.recordQuizResult(
      lessonId: lessonId,
      correctCount: current.bestScore,
      totalQuestions: totalQuestions,
      recentMistakes: const [],
    );
    await _refreshScreenData();
  }

  Future<void> _openLessonRetry(String lessonId, List<String> mistakes) async {
    if (mistakes.isEmpty) {
      return;
    }

    final services = AppServicesScope.of(context);
    final snapshot = await services.progressStore.loadSnapshot();
    final current = snapshot.progressFor(lessonId);
    final reviewIndex = _lessonMetadataFor(lessonId).reviewStartIndexFor(
      mistakes.first,
      fallbackIndex: current.lastViewedIndex,
    );
    await services.progressStore.recordLessonIndex(
      lessonId: lessonId,
      lastViewedIndex: reviewIndex,
    );
    await _refreshScreenData();
    if (!mounted) {
      return;
    }

    final opener = widget.onOpenLessonRetry;
    if (opener != null) {
      await opener(context, lessonId, mistakes);
      return;
    }

    final destination = _buildLessonRetryScreen(lessonId, mistakes);
    if (destination == null) {
      return;
    }

    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => destination));
  }

  Future<void> _importExpressionPhoto(AvatarExpression expression) async {
    final services = AppServicesScope.of(context);
    final sourceBytes = await services.avatarPhotoPicker.pickFromGallery();
    if (sourceBytes == null || sourceBytes.isEmpty) {
      return;
    }

    if (!mounted) {
      return;
    }

    final croppedBytes = await Navigator.of(context).push<Uint8List>(
      MaterialPageRoute<Uint8List>(
        builder: (_) =>
            AvatarCropScreen(expression: expression, sourceBytes: sourceBytes),
      ),
    );
    if (croppedBytes == null || croppedBytes.isEmpty) {
      return;
    }

    await services.avatarPhotoService.saveExpressionPhoto(
      expression: expression,
      bytes: croppedBytes,
    );
    if (!mounted) {
      return;
    }

    await _refreshScreenData();
  }

  Future<void> _clearExpressionPhoto(AvatarExpression expression) async {
    await AppServicesScope.of(
      context,
    ).avatarPhotoService.clearExpression(expression);
    if (!mounted) {
      return;
    }

    await _refreshScreenData();
  }

  Future<void> _exitApp() async {
    await SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PlaygroundScaffold(
      showRoad: true,
      child: LayoutBuilder(
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
                      vertical: compact ? 8 : 10,
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
                          Icons.lock_rounded,
                          color: KidPalette.coralDark,
                          size: compact ? 18 : 22,
                        ),
                        SizedBox(width: compact ? 6 : 8),
                        Text(
                          '부모 설정',
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
                  if (!compact)
                    Text(
                      '아이 얼굴 표정과 앱 설정을 함께 준비해요',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: KidPalette.coralDark,
                      ),
                    ),
                ],
              ),
              SizedBox(height: compact ? 12 : 18),
              Text(
                '표정 카드 만들기',
                textAlign: TextAlign.center,
                style: compact
                    ? Theme.of(context).textTheme.headlineSmall
                    : Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: compact ? 8 : 10),
              Text(
                '보통부터 놀람까지 5개 표정을 넣으면 더 다양한 반응을 만들 수 있어요.',
                textAlign: TextAlign.center,
                maxLines: compact ? 2 : 3,
                overflow: TextOverflow.ellipsis,
                style: compact
                    ? Theme.of(context).textTheme.titleSmall
                    : Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: compact ? 12 : 18),
              Expanded(
                child: FutureBuilder<_AvatarSetupViewData>(
                  future: _screenDataFuture,
                  builder: (context, snapshot) {
                    final screenData =
                        snapshot.data ?? const _AvatarSetupViewData();
                    final progress = screenData.progress;
                    final avatarPhotos = screenData.avatarPhotos;
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          ToyPanel(
                            backgroundColor: KidPalette.white.withValues(
                              alpha: 0.95,
                            ),
                            padding: EdgeInsets.all(compact ? 14 : 20),
                            child: Wrap(
                              spacing: compact ? 10 : 14,
                              runSpacing: compact ? 10 : 14,
                              children: [
                                for (final expression
                                    in AvatarExpression.values)
                                  SizedBox(
                                    width: compact ? 206 : 220,
                                    child: AvatarExpressionCard(
                                      key: Key(
                                        'avatar-card-${expression.name}',
                                      ),
                                      expression: expression,
                                      hasSavedPhoto:
                                          avatarPhotos.entryFor(expression) !=
                                          null,
                                      onImportPressed: () =>
                                          _importExpressionPhoto(expression),
                                      onClearPressed: () =>
                                          _clearExpressionPhoto(expression),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(height: compact ? 10 : 14),
                          _ParentSummaryPanel(
                            compact: compact,
                            snapshot: progress,
                            onOpenLessonRetry: _openLessonRetry,
                          ),
                          SizedBox(height: compact ? 10 : 14),
                          _ParentLessonManagementPanel(
                            compact: compact,
                            snapshot: progress,
                            onAdjustLessonIndex: _adjustLessonIndex,
                            onClearLessonMistakes: _clearLessonMistakes,
                            onOpenLessonRetry: _openLessonRetry,
                          ),
                          SizedBox(height: compact ? 10 : 14),
                          _ParentLessonUnlockPanel(
                            compact: compact,
                            snapshot: progress,
                            onSetLessonUnlocked: _setLessonUnlocked,
                          ),
                          SizedBox(height: compact ? 10 : 14),
                          ToyPanel(
                            backgroundColor: KidPalette.lilac.withValues(
                              alpha: 0.72,
                            ),
                            padding: EdgeInsets.all(compact ? 14 : 18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '부모님 제어',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: KidPalette.coralDark,
                                        fontWeight: FontWeight.w900,
                                      ),
                                ),
                                SizedBox(height: compact ? 10 : 12),
                                Wrap(
                                  spacing: compact ? 10 : 12,
                                  runSpacing: compact ? 10 : 12,
                                  children: [
                                    SizedBox(
                                      width: compact ? 188 : 220,
                                      child: ToyButton(
                                        label: progress.voicePromptsEnabled
                                            ? '음성 안내 켜짐'
                                            : '음성 안내 꺼짐',
                                        icon: Icons.record_voice_over_rounded,
                                        height: compact ? 56 : 66,
                                        onPressed: () => _toggleVoicePrompts(
                                          !progress.voicePromptsEnabled,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: compact ? 188 : 220,
                                      child: ToyButton(
                                        label: progress.effectsEnabled
                                            ? '피드백 효과 켜짐'
                                            : '피드백 효과 꺼짐',
                                        icon: Icons.auto_awesome_rounded,
                                        height: compact ? 56 : 66,
                                        colors: const [
                                          KidPalette.mint,
                                          KidPalette.mintDark,
                                        ],
                                        onPressed: () => _toggleEffects(
                                          !progress.effectsEnabled,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: compact ? 188 : 220,
                                      child: ToyButton(
                                        label: progress.bgmEnabled
                                            ? '배경 음악 켜짐'
                                            : '배경 음악 꺼짐',
                                        icon: Icons.music_note_rounded,
                                        height: compact ? 56 : 66,
                                        onPressed: () => _toggleBgm(
                                          !progress.bgmEnabled,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: compact ? 188 : 220,
                                      child: ToyButton(
                                        label: '진도 초기화',
                                        icon: Icons.restart_alt_rounded,
                                        height: compact ? 56 : 66,
                                        colors: const [
                                          KidPalette.yellow,
                                          KidPalette.yellowDark,
                                        ],
                                        onPressed: _resetProgress,
                                      ),
                                    ),
                                    SizedBox(
                                      width: compact ? 188 : 220,
                                      child: ToyButton(
                                        label: compact ? '앱 종료' : '앱 종료하기',
                                        icon: Icons.exit_to_app_rounded,
                                        height: compact ? 56 : 66,
                                        colors: const [
                                          KidPalette.coral,
                                          KidPalette.coralDark,
                                        ],
                                        onPressed: _exitApp,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: compact ? 10 : 12),
                                Text(
                                  '먼저 보통/웃음 표정부터 넣고, 나머지 표정은 천천히 추가해도 괜찮아요.',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(color: KidPalette.navy),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: compact ? 10 : 14),
                          SizedBox(
                            width: compact ? 180 : 240,
                            child: ToyButton(
                              label: compact ? '나중에 하기' : '나중에 이어서 하기',
                              icon: Icons.check_circle_rounded,
                              height: compact ? 58 : 72,
                              onPressed: () => Navigator.of(context).maybePop(),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ParentSummaryPanel extends StatelessWidget {
  const _ParentSummaryPanel({
    required this.compact,
    required this.snapshot,
    required this.onOpenLessonRetry,
  });

  final bool compact;
  final AppProgressSnapshot snapshot;
  final Future<void> Function(String lessonId, List<String> mistakes)
  onOpenLessonRetry;

  @override
  Widget build(BuildContext context) {
    final mistakeCount = snapshot.lessons.values
        .expand((lesson) => lesson.recentMistakes)
        .toSet()
        .length;
    final mistakeReplayCount = snapshot.lessons.values.fold<int>(
      0,
      (total, lesson) => total + lesson.mistakeReplayCount,
    );
    final recentReward = snapshot.lastEarnedReward;
    final recentRewardLesson = recentReward == null
        ? null
        : _lessonMetadataFor(recentReward.lessonId);
    final mostConfusingLesson = _mostConfusingLessonMetadataFor(snapshot);
    final mostConfusingLessonMistakes = mostConfusingLesson == null
        ? const <String>[]
        : snapshot.progressFor(mostConfusingLesson.lessonId).recentMistakes;

    return ToyPanel(
      key: const Key('parent-summary-panel'),
      backgroundColor: KidPalette.white.withValues(alpha: 0.95),
      padding: EdgeInsets.all(compact ? 14 : 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '현재 진행 요약',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: KidPalette.coralDark,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: compact ? 10 : 12),
          Wrap(
            spacing: compact ? 10 : 12,
            runSpacing: compact ? 10 : 12,
            children: [
              _SummaryChip(
                label: '자동차 스티커',
                value: '${snapshot.stickerCount}개',
                color: KidPalette.yellow,
              ),
              _SummaryChip(
                label: '기록된 세트',
                value: '${snapshot.lessons.length}개',
                color: KidPalette.mint,
              ),
              _SummaryChip(
                label: '최근 헷갈림',
                value: '$mistakeCount개',
                color: KidPalette.lilac,
              ),
              _SummaryChip(
                label: '오답 다시 보기',
                value: '$mistakeReplayCount번',
                color: KidPalette.blue,
              ),
              KeyedSubtree(
                key: const Key('parent-summary-replay-reward-chip'),
                child: _SummaryChip(
                  label: '다시 풀기 보상',
                  value: snapshot.replayRewardStickerCountTracked
                      ? '${snapshot.replayRewardStickerCount}개'
                      : '새로 집계',
                  color: KidPalette.coral,
                ),
              ),
            ],
          ),
          if (recentReward != null && recentRewardLesson != null) ...[
            SizedBox(height: compact ? 10 : 12),
            Container(
              key: const Key('parent-summary-reward-callout'),
              width: double.infinity,
              padding: EdgeInsets.all(compact ? 12 : 14),
              decoration: BoxDecoration(
                color: KidPalette.yellow.withValues(alpha: 0.26),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: KidPalette.yellowDark.withValues(alpha: 0.16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        color: KidPalette.coralDark,
                        size: compact ? 18 : 20,
                      ),
                      SizedBox(width: compact ? 6 : 8),
                      Expanded(
                        child: Text(
                          '최근 받은 보상',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: KidPalette.navy,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: compact ? 8 : 10),
                  Text(
                    _recentRewardAmountLabel(recentReward),
                    key: const Key('parent-summary-reward-amount'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: KidPalette.navy,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: compact ? 8 : 10),
                  Wrap(
                    spacing: compact ? 10 : 12,
                    runSpacing: compact ? 10 : 12,
                    children: [
                      KeyedSubtree(
                        key: const Key('parent-summary-reward-category'),
                        child: _LessonMetricChip(
                          label: '카테고리',
                          value: recentRewardLesson.categoryLabel,
                        ),
                      ),
                      KeyedSubtree(
                        key: const Key('parent-summary-reward-lesson'),
                        child: _LessonMetricChip(
                          label: '세트',
                          value: recentRewardLesson.title,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: compact ? 10 : 12),
          Container(
            key: const Key('parent-summary-confusion-callout'),
            width: double.infinity,
            padding: EdgeInsets.all(compact ? 12 : 14),
            decoration: BoxDecoration(
              color: KidPalette.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: KidPalette.navy.withValues(alpha: 0.12),
              ),
            ),
            child: mostConfusingLesson == null
                ? Text(
                    '지금은 헷갈린 세트가 없어요.',
                    key: const Key('parent-summary-confusion-fallback'),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: KidPalette.navy,
                      fontWeight: FontWeight.w800,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_rounded,
                            color: KidPalette.coralDark,
                            size: compact ? 18 : 20,
                          ),
                          SizedBox(width: compact ? 6 : 8),
                          Expanded(
                            child: Text(
                              '다음에 먼저 같이 보면 좋아요.',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    color: KidPalette.navy,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: compact ? 8 : 10),
                      Wrap(
                        spacing: compact ? 10 : 12,
                        runSpacing: compact ? 10 : 12,
                        children: [
                          KeyedSubtree(
                            key: const Key('parent-summary-confusion-category'),
                            child: _LessonMetricChip(
                              label: '카테고리',
                              value: mostConfusingLesson.categoryLabel,
                            ),
                          ),
                          KeyedSubtree(
                            key: const Key('parent-summary-confusion-lesson'),
                            child: _LessonMetricChip(
                              label: '세트',
                              value: mostConfusingLesson.title,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: compact ? 8 : 10),
                      _ParentMiniActionButton(
                        key: const Key('parent-summary-confusion-retry'),
                        label: '이 세트 다시 보기',
                        icon: Icons.refresh_rounded,
                        color: KidPalette.blue,
                        onPressed: () => onOpenLessonRetry(
                          mostConfusingLesson.lessonId,
                          mostConfusingLessonMistakes,
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

typedef _LessonIndexAdjustCallback =
    Future<void> Function(String lessonId, int delta);
typedef _LessonActionCallback = Future<void> Function(String lessonId);
typedef _LessonRetryCallback =
    Future<void> Function(String lessonId, List<String> mistakes);
typedef _LessonUnlockCallback =
    Future<void> Function(String lessonId, bool unlocked);

class _ParentLessonManagementPanel extends StatelessWidget {
  const _ParentLessonManagementPanel({
    required this.compact,
    required this.snapshot,
    required this.onAdjustLessonIndex,
    required this.onClearLessonMistakes,
    required this.onOpenLessonRetry,
  });

  final bool compact;
  final AppProgressSnapshot snapshot;
  final _LessonIndexAdjustCallback onAdjustLessonIndex;
  final _LessonActionCallback onClearLessonMistakes;
  final _LessonRetryCallback onOpenLessonRetry;

  @override
  Widget build(BuildContext context) {
    final lessonIds = snapshot.lessons.keys.toList(growable: false)
      ..sort((a, b) {
        final left = _lessonMetadataFor(a).sortOrder;
        final right = _lessonMetadataFor(b).sortOrder;
        if (left != right) {
          return left.compareTo(right);
        }
        return a.compareTo(b);
      });

    return ToyPanel(
      backgroundColor: KidPalette.white.withValues(alpha: 0.95),
      padding: EdgeInsets.all(compact ? 14 : 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '세트별 진도 조절',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: KidPalette.coralDark,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: compact ? 8 : 10),
          Text(
            lessonIds.isEmpty
                ? '아직 기록된 세트가 없어요. 놀이를 시작하면 여기서 진도를 조절할 수 있어요.'
                : '카드 진도를 앞뒤로 옮기고, 헷갈린 글자를 바로 정리할 수 있어요.',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: KidPalette.navy),
          ),
          if (lessonIds.isNotEmpty) ...[
            SizedBox(height: compact ? 10 : 14),
            for (var i = 0; i < lessonIds.length; i++) ...[
              _LessonManagementCard(
                compact: compact,
                lessonId: lessonIds[i],
                metadata: _lessonMetadataFor(lessonIds[i]),
                progress: snapshot.progressFor(lessonIds[i]),
                onAdjustLessonIndex: onAdjustLessonIndex,
                onClearLessonMistakes: onClearLessonMistakes,
                onOpenLessonRetry: onOpenLessonRetry,
              ),
              if (i != lessonIds.length - 1)
                SizedBox(height: compact ? 10 : 12),
            ],
          ],
        ],
      ),
    );
  }
}

class _ParentLessonUnlockPanel extends StatelessWidget {
  const _ParentLessonUnlockPanel({
    required this.compact,
    required this.snapshot,
    required this.onSetLessonUnlocked,
  });

  final bool compact;
  final AppProgressSnapshot snapshot;
  final _LessonUnlockCallback onSetLessonUnlocked;

  @override
  Widget build(BuildContext context) {
    final unlockTargets = _knownLessonMetadata
        .where((metadata) => !_isDefaultUnlockedLesson(metadata.lessonId))
        .toList(growable: false);

    return ToyPanel(
      backgroundColor: KidPalette.white.withValues(alpha: 0.95),
      padding: EdgeInsets.all(compact ? 14 : 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '다음 세트 미리 열기',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: KidPalette.coralDark,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: compact ? 8 : 10),
          Text(
            '첫 세트 뒤의 세트들은 부모가 미리 열어둘 수 있어요.',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(color: KidPalette.navy),
          ),
          SizedBox(height: compact ? 10 : 14),
          for (var i = 0; i < unlockTargets.length; i++) ...[
            _LessonUnlockCard(
              compact: compact,
              metadata: unlockTargets[i],
              unlocked: _isLessonUnlocked(snapshot, unlockTargets[i].lessonId),
              onPressed: () =>
                  onSetLessonUnlocked(unlockTargets[i].lessonId, true),
            ),
            if (i != unlockTargets.length - 1)
              SizedBox(height: compact ? 8 : 10),
          ],
        ],
      ),
    );
  }
}

class _LessonUnlockCard extends StatelessWidget {
  const _LessonUnlockCard({
    required this.compact,
    required this.metadata,
    required this.unlocked,
    required this.onPressed,
  });

  final bool compact;
  final _LessonMetadata metadata;
  final bool unlocked;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        color: metadata.color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metadata.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: KidPalette.navy,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: compact ? 6 : 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _LessonUnlockPill(
                      label: metadata.categoryLabel,
                      color: metadata.color,
                    ),
                    _LessonUnlockPill(
                      label: '${metadata.cardCount}개 카드',
                      color: KidPalette.blue,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: compact ? 10 : 12),
          FilledButton.icon(
            key: Key('lesson-unlock-${metadata.lessonId}'),
            onPressed: unlocked ? null : onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: unlocked ? KidPalette.mintDark : metadata.color,
              disabledBackgroundColor: KidPalette.mintDark,
              foregroundColor: KidPalette.white,
              disabledForegroundColor: KidPalette.white,
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 12 : 14,
                vertical: compact ? 10 : 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            icon: Icon(
              unlocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
              size: 18,
            ),
            label: Text(unlocked ? '열려 있어요' : '잠금 풀기'),
          ),
        ],
      ),
    );
  }
}

class _LessonUnlockPill extends StatelessWidget {
  const _LessonUnlockPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: KidPalette.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: color,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _LessonManagementCard extends StatelessWidget {
  const _LessonManagementCard({
    required this.compact,
    required this.lessonId,
    required this.metadata,
    required this.progress,
    required this.onAdjustLessonIndex,
    required this.onClearLessonMistakes,
    required this.onOpenLessonRetry,
  });

  final bool compact;
  final String lessonId;
  final _LessonMetadata metadata;
  final LessonProgress progress;
  final _LessonIndexAdjustCallback onAdjustLessonIndex;
  final _LessonActionCallback onClearLessonMistakes;
  final _LessonRetryCallback onOpenLessonRetry;

  @override
  Widget build(BuildContext context) {
    final currentStep = (progress.lastViewedIndex + 1).clamp(
      1,
      metadata.cardCount,
    );
    final bestScoreLabel = progress.totalQuestions > 0
        ? '${progress.bestScore} / ${progress.totalQuestions}'
        : '아직 기록 없음';

    return ToyPanel(
      key: Key('lesson-card-$lessonId'),
      backgroundColor: metadata.color.withValues(alpha: 0.22),
      padding: EdgeInsets.all(compact ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 10 : 12,
                  vertical: compact ? 6 : 8,
                ),
                decoration: BoxDecoration(
                  color: KidPalette.white.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  metadata.categoryLabel,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: metadata.color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                metadata.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: KidPalette.navy,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 10 : 12),
          Wrap(
            spacing: compact ? 10 : 12,
            runSpacing: compact ? 10 : 12,
            children: [
              _LessonMetricChip(
                label: '학습 진도',
                value: '$currentStep / ${metadata.cardCount}',
              ),
              _LessonMetricChip(label: '최고 점수', value: bestScoreLabel),
            ],
          ),
          SizedBox(height: compact ? 10 : 12),
          Text(
            '최근 헷갈린 글자',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: KidPalette.navy,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: compact ? 6 : 8),
          if (progress.recentMistakes.isEmpty)
            Text(
              '최근 헷갈림 없음',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: KidPalette.body),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final mistake in progress.recentMistakes)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: KidPalette.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      mistake,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: KidPalette.coralDark,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
              ],
            ),
          SizedBox(height: compact ? 10 : 12),
          Wrap(
            spacing: compact ? 8 : 10,
            runSpacing: compact ? 8 : 10,
            children: [
              _ParentMiniActionButton(
                key: Key('lesson-back-$lessonId'),
                label: '이전 카드',
                icon: Icons.remove_rounded,
                color: metadata.color,
                onPressed: progress.lastViewedIndex > 0
                    ? () => onAdjustLessonIndex(lessonId, -1)
                    : null,
              ),
              _ParentMiniActionButton(
                key: Key('lesson-forward-$lessonId'),
                label: '다음 카드',
                icon: Icons.add_rounded,
                color: metadata.color,
                onPressed: progress.lastViewedIndex < metadata.cardCount - 1
                    ? () => onAdjustLessonIndex(lessonId, 1)
                    : null,
              ),
              _ParentMiniActionButton(
                key: Key('lesson-retry-mistakes-$lessonId'),
                label: '헷갈림 다시 보기',
                icon: Icons.refresh_rounded,
                color: KidPalette.blue,
                onPressed: progress.recentMistakes.isNotEmpty
                    ? () => onOpenLessonRetry(lessonId, progress.recentMistakes)
                    : null,
              ),
              _ParentMiniActionButton(
                key: Key('lesson-clear-mistakes-$lessonId'),
                label: '오답 비우기',
                icon: Icons.cleaning_services_rounded,
                color: KidPalette.mintDark,
                onPressed: progress.recentMistakes.isNotEmpty
                    ? () => onClearLessonMistakes(lessonId)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LessonMetricChip extends StatelessWidget {
  const _LessonMetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: KidPalette.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: KidPalette.body,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: KidPalette.navy,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ParentMiniActionButton extends StatelessWidget {
  const _ParentMiniActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: color,
        disabledBackgroundColor: KidPalette.body.withValues(alpha: 0.22),
        foregroundColor: KidPalette.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: KidPalette.navy,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: KidPalette.navy,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarSetupViewData {
  const _AvatarSetupViewData({
    this.progress = const AppProgressSnapshot(),
    this.avatarPhotos = const AvatarPhotoSnapshot(),
  });

  final AppProgressSnapshot progress;
  final AvatarPhotoSnapshot avatarPhotos;
}

class _LessonMetadata {
  const _LessonMetadata({
    required this.lessonId,
    required this.categoryLabel,
    required this.title,
    required this.cardCount,
    required this.color,
    required this.sortOrder,
    this.cardSymbols = const [],
  });

  final String lessonId;
  final String categoryLabel;
  final String title;
  final int cardCount;
  final Color color;
  final int sortOrder;
  final List<String> cardSymbols;

  int reviewStartIndexFor(String symbol, {int fallbackIndex = 0}) {
    if (cardCount <= 0) {
      return 0;
    }

    final normalizedSymbol = symbol.trim();
    final matchIndex = cardSymbols.indexWhere(
      (candidate) => candidate == normalizedSymbol,
    );
    if (matchIndex >= 0) {
      return matchIndex;
    }

    return fallbackIndex.clamp(0, cardCount - 1).toInt();
  }
}

const List<_LessonMetadata> _knownLessonMetadata = [
  _LessonMetadata(
    lessonId: 'hangul:basic_consonants_1',
    categoryLabel: '한글 차고',
    title: '기본 자음 1',
    cardCount: 5,
    color: KidPalette.yellowDark,
    sortOrder: 0,
    cardSymbols: ['ㄱ', 'ㄴ', 'ㄷ', 'ㄹ', 'ㅁ'],
  ),
  _LessonMetadata(
    lessonId: 'hangul:basic_consonants_2',
    categoryLabel: '한글 차고',
    title: '기본 자음 2',
    cardCount: 5,
    color: KidPalette.yellowDark,
    sortOrder: 1,
    cardSymbols: ['ㅂ', 'ㅅ', 'ㅇ', 'ㅈ', 'ㅊ'],
  ),
  _LessonMetadata(
    lessonId: 'hangul:basic_consonants_3',
    categoryLabel: '한글 차고',
    title: '기본 자음 3',
    cardCount: 4,
    color: KidPalette.yellowDark,
    sortOrder: 2,
    cardSymbols: ['ㅋ', 'ㅌ', 'ㅍ', 'ㅎ'],
  ),
  _LessonMetadata(
    lessonId: 'hangul:tense_consonants_1',
    categoryLabel: '한글 차고',
    title: '된소리 1',
    cardCount: 5,
    color: KidPalette.yellowDark,
    sortOrder: 3,
    cardSymbols: ['ㄲ', 'ㄸ', 'ㅃ', 'ㅆ', 'ㅉ'],
  ),
  _LessonMetadata(
    lessonId: 'hangul:basic_vowels_1',
    categoryLabel: '한글 차고',
    title: '기본 모음 1',
    cardCount: 5,
    color: KidPalette.yellowDark,
    sortOrder: 4,
    cardSymbols: ['ㅏ', 'ㅑ', 'ㅓ', 'ㅕ', 'ㅗ'],
  ),
  _LessonMetadata(
    lessonId: 'hangul:basic_vowels_2',
    categoryLabel: '한글 차고',
    title: '기본 모음 2',
    cardCount: 5,
    color: KidPalette.yellowDark,
    sortOrder: 5,
    cardSymbols: ['ㅛ', 'ㅜ', 'ㅠ', 'ㅡ', 'ㅣ'],
  ),
  _LessonMetadata(
    lessonId: 'alphabet:alphabet_letters_1',
    categoryLabel: '알파벳 차고',
    title: '알파벳 1',
    cardCount: 5,
    color: KidPalette.blue,
    sortOrder: 10,
    cardSymbols: ['A a', 'B b', 'C c', 'D d', 'E e'],
  ),
  _LessonMetadata(
    lessonId: 'alphabet:alphabet_letters_2',
    categoryLabel: '알파벳 차고',
    title: '알파벳 2',
    cardCount: 5,
    color: KidPalette.blue,
    sortOrder: 11,
    cardSymbols: ['F f', 'G g', 'H h', 'I i', 'J j'],
  ),
  _LessonMetadata(
    lessonId: 'alphabet:alphabet_letters_3',
    categoryLabel: '알파벳 차고',
    title: '알파벳 3',
    cardCount: 5,
    color: KidPalette.blue,
    sortOrder: 12,
    cardSymbols: ['K k', 'L l', 'M m', 'N n', 'O o'],
  ),
  _LessonMetadata(
    lessonId: 'alphabet:alphabet_letters_4',
    categoryLabel: '알파벳 차고',
    title: '알파벳 4',
    cardCount: 5,
    color: KidPalette.blue,
    sortOrder: 13,
    cardSymbols: ['P p', 'Q q', 'R r', 'S s', 'T t'],
  ),
  _LessonMetadata(
    lessonId: 'alphabet:alphabet_letters_5',
    categoryLabel: '알파벳 차고',
    title: '알파벳 5',
    cardCount: 6,
    color: KidPalette.blue,
    sortOrder: 14,
    cardSymbols: ['U u', 'V v', 'W w', 'X x', 'Y y', 'Z z'],
  ),
  _LessonMetadata(
    lessonId: 'numbers:numbers_count_1',
    categoryLabel: '숫자 차고',
    title: '숫자 1부터 5까지',
    cardCount: 5,
    color: KidPalette.coralDark,
    sortOrder: 20,
    cardSymbols: ['1', '2', '3', '4', '5'],
  ),
  _LessonMetadata(
    lessonId: 'numbers:numbers_count_2',
    categoryLabel: '숫자 차고',
    title: '숫자 6부터 10까지',
    cardCount: 5,
    color: KidPalette.coralDark,
    sortOrder: 21,
    cardSymbols: ['6', '7', '8', '9', '10'],
  ),
  _LessonMetadata(
    lessonId: 'numbers:numbers_count_3',
    categoryLabel: '숫자 차고',
    title: '숫자 11부터 15까지',
    cardCount: 5,
    color: KidPalette.coralDark,
    sortOrder: 22,
    cardSymbols: ['11', '12', '13', '14', '15'],
  ),
  _LessonMetadata(
    lessonId: 'numbers:numbers_count_4',
    categoryLabel: '숫자 차고',
    title: '숫자 16부터 20까지',
    cardCount: 5,
    color: KidPalette.coralDark,
    sortOrder: 23,
    cardSymbols: ['16', '17', '18', '19', '20'],
  ),
];

_LessonMetadata _lessonMetadataFor(String lessonId) {
  for (final metadata in _knownLessonMetadata) {
    if (metadata.lessonId == lessonId) {
      return metadata;
    }
  }

  final parts = lessonId.split(':');
  final categoryKey = parts.length > 1 ? parts.first : 'custom';
  final rawLessonId = parts.length > 1 ? parts.last : lessonId;
  return _LessonMetadata(
    lessonId: lessonId,
    categoryLabel: _fallbackCategoryLabel(categoryKey),
    title: rawLessonId.replaceAll('_', ' '),
    cardCount: 5,
    color: KidPalette.navy,
    sortOrder: 99,
  );
}

String _recentRewardAmountLabel(RecentReward reward) {
  switch (reward.kind) {
    case rewardKindSticker:
      return '자동차 스티커 ${reward.amount}개';
    case rewardKindMistakeReplaySticker:
      return '오답 다시 풀기 자동차 스티커 ${reward.amount}개';
    default:
      return '보상 ${reward.amount}개';
  }
}

_LessonMetadata? _mostConfusingLessonMetadataFor(AppProgressSnapshot snapshot) {
  final lessonsWithMistakes = snapshot.lessons.entries
      .where((entry) => entry.value.recentMistakes.isNotEmpty)
      .toList(growable: false);
  if (lessonsWithMistakes.isEmpty) {
    return null;
  }

  lessonsWithMistakes.sort((a, b) {
    final mistakeCompare = b.value.recentMistakes.length.compareTo(
      a.value.recentMistakes.length,
    );
    if (mistakeCompare != 0) {
      return mistakeCompare;
    }

    final leftMetadata = _lessonMetadataFor(a.key);
    final rightMetadata = _lessonMetadataFor(b.key);
    final sortCompare = leftMetadata.sortOrder.compareTo(
      rightMetadata.sortOrder,
    );
    if (sortCompare != 0) {
      return sortCompare;
    }

    return a.key.compareTo(b.key);
  });

  return _lessonMetadataFor(lessonsWithMistakes.first.key);
}

String _fallbackCategoryLabel(String categoryKey) {
  switch (categoryKey) {
    case 'hangul':
      return '한글 차고';
    case 'alphabet':
      return '알파벳 차고';
    case 'numbers':
      return '숫자 차고';
    default:
      return '기타 차고';
  }
}

bool _isDefaultUnlockedLesson(String lessonId) {
  final categoryPrefix = '${lessonId.split(':').first}:';
  for (final metadata in _knownLessonMetadata) {
    if (metadata.lessonId.startsWith(categoryPrefix)) {
      return metadata.lessonId == lessonId;
    }
  }
  return false;
}

bool _isLessonUnlocked(AppProgressSnapshot snapshot, String lessonId) {
  return _isDefaultUnlockedLesson(lessonId) ||
      snapshot.unlockedLessonIds.contains(lessonId) ||
      snapshot.lessons.containsKey(lessonId);
}

Widget? _buildLessonRetryScreen(String lessonId, List<String> mistakes) {
  final lessonKey = lessonId.split(':').last;
  if (lessonId.startsWith('hangul:')) {
    return HangulQuizScreen(lessonId: lessonKey, mistakeSymbols: mistakes);
  }
  if (lessonId.startsWith('alphabet:')) {
    return AlphabetQuizScreen(lessonId: lessonKey, mistakeSymbols: mistakes);
  }
  if (lessonId.startsWith('numbers:')) {
    return NumbersQuizScreen(lessonId: lessonKey, mistakeSymbols: mistakes);
  }
  return null;
}
