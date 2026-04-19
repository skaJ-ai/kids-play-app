# Reward + Audio Polish Implementation Plan

> **For Hermes:** Use subagent-driven-development skill to implement this plan task-by-task.

**Goal:** toddler-facing 정답/오답/보상/배경음악 오디오를 실제 cue 기반으로 다듬고, 부모 설정에서 음성 안내 / 피드백 효과 / 배경 음악을 분리 제어할 수 있게 만든다.

**Architecture:** target end-state는 child-facing 화면이 `AudioService` 하나만 보게 만드는 것이다. 먼저 `ProgressStore`에 `bgmEnabled`를 추가해 기존 `voicePromptsEnabled` / `effectsEnabled`와 같은 방식으로 저장하고, 실제 recorded asset 재생은 작은 wrapper를 통해 `AudioService` 뒤로 숨긴다. prompt는 현재처럼 asset 우선 + TTS fallback을 유지하되 success/error/reward/bgm은 typed cue를 실제 asset playback으로 연결하고, 현재 `speechCueService`를 직접 쓰는 legacy Hangul/Numbers 화면은 별도 작은 slice로 순차 마이그레이션한다.

**Tech Stack:** Flutter, `shared_preferences`, `flutter_tts`, `AudioService` typed cue model, placeholder-first generated asset pipeline, widget/unit tests, `flutter pub add audioplayers`로 추가하는 asset playback dependency.

---

## Grounded current state

현재 live repo 기준 사실:
- `lib/app/services/progress_store.dart`에는 `voicePromptsEnabled` / `effectsEnabled`만 있고 `bgmEnabled`는 없다.
- `lib/features/avatar/presentation/avatar_setup_screen.dart` 부모 제어 패널에는 `음성 안내 켜짐/꺼짐`, `피드백 효과 켜짐/꺼짐` 버튼만 있다.
- `lib/app/audio/tts_fallback_audio_service.dart`는 `PromptCue`만 TTS fallback으로 재생하고, `SuccessCue` / `ErrorCue` / `RewardCue` / `IdleAttractCue` / `BgmCue`는 아직 silence로 degrade한다.
- `lib/features/lesson/application/quiz_controller.dart`는 정답/오답 때 아직 `speechCueService.speak('딩동댕')` / `speechCueService.speak('다시 해보자')`를 직접 호출한다.
- `pubspec.yaml`에는 `assets/generated/audio/voice/prompts/`, `assets/generated/audio/sfx/`, `assets/generated/audio/music/` 등록이 이미 있다.

이 계획은 위 현실을 기준으로 "저위험 small slice" 순서로 진행한다.

---

### Task 1: `bgmEnabled`를 progress snapshot에 추가

**Objective:** 배경 음악 on/off 상태를 다른 설정과 동일한 방식으로 저장/복원할 수 있게 만든다.

**Files:**
- Modify: `lib/app/services/progress_store.dart`
- Test: `test/app/services/progress_store_test.dart`

**Step 1: Write failing test**

```dart
test('setBgmEnabled persists the flag and reset restores true', () async {
  final store = MemoryProgressStore();

  await store.setBgmEnabled(false);
  expect((await store.loadSnapshot()).bgmEnabled, isFalse);

  await store.reset();
  expect((await store.loadSnapshot()).bgmEnabled, isTrue);
});
```

**Step 2: Run test to verify failure**

Run:
```bash
cd /home/openc/kids-play-app
/home/openc/sdk/flutter/bin/flutter test test/app/services/progress_store_test.dart -r compact
```

Expected: FAIL — `bgmEnabled` / `setBgmEnabled`가 아직 없음.

**Step 3: Write minimal implementation**

Add the new flag to the snapshot + store contract.

```dart
class AppProgressSnapshot {
  const AppProgressSnapshot({
    this.voicePromptsEnabled = true,
    this.effectsEnabled = true,
    this.bgmEnabled = true,
    ...
  });

  final bool bgmEnabled;
}

abstract class ProgressStore {
  Future<void> setBgmEnabled(bool enabled);
}
```

