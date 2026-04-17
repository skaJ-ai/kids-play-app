import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/ui/toy_panel.dart';

void main() {
  test(
    're-exports ToyPanelDensity for callers importing only toy_panel.dart',
    () {
      expect(ToyPanelDensity.compact, isA<ToyPanelDensity>());
    },
  );
}
