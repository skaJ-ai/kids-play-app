import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'kid_theme.dart';
import 'tap_cooldown.dart';

enum PlayChoiceCardFeedback { none, correctTapped, wrongTapped }

class PlayChoiceCard extends StatefulWidget {
  const PlayChoiceCard({
    super.key,
    required this.symbol,
    required this.onTap,
    required this.accentIndex,
    required this.compact,
    required this.disabled,
    this.feedback = PlayChoiceCardFeedback.none,
    this.hintPulse = false,
  });

  final String symbol;
  final VoidCallback onTap;
  final int accentIndex;
  final bool compact;
  final bool disabled;
  final PlayChoiceCardFeedback feedback;
  final bool hintPulse;

  /// Test hook: flutter_test_config.dart flips this off to stop the
  /// perpetual 1 Hz hint pulse ticker from stalling pumpAndSettle.
  static bool debugHintPulseEnabled = true;

  @override
  State<PlayChoiceCard> createState() => _PlayChoiceCardState();
}

class _PlayChoiceCardState extends State<PlayChoiceCard>
    with TickerProviderStateMixin {
  late final AnimationController _wrong;
  late final AnimationController _correct;
  late final AnimationController _hint;

  @override
  void initState() {
    super.initState();
    _wrong = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _correct = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _hint = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _syncHintLoop();
  }

  @override
  void didUpdateWidget(covariant PlayChoiceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.feedback != oldWidget.feedback) {
      switch (widget.feedback) {
        case PlayChoiceCardFeedback.wrongTapped:
          _wrong.forward(from: 0);
        case PlayChoiceCardFeedback.correctTapped:
          _correct.forward(from: 0);
        case PlayChoiceCardFeedback.none:
          break;
      }
    }
    if (widget.hintPulse != oldWidget.hintPulse) {
      _syncHintLoop();
    }
  }

  void _syncHintLoop() {
    final shouldRun =
        widget.hintPulse && PlayChoiceCard.debugHintPulseEnabled;
    if (shouldRun) {
      if (!_hint.isAnimating) {
        _hint.repeat(reverse: true);
      }
    } else {
      _hint.stop();
      _hint.value = 0;
    }
  }

  @override
  void dispose() {
    _wrong.dispose();
    _correct.dispose();
    _hint.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typography = theme.kidTypography;
    final textTheme = theme.textTheme;
    final palette = _paletteFor(widget.accentIndex);

    return Opacity(
      opacity: widget.disabled ? 0.88 : 1,
      child: AnimatedBuilder(
        animation: Listenable.merge([_wrong, _correct, _hint]),
        builder: (context, child) {
          final wrongT = _wrong.value;
          final wrongScale = 1 - 0.08 * (1 - (2 * wrongT - 1).abs());
          final shakeDx = wrongT == 0 || wrongT == 1
              ? 0.0
              : math.sin(wrongT * 6 * math.pi) * 6.0;

          final correctT = _correct.value;
          final correctScale = 1 + 0.08 * (1 - (2 * correctT - 1).abs());

          final hintScale =
              widget.hintPulse ? 1 + 0.04 * _hint.value : 1.0;

          final scale = wrongT > 0
              ? wrongScale
              : (correctT > 0 ? correctScale : hintScale);

          return Transform.translate(
            offset: Offset(shakeDx, 0),
            child: Transform.scale(scale: scale, child: child),
          );
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: palette),
            borderRadius: BorderRadius.circular(widget.compact ? 26 : 32),
            boxShadow: KidShadows.button,
          ),
          child: Material(
            color: Colors.transparent,
            child: CooldownInkWell(
              borderRadius: BorderRadius.circular(widget.compact ? 26 : 32),
              onTap: widget.disabled ? null : widget.onTap,
              child: Stack(
                children: [
                  Positioned(
                    right: 16,
                    top: 16,
                    child: Container(
                      width: widget.compact ? 30 : 38,
                      height: widget.compact ? 30 : 38,
                      decoration: BoxDecoration(
                        color: KidPalette.white.withValues(alpha: 0.24),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 18,
                    top: 16,
                    child: Text(
                      '콕!',
                      style: typography.labelLarge.copyWith(
                        fontSize: typography.titleSmall.fontSize,
                        color: KidPalette.white.withValues(alpha: 0.92),
                      ),
                    ),
                  ),
                  Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        widget.symbol,
                        style:
                            textTheme.displayLarge?.copyWith(
                              fontSize: widget.compact ? 66 : 92,
                              height: 1,
                              color: KidPalette.white,
                            ) ??
                            TextStyle(
                              fontSize: widget.compact ? 66 : 92,
                              height: 1,
                              color: KidPalette.white,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _paletteFor(int index) {
    switch (index % 4) {
      case 0:
        return const [KidPalette.blue, KidPalette.blueDark];
      case 1:
        return const [KidPalette.coral, KidPalette.coralDark];
      case 2:
        return const [KidPalette.mint, KidPalette.mintDark];
      default:
        return const [KidPalette.lilac, Color(0xFFA28CF5)];
    }
  }
}
