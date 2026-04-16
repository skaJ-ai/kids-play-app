import 'package:flutter/material.dart';

import '../../../app/ui/kid_theme.dart';
import '../../../app/ui/playground_scaffold.dart';
import '../../../app/ui/tap_cooldown.dart';
import '../../../app/ui/toy_button.dart';
import '../../../app/ui/toy_panel.dart';
import '../data/home_catalog_repository.dart';
import 'category_hub_screen.dart';
import 'home_category_config.dart';

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
                          Icons.celebration_rounded,
                          color: KidPalette.coralDark,
                          size: compact ? 18 : 24,
                        ),
                        SizedBox(width: compact ? 6 : 8),
                        Text(
                          '세 가지 놀이터',
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
                      '하나씩 크게 눌러봐!',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: KidPalette.coralDark,
                      ),
                    ),
                ],
              ),
              SizedBox(height: compact ? 12 : 18),
              Text(
                '어떤 놀이터로 갈까?',
                textAlign: TextAlign.center,
                style: compact
                    ? Theme.of(context).textTheme.headlineSmall
                    : Theme.of(context).textTheme.headlineMedium,
              ),
              if (!compact) ...[
                const SizedBox(height: 10),
                Text(
                  '좋아하는 놀이터를 콕 누르면 바로 시작돼요.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
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
                                  '놀이터를 불러오지 못했어요.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(color: KidPalette.navy),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  '다시 불러오면 바로 놀러갈 수 있어요.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 20),
                                ToyButton(
                                  label: '다시 시도',
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
    final config = HomeCategoryConfig.resolve(category);

    return Material(
      color: Colors.transparent,
      child: CooldownInkWell(
        borderRadius: BorderRadius.circular(34),
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
        child: Stack(
          children: [
            Positioned.fill(
              child: ToyPanel(
                padding: EdgeInsets.all(compact ? 14 : 24),
                backgroundColor: category.backgroundColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!compact)
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: KidPalette.white.withValues(alpha: 0.84),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            config.badgeText,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: KidPalette.coralDark,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ),
                      ),
                    if (!compact)
                      const Spacer()
                    else
                      const SizedBox(height: 10),
                    Container(
                      width: compact ? 50 : 92,
                      height: compact ? 50 : 92,
                      decoration: BoxDecoration(
                        color: KidPalette.white.withValues(alpha: 0.84),
                        shape: BoxShape.circle,
                        boxShadow: KidShadows.panel,
                      ),
                      child: Icon(
                        category.icon,
                        size: compact ? 28 : 50,
                        color: KidPalette.navy,
                      ),
                    ),
                    SizedBox(height: compact ? 10 : 18),
                    Text(
                      category.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          (compact
                                  ? Theme.of(context).textTheme.titleMedium
                                  : Theme.of(context).textTheme.headlineSmall)
                              ?.copyWith(
                                color: KidPalette.navy,
                                fontWeight: FontWeight.w900,
                              ),
                    ),
                    SizedBox(height: compact ? 6 : 12),
                    Text(
                      compact
                          ? config.compactDescription
                          : category.description,
                      maxLines: compact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          (compact
                                  ? Theme.of(context).textTheme.titleSmall
                                  : Theme.of(context).textTheme.titleMedium)
                              ?.copyWith(color: KidPalette.navy),
                    ),
                    if (!compact) ...[
                      const Spacer(),
                      Row(
                        children: [
                          Text(
                            '들어가기',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: KidPalette.navy,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: KidPalette.navy,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Positioned(
              left: compact ? 10 : 14,
              top: compact ? 10 : 14,
              child: Transform.rotate(
                angle: -0.08,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 10 : 12,
                    vertical: compact ? 6 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: KidPalette.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(compact ? 12 : 16),
                    boxShadow: KidShadows.button,
                  ),
                  child: Text(
                    config.stickerText,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: KidPalette.coralDark,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