Also update:
- `fromJson`
- `copyWith`
- `toJson`
- `MemoryProgressStore`
- `SharedPreferencesProgressStore`
- `reset()` default snapshot

**Step 4: Run test to verify pass**

Run:
```bash
cd /home/openc/kids-play-app
/home/openc/sdk/flutter/bin/flutter test test/app/services/progress_store_test.dart -r compact
```

Expected: PASS.

**Step 5: Commit**

```bash
git add lib/app/services/progress_store.dart test/app/services/progress_store_test.dart
git commit -m "feat(audio): persist bgm setting"
```

---

### Task 2: 부모 설정 화면에 배경 음악 토글 추가

**Objective:** 보호자 화면에서 배경 음악을 별도로 끄고 켤 수 있게 만든다.

**Files:**
- Modify: `lib/features/avatar/presentation/avatar_setup_screen.dart`
- Test: `test/features/avatar/presentation/avatar_setup_screen_test.dart`

**Step 1: Write failing test**

```dart
testWidgets('lets parent toggle background music separately', (
  WidgetTester tester,
) async {
  final progressStore = MemoryProgressStore(
    const AppProgressSnapshot(bgmEnabled: true),
  );

  await tester.pumpWidget(
    _wrapWithServices(
      progressStore: progressStore,
      child: const AvatarSetupScreen(),
    ),
  );
  await tester.pumpAndSettle();

  expect(find.text('배경 음악 켜짐'), findsOneWidget);

  await tester.tap(find.text('배경 음악 켜짐'));
  await tester.pumpAndSettle();

  expect((await progressStore.loadSnapshot()).bgmEnabled, isFalse);
  expect(find.text('배경 음악 꺼짐'), findsOneWidget);
});
```

**Step 2: Run test to verify failure**

Run:
```bash
cd /home/openc/kids-play-app
/home/openc/sdk/flutter/bin/flutter test test/features/avatar/presentation/avatar_setup_screen_test.dart -r compact
```

Expected: FAIL — 새 버튼/handler가 아직 없음.

**Step 3: Write minimal implementation**

Add a dedicated toggle and keep the current visual grouping.

```dart
Future<void> _toggleBgm(bool enabled) async {
  await AppServicesScope.of(context).progressStore.setBgmEnabled(enabled);
  await _refreshScreenData();
}
```

Render a third settings button near the existing two toggles:

```dart
ToyButton(
  label: progress.bgmEnabled ? '배경 음악 켜짐' : '배경 음악 꺼짐',
  icon: Icons.music_note_rounded,
  onPressed: () => _toggleBgm(!progress.bgmEnabled),
)
```

**Step 4: Run test to verify pass**

Run:
```bash
cd /home/openc/kids-play-app
/home/openc/sdk/flutter/bin/flutter test test/features/avatar/presentation/avatar_setup_screen_test.dart -r compact
```

Expected: PASS.

**Step 5: Commit**

```bash
git add lib/features/avatar/presentation/avatar_setup_screen.dart test/features/avatar/presentation/avatar_setup_screen_test.dart
git commit -m "feat(audio): add parent bgm toggle"
```

---

### Task 3: asset playback wrapper를 추가해 `AudioService`가 plugin에 직접 묶이지 않게 만들기

**Objective:** real asset playback 의존성을 UI/controller 밖으로 숨기고 테스트 가능한 audio adapter를 만든다.

**Files:**
- Create: `lib/app/audio/asset_audio_player.dart`
- Create: `lib/app/audio/audioplayers_asset_audio_player.dart`
- Modify: `pubspec.yaml`
- Modify: `pubspec.lock`
- Test: `test/app/audio/asset_audio_player_test.dart`

**Step 1: Write failing test**

```dart
test('fake asset audio player records play/stop requests', () async {
  final player = RecordingAssetAudioPlayer();

  await player.playAsset('assets/generated/audio/sfx/ui/success_cheer.ogg');
  await player.stop();

  expect(player.playedAssets, ['assets/generated/audio/sfx/ui/success_cheer.ogg']);
  expect(player.stopCalls, 1);
});
```

