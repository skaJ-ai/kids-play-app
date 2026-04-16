import 'package:flutter/material.dart';

import '../../../app/ui/app_colors.dart';
import '../../../app/ui/play_background.dart';
import '../data/home_catalog_repository.dart';
import 'category_hub_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<HomeCategory>>? _categoriesFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _categoriesFuture ??= HomeCatalogRepository(
      assetBundle: DefaultAssetBundle.of(context),
    ).loadCategories();
  }

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
                const _HomeTitle(),
                const SizedBox(height: 14),
                Expanded(
                  child: FutureBuilder<List<HomeCategory>>(
                    future: _categoriesFuture,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        );
                      }
                      final categories = snapshot.data!;
                      return Row(
                        children: [
                          for (final category in categories) ...[
                            Expanded(
                              child: _CategoryCard(category: category),
                            ),
                            if (category != categories.last)
                              const SizedBox(width: 14),
                          ],
                        ],
                      );
                    },
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

// ── Title ──────────────────────────────────────────────────────────────────────

class _HomeTitle extends StatelessWidget {
  const _HomeTitle();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: const Text(
        '어떤 놀이터로 갈까?',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: AppColors.navy,
        ),
      ),
    );
  }
}

// ── Category card ──────────────────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category});

  final HomeCategory category;

  static const _symbols = {
    'hangul': '가',
    'alphabet': 'Aa',
    'numbers': '1',
  };

  static const _gradients = {
    'hangul': LinearGradient(
      colors: [AppColors.hangulTop, AppColors.hangulBottom],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    'alphabet': LinearGradient(
      colors: [AppColors.alphabetTop, AppColors.alphabetBottom],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    'numbers': LinearGradient(
      colors: [AppColors.numberTop, AppColors.numberBottom],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  };

  LinearGradient get _gradient =>
      _gradients[category.id] ??
      const LinearGradient(colors: [Color(0xFFE0E0E0), Color(0xFFBDBDBD)]);

  String get _symbol => _symbols[category.id] ?? '?';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: _gradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowMid,
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => CategoryHubScreen(category: category),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Big symbol badge
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _symbol,
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  category.label,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  category.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.90),
                    height: 1.3,
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
