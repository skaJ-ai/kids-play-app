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
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const AvatarSetupScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PlaygroundScaffold(
      showRoad: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight <= 360;
          final sectionGap = compact ? 8.0 : 18.0;
          final featureItems = [
            (Icons.touch_app_rounded, '혼자 톡 눌러요', KidPalette.blue),
            (Icons.stars_rounded, '퀴즈 뒤 스티커', KidPalette.coralDark),
            (
              Icons.stay_primary_landscape_rounded,
              '가로로 크게 봐요',
              KidPalette.mintDark,
            ),
          ];
          final visibleFeatures = compact
              ? featureItems.take(2).toList(growable: false)
              : featureItems;

          return Row(
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _Badge(
                          icon: Icons.directions_car_filled_rounded,
                          label: '오늘의 드라이브',
                          color: KidPalette.blue,
                          compact: compact,
                        ),
                        if (!compact) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '차분하게 누르고 출발해요',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: KidPalette.body,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: compact ? 10 : 18),
                    Text(
                      '승원이의 빵빵 놀이터',
                      style: compact
                          ? theme.textTheme.headlineSmall
                          : theme.textTheme.headlineLarge,
                    ),
                    SizedBox(height: compact ? 6 : 10),
                    Text(
                      '차 타고 출발!',
                      style:
                          (compact
                                  ? theme.textTheme.titleLarge
                                  : theme.textTheme.headlineSmall)
                              ?.copyWith(color: KidPalette.coralDark),
                    ),
                    SizedBox(height: compact ? 8 : 14),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: compact ? 320 : 420,
                      ),
                      child: Text(
                        '한글 · 알파벳 · 숫자 놀이를 골라요.',
                        maxLines: compact ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: compact
                            ? theme.textTheme.titleSmall
                            : theme.textTheme.titleMedium,
                      ),
                    ),
                    SizedBox(height: sectionGap),
                    Expanded(
                      child: ToyPanel(
                        padding: EdgeInsets.all(compact ? 10 : 18),
                        backgroundColor: KidPalette.white.withValues(
                          alpha: 0.94,
                        ),
                        child: LayoutBuilder(
                          builder: (context, panelConstraints) {
                            final superCompact =
                                panelConstraints.maxHeight <= 180;
                            final showLabel = !superCompact;
                            final spacing = superCompact
                                ? 6.0
                                : (compact ? 10.0 : 12.0);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (showLabel)
                                  Text(
                                    '오늘 할 놀이',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: KidPalette.body,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                if (showLabel)
                                  SizedBox(height: superCompact ? 8 : 12),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: superCompact
                                        ? MainAxisAlignment.spaceEvenly
                                        : MainAxisAlignment.center,
                                    children: [
                                      for (
                                        var i = 0;
                                        i < visibleFeatures.length;
                                        i++
                                      ) ...[
                                        _MiniFeature(
                                          icon: visibleFeatures[i].$1,
                                          label: visibleFeatures[i].$2,
                                          color: visibleFeatures[i].$3,
                                          compact: compact || superCompact,
                                        ),
                                        if (i != visibleFeatures.length - 1)
                                          SizedBox(height: spacing),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: sectionGap),
                    SizedBox(
                      width: compact ? 196 : 244,
                      child: ToyButton(
                        label: '놀이 시작',
                        icon: Icons.arrow_forward_rounded,
                        height: compact ? 56 : 72,
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
              SizedBox(width: compact ? 14 : 24),
              Expanded(
                flex: 5,
                child: ToyPanel(
                  padding: EdgeInsets.all(compact ? 16 : 22),
                  backgroundColor: KidPalette.creamWarm,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          _DriverPill(
                            icon: Icons.person_rounded,
                            label: '오늘의 드라이버',
                            color: KidPalette.coralDark,
                            compact: compact,
                          ),
                          if (!compact) ...[
                            const SizedBox(width: 10),
                            _DriverPill(
                              icon: Icons.touch_app_rounded,
                              label: '큰 버튼',
                              color: KidPalette.blue,
                              compact: compact,
                            ),
                          ],
                        ],
                      ),
                      const Spacer(),
                      Center(
                        child: GestureDetector(
                          key: const Key('hero-face-parent-entry'),
                          onTap: _handleHeroFaceTap,
                          child: Container(
                            width: compact ? 112 : 192,
                            height: compact ? 112 : 192,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  KidPalette.white.withValues(alpha: 0.98),
                                  KidPalette.blueSoft.withValues(alpha: 0.88),
                                ],
                              ),
                              border: Border.all(
                                color: KidPalette.white.withValues(alpha: 0.82),
                                width: 1.8,
                              ),
                              boxShadow: KidShadows.panel,
                            ),
                            padding: EdgeInsets.all(compact ? 14 : 22),
                            child: Image.asset(
                              'assets/generated/images/hero/hero_face.png',
                              key: const Key('hero-face-image'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: compact ? 12 : 18),
                      Text(
                        compact ? '얼굴 누르고 출발!' : '얼굴을 누르고 차고를 골라요.',
                        textAlign: TextAlign.center,
                        maxLines: compact ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: compact
                            ? theme.textTheme.titleSmall
                            : theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
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
          width: compact ? 38 : 46,
          height: compact ? 38 : 46,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(compact ? 14 : 18),
          ),
          child: Icon(icon, color: color, size: compact ? 20 : 24),
        ),
        SizedBox(width: compact ? 10 : 14),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                (compact
                        ? Theme.of(context).textTheme.titleSmall
                        : Theme.of(context).textTheme.titleMedium)
                    ?.copyWith(color: KidPalette.navy),
          ),
        ),
      ],
    );
  }
}

class _DriverPill extends StatelessWidget {
  const _DriverPill({
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
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: KidPalette.white.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 16 : 18, color: color),
          SizedBox(width: compact ? 4 : 6),
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
