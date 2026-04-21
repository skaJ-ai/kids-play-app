import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../features/avatar/domain/avatar_expression.dart';
import '../../features/avatar/presentation/widgets/avatar_face_image.dart';
import 'kid_theme.dart';
import 'mascot_view.dart';

class CompanionPair extends StatefulWidget {
  const CompanionPair({
    super.key,
    required this.state,
    this.size = 180,
    this.onTap,
    this.avatarKey,
    this.mascotKey,
    this.idleMotion,
  });

  final MascotState state;
  final double size;
  final VoidCallback? onTap;
  final Key? avatarKey;
  final Key? mascotKey;

  /// Enables the idle breathe/tilt loops. When null, defaults to
  /// [debugIdleMotionDefault] so widget tests can opt out globally without
  /// touching every callsite.
  final bool? idleMotion;

  /// Global default for [idleMotion] when a call site leaves it unset.
  /// Tests set this to false in `flutter_test_config.dart` to keep
  /// `pumpAndSettle` from stalling on the perpetual breathe ticker.
  static bool debugIdleMotionDefault = true;

  @override
  State<CompanionPair> createState() => _CompanionPairState();
}

class _CompanionPairState extends State<CompanionPair>
    with TickerProviderStateMixin {
  static const _breatheAmplitudePx = 1.5;
  static const _tiltAmplitudeRad = 2 * math.pi / 180;
  static const _tiltMinGap = Duration(seconds: 11);
  static const _tiltJitter = Duration(seconds: 3);

  late final AnimationController _bounce;
  late final AnimationController _breathe;
  late final AnimationController _tilt;
  Timer? _tiltScheduler;
  final _random = math.Random();

  bool _idleEnabled = false;

  @override
  void initState() {
    super.initState();
    _bounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _breathe = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _tilt = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncIdleLoops();
  }

  @override
  void didUpdateWidget(covariant CompanionPair oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state != oldWidget.state &&
        (widget.state == MascotState.correct ||
            widget.state == MascotState.missionClear)) {
      _bounce.forward(from: 0);
    }
    _syncIdleLoops();
  }

  void _syncIdleLoops() {
    final shouldRun =
        widget.idleMotion ?? CompanionPair.debugIdleMotionDefault;
    if (shouldRun == _idleEnabled) {
      return;
    }
    _idleEnabled = shouldRun;
    if (shouldRun) {
      _breathe.repeat(reverse: true);
      _scheduleNextTilt();
    } else {
      _breathe.stop();
      _breathe.value = 0.5;
      _tiltScheduler?.cancel();
      _tiltScheduler = null;
      _tilt.stop();
      _tilt.value = 0;
    }
  }

  @override
  void dispose() {
    _tiltScheduler?.cancel();
    _bounce.dispose();
    _breathe.dispose();
    _tilt.dispose();
    super.dispose();
  }

  void _scheduleNextTilt() {
    _tiltScheduler?.cancel();
    final jitterMs = _random.nextInt(_tiltJitter.inMilliseconds);
    _tiltScheduler = Timer(_tiltMinGap + Duration(milliseconds: jitterMs), () {
      if (!mounted) return;
      _tilt.forward(from: 0).whenComplete(() {
        if (!mounted) return;
        _scheduleNextTilt();
      });
    });
  }

  void _handleTap() {
    _bounce.forward(from: 0);
    widget.onTap?.call();
  }

  List<AvatarExpression> _expressionsFor(MascotState state) {
    switch (state) {
      case MascotState.correct:
      case MascotState.missionClear:
        return const [AvatarExpression.smile, AvatarExpression.neutral];
      case MascotState.wrong:
      case MascotState.idle:
        return const [AvatarExpression.neutral, AvatarExpression.smile];
    }
  }

  @override
  Widget build(BuildContext context) {
    final mascotSize = widget.size;
    final avatarSize = mascotSize * 0.46;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation:
            Listenable.merge([_bounce, _breathe, _tilt]),
        builder: (context, child) {
          final bounceT = _bounce.value;
          final bounceScale = 1 + 0.08 * (1 - (2 * bounceT - 1).abs());

          final breatheDy = _idleEnabled
              ? (_breathe.value - 0.5) * 2 * _breatheAmplitudePx
              : 0.0;

          final tiltAngle = _idleEnabled
              ? math.sin(_tilt.value * 2 * math.pi) * _tiltAmplitudeRad
              : 0.0;

          return Transform.translate(
            offset: Offset(0, breatheDy),
            child: Transform.rotate(
              angle: tiltAngle,
              child: Transform.scale(scale: bounceScale, child: child),
            ),
          );
        },
        child: SizedBox(
          width: mascotSize,
          height: mascotSize,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: MascotView(
                    key: widget.mascotKey,
                    state: widget.state,
                    size: mascotSize * 0.92,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  key: widget.avatarKey,
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: KidPalette.white,
                    border: Border.all(
                      color: KidPalette.white.withValues(alpha: 0.92),
                      width: 2,
                    ),
                    boxShadow: KidShadows.button,
                  ),
                  padding: EdgeInsets.all(avatarSize * 0.08),
                  child: ClipOval(
                    child: AvatarFaceImage(
                      expressions: _expressionsFor(widget.state),
                      excludeFromSemantics: true,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
