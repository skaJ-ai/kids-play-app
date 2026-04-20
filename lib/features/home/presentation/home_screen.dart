import 'package:flutter/material.dart';

import '../../../app/audio/audio_cue.dart';
import '../../../app/services/app_services.dart';
import '../../../app/ui/kid_theme.dart';
import '../../../app/ui/playground_scaffold.dart';
import '../../../app/ui/tap_cooldown.dart';
import '../../../app/ui/toy_button.dart';
import '../../../app/ui/toy_panel.dart';
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
  late AppServices _services;
  Future<List<HomeCategory>>? _categoriesFuture;
  bool _didQueueIntroPrompt = false;

  String get _introPromptText => '오늘의 차고예요. 좋아하는 차고를 골라요.';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _services = AppServicesScope.of(context);
    _categoriesFuture ??= _loadCategories();
    _queueIntroPrompt();
  }

  Future<List<HomeCategory>> _loadCategories() {
    return (widget.catalogRepository ??
            HomeCatalogRepository(assetBundle: DefaultAssetBundle.of(context)))
        .loadCategories();
  }

  void _queueIntroPrompt() {
    if (_didQueueIntroPrompt) {
      return;
    }
    _didQueueIntroPrompt = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _replayIntroPrompt();
    });
  }

  Future<void> _replayIntroPrompt() async {
    try {
      final snapshot = await _services.progressStore.loadSnapshot();
      if (!mounted || !snapshot.voicePromptsEnabled) {
        return;
      }

      await _services.audioService.playPrompt(
        AudioPromptRequest(
          categoryId: 'home',
          lessonId: 'garage',
          symbol: '오늘의 차고',
          fallbackText: _introPromptText,
        ),
      );
    } catch (_) {
      return;
    }
  }

  void _retryLoad() {
    setState(() {
      _categoriesFuture = _loadCategories();
    });
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
                  const Spacer(),
                  _ReplayPromptButton(
                    compact: compact,
                    onTap: _replayIntroPrompt,
                  ),
                  if (!compact) ...[
                    const SizedBox(width: 10),
                    Text(
                      '천천히 고르고 출발',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: KidPalette.body,
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: compact ? 12 : 18),
              Text(
                '어떤 차고로 갈까?',
                textAlign: TextAlign.center,
                style: compact
                    ? theme.textTheme.headlineSmall
                    : theme.textTheme.headlineMedium,
              ),
              SizedBox(height: compact ? 6 : 10),
              Text(
                '좋아하는 차고를 콕 눌러요.',
                textAlign: TextAlign.center,
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

class _ReplayPromptButton extends StatelessWidget {
  const _ReplayPromptButton({required this.compact, required this.onTap});

  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('home-replay-prompt'),
        borderRadius: BorderRadius.circular(compact ? 18 : 20),
        onTap: onTap,
        child: Container(
          width: compact ? 44 : 48,
          height: compact ? 44 : 48,
          decoration: BoxDecoration(
            color: KidPalette.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(compact ? 18 : 20),
            boxShadow: KidShadows.button,
          ),
          child: Icon(
            Icons.volume_up_rounded,
            color: KidPalette.coralDark,
            size: compact ? 22 : 24,
          ),
        ),
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

    return Material(
      color: Colors.transparent,
      child: CooldownInkWell(
        borderRadius: BorderRadius.circular(36),
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
          padding: EdgeInsets.all(compact ? 14 : 20),
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
              Container(
                width: compact ? 58 : 76,
                height: compact ? 58 : 76,
                decoration: BoxDecoration(
                  color: KidPalette.white.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(compact ? 18 : 24),
                  border: Border.all(
                    color: KidPalette.white.withValues(alpha: 0.72),
                  ),
                  boxShadow: KidShadows.panel,
                ),
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
                      '차고 열기',
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
