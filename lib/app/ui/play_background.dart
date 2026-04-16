import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Sky-gradient background with clouds and a road strip at the bottom.
/// Wrap it in a [Stack] or use it as the outermost container of a screen.
class PlayBackground extends StatelessWidget {
  const PlayBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Sky gradient
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.skyTop, AppColors.skyBottom],
              ),
            ),
          ),
        ),
        // Clouds
        const Positioned(top: 18, left: 60, child: _Cloud(scale: 0.9)),
        const Positioned(top: 6, left: 230, child: _Cloud(scale: 0.6)),
        const Positioned(top: 22, right: 90, child: _Cloud(scale: 1.1)),
        const Positioned(top: 4, right: 280, child: _Cloud(scale: 0.7)),
        // Road strip
        const Positioned(left: 0, right: 0, bottom: 0, child: _RoadStrip()),
        // Content
        child,
      ],
    );
  }
}

class _Cloud extends StatelessWidget {
  const _Cloud({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final w = 120.0 * scale;
    final h = 54.0 * scale;
    return SizedBox(
      width: w,
      height: h,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            child: _circle(42 * scale),
          ),
          Positioned(
            left: w * 0.22,
            bottom: h * 0.18,
            child: _circle(54 * scale),
          ),
          Positioned(
            left: w * 0.5,
            bottom: 0,
            child: _circle(44 * scale),
          ),
          Positioned(
            left: w * 0.7,
            bottom: h * 0.06,
            child: _circle(36 * scale),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.88),
      ),
    );
  }
}

class _RoadStrip extends StatelessWidget {
  const _RoadStrip();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: CustomPaint(
        painter: _RoadPainter(),
      ),
    );
  }
}

class _RoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()..color = AppColors.road;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), roadPaint);

    // Dashed centre line
    final linePaint = Paint()
      ..color = AppColors.roadLine
      ..strokeWidth = 4;
    const dashW = 36.0;
    const gapW = 28.0;
    final y = size.height / 2;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(x + dashW, y), linePaint);
      x += dashW + gapW;
    }
  }

  @override
  bool shouldRepaint(_RoadPainter oldDelegate) => false;
}
