# handoff.md

## 프로젝트 요약

`승원이의 빵빵 놀이터`는 27개월 유아가 Galaxy S24에서 가로 화면으로 사용하는 개인용 오프라인 학습 APK입니다.

핵심 원칙
- child-facing 화면은 탭만 사용
- 텍스트 최소화, 소리/즉시 피드백 중심
- 한글 / 알파벳 / 숫자 3개 카테고리
- 보호자 메뉴는 숨김 진입
- GitHub Actions `build-apk.yml`은 `workflow_dispatch` 또는 main 브랜치의 `push.paths` 범위 변경에서 APK artifact를 생성

---

## 현재 기준 상태

레포
- local: `/home/openc/kids-play-app`
- remote: `git@github.com:skaJ-ai/kids-play-app.git`

대표 기능 커밋 예시
- `faff2ce` `feat(hero): use saved avatar photo fallback chain`
- `610a6aa` `fix(numbers): route learn prompts through audio service`
- `e2f1ed5` `feat(audio): persist bgm setting`
- `2450e81` `feat(audio): add parent bgm toggle`
- `58eecac` `feat(audio): add asset audio player wrapper`

현재 이미 동작하는 것
- landscape 고정 + immersive full-screen
- hero / home / category hub garage flow
- 보호자 메뉴의 5개 표정 카드에서 갤러리 사진 가져오기 + 정사각형 크롭 + 표정별 저장/지우기
- avatar photo metadata는 별도 `avatar_photos_v1` key에 저장되고, crop 결과 파일은 앱 전용 경로(`getApplicationSupportDirectory()/avatar_photos/<expression>.png`)에 저장
- 히어로 얼굴은 저장된 smile/neutral 런타임 사진이 있으면 우선 사용하고, 없으면 `assets/generated/images/hero/hero_face.png` 경로의 bundled/generated hero face asset으로 fallback
- 홈 / 카테고리 허브에서 한글 / 알파벳 / 숫자 3개 카테고리 배우기/퀴즈 라우팅 완료
- 한글 / 알파벳 / 숫자 다중 세트 학습
- 한글 / 알파벳 / 숫자 다중 세트 퀴즈
- 세트 선택 화면 추가
- compact landscape 대응 + 회귀 테스트
- toddler-safe tap cooldown / 즉시 피드백 오버레이
- 음성 cue / 다시 듣기 버튼
- shared_preferences 기반 progress / settings / sticker 저장, lesson별 오답 다시 풀기 횟수 / 다시 풀기 보상 스티커 합계 추적, `bgmEnabled` 기본값 true 저장/복원
- 보호자 메뉴의 진행 요약, 음성/효과 토글, 배경 음악 설정 토글 UI, 세트별 진도 조절, 오답 다시 풀기, 오답 비우기, 세트별 수동 해금, 앱 종료/리셋
- 보호자 진행 요약에서 최근 헷갈림 / 오답 다시 보기 집계 chip, 다시 풀기 보상 합계 chip, 최근 보상 callout(최근 보상이 replay reward면 전용 copy), 가장 헷갈린 세트 요약 callout(카테고리/세트 메타데이터 + `이 세트 다시 보기` quick retry) 노출
- GitHub Actions APK 빌드

아직 남은 확장 후보
- richer reward / recorded cue / 자산 오디오 wrapper 실제 playback(BGM 포함) wiring + polish

---

## 현재 큐 기준 상태

