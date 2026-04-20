import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/audio/audio_cue.dart';
import 'package:kids_play_app/app/audio/audio_service.dart';
import 'package:kids_play_app/app/services/app_services.dart';
import 'package:kids_play_app/app/services/progress_store.dart';
import 'package:kids_play_app/features/home/data/home_catalog_repository.dart';
import 'package:kids_play_app/features/home/presentation/home_screen.dart';

void main() {
  testWidgets('home plays an intro prompt when it appears', (
    WidgetTester tester,
  ) async {
    final audioService = _RecordingAudioService();

    await tester.pumpWidget(
      _wrapWithServices(
        audioService: audioService,
        child: HomeScreen(catalogRepository: _fakeHomeCatalogRepository()),
      ),
    );
    await tester.pumpAndSettle();

    expect(audioService.promptRequests, hasLength(1));
    expect(audioService.promptRequests.single.categoryId, 'home');
    expect(audioService.promptRequests.single.lessonId, 'garage');
    expect(audioService.promptRequests.single.symbol, '오늘의 차고');
    expect(
      audioService.promptRequests.single.fallbackText,
      '오늘의 차고예요. 좋아하는 차고를 골라요.',
    );
  });

  testWidgets('home replay button repeats the intro prompt', (
    WidgetTester tester,
  ) async {
    final audioService = _RecordingAudioService();

    await tester.pumpWidget(
      _wrapWithServices(
        audioService: audioService,
        child: HomeScreen(catalogRepository: _fakeHomeCatalogRepository()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home-replay-prompt')), findsOneWidget);
    expect(audioService.promptRequests, hasLength(1));

    await tester.tap(find.byKey(const Key('home-replay-prompt')));
    await tester.pumpAndSettle();

    expect(audioService.promptRequests, hasLength(2));
    expect(
      audioService.promptRequests.last.fallbackText,
      '오늘의 차고예요. 좋아하는 차고를 골라요.',
    );
  });

  testWidgets('home skips the intro prompt when voice prompts are off', (
    WidgetTester tester,
  ) async {
    final audioService = _RecordingAudioService();

    await tester.pumpWidget(
      _wrapWithServices(
        audioService: audioService,
        snapshot: const AppProgressSnapshot(voicePromptsEnabled: false),
        child: HomeScreen(catalogRepository: _fakeHomeCatalogRepository()),
      ),
    );
    await tester.pumpAndSettle();

    expect(audioService.promptRequests, isEmpty);
  });
}

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

HomeCatalogRepository _fakeHomeCatalogRepository() {
  return HomeCatalogRepository(
    assetBundle: _FakeAssetBundle({
      HomeCatalogRepository.manifestPath: jsonEncode({
        'categories': [
          {
            'id': 'hangul',
            'label': '한글',
            'description': '자음과 모음을 만나요',
            'backgroundColor': '#FFE699',
            'icon': 'text_fields_rounded',
          },
          {
            'id': 'alphabet',
            'label': '알파벳',
            'description': '대문자와 소문자를 만나요',
            'backgroundColor': '#B9F4D0',
            'icon': 'abc_rounded',
          },
          {
            'id': 'numbers',
            'label': '숫자',
            'description': '숫자 놀이를 시작해요',
            'backgroundColor': '#FFC6D9',
            'icon': 'looks_one_rounded',
          },
        ],
      }),
    }),
  );
}

class _FakeAssetBundle extends CachingAssetBundle {
  _FakeAssetBundle(this._assets);

  final Map<String, String> _assets;

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final value = _assets[key];
    if (value == null) {
      throw Exception('Missing fake asset for $key');
    }
    return value;
  }

  @override
  Future<ByteData> load(String key) async {
    final string = await loadString(key);
    final bytes = Uint8List.fromList(utf8.encode(string));
    return ByteData.view(bytes.buffer);
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
