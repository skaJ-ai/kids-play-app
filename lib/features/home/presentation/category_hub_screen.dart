import 'package:flutter/material.dart';

import '../../../app/ui/app_colors.dart';
import '../../../app/ui/play_background.dart';
import '../../hangul/data/hangul_lesson_repository.dart';
import '../../hangul/presentation/hangul_learn_screen.dart';
import '../../hangul/presentation/hangul_quiz_screen.dart';
import '../data/home_catalog_repository.dart';

class CategoryHubScreen extends StatelessWidget {
  const CategoryHubScreen({
    super.key,
    required this.category,
    this.hangulLessonRepository,
  });

  final HomeCategory category;
  final HangulLessonRepository? hangulLessonRepository;

  bool get _supportsLearnMode => category.id == 'hangul';
  bool get _supportsGameMode => category.id == 'hangul';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PlayBackground(
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 34),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HubTitle(category: category),
                const SizedBox(height: 16),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _ModeCard(
                          title: '학습하기',
                          subtitle: _supportsLearnMode
                              ? '큰 카드로 천천히 익혀요'
                              : '곧 만나요',
                          emoji: '📚',
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.learnTop,
                              AppColors.learnBottom,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          enabled: _supportsLearnMode,
                          onTap: _supportsLearnMode
                              ? () => _openLearnMode(context)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _ModeCard(
                          title: '게임하기',
                          subtitle: _supportsGameMode
                              ? '퀴즈로 신나게 맞혀요'
                              : '곧 만나요',
                          emoji: '🎮',
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.gameTop,
                              AppColors.gameBottom,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          enabled: _supportsGameMode,
                          onTap: _supportsGameMode
                              ? () => _openGameMode(context)
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openLearnMode(BuildContext context) {
    if (category.id == 'hangul') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              HangulLearnScreen(repository: hangulLessonRepository),
        ),
      );
    }
  }

  void _openGameMode(BuildContext context) {
    if (category.id == 'hangul') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              HangulQuizScreen(repository: hangulLessonRepository),
        ),
      );
    }
  }
}

// ── Hub title ──────────────────────────────────────────────────────────────────

class _HubTitle extends StatelessWidget {
  const _HubTitle({required this.category});

  final HomeCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '${category.label} 놀이터',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            category.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.midBlue,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mode card ──────────────────────────────────────────────────────────────────

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.gradient,
    required this.enabled,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String emoji;
  final LinearGradient gradient;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.55,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: enabled ? AppColors.shadowMid : AppColors.shadowSoft,
              blurRadius: enabled ? 18 : 8,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(emoji, style: const TextStyle(fontSize: 34)),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.92),
                      height: 1.3,
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
}
