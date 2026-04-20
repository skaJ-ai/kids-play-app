# 승원이의 빵빵 놀이터

27개월 유아가 Galaxy S24에서 가로 화면으로 사용하는 개인용 오프라인 학습 APK 프로젝트입니다.

현재 핵심 방향
- Flutter 기반 Android 앱
- 가로모드 고정 + immersive full-screen
- 오프라인 전용
- 탭만으로 조작하는 toddler UX
- 한글 / 알파벳 / 숫자 3개 카테고리
- child 화면은 텍스트 최소화, 소리/즉시 피드백 중심
- 보호자 메뉴는 숨김 진입(히어로 얼굴 5회 탭)
- GitHub Actions `build-apk.yml`은 `workflow_dispatch` 또는 main 브랜치의 `push.paths` 범위 변경에서 설치 가능한 APK artifact를 생성

## 현재 상태

- latest full Gate G provenance는 verified docs-only HEAD `9df0082` fresh local rerun이며, `2450e81..9df0082` 사이 변경이 `README.md`, `handoff.md`, `docs/plans/2026-04-16_full-mvp-delivery-plan.md` 3개 문서에만 있었기 때문에 그 rerun이 다시 검증한 앱 코드는 `2450e81`(`feat(audio): add parent bgm toggle`)와 동일했습니다.
- current live app-code snapshot은 `58eecac`(`feat(audio): add asset audio player wrapper`)입니다. 따라서 queue A-G full rerun provenance는 현재 HEAD 기준으로는 아직 fresh하지 않고, 새 current-head full Gate G rerun이 pending입니다.
- `2450e81` 이후 현재 앱 코드 delta는 asset-audio-player / audioplayers groundwork 1건뿐입니다: `lib/app/audio/asset_audio_player.dart`, `lib/app/audio/audioplayers_asset_audio_player.dart`, `pubspec.yaml`, `pubspec.lock`, `test/app/audio/asset_audio_player_test.dart`.
- 하지만 현재 runtime은 여전히 `main.dart`에서 `audioService: TtsFallbackAudioService(speech: speech)`를 주입하고, `lib/app/audio/tts_fallback_audio_service.dart`는 non-prompt cue(배경 음악 포함)를 silence로 degrade하며 recorded playback / Phase 8이 아직 not wired라고 명시합니다. 즉 `58eecac`은 실제 BGM playback shipping이 아니라 wrapper groundwork입니다.
- current queue-head focused verification(`58eecac` follow-up):
  - `./scripts/prepare_assets.sh` => succeeded
  - `/home/openc/sdk/flutter/bin/flutter test test/features/numbers` => `00:03 +28: All tests passed!`
  - `/home/openc/sdk/flutter/bin/flutter test test/app/audio/asset_audio_player_test.dart` => `00:00 +3: All tests passed!`
  - `/home/openc/sdk/flutter/bin/flutter analyze lib/app/audio/asset_audio_player.dart lib/app/audio/audioplayers_asset_audio_player.dart test/app/audio/asset_audio_player_test.dart` => `No issues found! (ran in 1.2s)`
- fresh Gate G rerun 결과(`9df0082`, app code matched `2450e81`): full `/home/openc/sdk/flutter/bin/flutter test` => `00:42 +279: All tests passed!`, full `/home/openc/sdk/flutter/bin/flutter analyze` => `No issues found! (ran in 5.2s)`, `/home/openc/sdk/flutter/bin/flutter build apk --release --target-platform android-arm64` => `build/app/outputs/flutter-apk/app-release.apk` (18.1MB / `18112444` bytes).
- live repo에는 `AppProgressSnapshot.bgmEnabled` 기본값 true + persistence API, 보호자 화면의 분리된 배경 음악 설정 토글 UI(`progressStore.setBgmEnabled`), 관련 targeted test cases(`test/app/services/progress_store_test.dart`, `test/features/avatar/presentation/avatar_setup_screen_test.dart`)가 반영돼 있습니다.
- 직전 full Gate G provenance는 docs-only HEAD `7487a97` fresh local rerun이며, 그때 다시 검증된 앱 코드는 `610a6aa`(`fix(numbers): route learn prompts through audio service`)였습니다.
- 추가 provenance 참고
  - 직전 full Gate G rerun: docs-only HEAD `7487a97`, 당시 검증된 앱 코드는 `610a6aa`
  - 이전 full Gate G rerun: docs-only HEAD `9d4c035`, 당시 검증된 앱 코드 스냅샷 `d81a2ec`
  - docs-only checkout `f1e23c3` fresh local rerun: 당시 checkout의 앱 코드는 `0c15caf`와 동일했습니다.
  - historical artifact-backed record: docs-only HEAD `1523559` / 코드 스냅샷 `5696c1f`, GitHub Actions run `24617840783`, artifact `kids-play-app-arm64-v8a-release`.

