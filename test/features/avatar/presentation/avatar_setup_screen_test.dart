import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/services/app_services.dart';
import 'package:kids_play_app/app/services/progress_store.dart';
import 'package:kids_play_app/app/services/speech_cue_service.dart';
import 'package:kids_play_app/features/avatar/presentation/avatar_setup_screen.dart';
import 'package:kids_play_app/features/hangul/data/hangul_lesson_repository.dart';
import 'package:kids_play_app/features/hangul/presentation/hangul_learn_screen.dart';

void main() {
  testWidgets('shows the five expression slots and parent helper copy', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AvatarSetupScreen()));
    await tester.pumpAndSettle();

    expect(find.text('표정 카드 만들기'), findsOneWidget);
    expect(find.text('보통'), findsOneWidget);
    expect(find.text('웃음'), findsOneWidget);
    expect(find.text('슬픔'), findsOneWidget);
    expect(find.text('화남'), findsOneWidget);
    expect(find.text('놀람'), findsOneWidget);
    expect(find.textContaining('5개 표정'), findsOneWidget);
    expect(find.text('아직 넣지 않았어요'), findsNWidgets(5));
  });

  testWidgets(
    'shows detailed lesson controls and lets parent adjust progress',
    (WidgetTester tester) async {
      final progressStore = MemoryProgressStore(
        const AppProgressSnapshot(
          stickerCount: 3,
          lessons: {
            'hangul:basic_consonants_1': LessonProgress(
              bestScore: 4,
              totalQuestions: 5,
              lastViewedIndex: 2,
              recentMistakes: ['ㄴ', 'ㄷ'],
            ),
            'alphabet:alphabet_letters_1': LessonProgress(
              bestScore: 5,
              totalQuestions: 5,
              lastViewedIndex: 4,
            ),
          },
        ),
      );

      await tester.pumpWidget(
        _wrapWithServices(
          progressStore: progressStore,
          child: const AvatarSetupScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('세트별 진도 조절'), findsOneWidget);
      expect(find.text('한글 차고'), findsOneWidget);
      expect(find.text('기본 자음 1'), findsOneWidget);
      expect(find.text('최근 헷갈린 글자'), findsNWidgets(2));
      expect(find.text('ㄴ'), findsOneWidget);
      expect(find.text('ㄷ'), findsOneWidget);
      expect(find.text('3 / 5'), findsOneWidget);

      final backButton = find.byKey(
        const Key('lesson-back-hangul:basic_consonants_1'),
      );
      await tester.scrollUntilVisible(backButton, 200);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      expect(find.text('2 / 5'), findsOneWidget);

      final clearMistakesButton = find.byKey(
        const Key('lesson-clear-mistakes-hangul:basic_consonants_1'),
      );
      await tester.scrollUntilVisible(clearMistakesButton, 120);
      await tester.tap(clearMistakesButton);
      await tester.pumpAndSettle();

      expect(find.text('최근 헷갈림 없음'), findsNWidgets(2));
      expect(find.text('ㄴ'), findsNothing);
      expect(find.text('ㄷ'), findsNothing);
    },
  );

  testWidgets(
    'stores the first recent mistake and opens the matching learn card from the parent controls',
    (WidgetTester tester) async {
      final repository = HangulLessonRepository(
        assetBundle: _FakeAssetBundle({
          HangulLessonRepository.manifestPath: jsonEncode({
            'lessons': [_hangulLesson],
          }),
        }),
      );
      final progressStore = MemoryProgressStore(
        const AppProgressSnapshot(
          lessons: {
            'hangul:basic_consonants_1': LessonProgress(
              bestScore: 4,
              totalQuestions: 5,
              lastViewedIndex: 0,
              recentMistakes: ['ㄷ', 'ㄴ'],
            ),
          },
        ),
      );

      await tester.pumpWidget(
        _wrapWithServices(
          progressStore: progressStore,
          child: AvatarSetupScreen(
            onOpenLessonRetry: (context, lessonId, mistakes) {
              return Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AppServicesScope(
                    services: AppServices(
                      progressStore: progressStore,
                      speechCueService: NoopSpeechCueService(),
                    ),
                    child: HangulLearnScreen(
                      repository: repository,
                      lessonId: lessonId.split(':').last,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      final retryButton = find.byKey(
        const Key('lesson-retry-mistakes-hangul:basic_consonants_1'),
      );
      await tester.scrollUntilVisible(retryButton, 120);
      await tester.tap(retryButton);
      await tester.pumpAndSettle();

      final snapshot = await progressStore.loadSnapshot();
      expect(
        snapshot.progressFor('hangul:basic_consonants_1').lastViewedIndex,
        2,
      );
      expect(find.text('기본 자음 1'), findsOneWidget);
      expect(find.text('디귿, ㄷ'), findsOneWidget);
      expect(find.text('3 / 3'), findsOneWidget);
    },
  );

  testWidgets(
    'keeps the avatar setup screen stable on a compact landscape phone',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(780, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(const MaterialApp(home: AvatarSetupScreen()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('표정 카드 만들기'), findsOneWidget);
    },
  );
}

Widget _wrapWithServices({
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

const Map<String, dynamic> _hangulLesson = {
  'id': 'basic_consonants_1',
  'title': '기본 자음 1',
  'cards': [
    {'symbol': 'ㄱ', 'label': '기역, ㄱ', 'hint': '큰 카드로 기역을 천천히 봐요'},
    {'symbol': 'ㄴ', 'label': '니은, ㄴ', 'hint': '니은을 손가락으로 콕 눌러봐요'},
    {'symbol': 'ㄷ', 'label': '디귿, ㄷ', 'hint': '디귿을 보고 소리를 따라 말해봐요'},
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
