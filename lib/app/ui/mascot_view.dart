import 'package:flutter/material.dart';

/// Mascot emotional state surfaced during learn / quiz / completion flows.
///
/// The `wrong` face is a playful belly-laugh — pre-readers (2–3yo) should
/// never read a wrong answer as shame. See the visual baseline doc §5.
enum MascotState { idle, correct, wrong, missionClear }

class MascotView extends StatelessWidget {
  const MascotView({super.key, required this.state, this.size = 120});

  final MascotState state;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(_assetFor(state), fit: BoxFit.contain),
    );
  }

  static String _assetFor(MascotState state) {
    switch (state) {
      case MascotState.idle:
        return 'assets/mascot/faces/idle.png';
      case MascotState.correct:
        return 'assets/mascot/faces/correct.jpg';
      case MascotState.wrong:
        return 'assets/mascot/faces/wrong.jpg';
      case MascotState.missionClear:
        return 'assets/mascot/faces/mission_clear.jpg';
    }
  }
}
