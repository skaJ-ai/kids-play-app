import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/audio/audio_cue.dart';
import 'package:kids_play_app/app/audio/audio_service.dart';
import 'package:kids_play_app/app/services/app_services.dart';
import 'package:kids_play_app/app/services/progress_store.dart';
import 'package:kids_play_app/app/services/speech_cue_service.dart';
import 'package:kids_play_app/features/hangul/data/hangul_lesson_repository.dart';
import 'package:kids_play_app/features/hangul/presentation/hangul_learn_screen.dart';

void main() {
  testWidgets('shows the first hangul card and advances to the next one', (
    WidgetTester tester,
  ) async {
    final repository = HangulLessonRepository(
      assetBundle: _FakeAssetBundle({
        HangulLessonRepository.manifestPath: jsonEncode({
          'lessons': [
            {
              'id': 'basic_consonants_1',
              'title': '기본 자음 1',
              'cards': [
                {'symbol': 'ㄱ', 'label': '기역, ㄱ', 'hint': '큰 카드로 기역을 천천히 봐요'},
                {'symbol': 'ㄴ', 'label': '니은, ㄴ', 'hint': '니은을 손가락으로 콕 눌러봐요'},
              ],
            },
          ],
        }),
      }),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HangulLearnScreen(
          repository: repository,
          lessonId: 'basic_consonants_1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('기본 자음 1'), findsOneWidget);
    expect(find.text('기역, ㄱ'), findsOneWidget);
    expect(find.text('1 / 2'), findsOneWidget);

    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    expect(find.text('니은, ㄴ'), findsOneWidget);
    expect(find.text('2 / 2'), findsOneWidget);
  });

  testWidgets('resumes from the saved hangul lesson progress', (
    WidgetTester tester,
  ) async {
    final repository = HangulLessonRepository(
      assetBundle: _FakeAssetBundle({
        HangulLessonRepository.manifestPath: jsonEncode({
          'lessons': [
            {
              'id': 'basic_consonants_1',
              'title': '기본 자음 1',
              'cards': [
                {'symbol': 'ㄱ', 'label': '기역, ㄱ', 'hint': '큰 카드로 기역을 천천히 봐요'},
                {'symbol': 'ㄴ', 'label': '니은, ㄴ', 'hint': '니은을 손가락으로 콕 눌러봐요'},
              ],
            },
          ],
        }),
      }),
    );
    final progressStore = MemoryProgressStore(
      const AppProgressSnapshot(
        lessons: {
          'hangul:basic_consonants_1': LessonProgress(lastViewedIndex: 1),
        },
      ),
    );

    await tester.pumpWidget(
      _wrapWithServices(
        progressStore: progressStore,
        child: HangulLearnScreen(
          repository: repository,
          lessonId: 'basic_consonants_1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('니은, ㄴ'), findsOneWidget);
    expect(find.text('2 / 2'), findsOneWidget);
    expect(find.text('기역, ㄱ'), findsNothing);
  });

  testWidgets(
    'replays the current hangul learn prompt through the injected audio service',
    (WidgetTester tester) async {
      final repository = HangulLessonRepository(
        assetBundle: _FakeAssetBundle({
          HangulLessonRepository.manifestPath: jsonEncode({
            'lessons': [
              {
                'id': 'basic_consonants_1',
                'title': '기본 자음 1',
                'cards': [
                  {'symbol': 'ㄱ', 'label': '기역, ㄱ', 'hint': '큰 카드로 기역을 천천히 봐요'},
                  {'symbol': 'ㄴ', 'label': '니은, ㄴ', 'hint': '니은을 손가락으로 콕 눌러봐요'},
                ],
              },
            ],
          }),
        }),
      );
      final audioService = _FakeAudioService();

      await tester.pumpWidget(
        _wrapWithServices(
          progressStore: MemoryProgressStore(),
          audioService: audioService,
          child: HangulLearnScreen(
            repository: repository,
            lessonId: 'basic_consonants_1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(audioService.promptCalls, hasLength(1));
      expect(audioService.promptCalls.single.categoryId, 'hangul');
      expect(audioService.promptCalls.single.lessonId, 'basic_consonants_1');
      expect(audioService.promptCalls.single.symbol, 'ㄱ');
      expect(audioService.promptCalls.single.fallbackText, '기역, ㄱ');

      await tester.tap(find.byIcon(Icons.volume_up_rounded));
      await tester.pumpAndSettle();

      expect(audioService.promptCalls, hasLength(2));
      expect(audioService.promptCalls.last.categoryId, 'hangul');
      expect(audioService.promptCalls.last.lessonId, 'basic_consonants_1');
      expect(audioService.promptCalls.last.symbol, 'ㄱ');
      expect(audioService.promptCalls.last.fallbackText, '기역, ㄱ');
    },
  );

  testWidgets('keeps the learn screen stable on a compact landscape phone', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(780, 360);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final repository = HangulLessonRepository(
      assetBundle: _FakeAssetBundle({
        HangulLessonRepository.manifestPath: jsonEncode({
          'lessons': [
            {
              'id': 'basic_consonants_1',
              'title': '기본 자음 1',
              'cards': [
                {'symbol': 'ㄱ', 'label': '기역, ㄱ', 'hint': '큰 카드로 기역을 천천히 봐요'},
                {'symbol': 'ㄴ', 'label': '니은, ㄴ', 'hint': '니은을 손가락으로 콕 눌러봐요'},
              ],
            },
          ],
        }),
      }),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HangulLearnScreen(
          repository: repository,
          lessonId: 'basic_consonants_1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('기역, ㄱ'), findsOneWidget);
  });

  testWidgets(
    'shows a restart button on the last card and loops back to start',
    (WidgetTester tester) async {
      final repository = HangulLessonRepository(
        assetBundle: _FakeAssetBundle({
          HangulLessonRepository.manifestPath: jsonEncode({
            'lessons': [
              {
                'id': 'basic_consonants_1',
                'title': '기본 자음 1',
                'cards': [
                  {'symbol': 'ㄱ', 'label': '기역, ㄱ', 'hint': '큰 카드로 기역을 천천히 봐요'},
                  {'symbol': 'ㄴ', 'label': '니은, ㄴ', 'hint': '니은을 손가락으로 콕 눌러봐요'},
                ],
              },
            ],
          }),
        }),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: HangulLearnScreen(
            repository: repository,
            lessonId: 'basic_consonants_1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();

      expect(find.text('처음부터'), findsOneWidget);

      await tester.tap(find.text('처음부터'));
      await tester.pumpAndSettle();

      expect(find.text('기역, ㄱ'), findsOneWidget);
      expect(find.text('1 / 2'), findsOneWidget);
      expect(find.text('다음'), findsOneWidget);
    },
  );

  testWidgets('shows an error message when the hangul lesson fails to load', (
    WidgetTester tester,
  ) async {
    final repository = HangulLessonRepository(
      assetBundle: _FakeAssetBundle({}),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: HangulLearnScreen(
          repository: repository,
          lessonId: 'basic_consonants_1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('한글 카드를 불러오지 못했어요.'), findsOneWidget);
    expect(find.text('다시 시도'), findsOneWidget);
  });
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

Widget _wrapWithServices({
  required ProgressStore progressStore,
  AudioService? audioService,
  required Widget child,
}) {
  return MaterialApp(
    home: AppServicesScope(
      services: AppServices(
        progressStore: progressStore,
        speechCueService: NoopSpeechCueService(),
        audioService: audioService,
      ),
      child: child,
    ),
  );
}

class _FakeAudioService implements AudioService {
  final List<AudioPromptRequest> promptCalls = <AudioPromptRequest>[];
  final List<AudioCue> cueCalls = <AudioCue>[];
  int stopCount = 0;

  @override
  Future<void> playPrompt(AudioPromptRequest request) async {
    promptCalls.add(request);
  }

  @override
  Future<void> playCue(AudioCue cue) async {
    cueCalls.add(cue);
  }

  @override
  Future<void> stop() async {
    stopCount += 1;
  }
}
