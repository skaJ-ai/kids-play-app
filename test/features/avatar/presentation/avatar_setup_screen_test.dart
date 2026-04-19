import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_play_app/app/services/app_services.dart';
import 'package:kids_play_app/app/services/progress_store.dart';
import 'package:kids_play_app/app/services/speech_cue_service.dart';
import 'package:kids_play_app/app/ui/toy_button.dart';
import 'package:kids_play_app/features/avatar/application/avatar_photo_picker.dart';
import 'package:kids_play_app/features/avatar/application/avatar_photo_service.dart';
import 'package:kids_play_app/features/avatar/data/avatar_photo_repository.dart';
import 'package:kids_play_app/features/avatar/data/avatar_photo_store.dart';
import 'package:kids_play_app/features/avatar/domain/avatar_expression.dart';
import 'package:kids_play_app/features/avatar/domain/avatar_photo_entry.dart';
import 'package:kids_play_app/features/avatar/domain/avatar_photo_snapshot.dart';
import 'package:kids_play_app/features/avatar/presentation/avatar_crop_screen.dart';
import 'package:kids_play_app/features/avatar/presentation/avatar_setup_screen.dart';
import 'package:kids_play_app/features/hangul/data/hangul_lesson_repository.dart';
import 'package:kids_play_app/features/hangul/presentation/hangul_learn_screen.dart';

