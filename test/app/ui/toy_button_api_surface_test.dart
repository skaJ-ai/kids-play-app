import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/ui/toy_button.dart';

void main() {
  test(
    're-exports ToyButtonDensity for callers importing only toy_button.dart',
    () {
      expect(ToyButtonDensity.compact, isA<ToyButtonDensity>());
    },
  );
}
