import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/services/app_services.dart';
import '../../../app/services/progress_store.dart';
import '../../../app/ui/kid_theme.dart';
import '../../../app/ui/playground_scaffold.dart';
import '../../../app/ui/toy_button.dart';
import '../../../app/ui/toy_panel.dart';
import '../domain/avatar_expression.dart';

class AvatarSetupScreen extends StatefulWidget {
  const AvatarSetupScreen({super.key});

  @override
  State<AvatarSetupScreen> createState() => _AvatarSetupScreenState();
}

class _AvatarSetupScreenState extends State<AvatarSetupScreen> {
  Future<AppProgressSnapshot>? _snapshotFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _snapshotFuture ??= _loadSnapshot();
  }

  Future<AppProgressSnapshot> _loadSnapshot() {
    return AppServicesScope.of(context).progressStore.loadSnapshot();
  }

  Future<void> _refreshSnapshot() async {
    setState(() {
      _snapshotFuture = _loadSnapshot();
    });
  }

  Future<void> _toggleVoicePrompts(bool enabled) async {
    await AppServicesScope.of(context).progressStore.setVoicePromptsEnabled(
      enabled,
    );
    await _refreshSnapshot();
  }

  Future<void> _toggleEffects(bool enabled) async {
    await AppServicesScope.of(context).progressStore.setEffectsEnabled(enabled);
    await _refreshSnapshot();
  }

  Future<void> _resetProgress() async {
    final services = AppServicesScope.of(context);
    await services.speechCueService.stop();
    await services.progressStore.reset();
    await _refreshSnapshot();
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
    await _refreshSnapshot();
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
    await _refreshSnapshot();
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
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
                child: FutureBuilder<AppProgressSnapshot>(
                  future: _snapshotFuture,
                  builder: (context, snapshot) {
                    final progress = snapshot.data ?? const AppProgressSnapshot();
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          ToyPanel(
                            backgroundColor: KidPalette.white.withValues(alpha: 0.95),
                            padding: EdgeInsets.all(compact ? 14 : 20),
                            child: Wrap(
                              spacing: compact ? 10 : 14,
                              runSpacing: compact ? 10 : 14,
                              children: [
                                for (final expression in AvatarExpression.values)
                                  SizedBox(
                                    width: compact ? 206 : 220,
                                    child: _ExpressionCard(expression: expression),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(height: compact ? 10 : 14),
                          _ParentSummaryPanel(
                            compact: compact,
                            snapshot: progress,
                          ),
                          SizedBox(height: compact ? 10 : 14),
                          _ParentLessonManagementPanel(
                            compact: compact,
                            snapshot: progress,
                            onAdjustLessonIndex: _adjustLessonIndex,
                            onClearLessonMistakes: _clearLessonMistakes,
                          ),
                          SizedBox(height: compact ? 10 : 14),
                          ToyPanel(
                            backgroundColor: KidPalette.lilac.withValues(alpha: 0.72),
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
  });

  final bool compact;
  final AppProgressSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final mistakeCount = snapshot.lessons.values
        .expand((lesson) => lesson.recentMistakes)
        .toSet()
        .length;

    return ToyPanel(
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
            ],
          ),
        ],
      ),
    );
  }
}

typedef _LessonIndexAdjustCallback = Future<void> Function(
  String lessonId,
  int delta,
);
typedef _LessonActionCallback = Future<void> Function(String lessonId);

class _ParentLessonManagementPanel extends StatelessWidget {
  const _ParentLessonManagementPanel({
    required this.compact,
    required this.snapshot,
    required this.onAdjustLessonIndex,
    required this.onClearLessonMistakes,
  });

  final bool compact;
  final AppProgressSnapshot snapshot;
  final _LessonIndexAdjustCallback onAdjustLessonIndex;
  final _LessonActionCallback onClearLessonMistakes;

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
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: KidPalette.navy,
            ),
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

class _LessonManagementCard extends StatelessWidget {
  const _LessonManagementCard({
    required this.compact,
    required this.lessonId,
    required this.metadata,
    required this.progress,
    required this.onAdjustLessonIndex,
    required this.onClearLessonMistakes,
  });

  final bool compact;
  final String lessonId;
  final _LessonMetadata metadata;
  final LessonProgress progress;
  final _LessonIndexAdjustCallback onAdjustLessonIndex;
  final _LessonActionCallback onClearLessonMistakes;

  @override
  Widget build(BuildContext context) {
    final currentStep = (progress.lastViewedIndex + 1).clamp(1, metadata.cardCount);
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
              _LessonMetricChip(
                label: '최고 점수',
                value: bestScoreLabel,
              ),
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
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: KidPalette.body,
              ),
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

class _ExpressionCard extends StatelessWidget {
  const _ExpressionCard({required this.expression});

  final AvatarExpression expression;

  @override
  Widget build(BuildContext context) {
    return ToyPanel(
      padding: const EdgeInsets.all(14),
      backgroundColor: KidPalette.creamWarm,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 210;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: KidPalette.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      expression.label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: KidPalette.coralDark,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.add_a_photo_rounded,
                    color: KidPalette.navy.withValues(alpha: 0.7),
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: KidPalette.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: EdgeInsets.all(compact ? 12 : 16),
                child: compact
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 68,
                            child: Image.asset(
                              'assets/generated/images/hero/hero_face.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            expression.shortPrompt,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: KidPalette.navy,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '아직 넣지 않았어요',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: KidPalette.body,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 88,
                              child: Image.asset(
                                'assets/generated/images/hero/hero_face.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  expression.shortPrompt,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: KidPalette.navy,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '아직 넣지 않았어요',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: KidPalette.body,
                                  ),
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
      ),
    );
  }
}

class _LessonMetadata {
  const _LessonMetadata({
    required this.lessonId,
    required this.categoryLabel,
    required this.title,
    required this.cardCount,
    required this.color,
    required this.sortOrder,
  });

  final String lessonId;
  final String categoryLabel;
  final String title;
  final int cardCount;
  final Color color;
  final int sortOrder;
}

const List<_LessonMetadata> _knownLessonMetadata = [
  _LessonMetadata(
    lessonId: 'hangul:basic_consonants_1',
    categoryLabel: '한글 차고',
    title: '기본 자음 1',
    cardCount: 5,
    color: KidPalette.yellowDark,
    sortOrder: 0,
  ),
  _LessonMetadata(
    lessonId: 'alphabet:alphabet_letters_1',
    categoryLabel: '알파벳 차고',
    title: '알파벳 1',
    cardCount: 5,
    color: KidPalette.blue,
    sortOrder: 1,
  ),
  _LessonMetadata(
    lessonId: 'numbers:numbers_count_1',
    categoryLabel: '숫자 차고',
    title: '숫자 1',
    cardCount: 5,
    color: KidPalette.coralDark,
    sortOrder: 2,
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
