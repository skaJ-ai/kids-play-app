import 'package:flutter/material.dart';

import '../../../app/services/app_services.dart';
import '../../../app/services/progress_store.dart';
import '../../../app/ui/kid_theme.dart';
import '../../../app/ui/playground_scaffold.dart';
import '../../../app/ui/tap_cooldown.dart';
import '../../../app/ui/toy_panel.dart';

class LessonPickerItem {
  const LessonPickerItem({
    required this.id,
    required this.title,
    required this.preview,
    required this.countLabel,
    required this.color,
    String? progressId,
    this.locked = false,
  }) : progressId = progressId ?? id;

  final String id;
  final String title;
  final String preview;
  final String countLabel;
  final Color color;
  final String progressId;
  final bool locked;

  LessonPickerItem copyWith({bool? locked}) {
    return LessonPickerItem(
      id: id,
      title: title,
      preview: preview,
      countLabel: countLabel,
      color: color,
      progressId: progressId,
      locked: locked ?? this.locked,
    );
  }
}

class AsyncLessonPickerScreen extends StatefulWidget {
  const AsyncLessonPickerScreen({
    super.key,
    required this.categoryLabel,
    required this.modeLabel,
    required this.loadItems,
    required this.buildDestination,
    required this.errorMessage,
    required this.emptyMessage,
  });

  final String categoryLabel;
  final String modeLabel;
  final Future<List<LessonPickerItem>> Function() loadItems;
  final Widget Function(String lessonId) buildDestination;
  final String errorMessage;
  final String emptyMessage;

  @override
  State<AsyncLessonPickerScreen> createState() =>
      _AsyncLessonPickerScreenState();
}