### queue 기준 상태
- latest full Gate G provenance는 verified docs-only HEAD `0eecf54` fresh local rerun이며, `58eecac..0eecf54` 사이 변경이 `README.md`, `handoff.md`, `docs/plans/2026-04-16_full-mvp-delivery-plan.md` 3개 문서뿐이었기 때문에 그때 다시 검증된 앱 코드는 `58eecac`였다
- queue A-F의 앱 기능 + G full Gate G provenance는 이제 `58eecac` / `0eecf54` baseline까지 fresh하게 읽을 수 있다
- current live app-code snapshot은 여전히 `58eecac`(`feat(audio): add asset audio player wrapper`)이고, latest full Gate G rerun이 이 app-code baseline을 다시 검증했다
- `2450e81` 이후 live app-code delta는 asset-audio-player / audioplayers groundwork 1건뿐이다: `lib/app/audio/asset_audio_player.dart`, `lib/app/audio/audioplayers_asset_audio_player.dart`, `pubspec.yaml`, `pubspec.lock`, `test/app/audio/asset_audio_player_test.dart`
- live repo에는 `AppProgressSnapshot.bgmEnabled` 기본값 true + persistence API, 보호자 화면의 분리된 배경 음악 설정 토글 UI(`progressStore.setBgmEnabled`), UI copy `배경 음악 켜짐/꺼짐`이 이미 반영돼 있고, `58eecac`은 그 위에 asset audio wrapper groundwork만 추가했다
- runtime truth: `main.dart`는 아직 `audioService: TtsFallbackAudioService(speech: speech)`를 주입하고, `lib/app/audio/tts_fallback_audio_service.dart`는 non-prompt cue(배경 음악 포함)를 silence로 degrade하며 recorded playback / Phase 8이 아직 not wired라고 명시한다. 따라서 `58eecac`은 실제 BGM playback shipping이 아니라 wrapper groundwork다
- live app-code focused verification(`58eecac` pre-rerun follow-up):
  - `./scripts/prepare_assets.sh` => succeeded
  - `/home/openc/sdk/flutter/bin/flutter test test/features/numbers` => `00:03 +28: All tests passed!`
  - `/home/openc/sdk/flutter/bin/flutter test test/app/audio/asset_audio_player_test.dart` => `00:00 +3: All tests passed!`
  - `/home/openc/sdk/flutter/bin/flutter analyze lib/app/audio/asset_audio_player.dart lib/app/audio/audioplayers_asset_audio_player.dart test/app/audio/asset_audio_player_test.dart` => `No issues found! (ran in 1.2s)`
- latest full Gate G rerun 결과(`0eecf54`, app code matched `58eecac`): `./scripts/prepare_assets.sh` / `/home/openc/sdk/flutter/bin/flutter pub get` succeeded, full test `00:42 +282: All tests passed!`, full analyze `No issues found! (ran in 6.1s)`, release APK `build/app/outputs/flutter-apk/app-release.apk` (`18538312` bytes)
- 이 handoff refresh는 verified docs-only HEAD `0eecf54`에서 실행한 full Gate G provenance를 기록하는 later docs-only follow-up이다. 따라서 fresh Gate G claim은 `0eecf54` / `58eecac`에 anchor해서 읽고, 이보다 뒤의 docs-only commit 자체를 rerun checkout으로 읽으면 안 된다
- historical provenance는 직전 docs-only HEAD `9df0082` 로컬 full rerun(`2450e81` 코드 일치), 그 이전 docs-only HEAD `7487a97` 로컬 full rerun(`610a6aa` 코드 일치), docs-only HEAD `9d4c035` 로컬 full rerun(`d81a2ec` 코드 일치), docs-only checkout `f1e23c3` 로컬 full rerun(`0c15caf` 코드 일치), historical docs-only HEAD `1523559` / 코드 스냅샷 `5696c1f`까지 함께 유지한다
- latest full rerun / live app-code spot check / historical reference 세부 결과는 아래 `선별 검증 + Gate G provenance 메모` 섹션에 정리돼 있다

### 1. 문서/CI 정합성
- docs/script 변경도 APK workflow에 포함되도록 정리됨
- README / handoff / 구현 계획 문서는 현재 상태에 맞춰 정리 완료

### 2. toddler interaction foundation
- 공통 탭 쿨타임/연타 방지 적용
- quiz 정답/오답 피드백 dwell + 자동 진행 적용
- 보호자 설정/진도용 로컬 저장소 적용
- 음성 cue 서비스 적용

