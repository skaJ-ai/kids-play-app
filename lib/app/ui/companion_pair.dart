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
  });

  final MascotState state;
  final double size;
  final VoidCallback? onTap;
  final Key? avatarKey;
  final Key? mascotKey;

  @override
  State<CompanionPair> createState() => _CompanionPairState();
}

class _CompanionPairState extends State<CompanionPair>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounce;

  @override
  void initState() {
    super.initState();
    _bounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
  }

  @override
  void didUpdateWidget(covariant CompanionPair oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state != oldWidget.state &&
        (widget.state == MascotState.correct ||
            widget.state == MascotState.missionClear)) {
      _bounce.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
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
        animation: _bounce,
        builder: (context, child) {
          final t = _bounce.value;
          final scale = 1 + 0.08 * (1 - (2 * t - 1).abs());
          return Transform.scale(scale: scale, child: child);
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
