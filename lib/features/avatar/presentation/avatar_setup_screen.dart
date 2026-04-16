import 'package:flutter/material.dart';

import '../../../app/ui/kid_theme.dart';
import '../../../app/ui/playground_scaffold.dart';
import '../../../app/ui/toy_button.dart';
import '../../../app/ui/toy_panel.dart';
import '../domain/avatar_expression.dart';

class AvatarSetupScreen extends StatelessWidget {
  const AvatarSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaygroundScaffold(
      showRoad: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 420;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 12 : 16,
                      vertical: compact ? 8 : 10,
                    ),
                    decoration: BoxDecoration(
                      color: KidPalette.white.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: KidShadows.panel,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_rounded,
                          color: KidPalette.coralDark,
                          size: compact ? 18 : 22,
                        ),
                        SizedBox(width: compact ? 6 : 8),
                        Text(
                          '부모 설정',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: KidPalette.navy,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (!compact)
                    Text(
                      '아이 얼굴 표정을 준비해요',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: KidPalette.coralDark,
                      ),
                    ),
                ],
              ),
              SizedBox(height: compact ? 12 : 18),
              Text(
                '표정 카드 만들기',
                textAlign: TextAlign.center,
                style: compact
                    ? Theme.of(context).textTheme.headlineSmall
                    : Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: compact ? 8 : 10),
              Text(
                '보통부터 놀람까지 5개 표정을 넣으면 더 다양한 반응을 만들 수 있어요.',
                textAlign: TextAlign.center,
                maxLines: compact ? 2 : 3,
                overflow: TextOverflow.ellipsis,
                style: compact
                    ? Theme.of(context).textTheme.titleSmall
                    : Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: compact ? 12 : 18),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ToyPanel(
                        backgroundColor: KidPalette.white.withValues(alpha: 0.95),
                        padding: EdgeInsets.all(compact ? 14 : 20),
                        child: Wrap(
                          spacing: compact ? 10 : 14,
                          runSpacing: compact ? 10 : 14,
                          children: [
                            for (final expression in AvatarExpression.values)
                              SizedBox(
                                width: compact ? 206 : 220,
                                child: _ExpressionCard(expression: expression),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: compact ? 10 : 14),
                      ToyPanel(
                        backgroundColor: KidPalette.lilac.withValues(alpha: 0.7),
                        padding: EdgeInsets.all(compact ? 14 : 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '부모님 안내',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: KidPalette.coralDark,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            SizedBox(height: compact ? 8 : 10),
                            Text(
                              '먼저 보통/웃음 표정부터 넣고, 나머지 표정은 천천히 추가해도 괜찮아요.',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(color: KidPalette.navy),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: compact ? 10 : 14),
                      SizedBox(
                        width: compact ? 180 : 240,
                        child: ToyButton(
                          label: compact ? '나중에 하기' : '나중에 이어서 하기',
                          icon: Icons.check_circle_rounded,
                          height: compact ? 58 : 72,
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ExpressionCard extends StatelessWidget {
  const _ExpressionCard({required this.expression});

  final AvatarExpression expression;

  @override
  Widget build(BuildContext context) {
    return ToyPanel(
      padding: const EdgeInsets.all(14),
      backgroundColor: KidPalette.creamWarm,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 210;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: KidPalette.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      expression.label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: KidPalette.coralDark,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.add_a_photo_rounded,
                    color: KidPalette.navy.withValues(alpha: 0.7),
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: KidPalette.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: EdgeInsets.all(compact ? 12 : 16),
                child: compact
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 68,
                            child: Image.asset(
                              'assets/generated/images/hero/hero_face.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            expression.shortPrompt,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: KidPalette.navy,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '아직 넣지 않았어요',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: KidPalette.body,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 88,
                              child: Image.asset(
                                'assets/generated/images/hero/hero_face.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  expression.shortPrompt,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: KidPalette.navy,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '아직 넣지 않았어요',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: KidPalette.body,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