### 3. 카테고리 확장
- 알파벳 학습 / 게임 구현 완료
- 숫자 학습 / 게임 구현 완료
- 홈의 3개 카테고리가 모두 실제 플레이 가능하도록 연결 완료
- 각 카테고리에서 세트 선택 후 진입하도록 확장 완료
- 한글/알파벳/숫자 manifest를 여러 세트 컨텐츠로 확장 완료

### 4. 보호자 기능 확장
- 스티커/점수/진도 요약 제공
- 소리 설정 제공
- 세트별 진도 앞뒤 조절 제공
- 세트별 오답 다시 풀기 제공
- lesson별 recentMistakes / 오답 다시 보기 누적 횟수 저장, 전역 다시 풀기 보상 합계 추적 및 이를 바탕으로 보호자 요약에서 최근 헷갈림 수, 최근 보상 callout, 가장 헷갈린 세트 요약 callout + `이 세트 다시 보기` quick retry 노출
- 세트별 최근 오답 비우기 제공
- 세트별 수동 해금 제공
- 앱 종료/리셋 최소 운영 기능 제공

### 5. 최근 UI polish
- hero / home / category hub를 garage tone으로 재정렬
- compact landscape 360px 높이에서 overflow 없이 보이도록 조정

---

## 선별 검증 + Gate G provenance 메모

최근 문서화된 live app-code spot check / latest full Gate G provenance / historical verification 메모
- 아래 provenance / spot-check 명령은 모두 repo root(`/home/openc/kids-play-app`) 기준이다
- latest full Gate G provenance는 verified docs-only HEAD `0eecf54` rerun이며, `58eecac..0eecf54`가 docs-only 범위(`README.md`, `handoff.md`, `docs/plans/2026-04-16_full-mvp-delivery-plan.md`)였기 때문에 그 rerun이 다시 검증한 앱 코드는 `58eecac`과 동일하다
- current live app-code snapshot은 여전히 `58eecac`(`feat(audio): add asset audio player wrapper`)이고, later docs-only refresh가 생겨도 fresh full Gate G claim은 계속 `0eecf54` / `58eecac`에 anchor해서 읽어야 한다
- live app-code incremental spot-check(`58eecac` pre-rerun follow-up)
  - `./scripts/prepare_assets.sh` => succeeded
  - `/home/openc/sdk/flutter/bin/flutter test test/features/numbers` => `00:03 +28: All tests passed!`
  - `/home/openc/sdk/flutter/bin/flutter test test/app/audio/asset_audio_player_test.dart` => `00:00 +3: All tests passed!`
  - `/home/openc/sdk/flutter/bin/flutter analyze lib/app/audio/asset_audio_player.dart lib/app/audio/audioplayers_asset_audio_player.dart test/app/audio/asset_audio_player_test.dart` => `No issues found! (ran in 1.2s)`
- runtime note
  - `main.dart`는 아직 `audioService: TtsFallbackAudioService(speech: speech)`를 주입한다
  - `lib/app/audio/tts_fallback_audio_service.dart`는 non-prompt cue(BGM 포함)를 silence로 degrade하며 recorded playback / Phase 8이 아직 not wired라고 적고 있다
- latest full Gate G 로컬 rerun (`0eecf54` docs-only HEAD, app code matched `58eecac` because `58eecac..0eecf54` only touched docs)
  - `./scripts/prepare_assets.sh` => succeeded
  - `/home/openc/sdk/flutter/bin/flutter pub get` => succeeded
  - full `/home/openc/sdk/flutter/bin/flutter test` => `00:42 +282: All tests passed!`
  - full `/home/openc/sdk/flutter/bin/flutter analyze` => `No issues found! (ran in 6.1s)`
  - `/home/openc/sdk/flutter/bin/flutter build apk --release --target-platform android-arm64` => `build/app/outputs/flutter-apk/app-release.apk` (18.5MB / `18538312` bytes)