**Step 2: Run test to verify failure**

Run:
```bash
cd /home/openc/kids-play-app
/home/openc/sdk/flutter/bin/flutter test test/app/audio/asset_audio_player_test.dart -r compact
```

Expected: FAIL — wrapper file/test helper가 아직 없음.

**Step 3: Write minimal implementation**

Add a tiny abstraction first:

```dart
abstract class AssetAudioPlayer {
  Future<void> playAsset(String assetPath, {bool loop = false});
  Future<void> stop();
}
```

Then add a production implementation backed by a plugin added with:

```bash
cd /home/openc/kids-play-app
/home/openc/sdk/flutter/bin/flutter pub add audioplayers
```

The concrete class should live in `lib/app/audio/audioplayers_asset_audio_player.dart` and translate `loop` to the chosen player's repeat mode.

**Step 4: Run test to verify pass**

Run:
```bash
cd /home/openc/kids-play-app
/home/openc/sdk/flutter/bin/flutter test test/app/audio/asset_audio_player_test.dart -r compact
```

Expected: PASS.

**Step 5: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/app/audio/asset_audio_player.dart lib/app/audio/audioplayers_asset_audio_player.dart test/app/audio/asset_audio_player_test.dart
git commit -m "feat(audio): add asset audio player wrapper"
```

---

### Task 4: `TtsFallbackAudioService`를 real cue playback으로 확장

**Objective:** prompt는 asset-or-TTS fallback을 유지하고, success/error/reward/bgm은 typed cue → asset path로 매핑해 실제 재생 경로를 만든다.

**Files:**
- Modify: `lib/app/audio/tts_fallback_audio_service.dart`
- Possibly create: `lib/app/audio/audio_asset_catalog.dart`
- Test: `test/app/audio/tts_fallback_audio_service_test.dart`

**Step 1: Write failing test**

```dart
test('non-prompt cues resolve to asset playback instead of silence', () async {
  final speech = _RecordingSpeech();
  final player = RecordingAssetAudioPlayer();
  final service = TtsFallbackAudioService(
    speech: speech,
    assetPlayer: player,
  );

  await service.play(const SuccessCue(tone: SuccessTone.cheer));
  await service.play(const ErrorCue());
  await service.play(const RewardCue(AudioPackId('numbers')));
  await service.play(const BgmCue(pack: AudioPackId('garage')));

  expect(speech.spoken, isEmpty);
  expect(player.playedAssets, [
    'assets/generated/audio/sfx/ui/success_cheer.ogg',
    'assets/generated/audio/sfx/ui/error_soft.ogg',
    'assets/generated/audio/sfx/reward/numbers_reward.ogg',
    'assets/generated/audio/music/garage_loop.ogg',
  ]);
});
```

**Step 2: Run test to verify failure**

Run:
```bash
cd /home/openc/kids-play-app
/home/openc/sdk/flutter/bin/flutter test test/app/audio/tts_fallback_audio_service_test.dart -r compact
```

Expected: FAIL — service가 아직 non-prompt cue를 silence로 버린다.

**Step 3: Write minimal implementation**

Inject the wrapper and centralize cue-to-asset resolution.

```dart
class TtsFallbackAudioService implements AudioService {
  TtsFallbackAudioService({
    required SpeechCueService speech,
    required AssetAudioPlayer assetPlayer,
    ...
  }) : _speech = speech,
       _assetPlayer = assetPlayer;