## 현재 구현 범위

이미 구현된 것
- hero → home → category hub의 garage flow
- 보호자 메뉴의 5개 표정 카드에서 갤러리 사진 가져오기 + 정사각형 크롭 + 표정별 저장/지우기
- avatar photo metadata는 별도 `avatar_photos_v1` key에 저장되고, crop 결과 파일은 앱 전용 경로(`getApplicationSupportDirectory()/avatar_photos/<expression>.png`)에 저장
- 히어로 얼굴은 저장된 smile/neutral 런타임 사진이 있으면 우선 사용하고, 없으면 `assets/generated/images/hero/hero_face.png` 경로의 bundled/generated hero face asset으로 fallback
- 홈/카테고리 허브에서 한글 / 알파벳 / 숫자 3개 카테고리 배우기 / 퀴즈 라우팅 완료
- 한글 / 알파벳 / 숫자 다중 세트 학습 카드
- 한글 / 알파벳 / 숫자 다중 세트 4지선다 퀴즈
- 카테고리 진입 뒤 세트 선택 화면
- compact landscape 대응 UI와 회귀 테스트
- toddler-safe tap cooldown / 연타 방지
- 정답/오답 즉시 피드백 오버레이
- 음성 cue + 문제 다시 듣기 버튼
- shared_preferences 기반 진도 / 오답 / 스티커 / 음성/효과/배경 음악 설정 저장, lesson별 오답 다시 풀기 횟수 / 다시 풀기 보상 스티커 합계 추적
- 보호자 메뉴의 진행 요약, 음성/효과 토글, 배경 음악 설정 토글 UI, 세트별 진도 조절, 오답 다시 풀기, 오답 비우기, 세트별 수동 해금, 리셋, 종료
- 보호자 진행 요약에서 최근 헷갈림 / 오답 다시 보기 집계 chip, 다시 풀기 보상 합계 chip, 최근 보상 callout(최근 보상이 replay reward면 전용 copy), 가장 헷갈린 세트 요약 callout(카테고리/세트 메타데이터 + `이 세트 다시 보기` quick retry)을 노출
- GitHub Actions APK 빌드 파이프라인

다음 확장 후보
- richer reward / 녹음 효과음 / 자산 오디오 wrapper를 실제 playback(BGM 포함)에 연결 + polish

## 현재 앱 흐름

1. 히어로 화면에서 출발
2. 홈 차고에서 한글 / 알파벳 / 숫자 선택
3. 카테고리 차고에서 배우기 / 퀴즈 진입
4. 세트 선택 화면에서 원하는 세트 선택
5. 세트 완료 시 점수와 스티커 저장
6. 보호자 메뉴에서 진행 요약, 세트별 진도 조절, 오답 다시 풀기, 오답 비우기, 세트별 수동 해금

## 실행 방법

### 로컬 개발
```bash
REPO_ROOT=/home/openc/kids-play-app
FLUTTER_BIN=/home/openc/sdk/flutter/bin/flutter
# 다른 머신에서는 REPO_ROOT 를 자신의 checkout root로 바꾸고,
# FLUTTER_BIN 은 자신의 Flutter binary 경로 또는 PATH 의 flutter 로 교체

cd "$REPO_ROOT"
./scripts/prepare_assets.sh
"$FLUTTER_BIN" pub get
"$FLUTTER_BIN" run
```