- previous full Gate G 로컬 rerun (`9df0082` docs-only HEAD, app code matched `2450e81`)
  - `./scripts/prepare_assets.sh` => succeeded
  - `/home/openc/sdk/flutter/bin/flutter pub get` => succeeded
  - full `/home/openc/sdk/flutter/bin/flutter test` => `00:42 +279: All tests passed!`
  - full `/home/openc/sdk/flutter/bin/flutter analyze` => `No issues found! (ran in 5.2s)`
  - `/home/openc/sdk/flutter/bin/flutter build apk --release --target-platform android-arm64` => `build/app/outputs/flutter-apk/app-release.apk` (18.1MB / `18112444` bytes)
- earlier full Gate G 로컬 rerun (`7487a97` docs-only HEAD, app code matched `610a6aa`)
  - `./scripts/prepare_assets.sh` => succeeded
  - `/home/openc/sdk/flutter/bin/flutter pub get` => succeeded
  - full `/home/openc/sdk/flutter/bin/flutter test` => `00:39 +275: All tests passed!`
  - full `/home/openc/sdk/flutter/bin/flutter analyze` => `No issues found! (ran in 5.0s)`
  - `/home/openc/sdk/flutter/bin/flutter build apk --release --target-platform android-arm64` => `build/app/outputs/flutter-apk/app-release.apk` (18.5MB / `18538008` bytes)
- same app-code snapshot `610a6aa` earlier pre-rerun targeted recheck (numbers / home flow / design-system / parent-summary spot checks, full Gate G 전에 남겨둔 기록)
  - `./scripts/prepare_assets.sh` => succeeded
  - `/home/openc/sdk/flutter/bin/flutter test test/features/numbers` => passed
  - `/home/openc/sdk/flutter/bin/flutter test test/widget_test.dart` => passed
  - `/home/openc/sdk/flutter/bin/flutter test test/app/ui` => passed
  - `/home/openc/sdk/flutter/bin/flutter test test/features/avatar/presentation/avatar_setup_screen_test.dart` => passed
  - `/home/openc/sdk/flutter/bin/flutter test test/app/services/progress_store_test.dart` => passed
- historical full Gate G 로컬 rerun (`9d4c035` docs-only HEAD, 당시 검증된 앱 코드는 `d81a2ec`와 동일)
  - `./scripts/prepare_assets.sh` + `/home/openc/sdk/flutter/bin/flutter pub get` 성공
  - full `/home/openc/sdk/flutter/bin/flutter test` => `00:34 +253: All tests passed!`
  - full `/home/openc/sdk/flutter/bin/flutter analyze` => `No issues found! (ran in 2.1s)`
  - `/home/openc/sdk/flutter/bin/flutter build apk --release --target-platform android-arm64` => `build/app/outputs/flutter-apk/app-release.apk` (16.8MB / `16774218` bytes)
- numbers + routing
  - `/home/openc/sdk/flutter/bin/flutter test test/features/numbers/data/numbers_lesson_repository_test.dart test/features/numbers/presentation/numbers_learn_screen_test.dart test/features/numbers/presentation/numbers_quiz_screen_test.dart test/features/home/presentation/category_lesson_picker_flow_test.dart`
  - 결과: passed
- design system
  - `/home/openc/sdk/flutter/bin/flutter test test/app/ui/kid_theme_test.dart test/app/ui/kid_theme_typography_test.dart test/app/ui/toy_button_test.dart test/app/ui/toy_panel_test.dart test/app/ui/toy_button_api_surface_test.dart test/app/ui/toy_panel_api_surface_test.dart test/app/ui/toy_button_label_centering_test.dart`
  - 결과: passed
- hero / home / parent entry + parent summary controls
  - `/home/openc/sdk/flutter/bin/flutter test test/features/hero/presentation/hero_screen_test.dart test/features/home/presentation/home_redesign_test.dart test/features/avatar/presentation/avatar_setup_screen_test.dart`
  - 결과: passed (`avatar_setup_screen_test.dart`에 최근 보상 callout, 가장 헷갈린 세트 요약 렌더링, `이 세트 다시 보기` quick retry 진입 케이스 포함)