void main() {
  testWidgets('shows the five expression slots and parent helper copy', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _wrapWithAvatarAssets(
        child: const MaterialApp(home: AvatarSetupScreen()),
      ),
    );
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
    "shows saved-photo copy instead of '아직 넣지 않았어요' when a slot exists",
    (WidgetTester tester) async {
      final repository = _TestAvatarPhotoRepository();
      final relativePath = await repository.saveExpressionPhoto(
        expression: AvatarExpression.smile,
        bytes: _heroFacePngBytes,
      );
      final avatarPhotoService = AvatarPhotoService(
        photoStore: _TestAvatarPhotoStore(
          AvatarPhotoSnapshot(
            entries: {
              AvatarExpression.smile: AvatarPhotoEntry(
                expression: AvatarExpression.smile,
                relativePath: relativePath,
                updatedAt: DateTime.utc(2026, 4, 19, 9),
              ),
            },
          ),
        ),
        repository: repository,
      );

      await tester.pumpWidget(
        _wrapWithServices(
          progressStore: MemoryProgressStore(),
          avatarPhotoService: avatarPhotoService,
          child: const AvatarSetupScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('사진이 준비됐어요'), findsOneWidget);
      expect(find.text('아직 넣지 않았어요'), findsNWidgets(4));
      expect(find.text('다시 자르기'), findsOneWidget);
      expect(find.text('지우기'), findsOneWidget);
      expect(find.text('사진 넣기'), findsNWidgets(4));
    },
  );

  testWidgets(
    'imports and clears an expression photo from the parent dashboard',
    (WidgetTester tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      final sourceBytes = Uint8List.fromList(_heroFacePngBytes);
      final croppedBytes = Uint8List.fromList(_heroFacePngBytes);
      final repository = _TestAvatarPhotoRepository();
      final photoStore = _TestAvatarPhotoStore();
      final picker = _FakeAvatarPhotoPicker(sourceBytes);
      final avatarPhotoService = AvatarPhotoService(
        photoStore: photoStore,
        repository: repository,
      );

      await tester.pumpWidget(
        _wrapWithServices(
          progressStore: MemoryProgressStore(),
          avatarPhotoService: avatarPhotoService,
          avatarPhotoPicker: picker,
          navigatorKey: navigatorKey,
          child: const AvatarSetupScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byKey(const Key('avatar-card-smile')), findsOneWidget);

      final importButton = find.byKey(const Key('avatar-import-smile'));
      expect(importButton, findsOneWidget);

      await tester.tap(importButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(picker.pickCount, 1);
      expect(find.byType(AvatarCropScreen), findsOneWidget);
      final cropScreen = tester.widget<AvatarCropScreen>(
        find.byType(AvatarCropScreen),
      );
      expect(cropScreen.expression, AvatarExpression.smile);
      expect(cropScreen.sourceBytes, orderedEquals(sourceBytes));

      navigatorKey.currentState!.pop<Uint8List>(croppedBytes);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(photoStore.snapshot.entryFor(AvatarExpression.smile), isNotNull);
      expect(
        repository.savedBytesByExpression[AvatarExpression.smile],
        orderedEquals(croppedBytes),
      );
      expect(find.text('사진이 준비됐어요'), findsOneWidget);
      expect(find.byKey(const Key('avatar-clear-smile')), findsOneWidget);
      expect(find.text('다시 자르기'), findsOneWidget);

      final clearButton = find.byKey(const Key('avatar-clear-smile'));
      await tester.ensureVisible(clearButton);
      await tester.pump();
      final clearAction = tester.widget<ToyButton>(clearButton);
      clearAction.onPressed!.call();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(photoStore.snapshot.entryFor(AvatarExpression.smile), isNull);
      expect(repository.deletedPaths, contains('avatar_photos/smile.png'));
      expect(find.byKey(const Key('avatar-clear-smile')), findsNothing);
      expect(find.text('지우기'), findsNothing);
      expect(find.text('아직 넣지 않았어요'), findsNWidgets(5));
      expect(find.text('사진 넣기'), findsNWidgets(5));
    },
  );

  testWidgets(
    'shows the recent reward callout with reward amount and lesson metadata',
    (WidgetTester tester) async {
      final progressStore = MemoryProgressStore(
        AppProgressSnapshot(
          stickerCount: 4,
          lastEarnedReward: RecentReward(
            kind: 'sticker',
            amount: 1,
            lessonId: 'numbers:numbers_count_1',
            earnedAt: DateTime(2026, 4, 18, 15),
          ),
          lessons: const {
            'numbers:numbers_count_1': LessonProgress(
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

      final summaryPanel = find.byKey(const Key('parent-summary-panel'));
      expect(summaryPanel, findsOneWidget);
      expect(
        find.descendant(
          of: summaryPanel,
          matching: find.byKey(const Key('parent-summary-reward-callout')),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: summaryPanel,
          matching: find.byKey(const Key('parent-summary-reward-amount')),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: summaryPanel, matching: find.text('자동차 스티커 1개')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: summaryPanel,
          matching: find.byKey(const Key('parent-summary-reward-category')),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: summaryPanel, matching: find.text('숫자 차고')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: summaryPanel,
          matching: find.byKey(const Key('parent-summary-reward-lesson')),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: summaryPanel, matching: find.text('숫자 1부터 5까지')),
        findsOneWidget,
      );
    },
  );

  testWidgets('shows generic reward copy for unknown recent reward kinds', (
    WidgetTester tester,
  ) async {
    final progressStore = MemoryProgressStore(
      AppProgressSnapshot(
        stickerCount: 5,
        lastEarnedReward: RecentReward(
          kind: 'bonus',
          amount: 2,
          lessonId: 'alphabet:alphabet_letters_1',
          earnedAt: DateTime(2026, 4, 18, 16),
        ),
        lessons: const {
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

    final summaryPanel = find.byKey(const Key('parent-summary-panel'));
    expect(summaryPanel, findsOneWidget);
    expect(
      find.descendant(
        of: summaryPanel,
        matching: find.byKey(const Key('parent-summary-reward-callout')),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: summaryPanel, matching: find.text('보상 2개')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: summaryPanel, matching: find.text('알파벳 차고')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: summaryPanel, matching: find.text('알파벳 1')),
      findsOneWidget,
    );
  });

  testWidgets('shows replay-specific reward copy for mistake replay rewards', (
    WidgetTester tester,
  ) async {
    final progressStore = MemoryProgressStore(
      AppProgressSnapshot(
        stickerCount: 5,
        lastEarnedReward: RecentReward(
          kind: 'mistakeReplaySticker',
          amount: 1,
          lessonId: 'alphabet:alphabet_letters_1',
          earnedAt: DateTime(2026, 4, 18, 16, 30),
        ),
        lessons: const {
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

    final summaryPanel = find.byKey(const Key('parent-summary-panel'));
    expect(summaryPanel, findsOneWidget);
    expect(
      find.descendant(
        of: summaryPanel,
        matching: find.text('오답 다시 풀기 자동차 스티커 1개'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: summaryPanel, matching: find.text('알파벳 차고')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: summaryPanel, matching: find.text('알파벳 1')),
      findsOneWidget,
    );
  });

  testWidgets(
    'shows the aggregate replay summary counts in the parent summary',
    (WidgetTester tester) async {
      final progressStore = MemoryProgressStore(
        const AppProgressSnapshot(
          replayRewardStickerCount: 7,
          lessons: {
            'alphabet:alphabet_letters_1': LessonProgress(
              bestScore: 5,
              totalQuestions: 5,
              lastViewedIndex: 4,
              mistakeReplayCount: 2,
            ),
            'hangul:basic_consonants_1': LessonProgress(
              bestScore: 4,
              totalQuestions: 5,
              lastViewedIndex: 3,
              mistakeReplayCount: 1,
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

      final summaryPanel = find.byKey(const Key('parent-summary-panel'));
      expect(summaryPanel, findsOneWidget);
      expect(
        find.descendant(of: summaryPanel, matching: find.text('오답 다시 보기')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: summaryPanel, matching: find.text('3번')),
        findsOneWidget,
      );
      final replayRewardChip = find.descendant(
        of: summaryPanel,
        matching: find.byKey(const Key('parent-summary-replay-reward-chip')),
      );
      expect(replayRewardChip, findsOneWidget);
      expect(
        find.descendant(of: replayRewardChip, matching: find.text('다시 풀기 보상')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: replayRewardChip, matching: find.text('7개')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'shows a fresh-tracking replay reward summary label for older snapshots missing the aggregate',
    (WidgetTester tester) async {
      final progressStore = MemoryProgressStore(
        AppProgressSnapshot.fromJson({
          'lessons': {
            'alphabet:alphabet_letters_1': {
              'bestScore': 5,
              'totalQuestions': 5,
              'lastViewedIndex': 4,
              'mistakeReplayCount': 2,
            },
          },
        }),
      );

      await tester.pumpWidget(
        _wrapWithServices(
          progressStore: progressStore,
          child: const AvatarSetupScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final summaryPanel = find.byKey(const Key('parent-summary-panel'));
      expect(summaryPanel, findsOneWidget);
      final replayRewardChip = find.descendant(
        of: summaryPanel,
        matching: find.byKey(const Key('parent-summary-replay-reward-chip')),
      );
      expect(replayRewardChip, findsOneWidget);
      expect(
        find.descendant(of: replayRewardChip, matching: find.text('다시 풀기 보상')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: replayRewardChip, matching: find.text('새로 집계')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'shows the scoped confusion summary for the most confusing lesson and tie breaks by metadata order',
    (WidgetTester tester) async {
      final progressStore = MemoryProgressStore(
        const AppProgressSnapshot(
          stickerCount: 4,
          lessons: {
            'alphabet:alphabet_letters_1': LessonProgress(
              bestScore: 4,
              totalQuestions: 5,
              lastViewedIndex: 3,
              recentMistakes: ['A a', 'B b'],
            ),
            'hangul:basic_consonants_1': LessonProgress(
              bestScore: 3,
              totalQuestions: 5,
              lastViewedIndex: 1,
              recentMistakes: ['ㄱ', 'ㄴ'],
            ),
            'numbers:numbers_count_1': LessonProgress(
              bestScore: 5,
              totalQuestions: 5,
              lastViewedIndex: 4,
              recentMistakes: ['1'],
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

      final summaryPanel = find.byKey(const Key('parent-summary-panel'));
      expect(summaryPanel, findsOneWidget);
      expect(
        find.descendant(
          of: summaryPanel,
          matching: find.byKey(const Key('parent-summary-confusion-callout')),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: summaryPanel,
          matching: find.byKey(const Key('parent-summary-confusion-category')),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: summaryPanel, matching: find.text('한글 차고')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: summaryPanel,
          matching: find.byKey(const Key('parent-summary-confusion-lesson')),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: summaryPanel, matching: find.text('기본 자음 1')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: summaryPanel,
          matching: find.text('지금은 헷갈린 세트가 없어요.'),
        ),
        findsNothing,
      );
    },
  );

  testWidgets(
    'shows a quick retry entry in the confusion summary and opens the matching retry flow',
    (WidgetTester tester) async {
      final progressStore = MemoryProgressStore(
        const AppProgressSnapshot(
          stickerCount: 2,
          lessons: {
            'hangul:basic_consonants_1': LessonProgress(
              bestScore: 3,
              totalQuestions: 5,
              lastViewedIndex: 0,
              recentMistakes: ['ㄷ', 'ㄴ'],
            ),
            'alphabet:alphabet_letters_1': LessonProgress(
              bestScore: 4,
              totalQuestions: 5,
              lastViewedIndex: 2,
              recentMistakes: ['A a'],
            ),
          },
        ),
      );
      String? openedLessonId;
      List<String>? openedMistakes;

      await tester.pumpWidget(
        _wrapWithServices(
          progressStore: progressStore,
          child: AvatarSetupScreen(
            onOpenLessonRetry: (context, lessonId, mistakes) async {
              openedLessonId = lessonId;
              openedMistakes = List<String>.from(mistakes);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      final summaryPanel = find.byKey(const Key('parent-summary-panel'));
      expect(summaryPanel, findsOneWidget);
      final summaryRetryButton = find.descendant(
        of: summaryPanel,
        matching: find.byKey(const Key('parent-summary-confusion-retry')),
      );
      expect(summaryRetryButton, findsOneWidget);
      expect(
        find.descendant(of: summaryPanel, matching: find.text('기본 자음 1')),
        findsOneWidget,
      );

      await tester.scrollUntilVisible(summaryRetryButton, 120);
      await tester.tap(summaryRetryButton);
      await tester.pumpAndSettle();

      expect(openedLessonId, 'hangul:basic_consonants_1');
      expect(openedMistakes, ['ㄷ', 'ㄴ']);
      final snapshot = await progressStore.loadSnapshot();
      expect(
        snapshot.progressFor('hangul:basic_consonants_1').lastViewedIndex,
        2,
      );
    },
  );

  testWidgets(
    'shows calm fallback copy when there are no recent mistakes to summarize',
    (WidgetTester tester) async {
      final progressStore = MemoryProgressStore(
        const AppProgressSnapshot(
          stickerCount: 1,
          lessons: {
            'hangul:basic_consonants_1': LessonProgress(
              bestScore: 5,
              totalQuestions: 5,
              lastViewedIndex: 4,
            ),
            'numbers:numbers_count_1': LessonProgress(
              bestScore: 4,
              totalQuestions: 5,
              lastViewedIndex: 2,
              recentMistakes: [],
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

      final summaryPanel = find.byKey(const Key('parent-summary-panel'));
      expect(summaryPanel, findsOneWidget);
      expect(
        find.descendant(
          of: summaryPanel,
          matching: find.byKey(const Key('parent-summary-confusion-fallback')),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: summaryPanel,
          matching: find.text('지금은 헷갈린 세트가 없어요.'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: summaryPanel,
          matching: find.byKey(const Key('parent-summary-confusion-lesson')),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: summaryPanel,
          matching: find.byKey(const Key('parent-summary-confusion-retry')),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: summaryPanel,
          matching: find.byKey(const Key('parent-summary-reward-callout')),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: summaryPanel,
          matching: find.byKey(const Key('parent-summary-reward-amount')),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: summaryPanel,
          matching: find.byKey(const Key('parent-summary-reward-category')),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: summaryPanel,
          matching: find.byKey(const Key('parent-summary-reward-lesson')),
        ),
        findsNothing,
      );
    },
  );

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
      expect(
        find.descendant(
          of: find.byKey(const Key('lesson-card-hangul:basic_consonants_1')),
          matching: find.text('한글 차고'),
        ),
        findsOneWidget,
      );
      final hangulLessonCard = find.byKey(
        const Key('lesson-card-hangul:basic_consonants_1'),
      );
      expect(
        find.descendant(of: hangulLessonCard, matching: find.text('기본 자음 1')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: hangulLessonCard, matching: find.text('최근 헷갈린 글자')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: hangulLessonCard, matching: find.text('ㄴ')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: hangulLessonCard, matching: find.text('ㄷ')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: hangulLessonCard, matching: find.text('3 / 5')),
        findsOneWidget,
      );

      final backButton = find.byKey(
        const Key('lesson-back-hangul:basic_consonants_1'),
      );
      await tester.scrollUntilVisible(backButton, 200);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      expect(
        find.descendant(of: hangulLessonCard, matching: find.text('2 / 5')),
        findsOneWidget,
      );

      final clearMistakesButton = find.byKey(
        const Key('lesson-clear-mistakes-hangul:basic_consonants_1'),
      );
      await tester.scrollUntilVisible(clearMistakesButton, 120);
      await tester.tap(clearMistakesButton);
      await tester.pumpAndSettle();

      expect(
        find.descendant(of: hangulLessonCard, matching: find.text('최근 헷갈림 없음')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: hangulLessonCard, matching: find.text('ㄴ')),
        findsNothing,
      );
      expect(
        find.descendant(of: hangulLessonCard, matching: find.text('ㄷ')),
        findsNothing,
      );
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
    'shows unlock controls for later sets and lets parent unlock one',
    (WidgetTester tester) async {
      final progressStore = MemoryProgressStore();

      await tester.pumpWidget(
        _wrapWithServices(
          progressStore: progressStore,
          child: const AvatarSetupScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('첫 세트 뒤의 세트들은 부모가 미리 열어둘 수 있어요.'), findsOneWidget);

      final unlockButton = find.byKey(
        const Key('lesson-unlock-hangul:basic_consonants_2'),
      );
      await tester.scrollUntilVisible(unlockButton, 200);
      await tester.tap(unlockButton);
      await tester.pumpAndSettle();

      final snapshot = await progressStore.loadSnapshot();
      expect(snapshot.unlockedLessonIds, contains('hangul:basic_consonants_2'));
    },
  );

  testWidgets(
    'shows unlock controls for all later lessons in the generated manifests',
    (WidgetTester tester) async {
      final progressStore = MemoryProgressStore();

      await tester.pumpWidget(
        _wrapWithServices(
          progressStore: progressStore,
          child: const AvatarSetupScreen(),
        ),
      );
      await tester.pumpAndSettle();

      for (final lesson in _generatedManifestLaterLessons()) {
        final unlockButton = find.byKey(Key('lesson-unlock-${lesson.id}'));
        await tester.scrollUntilVisible(unlockButton, 200);
        expect(unlockButton, findsOneWidget);
        expect(find.text(lesson.title), findsWidgets);
      }
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

      await tester.pumpWidget(
        _wrapWithAvatarAssets(
          child: const MaterialApp(home: AvatarSetupScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('표정 카드 만들기'), findsOneWidget);
    },
  );
}

Widget _wrapWithAvatarAssets({required Widget child}) {
  return DefaultAssetBundle(bundle: _AvatarTestAssetBundle(), child: child);
}

Widget _wrapWithServices({
  required ProgressStore progressStore,
  required Widget child,
  AvatarPhotoService? avatarPhotoService,
  AvatarPhotoPicker? avatarPhotoPicker,
  GlobalKey<NavigatorState>? navigatorKey,
}) {
  return AppServicesScope(
    services: AppServices(
      progressStore: progressStore,
      speechCueService: NoopSpeechCueService(),
      avatarPhotoService: avatarPhotoService,
      avatarPhotoPicker: avatarPhotoPicker,
    ),
    child: _wrapWithAvatarAssets(
      child: MaterialApp(navigatorKey: navigatorKey, home: child),
    ),
  );
}

List<_ManifestLessonExpectation> _generatedManifestLaterLessons() {
  return [
    ..._readManifestLaterLessons(
      categoryPrefix: 'hangul',
      path: 'assets/generated/manifest/hangul_lessons.json',
    ),
    ..._readManifestLaterLessons(
      categoryPrefix: 'alphabet',
      path: 'assets/generated/manifest/alphabet_lessons.json',
    ),
    ..._readManifestLaterLessons(
      categoryPrefix: 'numbers',
      path: 'assets/generated/manifest/numbers_lessons.json',
    ),
  ];
}

List<_ManifestLessonExpectation> _readManifestLaterLessons({
  required String categoryPrefix,
  required String path,
}) {
  final manifest =
      jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  final lessons = (manifest['lessons'] as List<dynamic>?) ?? const [];
  return lessons
      .skip(1)
      .map((lesson) {
        final lessonMap = lesson as Map<String, dynamic>;
        final lessonId = lessonMap['id'] as String;
        return _ManifestLessonExpectation(
          id: '$categoryPrefix:$lessonId',
          title: lessonMap['title'] as String,
        );
      })
      .toList(growable: false);
}

class _ManifestLessonExpectation {
  const _ManifestLessonExpectation({required this.id, required this.title});

  final String id;
  final String title;
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

class _AvatarTestAssetBundle extends CachingAssetBundle {
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

class _TestAvatarPhotoStore implements AvatarPhotoStore {
  _TestAvatarPhotoStore([AvatarPhotoSnapshot? snapshot])
    : snapshot = snapshot ?? const AvatarPhotoSnapshot();

  AvatarPhotoSnapshot snapshot;

  @override
  Future<AvatarPhotoSnapshot> loadSnapshot() async => snapshot;

  @override
  Future<void> saveSnapshot(AvatarPhotoSnapshot snapshot) async {
    this.snapshot = snapshot;
  }
}

class _TestAvatarPhotoRepository implements AvatarPhotoRepository {
  _TestAvatarPhotoRepository();

  final Map<AvatarExpression, Uint8List> savedBytesByExpression = {};
  final List<String> deletedPaths = [];

  @override
  Future<void> deletePhoto(String relativePath) async {
    deletedPaths.add(relativePath);
    savedBytesByExpression.removeWhere(
      (expression, _) => avatarPhotoRelativePathFor(expression) == relativePath,
    );
  }

  @override
  Future<File?> resolveFile(String relativePath) async {
    return null;
  }

  @override
  Future<String> saveExpressionPhoto({
    required AvatarExpression expression,
    required Uint8List bytes,
  }) async {
    final relativePath = avatarPhotoRelativePathFor(expression);
    savedBytesByExpression[expression] = Uint8List.fromList(bytes);
    return relativePath;
  }
}

class _FakeAvatarPhotoPicker implements AvatarPhotoPicker {
  _FakeAvatarPhotoPicker(this.result);

  final Uint8List? result;
  int pickCount = 0;

  @override
  Future<Uint8List?> pickFromGallery() async {
    pickCount += 1;
    return result == null ? null : Uint8List.fromList(result!);
  }
}

final Uint8List _heroFacePngBytes = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4////fwAJ+wP9KobjigAAAABJRU5ErkJggg==',
);
