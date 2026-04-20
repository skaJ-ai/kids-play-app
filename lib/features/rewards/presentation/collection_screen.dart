import 'package:flutter/material.dart';

import '../../../app/services/app_services.dart';
import '../../../app/services/progress_store.dart';
import '../../../app/ui/kid_theme.dart';
import '../../../app/ui/playground_scaffold.dart';
import '../../../app/ui/toy_panel.dart';
import '../../lesson/domain/lesson_category.dart';
import '../domain/reward_catalog.dart';
import '../domain/reward_models.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key, this.catalog = rewardCatalog});

  final List<RewardPack> catalog;

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  Future<AppProgressSnapshot>? _snapshotFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _snapshotFuture ??=
        AppServicesScope.of(context).progressStore.loadSnapshot();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PlaygroundScaffold(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight <= 360;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _BackPill(
                    onTap: () => Navigator.of(context).maybePop(),
                    compact: compact,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '내 스티커 모음',
                    style: compact
                        ? theme.textTheme.titleLarge?.copyWith(
                            color: KidPalette.navy,
                          )
                        : theme.textTheme.headlineSmall?.copyWith(
                            color: KidPalette.navy,
                          ),
                  ),
                ],
              ),
              SizedBox(height: compact ? 10 : 16),
              Expanded(
                child: FutureBuilder<AppProgressSnapshot>(
                  future: _snapshotFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    final earnedIds = <String>{
                      for (final event in snapshot.data!.rewardEvents)
                        event.reward.id,
                    };
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final pack in widget.catalog) ...[
                            _CategorySection(
                              pack: pack,
                              earnedIds: earnedIds,
                              compact: compact,
                            ),
                            SizedBox(height: compact ? 10 : 14),
                          ],
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

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.pack,
    required this.earnedIds,
    required this.compact,
  });

  final RewardPack pack;
  final Set<String> earnedIds;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = _accentFor(pack.categoryId);
    final earnedInPack = pack.rewards
        .where((reward) => earnedIds.contains(reward.id))
        .length;
    return ToyPanel(
      density: compact ? ToyPanelDensity.compact : ToyPanelDensity.regular,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                pack.label,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: KidPalette.navy,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$earnedInPack / ${pack.rewards.length}',
                  key: Key('collection-count-${pack.categoryId}'),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 6 : 10),
          Row(
            children: [
              for (var i = 0; i < pack.rewards.length; i++) ...[
                Expanded(
                  child: _RewardTile(
                    reward: pack.rewards[i],
                    earned: earnedIds.contains(pack.rewards[i].id),
                    accent: accent,
                    compact: compact,
                  ),
                ),
                if (i != pack.rewards.length - 1)
                  SizedBox(width: compact ? 6 : 10),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _RewardTile extends StatelessWidget {
  const _RewardTile({
    required this.reward,
    required this.earned,
    required this.accent,
    required this.compact,
  });

  final Reward reward;
  final bool earned;
  final Color accent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 52.0 : 64.0;
    return Container(
      key: Key(
        earned ? 'collection-unlocked-${reward.id}' : 'collection-locked-${reward.id}',
      ),
      padding: EdgeInsets.all(compact ? 6 : 8),
      decoration: BoxDecoration(
        color: earned ? accent.withValues(alpha: 0.14) : KidPalette.stroke,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: earned ? accent.withValues(alpha: 0.36) : KidPalette.stroke,
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: size,
            child: Center(
              child: earned
                  ? Text(reward.emoji, style: TextStyle(fontSize: size * 0.7))
                  : Icon(
                      Icons.lock_outline_rounded,
                      size: size * 0.5,
                      color: KidPalette.body,
                    ),
            ),
          ),
          SizedBox(height: compact ? 2 : 4),
          Text(
            reward.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: earned ? KidPalette.navy : KidPalette.body,
              fontWeight: earned ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackPill extends StatelessWidget {
  const _BackPill({required this.onTap, required this.compact});

  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('collection-back'),
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 12 : 16,
            vertical: compact ? 6 : 10,
          ),
          decoration: BoxDecoration(
            color: KidPalette.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: KidPalette.stroke),
            boxShadow: KidShadows.buttonSoft,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.arrow_back_rounded,
                color: KidPalette.navy,
                size: compact ? 18 : 22,
              ),
              SizedBox(width: compact ? 4 : 6),
              Text(
                '뒤로',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: KidPalette.navy,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color _accentFor(String categoryId) {
  switch (categoryId) {
    case 'alphabet':
      return alphabetLessonCategory.accentColor;
    case 'hangul':
      return hangulLessonCategory.accentColor;
    case 'numbers':
      return numbersLessonCategory.accentColor;
    default:
      return KidPalette.body;
  }
}