- docs-only HEAD `c5879e9` 기준 full test 재확인 (README-only docs commit)
  - 재실행 예시 (`REPO_ROOT` / `FLUTTER_BIN` 값만 바꾸면 다른 머신에서도 같은 순서로 재현 가능)
    ```bash
    REPO_ROOT=/home/openc/kids-play-app
    FLUTTER_BIN=/home/openc/sdk/flutter/bin/flutter

    cd "$REPO_ROOT"
    ./scripts/prepare_assets.sh
    "$FLUTTER_BIN" pub get
    "$FLUTTER_BIN" test
    ```
  - 결과: `./scripts/prepare_assets.sh` succeeded
  - 결과: `00:32 +227: All tests passed!`
- historical Gate G 전 마지막 code-snapshot provenance
  - `5696c1f` `fix(ui): remove tap cooldown analyze blocker`
  - 변경 파일: `lib/app/ui/tap_cooldown.dart`, `test/app/ui/tap_cooldown_test.dart`
- `5696c1f` 기준 코드 스냅샷 targeted verification
  - `/home/openc/sdk/flutter/bin/flutter test test/app/ui/tap_cooldown_test.dart`
  - 결과: `00:00 +9: All tests passed!`
  - `/home/openc/sdk/flutter/bin/flutter analyze lib/app/ui/tap_cooldown.dart test/app/ui/tap_cooldown_test.dart`
  - 결과: `No issues found!`
- 이후 replay-reward parent-summary 관련 follow-up code landed
  - `06d5098` `feat: preserve replay reward lesson stats`
  - `109ba9e` `feat(parent): track mistake replay sessions`
  - `0c15caf` `feat(parent): surface replay reward totals`
- replay-reward follow-up targeted verification
  - `/home/openc/sdk/flutter/bin/flutter test test/app/services/progress_store_test.dart test/features/avatar/presentation/avatar_setup_screen_test.dart test/features/lesson/application/quiz_controller_test.dart`
  - 결과: `00:05 +33: All tests passed!`
  - `/home/openc/sdk/flutter/bin/flutter analyze lib/app/services/progress_store.dart lib/features/avatar/presentation/avatar_setup_screen.dart test/app/services/progress_store_test.dart test/features/avatar/presentation/avatar_setup_screen_test.dart test/features/lesson/application/quiz_controller_test.dart`
  - 결과: `No issues found!`
- historical Gate G reference (docs-only HEAD `1523559`, 검증 대상 코드 스냅샷 `5696c1f`)
  - `./scripts/prepare_assets.sh` + `/home/openc/sdk/flutter/bin/flutter pub get` 성공
  - full `/home/openc/sdk/flutter/bin/flutter test` => `00:33 +236: All tests passed!`
  - full `/home/openc/sdk/flutter/bin/flutter analyze` => `No issues found!`
  - `/home/openc/sdk/flutter/bin/flutter build apk --release --target-platform android-arm64` => `build/app/outputs/flutter-apk/app-release.apk` (16.8MB)
  - GitHub Actions run `24617840783` 성공 / artifact `kids-play-app-arm64-v8a-release` 확인
- fresh Gate G rerun on docs-only checkout `f1e23c3` (app code matched `0c15caf`)
  - `./scripts/prepare_assets.sh` + `/home/openc/sdk/flutter/bin/flutter pub get` 성공
  - full `/home/openc/sdk/flutter/bin/flutter test` => `00:33 +249: All tests passed!`
  - full `/home/openc/sdk/flutter/bin/flutter analyze` => `No issues found! (ran in 3.1s)`
  - `/home/openc/sdk/flutter/bin/flutter build apk --release --target-platform android-arm64` => `build/app/outputs/flutter-apk/app-release.apk` (16.8MB / `16774218` bytes)
