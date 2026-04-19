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

- historical full Gate G provenance는 docs-only HEAD `9d4c035`에 남아 있고, 당시 full rerun이 검증한 앱 코드 스냅샷은 `d81a2ec`였습니다.
- 이번 docs-only refresh 직전의 latest live app-code snapshot은 `610a6aa`(`fix(numbers): route learn prompts through audio service`)입니다. historical Gate G snapshot 이후 avatar runtime photo flow(`2c78d5f`~`faff2ce`), quiz prompt replay audio service(`19a6f1d`), numbers learn prompt audio service(`610a6aa`) follow-up이 반영됐습니다.
- queue 관점에서는 A-E 앱 기능이 latest live app-code snapshot에 반영돼 있고, F 문서 정리는 이번 docs-only refresh에서 마무리했습니다. 이번 docs refresh에서는 numbers / home flow / design-system / parent-summary 관련 핵심 선별 테스트만 current app-code snapshot 기준으로 다시 확인했습니다.
- 다만 latest live app-code snapshot `610a6aa`에 대한 fresh full Gate G rerun(`flutter test`/`flutter analyze`/release build)은 아직 새로 주장하지 않습니다. 이번 run의 targeted verification 기록은 아래 `테스트 / 최종 검증` 섹션과 `handoff.md`에 남겨뒀습니다.
- 추가 provenance 참고
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
- shared_preferences 기반 진도 / 오답 / 스티커 / 설정 저장, lesson별 오답 다시 풀기 횟수 / 다시 풀기 보상 스티커 합계 추적
- 보호자 메뉴의 진행 요약, 음성/효과 토글, 세트별 진도 조절, 오답 다시 풀기, 오답 비우기, 세트별 수동 해금, 리셋, 종료
- 보호자 진행 요약에서 최근 헷갈림 / 오답 다시 보기 집계 chip, 다시 풀기 보상 합계 chip, 최근 보상 callout(최근 보상이 replay reward면 전용 copy), 가장 헷갈린 세트 요약 callout(카테고리/세트 메타데이터 + `이 세트 다시 보기` quick retry)을 노출
- GitHub Actions APK 빌드 파이프라인

다음 확장 후보
- richer reward / 효과음 / 배경음악 polish

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
- historical full Gate G rerun reference는 docs-only HEAD `9d4c035`이고, 당시 검증된 앱 코드 스냅샷은 `d81a2ec`였습니다.
- 이번 docs-only refresh 직전의 latest live app-code snapshot은 `610a6aa`(`fix(numbers): route learn prompts through audio service`)입니다. 이 docs-only update는 `610a6aa`의 fresh full Gate G rerun을 다시 주장하지 않고, 아래 targeted recheck만 반영합니다.
- current app-code snapshot targeted recheck (`610a6aa`, numbers / home flow / design-system / parent-summary spot checks, full Gate G 재실행 아님):
  - `./scripts/prepare_assets.sh` => succeeded
  - `/home/openc/sdk/flutter/bin/flutter test test/features/numbers` => passed
  - `/home/openc/sdk/flutter/bin/flutter test test/widget_test.dart` => passed
  - `/home/openc/sdk/flutter/bin/flutter test test/app/ui` => passed
  - `/home/openc/sdk/flutter/bin/flutter test test/features/avatar/presentation/avatar_setup_screen_test.dart` => passed
  - `/home/openc/sdk/flutter/bin/flutter test test/app/services/progress_store_test.dart` => passed
- latest live app-code snapshot `610a6aa` 기준 fresh full Gate G rerun(`flutter test` / `flutter analyze` / release build)은 아직 pending입니다.
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

- 아래 명령 블록은 `docs/local-dev-setup.md` 및 `.github/workflows/build-apk.yml` 과 같은 순서의 Gate G 재현용 체크리스트입니다. historical full rerun reference는 docs-only HEAD `9d4c035`(당시 검증된 앱 코드는 `d81a2ec`)이고, latest live app-code snapshot `610a6aa`에는 위의 targeted recheck만 새로 반영했습니다. 그 이전 로컬 rerun은 docs-only checkout `f1e23c3`(검증된 앱 코드는 `0c15caf`와 동일)이며, historical artifact-backed 기준은 docs-only HEAD `1523559` / code snapshot `5696c1f`입니다.

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
