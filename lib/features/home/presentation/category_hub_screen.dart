import 'package:flutter/material.dart';

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${category.label} 놀이터',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF184A78),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                category.description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF35658F),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _ModeButton(
                        title: '학습하기',
                        subtitle: _supportsLearnMode ? '큰 카드로 천천히 익혀요' : '곧 만나요',
                        color: const Color(0xFFFFE699),
                        icon: Icons.menu_book_rounded,
                        onTap: _supportsLearnMode
                            ? () => _openLearnMode(context)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _ModeButton(
                        title: '게임하기',
                        subtitle: _supportsGameMode ? '퀴즈로 신나게 맞혀요' : '곧 만나요',
                        color: const Color(0xFFB9F4D0),
                        icon: Icons.videogame_asset_rounded,
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
    );
  }

  void _openLearnMode(BuildContext context) {
    if (category.id == 'hangul') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => HangulLearnScreen(repository: hangulLessonRepository),
        ),
      );
      return;
    }
  }

  void _openGameMode(BuildContext context) {
    if (category.id == 'hangul') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => HangulQuizScreen(repository: hangulLessonRepository),
        ),
      );
      return;
    }
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;

    return Opacity(
      opacity: isEnabled ? 1 : 0.55,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(32),
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 72, color: const Color(0xFF184A78)),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF184A78),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2E628F),
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