- later app-code verification after the fresh rerun
  - `d81a2ec` `feat(lesson): route generic learn prompts through audio service`
  - `/home/openc/sdk/flutter/bin/flutter test test/features/lesson/presentation/generic_learn_screen_test.dart`
  - 결과: `00:01 +6: All tests passed!`
  - `/home/openc/sdk/flutter/bin/flutter analyze lib/features/lesson/presentation/generic_learn_screen.dart test/features/lesson/presentation/generic_learn_screen_test.dart`
  - 결과: `No issues found! (ran in 1.1s)`

release build output path (when generated)
- `build/app/outputs/flutter-apk/app-release.apk`

artifact name (when workflow passes)
- `kids-play-app-arm64-v8a-release`

---

## 자산 구조

- `assets/public`
- `assets/local_private`
- `assets/generated`
- app-private runtime avatar photos: `getApplicationSupportDirectory()/avatar_photos/*.png` + `avatar_photos_v1` metadata

규칙
- build-time asset 경로는 `assets/generated` 기준으로 읽는다.
- 빌드/실행 전에 `./scripts/prepare_assets.sh`를 실행한다.
- 실제 얼굴/민감 자산은 `assets/local_private`에 둔다.
- 보호자 표정 카드가 저장하는 runtime avatar photo는 build-time asset pipeline 바깥에 두며, `prepare_assets.sh`가 복사/삭제하지 않는다.

예시 private 자산
- `/home/openc/kids-play-app/assets/local_private/images/hero/hero_face.png`

---

## 로컬 실행 / 검증

현재 머신에서 확인된 기본값
- `REPO_ROOT=/home/openc/kids-play-app`
- `FLUTTER_BIN=/home/openc/sdk/flutter/bin/flutter`

다른 머신에서 실행할 때
- `REPO_ROOT` 는 자신의 checkout 경로로 바꾼다
- `FLUTTER_BIN` 은 자신의 Flutter binary 경로로 바꾸거나 PATH 의 `flutter` 로 바꾼다

기본 명령 (`docs/local-dev-setup.md` 및 `.github/workflows/build-apk.yml` 과 같은 순서)
```bash
REPO_ROOT=/home/openc/kids-play-app
FLUTTER_BIN=/home/openc/sdk/flutter/bin/flutter

cd "$REPO_ROOT"
./scripts/prepare_assets.sh
"$FLUTTER_BIN" pub get
"$FLUTTER_BIN" test
"$FLUTTER_BIN" analyze
"$FLUTTER_BIN" build apk --release --target-platform android-arm64
```

---

## GitHub Actions

workflow
- `.github/workflows/build-apk.yml`

artifact
- `kids-play-app-arm64-v8a-release`

원칙
- `build-apk.yml`의 `push.paths` 범위 변경은 main에 push되면, 또는 `workflow_dispatch`로 실행하면 Actions APK artifact로 계속 확인 가능해야 한다.
- 사용자는 다음날 커밋/푸시 순서대로 작업물을 확인한다.

---

## 다음 작업자가 바로 이어갈 포인트

우선순위 추천
1. latest full Gate G provenance는 verified docs-only HEAD `0eecf54` / app-code snapshot `58eecac`까지 fresh하다. 다음 real unfinished slice는 richer reward / recorded cue / 자산 오디오 wrapper 실제 playback(BGM 포함) wiring + polish이고, 그 뒤 또 다른 code-changing slice가 누적되면 release 직전이나 의미 있는 통합 시점에 새 queue-head 기준 full Gate G를 다시 돌리는 편이 안전하다.

남은 확장 후보
- richer reward / recorded cue / 자산 오디오 wrapper 실제 playback(BGM 포함) wiring + polish

주의
- 이 앱은 데모가 아니라 실제 아이가 눌러보는 앱이다.
- generic한 Flutter 샘플 느낌이면 실패다.
- compact landscape 회귀를 깨지 않는 것이 중요하다.
- 변경 후에는 해당 slice에 맞는 최소 검증을 우선하고, 최종 handoff/merge 전에는 test / analyze / release apk까지 확인하는 것이 가장 안전하다.
