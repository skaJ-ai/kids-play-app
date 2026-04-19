import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Mascot emotional state surfaced during learn / quiz / completion flows.
///
/// The `wrong` face is a playful belly-laugh — pre-readers (2–3yo) should
/// never read a wrong answer as shame. See the visual baseline doc §5.
enum MascotState { idle, correct, wrong, missionClear }

class MascotView extends StatefulWidget {
  const MascotView({super.key, required this.state, this.size = 120});

  final MascotState state;
  final double size;

  @override
  State<MascotView> createState() => _MascotViewState();
}

class _MascotViewState extends State<MascotView>
    with TickerProviderStateMixin {
  late final AnimationController _jump;
  late final AnimationController _shake;

  @override
  void initState() {
    super.initState();
    _jump = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
  }

  @override
  void didUpdateWidget(MascotView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state == oldWidget.state) return;
    switch (widget.state) {
      case MascotState.correct:
      case MascotState.missionClear:
        _jump.forward(from: 0);
        break;
      case MascotState.wrong:
        _shake.forward(from: 0);
        break;
      case MascotState.idle:
        break;
    }
  }

  @override
  void dispose() {
    _jump.dispose();
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_jump, _shake]),
        builder: (context, child) {
          final jumpT = _jump.value;
          // triangle wave — 1.0 at t=0, 1.15 at t=0.5, 1.0 at t=1.
          final jumpScale = 1 + 0.15 * (1 - (2 * jumpT - 1).abs());
          final shakeT = _shake.value;
          final shakeDx = math.sin(shakeT * math.pi * 6) *
              (widget.size * 0.05) *
              (1 - shakeT);
          return Transform.translate(
            offset: Offset(shakeDx, 0),
            child: Transform.scale(
              scale: jumpScale,
              child: child,
            ),
          );
        },
        child: Image.asset(
          _assetFor(widget.state),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stack) => const SizedBox.shrink(),
        ),
      ),
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
