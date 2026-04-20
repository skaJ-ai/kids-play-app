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

- latest full Gate G provenance는 docs-only HEAD `7487a97` fresh local rerun이며, 그때 다시 검증된 앱 코드는 `610a6aa`(`fix(numbers): route learn prompts through audio service`)였습니다.
- current live app-code snapshot은 `2450e81`(`feat(audio): add parent bgm toggle`)이며, Gate G rerun 뒤 `e2f1ed5`(`feat(audio): persist bgm setting`)와 `2450e81` audio follow-up이 추가됐습니다.
- `610a6aa` provenance 범위에는 avatar runtime photo flow(`2c78d5f`~`faff2ce`), quiz prompt replay audio service(`19a6f1d`), numbers learn prompt audio service(`610a6aa`) follow-up이 포함됩니다.
- live repo에는 `AppProgressSnapshot.bgmEnabled` 기본값 true + persistence API, 보호자 화면의 분리된 배경 음악 설정 토글 UI(`progressStore.setBgmEnabled`), 관련 targeted test cases(`test/app/services/progress_store_test.dart`, `test/features/avatar/presentation/avatar_setup_screen_test.dart`)가 반영돼 있습니다.
- 따라서 queue A-G full rerun provenance는 아직 `610a6aa` / `7487a97` 기준까지만 fresh합니다. 이 docs refresh는 `2450e81`에 대한 fresh full Gate G rerun을 뜻하지 않습니다.
- 추가 provenance 참고
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
- richer reward / 녹음 효과음 / 배경음악 재생 연결 + polish

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
- latest full Gate G rerun reference는 docs-only HEAD `7487a97`이고, 이 rerun이 다시 검증한 앱 코드는 `610a6aa`와 동일했습니다.
- current live app-code snapshot은 `2450e81`이며, Gate G rerun 뒤 `e2f1ed5` / `2450e81` audio follow-up이 추가됐습니다.
- 따라서 queue A-G full rerun provenance는 아직 `610a6aa` 기준까지만 fresh합니다. 이 README는 `2450e81`에 대한 fresh full Gate G rerun을 주장하지 않습니다.
- 현재 queue-head fresh pass 기록은 `./scripts/prepare_assets.sh`, `/home/openc/sdk/flutter/bin/flutter test test/features/numbers`, 그리고 아래 parent BGM follow-up targeted verification입니다.
- parent BGM follow-up targeted verification:
  - `/home/openc/sdk/flutter/bin/flutter test test/app/services/progress_store_test.dart --plain-name "memory progress store setBgmEnabled persists the flag and reset restores true"` => `00:00 +1: All tests passed!`
  - `/home/openc/sdk/flutter/bin/flutter test test/app/services/progress_store_test.dart --plain-name "shared preferences progress store persists bgm across reload and reset restores true"` => `00:00 +1: All tests passed!`
  - `/home/openc/sdk/flutter/bin/flutter test test/app/services/progress_store_test.dart --plain-name "snapshot json and copyWith preserve bgm and default missing payloads to true"` => `00:00 +1: All tests passed!`
  - `/home/openc/sdk/flutter/bin/flutter test test/features/avatar/presentation/avatar_setup_screen_test.dart --plain-name "lets parent toggle background music separately"` => `00:01 +1: All tests passed!`
- fresh full Gate G rerun (`7487a97`, app code matched `610a6aa`):
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

- 아래 명령 블록은 `docs/local-dev-setup.md` 및 `.github/workflows/build-apk.yml` 과 같은 순서의 Gate G 재현용 체크리스트입니다. latest full rerun reference는 docs-only HEAD `7487a97`(app code matched `610a6aa`)이고, current live queue-head는 `2450e81`까지 이동했습니다. 따라서 `e2f1ed5` / `2450e81` audio follow-up은 아래 full Gate G reference와 별개로 좁게 읽어야 합니다. 이전 로컬 full rerun은 docs-only HEAD `9d4c035`(검증된 앱 코드는 `d81a2ec`) 및 docs-only checkout `f1e23c3`(검증된 앱 코드는 `0c15caf`와 동일)입니다. historical artifact-backed 기준은 docs-only HEAD `1523559` / code snapshot `5696c1f`입니다.

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
