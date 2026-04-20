import 'package:flutter/material.dart';

import 'kid_theme.dart';

/// Traffic-light correctness feedback that doubles as car-world decor.
///
/// Red = wrong, yellow = idle/waiting, green = correct.
enum SignalLightState { idle, correct, wrong }

class SignalLight extends StatelessWidget {
  const SignalLight({super.key, required this.state, this.size = 120});

  final SignalLightState state;

  /// Width of the housing. Height is ~2.4x the width to fit three lamps.
  final double size;

  @override
  Widget build(BuildContext context) {
    final lampDiameter = size * 0.62;
    final housingPadding = size * 0.12;
    final lampGap = size * 0.08;

    return Container(
      width: size,
      height: size * 2.4,
      padding: EdgeInsets.all(housingPadding),
      decoration: BoxDecoration(
        color: KidPalette.navy,
        borderRadius: BorderRadius.circular(size * 0.24),
        boxShadow: KidShadows.panel,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SignalLamp(
            key: const Key('signal-red'),
            color: KidPalette.coralDark,
            lit: state == SignalLightState.wrong,
            diameter: lampDiameter,
          ),
          SizedBox(height: lampGap),
          SignalLamp(
            key: const Key('signal-yellow'),
            color: KidPalette.yellowDark,
            lit: state == SignalLightState.idle,
            diameter: lampDiameter,
          ),
          SizedBox(height: lampGap),
          SignalLamp(
            key: const Key('signal-green'),
            color: KidPalette.mintDark,
            lit: state == SignalLightState.correct,
            diameter: lampDiameter,
          ),
        ],
      ),
    );
  }
}

@visibleForTesting
class SignalLamp extends StatelessWidget {
  const SignalLamp({
    super.key,
    required this.color,
    required this.lit,
    required this.diameter,
  });

  final Color color;
  final bool lit;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: lit ? color : color.withValues(alpha: 0.22),
        boxShadow: lit
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.55),
                  blurRadius: diameter * 0.45,
                  spreadRadius: diameter * 0.05,
                ),
              ]
            : null,
      ),
    );
  }
}