### 테스트 / 최종 검증
현재 기준
- 아래 provenance / spot-check 명령은 모두 repo root(`/home/openc/kids-play-app`) 기준입니다.
- latest full Gate G rerun reference는 verified docs-only HEAD `9df0082`이며, `2450e81..9df0082`가 docs-only 범위였기 때문에 이 rerun이 다시 검증한 앱 코드는 `2450e81`과 동일했습니다.
- current live app-code snapshot은 `58eecac`(`feat(audio): add asset audio player wrapper`)입니다. 따라서 current HEAD 기준 queue A-G full rerun provenance는 아직 fresh하지 않으며, 새 full Gate G rerun이 pending입니다.
- `58eecac` delta는 `lib/app/audio/asset_audio_player.dart`, `lib/app/audio/audioplayers_asset_audio_player.dart`, `pubspec.yaml`, `pubspec.lock`, `test/app/audio/asset_audio_player_test.dart`의 asset-audio-player / audioplayers groundwork뿐입니다.
- current queue-head focused spot-check(`58eecac` follow-up):
  - `./scripts/prepare_assets.sh` => succeeded
  - `/home/openc/sdk/flutter/bin/flutter test test/features/numbers` => `00:03 +28: All tests passed!`
  - `/home/openc/sdk/flutter/bin/flutter test test/app/audio/asset_audio_player_test.dart` => `00:00 +3: All tests passed!`
  - `/home/openc/sdk/flutter/bin/flutter analyze lib/app/audio/asset_audio_player.dart lib/app/audio/audioplayers_asset_audio_player.dart test/app/audio/asset_audio_player_test.dart` => `No issues found! (ran in 1.2s)`
- current runtime note: `main.dart`는 아직 `audioService: TtsFallbackAudioService(speech: speech)`를 주입하고, non-prompt cue(BGM 포함)는 recorded playback / Phase 8 wiring 전까지 silence로 degrade됩니다.
- fresh full Gate G rerun (`9df0082`, app code unchanged since `2450e81`):
  - `./scripts/prepare_assets.sh` => succeeded
  - `/home/openc/sdk/flutter/bin/flutter pub get` => succeeded
  - full `/home/openc/sdk/flutter/bin/flutter test` => `00:42 +279: All tests passed!`
  - full `/home/openc/sdk/flutter/bin/flutter analyze` => `No issues found! (ran in 5.2s)`
  - `/home/openc/sdk/flutter/bin/flutter build apk --release --target-platform android-arm64` => `build/app/outputs/flutter-apk/app-release.apk` (18.1MB / `18112444` bytes)
- previous full Gate G rerun (`7487a97`, app code matched `610a6aa`):
  - `./scripts/prepare_assets.sh` => succeeded
  - `/home/openc/sdk/flutter/bin/flutter pub get` => succeeded
  - full `/home/openc/sdk/flutter/bin/flutter test` => `00:39 +275: All tests passed!`
  - full `/home/openc/sdk/flutter/bin/flutter analyze` => `No issues found! (ran in 5.0s)`
  - `/home/openc/sdk/flutter/bin/flutter build apk --release --target-platform android-arm64` => `build/app/outputs/flutter-apk/app-release.apk` (18.5MB / `18538008` bytes)
- historical full Gate G rerun (`9d4c035`, 당시 검증된 앱 코드는 `d81a2ec`와 동일):
  - `./scripts/prepare_assets.sh` + `/home/openc/sdk/flutter/bin/flutter pub get` 성공
  - full `/home/openc/sdk/flutter/bin/flutter test` => `00:34 +253: All tests passed!`
  - full `/home/openc/sdk/flutter/bin/flutter analyze` => `No issues found! (ran in 2.1s)`
  - `/home/openc/sdk/flutter/bin/flutter build apk --release --target-platform android-arm64` => `build/app/outputs/flutter-apk/app-release.apk` (16.8MB / `16774218` bytes)
- 이전 로컬 full rerun 기록 (`f1e23c3`, 검증된 앱 코드는 `0c15caf`와 동일):
  - `./scripts/prepare_assets.sh` + `/home/openc/sdk/flutter/bin/flutter pub get` 성공
  - full `/home/openc/sdk/flutter/bin/flutter test` => `00:33 +249: All tests passed!`
  - full `/home/openc/sdk/flutter/bin/flutter analyze` => `No issues found! (ran in 3.1s)`
  - `/home/openc/sdk/flutter/bin/flutter build apk --release --target-platform android-arm64` => `build/app/outputs/flutter-apk/app-release.apk` (16.8MB / `16774218` bytes)
