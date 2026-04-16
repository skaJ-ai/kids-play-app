import 'package:flutter/material.dart';

import '../../../app/ui/kid_theme.dart';
import '../../../app/ui/playground_scaffold.dart';
import '../../../app/ui/toy_panel.dart';
import '../../hangul/data/hangul_lesson_repository.dart';
import '../../hangul/presentation/hangul_learn_screen.dart';
import '../../hangul/presentation/hangul_quiz_screen.dart';
import '../data/home_catalog_repository.dart';

class CategoryHubScreen extends StatelessWidget {
  const CategoryHubScreen({
    super.key,
    required this.category,
    this.hangulLessonRepository,
  });

  final HomeCategory category;
  final HangulLessonRepository? hangulLessonRepository;

  bool get _supportsLearnMode => category.id == 'hangul';
  bool get _supportsGameMode => category.id == 'hangul';

  @override
  Widget build(BuildContext context) {
    return PlaygroundScaffold(
      showRoad: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 360;

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
                          category.icon,
                          color: KidPalette.navy,
                          size: compact ? 18 : 24,
                        ),
                        SizedBox(width: compact ? 6 : 8),
                        Text(
                          compact ? category.label : '${category.label} 준비완료',
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
                      _supportsGameMode ? '배우고 바로 퀴즈!' : '곧 더 많이 열려요',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: KidPalette.coralDark,
                      ),
                    ),
                ],
              ),
              SizedBox(height: compact ? 12 : 18),
              Text(
                '${category.label} 놀이터',
                textAlign: TextAlign.center,
                style: compact
                    ? Theme.of(context).textTheme.headlineSmall
                    : Theme.of(context).textTheme.headlineMedium,
              ),
              if (!compact) ...[
                const SizedBox(height: 10),
                Text(
                  category.description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
              SizedBox(height: compact ? 14 : 22),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _ModeCard(
                        title: '학습하기',
                        subtitle: _supportsLearnMode ? '큰 카드로 천천히 익혀요' : '곧 만나요',
                        sticker: 'LEARN',
                        color: KidPalette.yellow,
                        icon: Icons.menu_book_rounded,
                        compact: compact,
                        onTap: _supportsLearnMode
                            ? () => _openLearnMode(context)
                            : null,
                      ),
                    ),
                    SizedBox(width: compact ? 12 : 18),
                    Expanded(
                      child: _ModeCard(
                        title: '게임하기',
                        subtitle: _supportsGameMode ? '퀴즈로 신나게 맞혀요' : '곧 만나요',
                        sticker: _supportsGameMode ? 'QUIZ' : 'SOON',
                        color: KidPalette.mint,
                        icon: Icons.videogame_asset_rounded,
                        compact: compact,
                        onTap: _supportsGameMode
                            ? () => _openGameMode(context)
                            : null,
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

  void _openLearnMode(BuildContext context) {
    if (category.id == 'hangul') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => HangulLearnScreen(repository: hangulLessonRepository),
        ),
      );
    }
  }

  void _openGameMode(BuildContext context) {
    if (category.id == 'hangul') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => HangulQuizScreen(repository: hangulLessonRepository),
        ),
      );
    }
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.sticker,
    required this.color,
    required this.icon,
    this.compact = false,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String sticker;
  final Color color;
  final IconData icon;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return Opacity(
      opacity: enabled ? 1 : 0.62,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(34),
          onTap: onTap,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = compact || constraints.maxHeight < 240;

              return Stack(
                children: [
                  Positioned.fill(
                    child: ToyPanel(
                      padding: EdgeInsets.all(isCompact ? 14 : 24),
                      backgroundColor: color,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isCompact) const Spacer() else const SizedBox(height: 8),
                          Container(
                            width: isCompact ? 60 : 86,
                            height: isCompact ? 60 : 86,
                            decoration: BoxDecoration(
                              color: KidPalette.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                              boxShadow: KidShadows.panel,
                            ),
                            child: Icon(
                              icon,
                              size: isCompact ? 32 : 46,
                              color: KidPalette.navy,
                            ),
                          ),
                          SizedBox(height: isCompact ? 10 : 18),
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: (isCompact
                                    ? Theme.of(context).textTheme.titleLarge
                                    : Theme.of(context).textTheme.headlineSmall)
                                ?.copyWith(
                                  color: KidPalette.navy,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          SizedBox(height: isCompact ? 6 : 10),
                          Text(
                            subtitle,
                            maxLines: isCompact ? 2 : 3,
                            overflow: TextOverflow.ellipsis,
                            style: (isCompact
                                    ? Theme.of(context).textTheme.titleSmall
                                    : Theme.of(context).textTheme.titleMedium)
                                ?.copyWith(
                                  color: KidPalette.navy,
                                ),
                          ),
                          const Spacer(),
                          Text(
                            enabled ? '눌러서 시작' : '준비 중',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: (isCompact
                                    ? Theme.of(context).textTheme.titleSmall
                                    : Theme.of(context).textTheme.titleMedium)
                                ?.copyWith(
                                  color: KidPalette.coralDark,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: isCompact ? 10 : 14,
                    right: isCompact ? 10 : 16,
                    child: Transform.rotate(
                      angle: 0.08,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isCompact ? 10 : 12,
                          vertical: isCompact ? 6 : 8,
                        ),
                        decoration: BoxDecoration(
                          color: KidPalette.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(isCompact ? 12 : 16),
                          boxShadow: KidShadows.button,
                        ),
                        child: Text(
                          sticker,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: KidPalette.coralDark,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
