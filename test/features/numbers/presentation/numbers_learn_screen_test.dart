import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/audio/audio_cue.dart';
import 'package:kids_play_app/app/audio/audio_service.dart';
import 'package:kids_play_app/app/services/app_services.dart';
import 'package:kids_play_app/app/services/progress_store.dart';
import 'package:kids_play_app/app/services/speech_cue_service.dart';
import 'package:kids_play_app/app/ui/kid_theme.dart';
import 'package:kids_play_app/app/ui/toy_button.dart';
import 'package:kids_play_app/app/ui/toy_panel.dart';
import 'package:kids_play_app/features/numbers/data/numbers_lesson_repository.dart';
import 'package:kids_play_app/features/numbers/presentation/numbers_learn_screen.dart';

void main() {
  test('uses numbers_count_1 as the default lesson id', () {
    expect(const NumbersLearnScreen().lessonId, 'numbers_count_1');
  });

  testWidgets(
    'queued prompt playback uses audio service prompt metadata instead of speech cue service',
    (WidgetTester tester) async {
      final repository = NumbersLessonRepository(
        assetBundle: _FakeAssetBundle({
          NumbersLessonRepository.manifestPath: jsonEncode({
            'lessons': [_numbersLesson],
          }),
        }),
      );
      final audio = _RecordingAudioService();
      final speech = _RecordingSpeechCueService();

      await tester.pumpWidget(
        _wrapWithServices(
          audioService: audio,
          speechCueService: speech,
          child: NumbersLearnScreen(
            repository: repository,
            lessonId: 'numbers_count_1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('하나, 1'), findsOneWidget);
      expect(audio.played, hasLength(1));
      final cue = audio.played.single;
      expect(cue, isA<PromptCue>());
      final promptCue = cue as PromptCue;
      expect(
        promptCue.ref.assetPath,
        'assets/generated/audio/voice/prompts/numbers/numbers_count_1_1.mp3',
      );
      expect(promptCue.ref.fallbackText, '하나, 1');
      expect(speech.spoken, isEmpty);
    },
  );

  testWidgets(
    'queued prompt playback is suppressed when voice prompts start disabled',
    (WidgetTester tester) async {
      final repository = NumbersLessonRepository(
        assetBundle: _FakeAssetBundle({
          NumbersLessonRepository.manifestPath: jsonEncode({
            'lessons': [_numbersLesson],
          }),
        }),
      );
      final audio = _RecordingAudioService();
      final speech = _RecordingSpeechCueService();

      await tester.pumpWidget(
        _wrapWithServices(
          progressStore: MemoryProgressStore(
            const AppProgressSnapshot(voicePromptsEnabled: false),
          ),
          audioService: audio,
          speechCueService: speech,
          child: NumbersLearnScreen(
            repository: repository,
            lessonId: 'numbers_count_1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(audio.played, isEmpty);
      expect(speech.spoken, isEmpty);
    },
  );

  testWidgets('shows the first numbers card and advances to the next one', (
    WidgetTester tester,
  ) async {
    final repository = NumbersLessonRepository(
      assetBundle: _FakeAssetBundle({
        NumbersLessonRepository.manifestPath: jsonEncode({
          'lessons': [_numbersLesson],
        }),
      }),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: NumbersLearnScreen(
          repository: repository,
          lessonId: 'numbers_count_1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('숫자 1'), findsOneWidget);
    expect(find.text('하나, 1'), findsOneWidget);
    expect(find.text('1 / 5'), findsOneWidget);

    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    expect(find.text('둘, 2'), findsOneWidget);
    expect(find.text('2 / 5'), findsOneWidget);
  });

  testWidgets('uses named warm and lilac panel tones in the learn body', (
    WidgetTester tester,
  ) async {
    final repository = NumbersLessonRepository(
      assetBundle: _FakeAssetBundle({
        NumbersLessonRepository.manifestPath: jsonEncode({
          'lessons': [_numbersLesson],
        }),
      }),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: NumbersLearnScreen(
          repository: repository,
          lessonId: 'numbers_count_1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    final numberPanelFinder = find.byKey(
      const ValueKey('numbersLearnSymbolPanel'),
    );
    expect(numberPanelFinder, findsOneWidget);
    expect(tester.widget<ToyPanel>(numberPanelFinder).tone, ToyPanelTone.warm);

    final encouragementPanelFinder = find.byKey(
      const ValueKey('numbersLearnEncouragementPanel'),
    );
    expect(encouragementPanelFinder, findsOneWidget);
    expect(
      tester.widget<ToyPanel>(encouragementPanelFinder).tone,
      ToyPanelTone.lilac,
    );
  });

  testWidgets('header pills use calmer chrome with stroke borders', (
    WidgetTester tester,
  ) async {
    final repository = NumbersLessonRepository(
      assetBundle: _FakeAssetBundle({
        NumbersLessonRepository.manifestPath: jsonEncode({
          'lessons': [_numbersLesson],
        }),
      }),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: NumbersLearnScreen(
          repository: repository,
          lessonId: 'numbers_count_1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    _expectHeaderPillChrome(tester, 'numbersLearnModePill');
    _expectHeaderPillChrome(tester, 'numbersLearnProgressPill');
  });

  testWidgets('resumes from the saved numbers lesson progress', (
    WidgetTester tester,
  ) async {
    final repository = NumbersLessonRepository(
      assetBundle: _FakeAssetBundle({
        NumbersLessonRepository.manifestPath: jsonEncode({
          'lessons': [_numbersLesson],
        }),
      }),
    );
    final progressStore = MemoryProgressStore(
      const AppProgressSnapshot(
        lessons: {
          'numbers:numbers_count_1': LessonProgress(lastViewedIndex: 3),
        },
      ),
    );

    await tester.pumpWidget(
      _wrapWithServices(
        progressStore: progressStore,
        child: NumbersLearnScreen(
          repository: repository,
          lessonId: 'numbers_count_1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('넷, 4'), findsOneWidget);
    expect(find.text('4 / 5'), findsOneWidget);
    expect(find.text('하나, 1'), findsNothing);
  });

  testWidgets('propagates themed button height tokens to the 다음 action', (
    WidgetTester tester,
  ) async {
    final repository = NumbersLessonRepository(
      assetBundle: _FakeAssetBundle({
        NumbersLessonRepository.manifestPath: jsonEncode({
          'lessons': [_numbersLesson],
        }),
      }),
    );
    final customLayout = KidLayoutTheme(
      button: KidButtonTokens(
        regular: KidLayoutTheme.defaults.button.regular.copyWith(height: 83),
        compact: KidLayoutTheme.defaults.button.compact.copyWith(height: 39),
      ),
      panel: KidLayoutTheme.defaults.panel,
    );

    Future<void> pumpScreen() async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildKidTheme().copyWith(extensions: [customLayout]),
          home: NumbersLearnScreen(
            repository: repository,
            lessonId: 'numbers_count_1',
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    await pumpScreen();

    final regularCta = _ctaButton(tester);

    expect(regularCta.height, isNull);
    expect(regularCta.density, ToyButtonDensity.regular);
    expect(
      tester.getSize(_ctaButtonFinder()).height,
      customLayout.button.regular.height,
    );

    _setSurfaceSize(tester, const Size(780, 360));
    await pumpScreen();

    final compactCta = _ctaButton(tester);

    expect(compactCta.height, isNull);
    expect(compactCta.density, ToyButtonDensity.compact);
    expect(
      tester.getSize(_ctaButtonFinder()).height,
      customLayout.button.compact.height,
    );
  });

  testWidgets('propagates themed regular button radius to the 다음 action', (
    WidgetTester tester,
  ) async {
    final repository = NumbersLessonRepository(
      assetBundle: _FakeAssetBundle({
        NumbersLessonRepository.manifestPath: jsonEncode({
          'lessons': [_numbersLesson],
        }),
      }),
    );
    final customLayout = KidLayoutTheme(
      button: KidButtonTokens(
        regular: KidLayoutTheme.defaults.button.regular.copyWith(radius: 18),
        compact: KidLayoutTheme.defaults.button.compact,
      ),
      panel: KidLayoutTheme.defaults.panel,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: buildKidTheme().copyWith(extensions: [customLayout]),
        home: NumbersLearnScreen(
          repository: repository,
          lessonId: 'numbers_count_1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(_toyButtonBorderRadius(tester, _ctaButtonFinder()), 18);
  });

  testWidgets(
    'keeps the numbers learn screen stable on a compact landscape phone',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(780, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repository = NumbersLessonRepository(
        assetBundle: _FakeAssetBundle({
          NumbersLessonRepository.manifestPath: jsonEncode({
            'lessons': [_numbersLesson],
          }),
        }),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: NumbersLearnScreen(
            repository: repository,
            lessonId: 'numbers_count_1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('하나, 1'), findsOneWidget);
    },
  );

  testWidgets('shows an error message when the numbers lesson fails to load', (
    WidgetTester tester,
  ) async {
    final repository = NumbersLessonRepository(
      assetBundle: _FakeAssetBundle({}),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: NumbersLearnScreen(
          repository: repository,
          lessonId: 'numbers_count_1',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('숫자 카드를 불러오지 못했어요.'), findsOneWidget);
    expect(find.text('다시 시도'), findsOneWidget);
  });
}

const Map<String, dynamic> _numbersLesson = {
  'id': 'numbers_count_1',
  'title': '숫자 1',
  'cards': [
    {'symbol': '1', 'label': '하나, 1', 'hint': '자동차 한 대를 보며 하나를 말해봐요'},
    {'symbol': '2', 'label': '둘, 2', 'hint': '자동차 두 대를 세며 둘을 말해봐요'},
    {'symbol': '3', 'label': '셋, 3', 'hint': '자동차 세 대를 세며 셋을 말해봐요'},
    {'symbol': '4', 'label': '넷, 4', 'hint': '자동차 네 대를 세며 넷을 말해봐요'},
    {'symbol': '5', 'label': '다섯, 5', 'hint': '자동차 다섯 대를 보며 다섯을 말해봐요'},
  ],
};

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
  final List<AudioCue> played = [];
  bool _isMuted = false;

  @override
  bool get isMuted => _isMuted;

  @override
  set isMuted(bool value) => _isMuted = value;

  @override
  Future<void> play(AudioCue cue) async {
    played.add(cue);
  }

  @override
  Future<void> stop() async {}
}

class _RecordingSpeechCueService implements SpeechCueService {
  final List<String> spoken = [];

  @override
  Future<void> speak(
    String text, {
    String locale = 'ko-KR',
    double rate = 0.42,
    double pitch = 1.0,
  }) async {
    spoken.add(text);
  }

  @override
  Future<void> stop() async {}
}

Widget _wrapWithServices({
  required Widget child,
  ProgressStore? progressStore,
  SpeechCueService? speechCueService,
  AudioService? audioService,
}) {
  return MaterialApp(
    home: AppServicesScope(
      services: AppServices(
        progressStore: progressStore ?? MemoryProgressStore(),
        speechCueService: speechCueService ?? NoopSpeechCueService(),
        audioService: audioService,
      ),
      child: child,
    ),
  );
}

void _setSurfaceSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

ToyButton _ctaButton(WidgetTester tester) {
  return tester.widget<ToyButton>(_ctaButtonFinder());
}

Finder _ctaButtonFinder() {
  return find.widgetWithText(ToyButton, '다음');
}

double _toyButtonBorderRadius(WidgetTester tester, Finder finder) {
  final decoratedBox = tester.widget<DecoratedBox>(
    find.descendant(
      of: finder,
      matching: find.byWidgetPredicate((Widget widget) {
        if (widget is! DecoratedBox) {
          return false;
        }

        final decoration = widget.decoration;
        return decoration is BoxDecoration &&
            decoration.gradient != null &&
            decoration.border != null &&
            decoration.boxShadow != null;
      }),
    ),
  );
  final borderRadius =
      (decoratedBox.decoration as BoxDecoration).borderRadius! as BorderRadius;

  return borderRadius.topLeft.x;
}

void _expectHeaderPillChrome(WidgetTester tester, String keyValue) {
  final pillFinder = find.byKey(ValueKey<String>(keyValue));

  expect(pillFinder, findsOneWidget);

  final pill = tester.widget<Container>(pillFinder);
  expect(pill.decoration, isA<BoxDecoration>());

  final decoration = pill.decoration! as BoxDecoration;
  expect(decoration.color, KidPalette.white.withValues(alpha: 0.92));

  final border = decoration.border;
  expect(border, isA<Border>());
  expect((border! as Border).top.color, KidPalette.stroke);
}