- historical artifact-backed Gate G reference (`1523559` / `5696c1f`):
  - `./scripts/prepare_assets.sh` + `/home/openc/sdk/flutter/bin/flutter pub get` 성공
  - full `/home/openc/sdk/flutter/bin/flutter test` => `00:33 +236: All tests passed!`
  - full `/home/openc/sdk/flutter/bin/flutter analyze` => `No issues found!`
  - `/home/openc/sdk/flutter/bin/flutter build apk --release --target-platform android-arm64` => `build/app/outputs/flutter-apk/app-release.apk` (16.8MB)
  - GitHub Actions run `24617840783` 성공, artifact `kids-play-app-arm64-v8a-release` 확인

```bash
REPO_ROOT=/home/openc/kids-play-app
FLUTTER_BIN=/home/openc/sdk/flutter/bin/flutter
# 다른 머신에서는 REPO_ROOT 를 자신의 checkout root로 바꾸고,
# FLUTTER_BIN 은 자신의 Flutter binary 경로 또는 PATH 의 flutter 로 교체

cd "$REPO_ROOT"
./scripts/prepare_assets.sh
"$FLUTTER_BIN" pub get
"$FLUTTER_BIN" test
"$FLUTTER_BIN" analyze
"$FLUTTER_BIN" build apk --release --target-platform android-arm64
```

- 아래 명령 블록은 `docs/local-dev-setup.md` 및 `.github/workflows/build-apk.yml` 과 같은 순서의 Gate G 재현용 체크리스트입니다. latest full rerun reference는 verified docs-only HEAD `9df0082`(app code matched `2450e81` because `2450e81..9df0082` only touched docs)입니다. current live app-code snapshot은 현재 `58eecac`(`feat(audio): add asset audio player wrapper`)이므로 current-head fresh Gate G claim은 아직 없습니다. current delta는 asset-audio-player groundwork와 focused verification만 추가됐고, live runtime은 여전히 `TtsFallbackAudioService`를 통해 non-prompt/BGM cue를 silence로 degrade하므로 실제 playback wiring은 pending입니다. 직전 로컬 full rerun은 docs-only HEAD `7487a97`(app code matched `610a6aa`)이고, 그 이전 로컬 full rerun은 docs-only HEAD `9d4c035`(검증된 앱 코드는 `d81a2ec`) 및 docs-only checkout `f1e23c3`(검증된 앱 코드는 `0c15caf`와 동일)입니다. historical artifact-backed 기준은 docs-only HEAD `1523559` / code snapshot `5696c1f`입니다.

## APK 확인 방법

GitHub Actions
- Workflow: Build Android APK
- Artifact: kids-play-app-arm64-v8a-release

로컬 빌드 결과
- build/app/outputs/flutter-apk/app-release.apk

## 자산 구조

- assets/public: git에 커밋하는 placeholder / 안전 자산
- assets/local_private: gitignore되는 실제 얼굴/민감 자산
- assets/generated: 앱이 실제로 읽는 최종 자산 폴더
- runtime avatar photos: 보호자 표정 카드가 저장하는 앱 전용 파일(`getApplicationSupportDirectory()/avatar_photos/*.png`) + `avatar_photos_v1` metadata. build-time asset 폴더와 별도

자산 준비
```bash
REPO_ROOT=/home/openc/kids-play-app
# 다른 머신에서는 REPO_ROOT 를 자신의 checkout root로 교체

cd "$REPO_ROOT"
./scripts/prepare_assets.sh
```

이 머신에서는 위처럼 repo root(`/home/openc/kids-play-app`)를 기준으로 실행한다. 다른 머신도 같은 순서로 자신의 checkout root에서 실행하면 된다. `./scripts/prepare_assets.sh`는 build-time asset만 준비하며, runtime avatar photo 파일은 복사/삭제하지 않는다.

## 참고 문서

- handoff: `handoff.md`
- 구현 계획: `docs/plans/2026-04-16_full-mvp-delivery-plan.md`
- avatar photo status: `docs/plans/2026-04-19_avatar-photo-upload-crop-plan.md`
- 자산 파이프라인: `docs/asset-pipeline.md`
- 히어로 얼굴 자산 가이드: `docs/hero-face-asset-spec.md`
- 로컬 개발 환경: `docs/local-dev-setup.md`
