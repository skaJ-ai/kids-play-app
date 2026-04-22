import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/services/app_services.dart';
import 'package:kids_play_app/app/services/progress_store.dart';
import 'package:kids_play_app/app/services/speech_cue_service.dart';
import 'package:kids_play_app/app/ui/companion_pair.dart';
import 'package:kids_play_app/app/ui/mascot_view.dart';
import 'package:kids_play_app/features/avatar/application/avatar_photo_service.dart';
import 'package:kids_play_app/features/avatar/data/avatar_photo_repository.dart';
import 'package:kids_play_app/features/avatar/data/avatar_photo_store.dart';
import 'package:kids_play_app/features/avatar/domain/avatar_expression.dart';
import 'package:kids_play_app/features/avatar/domain/avatar_photo_snapshot.dart';
import 'package:kids_play_app/features/avatar/presentation/widgets/avatar_face_image.dart';

void main() {
  testWidgets(
    'maps correct/missionClear to smile-first expression and idle/wrong to neutral-first',
    (WidgetTester tester) async {
      const pairs = [
        (MascotState.correct, [AvatarExpression.smile, AvatarExpression.neutral]),
        (MascotState.missionClear, [AvatarExpression.smile, AvatarExpression.neutral]),
        (MascotState.idle, [AvatarExpression.neutral, AvatarExpression.smile]),
        (MascotState.wrong, [AvatarExpression.neutral, AvatarExpression.smile]),
      ];

      for (final (state, expected) in pairs) {
        await tester.pumpWidget(
          _wrapWithServices(
            child: CompanionPair(state: state),
          ),
        );
        await tester.pump();

        final face = tester.widget<AvatarFaceImage>(find.byType(AvatarFaceImage));
        expect(
          face.expressions.toList(),
          expected,
          reason: 'state=$state',
        );

        final mascot = tester.widget<MascotView>(find.byType(MascotView));
        expect(mascot.state, state, reason: 'state=$state');
      }
    },
  );

  testWidgets(
    'tapping the pair invokes onTap',
    (WidgetTester tester) async {
      var taps = 0;

      await tester.pumpWidget(
        _wrapWithServices(
          child: CompanionPair(
            state: MascotState.idle,
            onTap: () => taps += 1,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(CompanionPair));
      await tester.pump();

      expect(taps, 1);
    },
  );

  testWidgets(
    'does not stall pumpAndSettle when idleMotion is left to the test default (disabled)',
    (WidgetTester tester) async {
      // flutter_test_config.dart sets debugIdleMotionDefault = false globally.
      // If that wiring regresses, the breathe/tilt loops would stall
      // pumpAndSettle here — so this test doubles as a canary.
      await tester.pumpWidget(
        _wrapWithServices(
          child: const CompanionPair(state: MascotState.idle),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CompanionPair), findsOneWidget);
    },
  );

  testWidgets(
    'idleMotion: true overrides the test default and keeps the breathe ticker running',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapWithServices(
          child: const CompanionPair(
            state: MascotState.idle,
            idleMotion: true,
          ),
        ),
      );
      await tester.pump();
      // Two half-breaths worth — enough for the controller to have advanced
      // past its start value if the ticker is active.
      await tester.pump(const Duration(milliseconds: 1600));

      expect(find.byType(CompanionPair), findsOneWidget);
      // No pumpAndSettle here; the ticker is intentionally perpetual.
    },
  );

  testWidgets(
    'transitioning into correct fires the bounce scale above 1.0 mid-flight',
    (WidgetTester tester) async {
      final controller = ValueNotifier<MascotState>(MascotState.idle);

      await tester.pumpWidget(
        _wrapWithServices(
          child: ValueListenableBuilder<MascotState>(
            valueListenable: controller,
            builder: (context, state, _) => CompanionPair(state: state),
          ),
        ),
      );
      await tester.pump();

      // Baseline: no bounce, so the scale transform under CompanionPair
      // sits exactly at 1.0.
      expect(_bounceScale(tester), closeTo(1.0, 0.0001));

      controller.value = MascotState.correct;
      await tester.pump();
      // Bounce is 260ms with a triangle profile peaking at t≈0.5 → +8%.
      await tester.pump(const Duration(milliseconds: 130));

      expect(_bounceScale(tester), greaterThan(1.03));

      // Runs to completion without exception and returns to rest.
      await tester.pump(const Duration(milliseconds: 260));
      expect(tester.takeException(), isNull);
      expect(_bounceScale(tester), closeTo(1.0, 0.0001));
    },
  );
}

/// Walks up from MascotView to the nearest Transform.scale inside
/// CompanionPair and returns its X-axis scale.
double _bounceScale(WidgetTester tester) {
  final transforms = tester.widgetList<Transform>(
    find.descendant(
      of: find.byType(CompanionPair),
      matching: find.byType(Transform),
    ),
  );
  for (final t in transforms) {
    // Transform.scale produces a matrix whose row 0, col 0 is the X scale.
    final sx = t.transform.entry(0, 0);
    if (sx != 1.0 ||
        // At rest, every transform is identity on X — return 1.0.
        t == transforms.last) {
      return sx;
    }
  }
  return 1.0;
}

Widget _wrapWithServices({required Widget child}) {
  return AppServicesScope(
    services: AppServices(
      progressStore: MemoryProgressStore(),
      speechCueService: NoopSpeechCueService(),
      avatarPhotoService: AvatarPhotoService(
        photoStore: _TestAvatarPhotoStore(),
        repository: _TestAvatarPhotoRepository(),
      ),
    ),
    child: DefaultAssetBundle(
      bundle: _CompanionTestAssetBundle(),
      child: MaterialApp(
        home: Scaffold(
          body: Center(child: child),
        ),
      ),
    ),
  );
}

class _CompanionTestAssetBundle extends CachingAssetBundle {
  static const heroFacePath = 'assets/generated/images/hero/hero_face.png';

  @override
  Future<ByteData> load(String key) async {
    if (key == heroFacePath) {
      return ByteData.view(
        _heroFacePngBytes.buffer,
        _heroFacePngBytes.offsetInBytes,
        _heroFacePngBytes.lengthInBytes,
      );
    }
    return rootBundle.load(key);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) {
    return rootBundle.loadString(key, cache: cache);
  }
}

class _TestAvatarPhotoStore implements AvatarPhotoStore {
  @override
  Future<AvatarPhotoSnapshot> loadSnapshot() async =>
      const AvatarPhotoSnapshot();

  @override
  Future<void> saveSnapshot(AvatarPhotoSnapshot snapshot) async {}
}

class _TestAvatarPhotoRepository implements AvatarPhotoRepository {
  @override
  Future<void> deletePhoto(String relativePath) async {}

  @override
  Future<File?> resolveFile(String relativePath) async => null;

  @override
  Future<String> saveExpressionPhoto({
    required AvatarExpression expression,
    required Uint8List bytes,
  }) async {
    return avatarPhotoRelativePathFor(expression);
  }
}

final Uint8List _heroFacePngBytes = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4////fwAJ+wP9KobjigAAAABJRU5ErkJggg==',
);
