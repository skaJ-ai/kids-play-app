import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/audio/audio_cue.dart';
import 'package:kids_play_app/app/audio/audio_service.dart';
import 'package:kids_play_app/app/services/app_services.dart';
import 'package:kids_play_app/app/services/progress_store.dart';
import 'package:kids_play_app/features/home/data/home_catalog_repository.dart';
import 'package:kids_play_app/features/home/presentation/category_hub_screen.dart';

void main() {
  testWidgets('category hub plays an intro prompt when it appears', (
    WidgetTester tester,
  ) async {
    final audioService = _RecordingAudioService();

    await tester.pumpWidget(
      _wrapWithServices(
        audioService: audioService,
        child: const CategoryHubScreen(category: _hangulCategory),
      ),
    );
    await tester.pumpAndSettle();

    expect(audioService.promptRequests, hasLength(1));
    expect(audioService.promptRequests.single.categoryId, 'hangul');
    expect(audioService.promptRequests.single.lessonId, 'hub');
    expect(audioService.promptRequests.single.symbol, '한글');
    expect(
      audioService.promptRequests.single.fallbackText,
      '한글 차고예요. 배우기나 퀴즈를 골라요.',
    );
  });

  testWidgets('category hub replay button repeats the intro prompt', (
    WidgetTester tester,
  ) async {
    final audioService = _RecordingAudioService();

    await tester.pumpWidget(
      _wrapWithServices(
        audioService: audioService,
        child: const CategoryHubScreen(category: _hangulCategory),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('category-hub-replay-prompt')), findsOneWidget);
    expect(audioService.promptRequests, hasLength(1));

    await tester.tap(find.byKey(const Key('category-hub-replay-prompt')));
    await tester.pumpAndSettle();

    expect(audioService.promptRequests, hasLength(2));
    expect(
      audioService.promptRequests.last.fallbackText,
      '한글 차고예요. 배우기나 퀴즈를 골라요.',
    );
  });

  testWidgets(
    'category hub does not play after it is disposed before settings load',
    (WidgetTester tester) async {
      final audioService = _RecordingAudioService();
      final snapshotCompleter = Completer<AppProgressSnapshot>();

      await tester.pumpWidget(
        _wrapWithServices(
          audioService: audioService,
          progressStore: _DeferredSnapshotProgressStore(snapshotCompleter),
          child: const CategoryHubScreen(category: _hangulCategory),
        ),
      );
      await tester.pump();

      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));

      snapshotCompleter.complete(const AppProgressSnapshot());
      await tester.pumpAndSettle();

      expect(audioService.promptRequests, isEmpty);
    },
  );

  testWidgets('category hub ignores intro prompt errors', (
    WidgetTester tester,
  ) async {
    final audioService = _RecordingAudioService();

    await tester.pumpWidget(
      _wrapWithServices(
        audioService: audioService,
        progressStore: _ThrowingSnapshotProgressStore(
          StateError('snapshot load failed'),
        ),
        child: const CategoryHubScreen(category: _hangulCategory),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(audioService.promptRequests, isEmpty);
  });

  testWidgets(
    'category hub skips the intro prompt when voice prompts are off',
    (WidgetTester tester) async {
      final audioService = _RecordingAudioService();

      await tester.pumpWidget(
        _wrapWithServices(
          audioService: audioService,
          snapshot: const AppProgressSnapshot(voicePromptsEnabled: false),
          child: const CategoryHubScreen(category: _hangulCategory),
        ),
      );
      await tester.pumpAndSettle();

      expect(audioService.promptRequests, isEmpty);
    },
  );
}

const _hangulCategory = HomeCategory(
  id: 'hangul',
  label: '한글',
  description: '자음과 모음을 만나요',
  backgroundColorHex: '#FFE699',
  iconName: 'text_fields_rounded',
);

Widget _wrapWithServices({
  required AudioService audioService,
  ProgressStore? progressStore,
  AppProgressSnapshot snapshot = const AppProgressSnapshot(),
  required Widget child,
}) {
  return AppServicesScope(
    services: AppServices(
      progressStore: progressStore ?? MemoryProgressStore(snapshot),
      audioService: audioService,
    ),
    child: MaterialApp(home: child),
  );
}

class _DeferredSnapshotProgressStore extends MemoryProgressStore {
  _DeferredSnapshotProgressStore(this.snapshotCompleter);

  final Completer<AppProgressSnapshot> snapshotCompleter;

  @override
  Future<AppProgressSnapshot> loadSnapshot() {
    return snapshotCompleter.future;
  }
}

class _ThrowingSnapshotProgressStore extends MemoryProgressStore {
  _ThrowingSnapshotProgressStore(this.error);

  final Object error;

  @override
  Future<AppProgressSnapshot> loadSnapshot() {
    return Future<AppProgressSnapshot>.error(error);
  }
}

class _RecordingAudioService implements AudioService {
  final List<AudioPromptRequest> promptRequests = <AudioPromptRequest>[];
  final List<AudioCue> cueRequests = <AudioCue>[];

  @override
  Future<void> playCue(AudioCue cue) async {
    cueRequests.add(cue);
  }

  @override
  Future<void> playPrompt(AudioPromptRequest request) async {
    promptRequests.add(request);
  }

  @override
  Future<void> stop() async {}
}
