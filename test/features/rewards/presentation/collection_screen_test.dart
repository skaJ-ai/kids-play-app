import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/services/app_services.dart';
import 'package:kids_play_app/app/services/progress_store.dart';
import 'package:kids_play_app/app/services/speech_cue_service.dart';
import 'package:kids_play_app/features/rewards/domain/reward_catalog.dart';
import 'package:kids_play_app/features/rewards/domain/reward_models.dart';
import 'package:kids_play_app/features/rewards/presentation/collection_screen.dart';

void main() {
  testWidgets('renders a category section per reward pack', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(progressStore: MemoryProgressStore(), child: const CollectionScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('내 스티커 모음'), findsOneWidget);
    expect(find.text('알파벳 자동차 스티커'), findsOneWidget);
    expect(find.text('한글 자동차 스티커'), findsOneWidget);
    expect(find.text('숫자 자동차 스티커'), findsOneWidget);
  });

  testWidgets('locks rewards that have not been earned yet', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(progressStore: MemoryProgressStore(), child: const CollectionScreen()),
    );
    await tester.pumpAndSettle();

    final firstAlphabet = rewardCatalog.first.rewards.first;
    expect(
      find.byKey(Key('collection-locked-${firstAlphabet.id}')),
      findsOneWidget,
    );
    expect(find.text('0 / 5'), findsOneWidget);
  });

  testWidgets('shows an earned reward with its emoji and bumped counter', (
    WidgetTester tester,
  ) async {
    final reward = rewardCatalog.first.rewards.first;
    final progressStore = MemoryProgressStore();
    await progressStore.recordRewardEvent(
      RewardEvent(
        at: DateTime.utc(2026, 4, 20),
        lessonId: reward.lessonId,
        reward: reward,
      ),
    );

    await tester.pumpWidget(
      _wrap(progressStore: progressStore, child: const CollectionScreen()),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(Key('collection-unlocked-${reward.id}')),
      findsOneWidget,
    );
    expect(find.text(reward.emoji), findsOneWidget);
    expect(find.text('1 / 5'), findsOneWidget);
  });

  testWidgets('keeps the collection readable on a compact landscape phone', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(780, 360);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      _wrap(progressStore: MemoryProgressStore(), child: const CollectionScreen()),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('내 스티커 모음'), findsOneWidget);
    expect(find.byKey(const Key('collection-back')), findsOneWidget);
  });
}

Widget _wrap({
  required ProgressStore progressStore,
  required Widget child,
}) {
  return MaterialApp(
    home: AppServicesScope(
      services: AppServices(
        progressStore: progressStore,
        speechCueService: NoopSpeechCueService(),
      ),
      child: child,
    ),
  );
}
