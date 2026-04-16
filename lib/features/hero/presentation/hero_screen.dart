import 'package:flutter/material.dart';

import '../../../app/ui/kid_theme.dart';
import '../../../app/ui/playground_scaffold.dart';
import '../../../app/ui/toy_button.dart';
import '../../../app/ui/toy_panel.dart';
import '../../avatar/presentation/avatar_setup_screen.dart';
import '../../home/presentation/home_screen.dart';

class HeroScreen extends StatefulWidget {
  const HeroScreen({super.key});

  @override
  State<HeroScreen> createState() => _HeroScreenState();
}

class _HeroScreenState extends State<HeroScreen> {
  int _parentTapCount = 0;

  Future<void> _handleHeroFaceTap() async {
    _parentTapCount += 1;
    if (_parentTapCount < 5) {
      return;
    }

    _parentTapCount = 0;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const AvatarSetupScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PlaygroundScaffold(
      showRoad: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 360;
          final leftGap = compact ? 8.0 : 20.0;
          final sectionGap = compact ? 10.0 : 18.0;
          final featureSpacing = compact ? 8.0 : 14.0;
          final featureItems = [
            (
              Icons.touch_app_rounded,
              '탭만으로 혼자 놀 수 있어요',
              KidPalette.blue,
            ),
            (
              Icons.style_rounded,
              '퀴즈를 풀면 자동차 스티커를 받아요',
              KidPalette.mintDark,
            ),
            (
              Icons.landscape_rounded,
              '가로 화면에서 크게 보고 눌러요',
              KidPalette.yellowDark,
            ),
          ];
          final visibleFeatures = compact ? featureItems.take(2).toList() : featureItems;

          return Row(
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Badge(
                      icon: Icons.directions_car_filled_rounded,
                      label: compact ? '빵빵 출발!' : '오늘의 빵빵 출발!',
                      color: KidPalette.coral,
                      compact: compact,
                    ),
                    SizedBox(height: leftGap),
                    Text(
                      '승원이의 빵빵 놀이터',
                      style: compact
                          ? theme.textTheme.headlineSmall
                          : theme.textTheme.headlineLarge,
                    ),
                    SizedBox(height: compact ? 6 : 12),
                    Text(
                      '빵빵 출발!',
                      style: (compact
                              ? theme.textTheme.titleLarge
                              : theme.textTheme.headlineSmall)
                          ?.copyWith(color: KidPalette.coralDark),
                    ),
                    SizedBox(height: compact ? 8 : 14),
                    Text(
                      compact
                          ? '자동차 놀이터처럼 신나게 눌러보며 배워요.'
                          : '자동차 놀이터처럼 신나게 눌러보며 한글, 알파벳, 숫자를 익혀요.',
                      style: compact
                          ? theme.textTheme.titleSmall
                          : theme.textTheme.titleMedium,
                      maxLines: compact ? 2 : 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: sectionGap),
                    Expanded(
                      child: ToyPanel(
                        padding: EdgeInsets.all(compact ? 12 : 16),
                        backgroundColor: KidPalette.white.withValues(alpha: 0.94),
                        child: LayoutBuilder(
                          builder: (context, panelConstraints) {
                            final superCompact = panelConstraints.maxHeight < 150;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for (var i = 0; i < visibleFeatures.length; i++) ...[
                                  _MiniFeature(
                                    icon: visibleFeatures[i].$1,
                                    label: visibleFeatures[i].$2,
                                    color: visibleFeatures[i].$3,
                                    compact: compact || superCompact,
                                  ),
                                  if (i != visibleFeatures.length - 1)
                                    SizedBox(
                                      height: superCompact ? 6 : featureSpacing,
                                    ),
                                ],
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: sectionGap),
                    SizedBox(
                      width: compact ? 200 : 280,
                      child: ToyButton(
                        label: '플레이하기',
                        icon: Icons.play_arrow_rounded,
                        height: compact ? 60 : 76,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const HomeScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: compact ? 16 : 24),
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    Positioned(
                      left: compact ? 8 : 12,
                      right: 0,
                      bottom: 0,
                      top: compact ? 18 : 26,
                      child: ToyPanel(
                        padding: EdgeInsets.all(compact ? 16 : 24),
                        backgroundColor: KidPalette.creamWarm,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              key: const Key('hero-face-parent-entry'),
                              onTap: _handleHeroFaceTap,
                              child: Container(
                                width: compact ? 118 : 190,
                                height: compact ? 118 : 190,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: KidPalette.white.withValues(alpha: 0.9),
                                  boxShadow: KidShadows.panel,
                                ),
                                padding: EdgeInsets.all(compact ? 14 : 18),
                                child: Image.asset(
                                  'assets/generated/images/hero/hero_face.png',
                                  key: const Key('hero-face-image'),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            SizedBox(height: compact ? 12 : 18),
                            Text(
                              '오늘의 기사님',
                              style: (compact
                                      ? theme.textTheme.titleSmall
                                      : theme.textTheme.titleLarge)
                                  ?.copyWith(color: KidPalette.coralDark),
                            ),
                            SizedBox(height: compact ? 2 : 8),
                            Text(
                              compact
                                  ? '바로 놀이터로 출발!'
                                  : '빵빵 누르면 바로 놀이터로 출발!',
                              textAlign: TextAlign.center,
                              maxLines: compact ? 1 : 2,
                              overflow: TextOverflow.ellipsis,
                              style: compact
                                  ? theme.textTheme.titleSmall
                                  : theme.textTheme.titleSmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: compact ? 4 : 10,
                      top: 0,
                      child: _Sticker(label: 'GO!', compact: compact),
                    ),
                    Positioned(
                      left: 0,
                      bottom: compact ? 10 : 20,
                      child: _Sticker(
                        label: 'VROOM',
                        color: KidPalette.mint,
                        compact: compact,
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

class _Badge extends StatelessWidget {
  const _Badge({
    required this.icon,
    required this.label,
    required this.color,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: KidPalette.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(999),
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
            Icon(icon, size: compact ? 18 : 22, color: color),
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

class _MiniFeature extends StatelessWidget {
  const _MiniFeature({
    required this.icon,
    required this.label,
    required this.color,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: compact ? 34 : 44,
          height: compact ? 34 : 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(compact ? 12 : 16),
          ),
          child: Icon(icon, color: color, size: compact ? 19 : 24),
        ),
        SizedBox(width: compact ? 10 : 14),
        Expanded(
          child: Text(
            label,
            maxLines: compact ? 1 : 2,
            overflow: TextOverflow.ellipsis,
            style: (compact
                    ? Theme.of(context).textTheme.titleSmall
                    : Theme.of(context).textTheme.titleMedium)
                ?.copyWith(color: KidPalette.navy),
          ),
        ),
      ],
    );
  }
}

class _Sticker extends StatelessWidget {
  const _Sticker({
    required this.label,
    this.color = KidPalette.coral,
    this.compact = false,
  });

  final String label;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.12,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 16,
          vertical: compact ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(compact ? 14 : 18),
          boxShadow: KidShadows.button,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: KidPalette.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