  final AssetAudioPlayer _assetPlayer;
}
```

Then map:
- `SuccessCue(tone: SuccessTone.cheer)` → `assets/generated/audio/sfx/ui/success_cheer.ogg`
- `ErrorCue()` → `assets/generated/audio/sfx/ui/error_soft.ogg`
- `RewardCue(AudioPackId('numbers'))` → `assets/generated/audio/sfx/reward/numbers_reward.ogg`
- `BgmCue(pack: AudioPackId('garage'))` → `assets/generated/audio/music/garage_loop.ogg`

Keep prompt behavior unchanged:
- asset exists → play asset path
- asset missing → speak fallback text

**Step 4: Run test to verify pass**

Run:
```bash
cd /home/openc/kids-play-app
/home/openc/sdk/flutter/bin/flutter test test/app/audio/tts_fallback_audio_service_test.dart -r compact
```

Expected: PASS.

**Step 5: Commit**

```bash
git add lib/app/audio/tts_fallback_audio_service.dart lib/app/audio/audio_asset_catalog.dart test/app/audio/tts_fallback_audio_service_test.dart
git commit -m "feat(audio): route typed cues through asset playback"
```

---

### Task 5: production `main.dart`에 real asset player를 주입

**Objective:** 앱이 실제 기기에서 새 asset playback 경로를 쓰도록 wiring을 마무리한다.

**Files:**
- Modify: `lib/main.dart`
- Possibly create: `lib/app/audio/asset_probe.dart`
- Test: `test/widget_test.dart` or a new wiring test under `test/app/`

**Step 1: Write failing test**

If no focused wiring test exists yet, create one:

```dart
testWidgets('fallback app wiring still boots with the expanded audio service', (
  WidgetTester tester,
) async {
  await tester.pumpWidget(KidsPlayApp(services: AppServices.fallback()));
  expect(find.byType(KidsPlayApp), findsOneWidget);
});
```

**Step 2: Run test to verify failure**

Run:
```bash
cd /home/openc/kids-play-app
/home/openc/sdk/flutter/bin/flutter test test/widget_test.dart -r compact
```

Expected: FAIL only if wiring/API shape changed incompatibly.

**Step 3: Write minimal implementation**

Instantiate the production player and a real prompt asset probe before `AppServices`:

```dart
Future<bool> rootBundleAssetProbe(String assetPath) async {
  try {
    await rootBundle.load(assetPath);
    return true;
  } catch (_) {
    return false;
  }
}