class _AsyncLessonPickerScreenState extends State<AsyncLessonPickerScreen> {
  late Future<List<LessonPickerItem>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _itemsFuture = widget.loadItems();
  }

  void _retry() {
    setState(() {
      _itemsFuture = widget.loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LessonPickerItem>>(
      future: _itemsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _LessonPickerError(
            message: widget.errorMessage,
            onRetry: _retry,
          );
        }

        if (!snapshot.hasData) {
          return const PlaygroundScaffold(
            showRoad: true,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final items = snapshot.data!;
        if (items.isEmpty) {
          return PlaygroundScaffold(
            showRoad: true,
            child: Center(
              child: Text(
                widget.emptyMessage,
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: KidPalette.navy),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return FutureBuilder<AppProgressSnapshot>(
          future: AppServicesScope.of(context).progressStore.loadSnapshot(),
          builder: (context, progressSnapshot) {
            if (progressSnapshot.hasError) {
              return _LessonPickerError(
                message: '세트 잠금 정보를 불러오지 못했어요.',
                onRetry: _retry,
              );
            }

            if (!progressSnapshot.hasData) {
              return const PlaygroundScaffold(
                showRoad: true,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final progress = progressSnapshot.data!;
            final resolvedItems = _resolveLockState(items, progress);
            if (resolvedItems.length == 1) {
              return widget.buildDestination(resolvedItems.first.id);
            }

            return LessonPickerScreen(
              categoryLabel: widget.categoryLabel,
              modeLabel: widget.modeLabel,
              items: resolvedItems,
              buildDestination: widget.buildDestination,
            );
          },
        );
      },
    );
  }

  List<LessonPickerItem> _resolveLockState(
    List<LessonPickerItem> items,
    AppProgressSnapshot progress,
  ) {
    final firstProgressId = items.first.progressId;
    return items
        .map(
          (item) => item.copyWith(
            locked:
                item.progressId != firstProgressId &&
                !progress.unlockedLessonIds.contains(item.progressId) &&
                !progress.lessons.containsKey(item.progressId),
          ),
        )
        .toList(growable: false);
  }
}

class LessonPickerScreen extends StatelessWidget {
  const LessonPickerScreen({
    super.key,
    required this.categoryLabel,
    required this.modeLabel,
    required this.items,
    required this.buildDestination,
  });

  final String categoryLabel;
  final String modeLabel;
  final List<LessonPickerItem> items;
  final Widget Function(String lessonId) buildDestination;

  @override
  Widget build(BuildContext context) {
    return PlaygroundScaffold(
      showRoad: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight <= 360;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _HeaderPill(
                    icon: Icons.menu_book_rounded,
                    label: '$categoryLabel $modeLabel',
                    compact: compact,
                  ),
                  const Spacer(),
                  if (!compact)
                    Text(
                      '원하는 세트를 골라요',
                      style: Theme.of(
                        context,
                      ).textTheme.titleSmall?.copyWith(color: KidPalette.body),
                    ),
                ],
              ),
              SizedBox(height: compact ? 12 : 18),
              Text(
                '$categoryLabel 세트 고르기',
                textAlign: TextAlign.center,
                style: compact
                    ? Theme.of(context).textTheme.headlineSmall
                    : Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: compact ? 6 : 10),
              Text(
                compact ? '할 세트를 콕 눌러요.' : '배울 세트나 퀴즈 세트를 골라 바로 시작해요.',
                textAlign: TextAlign.center,
                style: compact
                    ? Theme.of(context).textTheme.titleSmall
                    : Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: compact ? 14 : 20),
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, separatorIndex) =>
                      SizedBox(height: compact ? 10 : 12),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _LessonCard(
                      item: item,
                      compact: compact,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => buildDestination(item.id),
                          ),
                        );
                      },
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

class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.item,
    required this.compact,
    required this.onTap,
  });

  final LessonPickerItem item;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final panelColor = Color.lerp(
      item.color,
      KidPalette.white,
      item.locked ? 0.82 : 0.72,
    )!;
    final accentColor = item.locked
        ? Color.lerp(item.color, KidPalette.body, 0.45)!
        : item.color;
    final titleColor = item.locked ? KidPalette.body : KidPalette.navy;

    return Material(
      color: Colors.transparent,
      child: CooldownInkWell(
        key: Key('lesson-picker-item-${item.id}'),
        borderRadius: BorderRadius.circular(28),
        onTap: item.locked ? null : onTap,
        child: ToyPanel(
          padding: EdgeInsets.all(compact ? 14 : 18),
          backgroundColor: panelColor,
          borderColor: item.locked
              ? KidPalette.stroke.withValues(alpha: 0.82)
              : KidPalette.white.withValues(alpha: 0.82),
          child: Row(
            children: [
              Container(
                width: compact ? 56 : 68,
                height: compact ? 56 : 68,
                decoration: BoxDecoration(
                  color: KidPalette.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(compact ? 18 : 22),
                  boxShadow: KidShadows.panel,
                ),
                child: Icon(
                  item.locked ? Icons.lock_rounded : Icons.auto_stories_rounded,
                  color: accentColor,
                  size: compact ? 28 : 34,
                ),
              ),
              SizedBox(width: compact ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          (compact
                                  ? Theme.of(context).textTheme.titleLarge
                                  : Theme.of(context).textTheme.headlineSmall)
                              ?.copyWith(
                                color: titleColor,
                                fontWeight: FontWeight.w900,
                              ),
                    ),
                    SizedBox(height: compact ? 4 : 6),
                    Text(
                      item.preview,
                      maxLines: compact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          (compact
                                  ? Theme.of(context).textTheme.titleSmall
                                  : Theme.of(context).textTheme.titleMedium)
                              ?.copyWith(
                                color: item.locked
                                    ? KidPalette.body
                                    : KidPalette.navy,
                              ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: compact ? 10 : 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 10 : 12,
                      vertical: compact ? 6 : 8,
                    ),
                    decoration: BoxDecoration(
                      color: KidPalette.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      item.countLabel,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  SizedBox(height: compact ? 8 : 10),
                  if (item.locked)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: compact ? 10 : 12,
                        vertical: compact ? 6 : 8,
                      ),
                      decoration: BoxDecoration(
                        color: KidPalette.coral.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lock_rounded,
                            color: KidPalette.coralDark,
                            size: compact ? 14 : 16,
                          ),
                          SizedBox(width: compact ? 4 : 6),
                          Text(
                            '잠겨 있어요',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: KidPalette.coralDark,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ],
                      ),
                    )
                  else
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: accentColor,
                      size: compact ? 22 : 26,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({
    required this.icon,
    required this.label,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: KidPalette.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: KidPalette.stroke),
        boxShadow: KidShadows.panel,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 16,
          vertical: compact ? 8 : 10,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: KidPalette.blue, size: compact ? 18 : 22),
            SizedBox(width: compact ? 6 : 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: KidPalette.navy,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonPickerError extends StatelessWidget {
  const _LessonPickerError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return PlaygroundScaffold(
      showRoad: true,
      child: Center(
        child: SizedBox(
          width: 440,
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
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('다시 시도'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
