import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/ui/companion_pair.dart';
import 'package:kids_play_app/app/ui/play_choice_card.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  // CompanionPair's idle breathe/tilt loops keep a ticker running forever,
  // which stalls pumpAndSettle. Force-disable them for all widget tests by
  // default; tests that want to exercise the idle loop explicitly can still
  // override on the widget via `idleMotion: true`.
  CompanionPair.debugIdleMotionDefault = false;
  // Same reasoning for the correct-answer hint pulse on PlayChoiceCard.
  PlayChoiceCard.debugHintPulseEnabled = false;
  await testMain();
}
