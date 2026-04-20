import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/routing/boot_resume_router.dart';
import 'package:kids_play_app/app/services/app_services.dart';
import 'package:kids_play_app/app/services/progress_store.dart';
import 'package:kids_play_app/app/services/speech_cue_service.dart';
import 'package:kids_play_app/features/hangul/data/hangul_lesson_repository.dart';
import 'package:kids_play_app/features/hero/presentation/hero_screen.dart';
import 'package:kids_play_app/features/home/presentation/home_category_config.dart';

void main() {
  testWidgets('falls back to the hero screen on a fresh install', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        progressStore: MemoryProgressStore(),
        child: const BootResumeRouter(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HeroScreen), findsOneWidget);
    expect(find.text('놀이 시작'), findsOneWidget);
  });

  testWidgets('opens directly into the last-played hangul learn screen', (
    WidgetTester tester,
  ) async {
    final progressStore = MemoryProgressStore(
      const AppProgressSnapshot(
        lastLesson: RecentLessonRef(
          categoryId: 'hangul',
          lessonId: 'basic_consonants_1',
        ),
      ),
    );

    await tester.pumpWidget(
      _wrap(
        progressStore: progressStore,
        child: BootResumeRouter(
          categoryDependencies: HomeCategoryDependencies(
            hangulLessonRepository: _fakeHangulRepository(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HeroScreen), findsNothing);
    expect(find.text('한글 학습'), findsOneWidget);
    expect(find.text('기역, ㄱ'), findsOneWidget);
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

HangulLessonRepository _fakeHangulRepository() {
  return HangulLessonRepository(
    assetBundle: _FakeAssetBundle({
      HangulLessonRepository.manifestPath: jsonEncode({
        'lessons': [_basicConsonantsLesson],
      }),
    }),
  );
}

const Map<String, dynamic> _basicConsonantsLesson = {
  'id': 'basic_consonants_1',
  'title': '기본 자음 1',
  'cards': [
    {'symbol': 'ㄱ', 'label': '기역, ㄱ', 'hint': '큰 카드로 기역을 천천히 보고 눌러봐요'},
    {'symbol': 'ㄴ', 'label': '니은, ㄴ', 'hint': '니은을 만나고 입으로 따라 말해봐요'},
    {'symbol': 'ㄷ', 'label': '디귿, ㄷ', 'hint': '디귿을 보고 손가락으로 콕 눌러봐요'},
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
