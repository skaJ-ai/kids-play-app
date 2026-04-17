import 'package:flutter/material.dart';

import '../../../app/ui/kid_theme.dart';
import '../../../app/ui/playground_scaffold.dart';
import '../../../app/ui/tap_cooldown.dart';
import '../../../app/ui/toy_panel.dart';
import '../data/home_catalog_repository.dart';
import 'home_category_config.dart';
import 'home_pills.dart';

class CategoryHubScreen extends StatelessWidget {
  const CategoryHubScreen({
    super.key,
    required this.category,
    this.categoryDependencies = const HomeCategoryDependencies(),
  });

  final HomeCategory category;
  final HomeCategoryDependencies categoryDependencies;

  HomeCategoryConfig get _config => HomeCategoryConfig.resolve(category);

  bool get _supportsLearnMode => _config.supportsLearnMode;

  bool get _supportsGameMode => _config.supportsGameMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = _config.accentColor;

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
                  HomeHeaderPill(
                    icon: category.icon,
                    label: '${category.label} 차고',
                    iconColor: accentColor,
                    compact: compact,
                  ),
                  const Spacer(),
                  if (!compact)
                    Text(
                      _supportsGameMode ? '배우고 바로 출발!' : '천천히 둘러봐요',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: KidPalette.body,
                      ),
                    ),
                ],
              ),
              SizedBox(height: compact ? 12 : 18),
              Text(
                '어떻게 놀까?',
                textAlign: TextAlign.center,
                style: compact
                    ? theme.textTheme.headlineSmall
                    : theme.textTheme.headlineMedium,
              ),
              SizedBox(height: compact ? 6 : 10),
              Text(
                _config.hubDescription,
                textAlign: TextAlign.center,
                maxLines: compact ? 2 : 2,
                overflow: TextOverflow.ellipsis,
                style: compact
                    ? theme.textTheme.titleSmall
                    : theme.textTheme.titleMedium,
              ),
              SizedBox(height: compact ? 14 : 22),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _ModeCard(
                        title: '배우기',
                        subtitle: _supportsLearnMode ? '큰 카드로 천천히' : '곧 열려요',
                        tag: '천천히',
                        backgroundColor: Color.lerp(
                          KidPalette.yellow,
                          KidPalette.white,
                          0.36,
                        )!,
                        accentColor: KidPalette.yellowDark,
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
                        title: '퀴즈',
                        subtitle: _supportsGameMode ? '듣고 바로 맞혀요' : '곧 열려요',
                        tag: _supportsGameMode ? '도전' : '곧',
                        backgroundColor: Color.lerp(
                          KidPalette.blueSoft,
                          KidPalette.white,
                          0.12,
                        )!,
                        accentColor: KidPalette.blue,
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
    final destinationBuilder = _config.learnScreenBuilder;
    if (destinationBuilder == null) {
      return;
    }
    final destination = destinationBuilder(categoryDependencies);

    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => destination));
  }

  void _openGameMode(BuildContext context) {
    final destinationBuilder = _config.gameScreenBuilder;
    if (destinationBuilder == null) {
      return;
    }
    final destination = destinationBuilder(categoryDependencies);

    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => destination));
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.backgroundColor,
    required this.accentColor,
    required this.icon,
    this.compact = false,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String tag;
  final Color backgroundColor;
  final Color accentColor;
  final IconData icon;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onTap != null;

    return Opacity(
      opacity: enabled ? 1 : 0.66,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = compact || constraints.maxHeight < 240;
          final isTight = constraints.maxHeight <= 180;
          final panelDensity = isCompact
              ? ToyPanelDensity.compact
              : ToyPanelDensity.regular;
          final panelTokens = theme.kidLayout.panel.forDensity(panelDensity);
          final panelRadius = panelTokens.radius;
          final iconTileDensity = isCompact
              ? ToyPanelDensity.tight
              : ToyPanelDensity.regular;
          final iconTileRadius = theme.kidLayout.panel
              .forDensity(iconTileDensity)
              .insetRadius;
          final topGap = isTight ? 8.0 : (isCompact ? 12.0 : 18.0);
          final iconBoxSize = isTight ? 44.0 : (isCompact ? 62.0 : 76.0);
          final iconSize = isTight ? 24.0 : (isCompact ? 30.0 : 38.0);
          final titleStyle = isTight
              ? theme.textTheme.titleMedium
              : (isCompact
                    ? theme.textTheme.titleLarge
                    : theme.textTheme.headlineSmall);
          final subtitleStyle = isTight
              ? theme.textTheme.labelLarge
              : (isCompact
                    ? theme.textTheme.titleSmall
                    : theme.textTheme.titleMedium);

          return Material(
            color: Colors.transparent,
            child: CooldownInkWell(
              borderRadius: BorderRadius.circular(panelRadius),
              onTap: onTap,
              child: isCompact
                  ? ToyPanel(
                      density: ToyPanelDensity.compact,
                      backgroundColor: backgroundColor,
                      borderColor: KidPalette.white.withValues(alpha: 0.78),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: KidPalette.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(iconTileRadius),
                              border: Border.all(
                                color: KidPalette.white.withValues(alpha: 0.72),
                              ),
                              boxShadow: KidShadows.panel,
                            ),
                            child: Icon(icon, size: 24, color: accentColor),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              color: KidPalette.navy,
                                              fontWeight: FontWeight.w900,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    HomeAccentPill(
                                      label: tag,
                                      textColor: accentColor,
                                      backgroundColor: accentColor.withValues(
                                        alpha: 0.12,
                                      ),
                                      compact: true,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: KidPalette.navy,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  enabled ? '바로 시작' : '준비 중',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: accentColor,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ToyPanel(
                      density: ToyPanelDensity.regular,
                      backgroundColor: backgroundColor,
                      borderColor: KidPalette.white.withValues(alpha: 0.78),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              HomeAccentPill(
                                label: tag,
                                textColor: accentColor,
                                backgroundColor: accentColor.withValues(alpha: 0.12),
                                compact: isCompact,
                              ),
                              const Spacer(),
                              Icon(
                                Icons.arrow_outward_rounded,
                                color: enabled ? accentColor : KidPalette.body,
                                size: isTight ? 16 : (isCompact ? 18 : 22),
                              ),
                            ],
                          ),
                          SizedBox(height: topGap),
                          Container(
                            width: iconBoxSize,
                            height: iconBoxSize,
                            decoration: BoxDecoration(
                              color: KidPalette.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(iconTileRadius),
                              border: Border.all(
                                color: KidPalette.white.withValues(alpha: 0.72),
                              ),
                              boxShadow: KidShadows.panel,
                            ),
                            child: Icon(icon, size: iconSize, color: accentColor),
                          ),
                          SizedBox(height: isTight ? 8 : topGap),
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: titleStyle?.copyWith(
                              color: KidPalette.navy,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: isTight ? 4 : (isCompact ? 6 : 10)),
                          Text(
                            subtitle,
                            maxLines: isTight ? 1 : (isCompact ? 2 : 3),
                            overflow: TextOverflow.ellipsis,
                            style: subtitleStyle?.copyWith(color: KidPalette.navy),
                          ),
                          const Spacer(),
                          Text(
                            enabled ? '바로 시작' : '준비 중',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                (isTight
                                        ? theme.textTheme.titleSmall
                                        : (isCompact
                                              ? theme.textTheme.titleSmall
                                              : theme.textTheme.titleMedium))
                                    ?.copyWith(
                                      color: accentColor,
                                      fontWeight: FontWeight.w900,
                                    ),
                          ),
                        ],
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
