import 'package:flutter/material.dart';

import '../../../app/ui/app_colors.dart';
import '../../../app/ui/play_background.dart';
import '../../home/presentation/home_screen.dart';

class HeroScreen extends StatelessWidget {
  const HeroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PlayBackground(
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxHeight < 420;
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  isCompact ? 20 : 32,
                  isCompact ? 8 : 20,
                  isCompact ? 20 : 32,
                  34, // leaves room for road strip
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ── Left: hero face ────────────────────────────
                    Expanded(
                      flex: 5,
                      child: Center(
                        child: _HeroFace(size: isCompact ? 150 : 200),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // ── Right: title + button ──────────────────────
                    Expanded(
                      flex: 7,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _TitleCard(isCompact: isCompact),
                          SizedBox(height: isCompact ? 12 : 20),
                          _PlayButton(isCompact: isCompact),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ── Hero face ──────────────────────────────────────────────────────────────────

class _HeroFace extends StatelessWidget {
  const _HeroFace({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: AppColors.hangulBottom, width: 5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowMid,
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Image.asset(
        'assets/generated/images/hero/hero_face.png',
        key: const Key('hero-face-image'),
        fit: BoxFit.cover,
      ),
    );
  }
}

// ── Title card ─────────────────────────────────────────────────────────────────

class _TitleCard extends StatelessWidget {
  const _TitleCard({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 18 : 24,
        vertical: isCompact ? 14 : 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(isCompact ? 20 : 28),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '승원이의 빵빵 놀이터',
            style: TextStyle(
              fontSize: isCompact ? 22 : 30,
              fontWeight: FontWeight.w900,
              color: AppColors.navy,
              height: 1.1,
            ),
          ),
          SizedBox(height: isCompact ? 6 : 10),
          Text(
            '빵빵 출발!',
            style: TextStyle(
              fontSize: isCompact ? 16 : 20,
              fontWeight: FontWeight.w800,
              color: AppColors.coral,
            ),
          ),
          if (!isCompact) ...[
            const SizedBox(height: 8),
            const Text(
              '한글 · 알파벳 · 숫자',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.midBlue,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Play button ────────────────────────────────────────────────────────────────

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isCompact ? 56 : 68,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isCompact ? 20 : 24),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFAA00), Color(0xFFFF7043)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55FF7043),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(isCompact ? 20 : 24),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const HomeScreen(),
              ),
            );
          },
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '🚗 ',
                  style: TextStyle(fontSize: isCompact ? 20 : 24),
                ),
                Text(
                  '플레이하기',
                  style: TextStyle(
                    fontSize: isCompact ? 20 : 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