final services = AppServices(
  progressStore: SharedPreferencesProgressStore(preferences),
  speechCueService: speech,
  audioService: TtsFallbackAudioService(
    speech: speech,
    assetPlayer: AudioplayersAssetAudioPlayer(),
    assetProbe: rootBundleAssetProbe,
  ),
  ...
);
```

**Step 4: Run test to verify pass**

Run:
```bash
cd /home/openc/kids-play-app
/home/openc/sdk/flutter/bin/flutter test test/widget_test.dart -r compact
```

Expected: PASS.

**Step 5: Commit**

```bash
git add lib/main.dart test/widget_test.dart
git commit -m "feat(audio): wire production asset player"
```

---

### Task 6: shared `QuizController` feedback / reward 경로를 `AudioService` typed cue로 전환

**Objective:** generic/alphabet 쪽 shared `QuizController`가 정답/오답/보상 사운드를 직접 문자열 TTS로 부르지 않고 typed cue로 일관되게 흐르도록 만든다. live app의 legacy Hangul/Numbers quiz 화면은 다음 task에서 별도로 마이그레이션한다.

**Files:**
- Modify: `lib/features/lesson/application/quiz_controller.dart`
- Test: `test/features/lesson/application/quiz_controller_test.dart`

**Step 1: Write failing test**

```dart
test('selectChoice plays success/error cues and reward cue through AudioService', () async {
  final audio = _RecordingAudioService();
  final controller = _buildController(audioService: audio);

  await controller.selectChoice(controller.currentQuestion);

  expect(audio.played.whereType<SuccessCue>(), isNotEmpty);
});
```

**Step 2: Run test to verify failure**

Run:
```bash
cd /home/openc/kids-play-app
/home/openc/sdk/flutter/bin/flutter test test/features/lesson/application/quiz_controller_test.dart -r compact
```

Expected: FAIL — controller가 아직 `speechCueService.speak(...)`를 직접 호출한다.

**Step 3: Write minimal implementation**

Replace direct TTS feedback with typed cues:

```dart
await _services.audioService.play(
  isCorrect ? const SuccessCue(tone: SuccessTone.cheer) : const ErrorCue(),
);
```

When the child earns a sticker on completion:

```dart
await _services.audioService.play(
  RewardCue(AudioPackId(category.id)),
);
```

Keep existing overlay timing and progress persistence unchanged.

**Step 4: Run test to verify pass**

Run:
```bash
cd /home/openc/kids-play-app
/home/openc/sdk/flutter/bin/flutter test test/features/lesson/application/quiz_controller_test.dart -r compact
```

Expected: PASS.

**Step 5: Commit**

```bash
git add lib/features/lesson/application/quiz_controller.dart test/features/lesson/application/quiz_controller_test.dart
git commit -m "feat(audio): route shared quiz feedback through audio cues"
```

---

### Task 7: legacy Hangul/Numbers quiz 화면을 `AudioService` typed cue로 마이그레이션

**Objective:** 실제 앱 라우팅이 아직 `HangulQuizScreen` / `NumbersQuizScreen`을 사용하므로, shared controller task와 별개로 두 legacy 화면의 정답/오답/보상 경로도 typed cue로 옮긴다.

**Files:**
- Modify: `lib/features/hangul/presentation/hangul_quiz_screen.dart`
- Modify: `lib/features/numbers/presentation/numbers_quiz_screen.dart`
- Test: `test/features/hangul/presentation/hangul_quiz_screen_test.dart`
- Test: `test/features/numbers/presentation/numbers_quiz_screen_test.dart`
- Spot-check routing source: `lib/features/home/presentation/home_category_config.dart`

**Step 1: Write failing tests**

Add one focused regression per legacy screen proving feedback routes through `audioService` instead of direct feedback TTS.

```dart
testWidgets('numbers quiz plays a success cue through audioService', (
  WidgetTester tester,
) async {
  final audio = _RecordingAudioService();

  await tester.pumpWidget(
    _wrapWithServices(
      audioService: audio,
      child: NumbersQuizScreen(repository: _repository),
    ),
  );
  await tester.pumpAndSettle();

  await tester.tap(find.widgetWithText(FilledButton, '1'));
  await tester.pump();

  expect(audio.played.whereType<SuccessCue>(), isNotEmpty);
});
```

Mirror the same idea in `hangul_quiz_screen_test.dart`.

**Step 2: Run tests to verify failure**

Run:
```bash
cd /home/openc/kids-play-app
/home/openc/sdk/flutter/bin/flutter test \
  test/features/hangul/presentation/hangul_quiz_screen_test.dart \
  test/features/numbers/presentation/numbers_quiz_screen_test.dart -r compact
```

Expected: FAIL — both screens still call `speechCueService.speak(...)` directly for feedback.

**Step 3: Write minimal implementation**

In each legacy screen:
- keep prompt replay behavior as-is for now
- replace direct correct/wrong feedback speech with

```dart
await _services.audioService.play(
  isCorrect ? const SuccessCue(tone: SuccessTone.cheer) : const ErrorCue(),
);
```

When a sticker/replay reward is earned, also play:

```dart
await _services.audioService.play(
  RewardCue(AudioPackId('hangul')), // or 'numbers'
);
```

Do not refactor the full screen to `QuizController` in this slice. Keep it to the feedback/reward audio path only.

**Step 4: Run tests to verify pass**

Run:
```bash
cd /home/openc/kids-play-app
/home/openc/sdk/flutter/bin/flutter test \
  test/features/hangul/presentation/hangul_quiz_screen_test.dart \
  test/features/numbers/presentation/numbers_quiz_screen_test.dart -r compact
