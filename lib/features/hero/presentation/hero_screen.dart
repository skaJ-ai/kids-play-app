import 'package:flutter/material.dart';

import '../../home/presentation/home_screen.dart';

class HeroScreen extends StatelessWidget {
  const HeroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFDFF6FF), Color(0xFFFFF6E2)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.66),
                      borderRadius: BorderRadius.circular(36),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 132,
                            height: 132,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD86E),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: const Icon(
                              Icons.directions_car_rounded,
                              size: 72,
                              color: Color(0xFF1E4A7A),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            '승원이의 빵빵 놀이터',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF184A78),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '빵빵 출발!',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFF06275),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '큰 카드와 쉬운 퀴즈로 한글, 알파벳, 숫자를 만나요.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF35658F),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 78,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const HomeScreen(),
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF4B98FF),
                      foregroundColor: Colors.white,
                      textStyle: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text('플레이하기'),
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
