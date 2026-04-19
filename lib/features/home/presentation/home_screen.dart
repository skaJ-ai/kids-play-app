import 'package:flutter/material.dart';

import '../../../app/ui/kid_theme.dart';
import '../../../app/ui/mascot_view.dart';
import '../../../app/ui/playground_scaffold.dart';
import '../../../app/ui/tap_cooldown.dart';
import '../../../app/ui/toy_button.dart';
import '../../../app/ui/toy_panel.dart';
import '../../rewards/presentation/collection_screen.dart';
import '../data/home_catalog_repository.dart';
import 'category_hub_screen.dart';
import 'home_category_config.dart';
import 'home_pills.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.catalogRepository,
    this.categoryDependencies = const HomeCategoryDependencies(),
  });

  final HomeCatalogRepository? catalogRepository;
  final HomeCategoryDependencies categoryDependencies;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<HomeCategory>>? _categoriesFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _categoriesFuture ??= _loadCategories();
  }

  Future<List<HomeCategory>> _loadCategories() {
    return (widget.catalogRepository ??
            HomeCatalogRepository(assetBundle: DefaultAssetBundle.of(context)))
        .loadCategories();
  }

  void _retryLoad() {
    setState(() {
      _categoriesFuture = _loadCategories();
    });
  }

  Future<void> _openCollection() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const CollectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                    icon: Icons.directions_car_filled_rounded,
                    label: '오늘의 차고',
                    iconColor: KidPalette.blue,
                    compact: compact,
                  ),
                  if (!compact) ...[
                    const SizedBox(width: 12),
                    const MascotView(
                      key: Key('home-hero-mascot'),
                      state: MascotState.idle,
                      size: 48,
                    ),
                  ],
                  const Spacer(),
                  _CollectionPill(
                    compact: compact,
                    onTap: _openCollection,
                  ),
                  SizedBox(width: compact ? 8 : 12),
                  if (!compact)
                    Text(
                      '천천히 고르고 출발',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: KidPalette.body,
                      ),
                    ),
                ],
              ),
              SizedBox(height: compact ? 12 : 18),
              Text(
                compact ? '어떤 차고로 갈까?' : '오늘은 어디로 달릴까?',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: compact
                    ? theme.textTheme.headlineSmall
                    : theme.textTheme.headlineMedium,
              ),
              SizedBox(height: compact ? 6 : 10),
              Text(
                compact ? '좋아하는 차고를 콕 눌러요.' : '마음에 드는 차고를 누르고 놀이를 골라요.',
                textAlign: TextAlign.center,
                maxLines: compact ? 1 : 2,
                overflow: TextOverflow.ellipsis,
                style: compact
                    ? theme.textTheme.titleSmall
                    : theme.textTheme.titleMedium,
              ),
              SizedBox(height: compact ? 14 : 22),
              Expanded(
                child: FutureBuilder<List<HomeCategory>>(
                  future: _categoriesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: SizedBox(
                          width: 420,
                          child: ToyPanel(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '차고를 불러오지 못했어요.',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(color: KidPalette.navy),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '다시 누르면 바로 달릴 수 있어요.',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(height: 20),
                                ToyButton(
                                  label: '다시 보기',
                                  icon: Icons.refresh_rounded,
                                  onPressed: _retryLoad,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final categories = snapshot.data!;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final category in categories) ...[
                          Expanded(
                            child: _CategoryCard(
                              category: category,
                              compact: compact,
                              categoryDependencies: widget.categoryDependencies,
                            ),
                          ),
                          if (category != categories.last)
                            SizedBox(width: compact ? 12 : 18),
                        ],
                      ],
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

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.categoryDependencies,
    this.compact = false,
  });

  final HomeCategory category;
  final HomeCategoryDependencies categoryDependencies;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = HomeCategoryConfig.resolve(category);
    final accentColor = config.accentColor;
    final panelColor = Color.lerp(
      category.backgroundColor,
      KidPalette.white,
      0.52,
    )!;

    final panelDensity = compact
        ? ToyPanelDensity.compact
        : ToyPanelDensity.regular;
    final panelRadius = theme.kidLayout.panel.forDensity(panelDensity).radius;

    return Material(
      color: Colors.transparent,
      child: CooldownInkWell(
        borderRadius: BorderRadius.circular(panelRadius),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CategoryHubScreen(
                category: category,
                categoryDependencies: categoryDependencies,
              ),
            ),
          );
        },
        child: ToyPanel(
          density: panelDensity,
          backgroundColor: panelColor,
          borderColor: KidPalette.white.withValues(alpha: 0.78),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  HomeAccentPill(
                    label: config.stickerText,
                    textColor: accentColor,
                    backgroundColor: KidPalette.white.withValues(alpha: 0.76),
                    compact: compact,
                  ),
                  const Spacer(),
                  HomeAccentPill(
                    label: config.badgeText,
                    textColor: accentColor,
                    backgroundColor: accentColor.withValues(alpha: 0.12),
                    compact: compact,
                  ),
                ],
              ),
              const Spacer(),
              ToyPanelInsetSurface(
                density: panelDensity,
                width: compact ? 58 : 76,
                height: compact ? 58 : 76,
                backgroundColor: KidPalette.white.withValues(alpha: 0.88),
                child: Icon(
                  category.icon,
                  size: compact ? 30 : 38,
                  color: accentColor,
                ),
              ),
              SizedBox(height: compact ? 12 : 16),
              Text(
                category.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    (compact
                            ? theme.textTheme.titleLarge
                            : theme.textTheme.headlineSmall)
                        ?.copyWith(
                          color: KidPalette.navy,
                          fontWeight: FontWeight.w900,
                        ),
              ),
              SizedBox(height: compact ? 6 : 10),
              Text(
                compact ? config.compactDescription : config.homeDescription,
                maxLines: compact ? 1 : 2,
                overflow: TextOverflow.ellipsis,
                style:
                    (compact
                            ? theme.textTheme.titleSmall
                            : theme.textTheme.titleMedium)
                        ?.copyWith(color: KidPalette.navy),
              ),
              if (!compact) ...[
                const Spacer(),
                Row(
                  children: [
                    Text(
                      '놀이 고르기',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: accentColor,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CollectionPill extends StatelessWidget {
  const _CollectionPill({required this.compact, required this.onTap});

  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('home-collection-pill'),
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
                Icons.star_rounded,
                color: KidPalette.coralDark,
                size: compact ? 18 : 22,
              ),
              SizedBox(width: compact ? 4 : 6),
              Text(
                '스티커',
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
