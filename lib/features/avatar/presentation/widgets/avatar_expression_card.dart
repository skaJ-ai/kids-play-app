import 'package:flutter/material.dart';

import '../../../../app/ui/kid_theme.dart';
import '../../../../app/ui/toy_button.dart';
import '../../../../app/ui/toy_panel.dart';
import '../../domain/avatar_expression.dart';
import 'avatar_face_image.dart';

class AvatarExpressionCard extends StatelessWidget {
  const AvatarExpressionCard({
    super.key,
    required this.expression,
    required this.hasSavedPhoto,
    required this.onImportPressed,
    this.onClearPressed,
  }) : assert(!hasSavedPhoto || onClearPressed != null);

  final AvatarExpression expression;
  final bool hasSavedPhoto;
  final VoidCallback onImportPressed;
  final VoidCallback? onClearPressed;

  @override
  Widget build(BuildContext context) {
    final statusCopy = hasSavedPhoto ? '사진이 준비됐어요' : '아직 넣지 않았어요';
    final importLabel = hasSavedPhoto ? '다시 자르기' : '사진 넣기';
    final icon = hasSavedPhoto ? Icons.crop_rounded : Icons.add_a_photo_rounded;

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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
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
                    icon,
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: compact ? 68 : 88,
                      child: AvatarFaceImage(expressions: [expression]),
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
                      statusCopy,
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: KidPalette.body),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ToyButton(
                  key: Key('avatar-import-${expression.name}'),
                  label: importLabel,
                  icon: icon,
                  density: compact
                      ? ToyButtonDensity.tight
                      : ToyButtonDensity.compact,
                  height: compact ? 48 : 52,
                  onPressed: onImportPressed,
                ),
              ),
              if (hasSavedPhoto) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ToyButton(
                    key: Key('avatar-clear-${expression.name}'),
                    label: '지우기',
                    icon: Icons.delete_outline_rounded,
                    tone: ToyButtonTone.secondary,
                    density: compact
                        ? ToyButtonDensity.tight
                        : ToyButtonDensity.compact,
                    height: compact ? 44 : 48,
                    onPressed: onClearPressed,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
