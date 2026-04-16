import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = const [
      _CategoryCardData('한글', Color(0xFFFFE699), Icons.text_fields_rounded),
      _CategoryCardData('알파벳', Color(0xFFB9F4D0), Icons.abc_rounded),
      _CategoryCardData('숫자', Color(0xFFFFC6D9), Icons.looks_one_rounded),
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '어떤 놀이터로 갈까?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF184A78),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Row(
                  children: [
                    for (final card in cards) ...[
                      Expanded(child: _CategoryCard(data: card)),
                      if (card != cards.last) const SizedBox(width: 16),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.data});

  final _CategoryCardData data;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: data.color,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(data.icon, size: 72, color: const Color(0xFF184A78)),
            const SizedBox(height: 16),
            Text(
              data.label,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: const Color(0xFF184A78),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '학습 / 게임',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2E628F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCardData {
  const _CategoryCardData(this.label, this.color, this.icon);

  final String label;
  final Color color;
  final IconData icon;
}
