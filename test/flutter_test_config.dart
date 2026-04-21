import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/ui/companion_pair.dart';
import 'package:kids_play_app/features/lesson/presentation/generic_quiz_screen.dart'
    as generic_quiz;

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  // CompanionPair's idle breathe/tilt loops keep a ticker running forever,
  // which stalls pumpAndSettle. Force-disable them for all widget tests by
  // default; tests that want to exercise the idle loop explicitly can still
  // override on the widget via `idleMotion: true`.
  CompanionPair.debugIdleMotionDefault = false;
  // Same reasoning for the correct-answer hint pulse on quiz choice tiles.
  generic_quiz.debugSetQuizChoiceHintPulseEnabled(false);
  await testMain();
}
