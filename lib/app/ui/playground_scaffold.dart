import 'package:flutter/material.dart';

import 'kid_theme.dart';

class PlaygroundScaffold extends StatelessWidget {
  const PlaygroundScaffold({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
    this.showRoad = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool showRoad;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        key: const Key('playground-background'),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [KidPalette.skyTop, KidPalette.skyBottom],
          ),
        ),
        child: Stack(
          children: [
            const Positioned(top: 26, left: 40, child: _GlowBubble(size: 92)),
            const Positioned(top: 58, right: 84, child: _GlowBubble(size: 62)),
            const Positioned(bottom: 118, right: 26, child: _GlowBubble(size: 132)),
            const Positioned(top: 88, left: 180, child: _CloudPuff(width: 112)),
            const Positioned(top: 38, right: 190, child: _CloudPuff(width: 84)),
            if (showRoad)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  key: const Key('playground-road'),
                  height: 92,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF59738E), Color(0xFF425A72)],
                    ),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: Align(
                    child: Container(
                      width: 180,
                      height: 8,
                      decoration: BoxDecoration(
                        color: KidPalette.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              ),
            SafeArea(
              child: Padding(
                padding: padding,
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowBubble extends StatelessWidget {
  const _GlowBubble({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: KidPalette.white.withValues(alpha: 0.24),
      ),
    );
  }
}

class _CloudPuff extends StatelessWidget {
  const _CloudPuff({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: width * 0.44,
      child: Stack(
        children: [
          Positioned(
            left: width * 0.12,
            bottom: 0,
            child: _cloudCircle(width * 0.28),
          ),
          Positioned(
            left: width * 0.32,
            top: 0,
            child: _cloudCircle(width * 0.34),
          ),
          Positioned(
            right: width * 0.12,
            bottom: width * 0.02,
            child: _cloudCircle(width * 0.28),
          ),
          Positioned(
            left: width * 0.18,
            right: width * 0.18,
            bottom: 0,
            child: Container(
              height: width * 0.16,
              decoration: BoxDecoration(
                color: KidPalette.white.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cloudCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: KidPalette.white.withValues(alpha: 0.88),
        shape: BoxShape.circle,
      ),
    );
  }
}