```

Expected: PASS.

**Step 5: Commit**

```bash
git add lib/features/hangul/presentation/hangul_quiz_screen.dart lib/features/numbers/presentation/numbers_quiz_screen.dart test/features/hangul/presentation/hangul_quiz_screen_test.dart test/features/numbers/presentation/numbers_quiz_screen_test.dart
git commit -m "feat(audio): route legacy quiz feedback through audio cues"
```

---

### Task 8: hero / home에 ambient BGM lifecycle를 연결

**Objective:** 히어로/홈 화면에서만 부드러운 차고 분위기 음악이 흐르고, 다른 화면으로 push 이동하거나 부모 화면에 들어가기 직전에는 멈추게 만든다. `dispose()`만 믿지 않고 push-navigation 경로를 명시적으로 다룬다.

**Files:**
- Modify: `lib/features/hero/presentation/hero_screen.dart`
- Modify: `lib/features/home/presentation/home_screen.dart`
- Test: `test/features/hero/presentation/hero_screen_test.dart`
- Create or modify: `test/features/home/presentation/home_audio_test.dart`

**Step 1: Write failing test**

```dart
testWidgets('hero starts garage bgm and stops it on navigation', (
  WidgetTester tester,
) async {
  final audio = _RecordingAudioService();

  await tester.pumpWidget(
    _buildHeroScreen(
      // extend the helper so AppServices can inject a recording audioService
      audioService: audio,
    ),
  );
  await tester.pumpAndSettle();

  expect(audio.played.whereType<BgmCue>(), isNotEmpty);
});
```

**Step 2: Run test to verify failure**

Run:
```bash
cd /home/openc/kids-play-app
/home/openc/sdk/flutter/bin/flutter test test/features/hero/presentation/hero_screen_test.dart -r compact
```

Expected: FAIL — hero/home이 아직 `BgmCue`를 쓰지 않는다.

**Step 3: Write minimal implementation**

On screen entry, gate BGM by the new setting:

```dart
final snapshot = await services.progressStore.loadSnapshot();
if (snapshot.bgmEnabled) {
  await services.audioService.play(const BgmCue(pack: AudioPackId('garage')));
}
```

Before every `Navigator.push(...)` from hero/home, stop current audio first, and keep `dispose()` as a safety net:

```dart
await services.audioService.stop();
await Navigator.of(context).push(...);
```

```dart
@override
void dispose() {
  unawaited(AppServicesScope.of(context).audioService.stop());
  super.dispose();
}
```

Keep this limited to hero/home first. Do not spread ambient music to learn/quiz screens in the same slice.

**Step 4: Run test to verify pass**

Run:
```bash
cd /home/openc/kids-play-app
/home/openc/sdk/flutter/bin/flutter test \
  test/features/hero/presentation/hero_screen_test.dart \
  test/features/home/presentation/home_audio_test.dart -r compact
```

Expected: PASS.

**Step 5: Commit**

```bash
git add lib/features/hero/presentation/hero_screen.dart lib/features/home/presentation/home_screen.dart test/features/hero/presentation/hero_screen_test.dart test/features/home/presentation/home_audio_test.dart
git commit -m "feat(audio): add garage bgm lifecycle"
```

---

### Task 9: placeholder audio assets + docs 정리

**Objective:** CI/clean checkout에서도 새 cue path가 안전하게 존재하도록 placeholder 자산과 operator-facing 문서를 정리한다.

**Files:**
- Create: `assets/public/audio/sfx/ui/success_cheer.ogg`
- Create: `assets/public/audio/sfx/ui/error_soft.ogg`
- Create: `assets/public/audio/sfx/reward/numbers_reward.ogg`
- Create: `assets/public/audio/sfx/reward/hangul_reward.ogg`
- Create: `assets/public/audio/sfx/reward/alphabet_reward.ogg`
- Create: `assets/public/audio/music/garage_loop.ogg`
- Modify: `assets/public/manifest/asset_register.csv`
- Modify: `README.md`
- Modify: `handoff.md`
- Modify: `docs/asset-pipeline.md`

**Step 1: Write failing test / verification**

Prefer a small asset existence check instead of a giant UI test:

```dart
test('audio placeholders are present in generated assets after prepare script', () async {
  // verify with file existence or asset manifest probe helper
});
```

If a dedicated Dart test is overkill, use shell verification only for this docs/assets slice.

**Step 2: Run asset prep and verify failure if paths are missing**

Run:
```bash
cd /home/openc/kids-play-app
./scripts/prepare_assets.sh
python3 - <<'PY'
from pathlib import Path
required = [
    'assets/generated/audio/sfx/ui/success_cheer.ogg',
    'assets/generated/audio/sfx/ui/error_soft.ogg',
    'assets/generated/audio/sfx/reward/numbers_reward.ogg',
    'assets/generated/audio/music/garage_loop.ogg',
]
missing = [p for p in required if not Path(p).exists()]
if missing:
    raise SystemExit('\n'.join(missing))
