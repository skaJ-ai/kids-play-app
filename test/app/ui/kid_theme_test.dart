import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/ui/kid_theme.dart';

void main() {
  test('buildKidTheme exposes the kid layout tokens extension defaults', () {
    final theme = buildKidTheme();
    final layout = theme.extension<KidLayoutTheme>();

    expect(layout, isNotNull);
    expect(layout!.button.regular.height, 64);
    expect(layout.button.compact.height, 56);
    expect(layout.panel.regular.padding, const EdgeInsets.all(24));
    expect(layout.panel.regular.radius, 32);
    expect(layout.panel.compact.padding, const EdgeInsets.all(14));
    expect(layout.panel.compact.radius, 32);
    expect(layout.panel.tight.padding, const EdgeInsets.all(12));
    expect(layout.panel.tight.radius, 24);
  });

  test('preserves the legacy static KidPanelTokens accessors', () {
    expect(KidPanelTokens.regular.padding, const EdgeInsets.all(24));
    expect(KidPanelTokens.regular.radius, 32);
    expect(KidPanelTokens.compact.padding, const EdgeInsets.all(14));
    expect(KidPanelTokens.compact.radius, 32);
    expect(
      KidPanelTokens.forDensity(ToyPanelDensity.tight).padding,
      const EdgeInsets.all(12),
    );
    expect(KidPanelTokens.forDensity(ToyPanelDensity.tight).radius, 24);
  });
}