PY
```

Expected: FAIL until placeholder files exist.

**Step 3: Write minimal implementation**

- add safe placeholder audio files under `assets/public/audio/...`
- update `assets/public/manifest/asset_register.csv` so the repo inventory matches the new public audio placeholders
- run `./scripts/prepare_assets.sh`
- document that private/local overrides keep the same relative paths under `assets/local_private/audio/...`
- document that runtime avatar photos remain outside the generated asset pipeline

**Step 4: Run verification to verify pass**

Run:
```bash
cd /home/openc/kids-play-app
./scripts/prepare_assets.sh
/home/openc/sdk/flutter/bin/flutter test test/app/audio test/features/lesson/application/quiz_controller_test.dart -r compact
```

Expected: PASS.

**Step 5: Commit**

```bash
git add assets/public/audio assets/public/manifest/asset_register.csv README.md handoff.md docs/asset-pipeline.md
git commit -m "docs(audio): add placeholder reward and bgm assets"
```

---

## Final targeted verification after Tasks 1-9

Run:
```bash
cd /home/openc/kids-play-app
./scripts/prepare_assets.sh
/home/openc/sdk/flutter/bin/flutter test \
  test/app/services/progress_store_test.dart \
  test/features/avatar/presentation/avatar_setup_screen_test.dart \
  test/app/audio \
  test/features/lesson/application/quiz_controller_test.dart \
  test/features/hero/presentation/hero_screen_test.dart \
  test/features/home/presentation/home_audio_test.dart \
  test/features/hangul/presentation/hangul_quiz_screen_test.dart \
  test/features/numbers/presentation/numbers_quiz_screen_test.dart -r compact
/home/openc/sdk/flutter/bin/flutter analyze \
  lib/app/audio \
  lib/app/services/progress_store.dart \
  lib/features/avatar/presentation/avatar_setup_screen.dart \
  lib/features/lesson/application/quiz_controller.dart \
  lib/features/hangul/presentation/hangul_quiz_screen.dart \
  lib/features/numbers/presentation/numbers_quiz_screen.dart \
  lib/features/hero/presentation/hero_screen.dart \
  lib/features/home/presentation/home_screen.dart \
  test/app/audio \
  test/app/services/progress_store_test.dart \
  test/features/avatar/presentation/avatar_setup_screen_test.dart \
  test/features/lesson/application/quiz_controller_test.dart \
  test/features/hangul/presentation/hangul_quiz_screen_test.dart \
  test/features/numbers/presentation/numbers_quiz_screen_test.dart \
  test/features/hero/presentation/hero_screen_test.dart \
  test/features/home/presentation/home_audio_test.dart
```

Expected:
- all targeted tests pass
- analyze reports `No issues found!`

## Final integration gate

Do **not** claim a fresh full Gate G rerun during the middle slices.
Only after the full reward/audio polish stack is landed, run the full project gate again:

```bash
cd /home/openc/kids-play-app
./scripts/prepare_assets.sh
/home/openc/sdk/flutter/bin/flutter pub get
/home/openc/sdk/flutter/bin/flutter test
/home/openc/sdk/flutter/bin/flutter analyze
/home/openc/sdk/flutter/bin/flutter build apk --release --target-platform android-arm64
```

## Notes for implementation

- Keep every slice small and independently shippable.
- Prompt replay remains the most important toddler audio path; do not regress it while adding SFX/BGM.
- `effectsEnabled` should continue to gate visual feedback + short SFX. `bgmEnabled` is separate.
- Do not wire ambient BGM into learn/quiz screens in the same run that lands hero/home BGM.
- Use placeholder-safe public audio first; private/local polished sounds can override later via `assets/local_private/audio/...`.
- Update docs wording carefully: `prepare_assets.sh` manages build-time audio assets, not runtime avatar photo files.
