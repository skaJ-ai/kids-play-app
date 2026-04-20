# Full MVP Delivery Plan

> For Hermes: execute this plan incrementally with small, committable slices, keep GitHub Actions generating an APK artifact for slices that land in the workflow `push.paths` scope on `main` or when `build-apk.yml` is run via `workflow_dispatch`, use the smallest relevant verification for each run, and reserve the full `./scripts/prepare_assets.sh` + `/home/openc/sdk/flutter/bin/flutter pub get` + `flutter test` / `flutter analyze` / release build gate for final integration gate G.

## Status update

완료되었거나 live repo에서 재확인된 slice
- Slice 0 — docs + CI alignment
- Slice 1 — toddler interaction foundation
- Slice 2 — persistence + parent controls foundation
- Slice 3 — alphabet playable MVP
- Slice 4 — numbers playable MVP
- Slice 5 — audio-first prompt layer
- Slice 6 기능 범위 중 home/category/hub garage UI 정리, 보호자 진행 요약/진도 제어/오답 다시 풀기/오답 비우기/수동 해금, 다중 세트와 3개 카테고리 라우팅 확장까지 반영 및 재확인됨
- live repo follow-up으로 avatar runtime photo flow(`2c78d5f`~`faff2ce`), quiz prompt replay audio service(`19a6f1d`), numbers learn prompt audio service(`610a6aa`), bgm setting persistence(`e2f1ed5`), parent BGM toggle(`2450e81`)까지 main에 반영됨

현재 큐 기준 상태
- latest full Gate G provenance는 verified docs-only HEAD `9df0082` fresh local rerun이며, `2450e81..9df0082` 사이 변경이 `README.md`, `handoff.md`, `docs/plans/2026-04-16_full-mvp-delivery-plan.md` 3개 문서뿐이었기 때문에 그때 다시 검증된 앱 코드는 `2450e81`였다
- queue A-F의 앱 기능 + G full Gate G provenance는 현재 `2450e81` / `9df0082` 기준으로 fresh하게 읽을 수 있다
- current live app-code snapshot은 `2450e81`(`feat(audio): add parent bgm toggle`)이며, latest full Gate G rerun이 이 app-code baseline을 다시 검증했다
- live repo에는 `AppProgressSnapshot.bgmEnabled` 기본값 true + persistence API, 보호자 화면의 분리된 배경 음악 설정 토글 UI(`progressStore.setBgmEnabled`)가 반영돼 있다
- current queue-head focused spot-check 기록에는 `./scripts/prepare_assets.sh`, `/home/openc/sdk/flutter/bin/flutter test test/features/numbers`, 그리고 아래 parent BGM follow-up targeted verification이 포함된다
- parent BGM follow-up targeted verification:
  - `/home/openc/sdk/flutter/bin/flutter test test/app/services/progress_store_test.dart --plain-name "memory progress store setBgmEnabled persists the flag and reset restores true"` => `00:00 +1: All tests passed!`
  - `/home/openc/sdk/flutter/bin/flutter test test/app/services/progress_store_test.dart --plain-name "shared preferences progress store persists bgm across reload and reset restores true"` => `00:00 +1: All tests passed!`
  - `/home/openc/sdk/flutter/bin/flutter test test/app/services/progress_store_test.dart --plain-name "snapshot json and copyWith preserve bgm and default missing payloads to true"` => `00:00 +1: All tests passed!`
  - `/home/openc/sdk/flutter/bin/flutter test test/features/avatar/presentation/avatar_setup_screen_test.dart --plain-name "lets parent toggle background music separately"` => `00:01 +1: All tests passed!`
- latest full Gate G rerun 결과(`9df0082`): full test `00:42 +279: All tests passed!`, full analyze `No issues found! (ran in 5.2s)`, release APK `build/app/outputs/flutter-apk/app-release.apk` (`18112444` bytes)
- 이 plan refresh는 verified docs-only HEAD `9df0082`에서 실행한 full Gate G provenance를 기록하는 later docs-only refresh다. 따라서 fresh Gate G claim은 `9df0082`에 anchor해서 읽고, 이보다 뒤의 docs-only commit 자체를 rerun checkout으로 읽으면 안 된다
- provenance 메모: historical progression은 `c5879e9`(README-only full test 재확인) → docs-only HEAD `1523559` / 코드 스냅샷 `5696c1f`(Gate G + historical GitHub Actions provenance) → docs-only checkout `f1e23c3` 로컬 full rerun(`0c15caf` 코드 일치) → docs-only HEAD `9d4c035` 로컬 full rerun(`d81a2ec` 코드 일치) → docs-only HEAD `7487a97` 로컬 full rerun(`610a6aa` 코드 일치) → docs-only HEAD `9df0082` 로컬 full rerun(`2450e81` 코드 일치) 순서로 누적됐다. 세부 명령 결과는 아래 Gate G checklist에 정리한다
- `test/features/avatar/presentation/avatar_setup_screen_test.dart`에는 가장 헷갈린 세트 요약 렌더링 / `이 세트 다시 보기` quick retry와 함께 parent BGM toggle 케이스도 포함된다

남은 확장 후보
- richer reward / 녹음 효과음 / 배경음악 재생 연결 + polish

## Goal

현재 한글/알파벳/숫자 라우팅까지 완료된 `승원이의 빵빵 놀이터`를, 사용자가 다음날 순차적으로 확인할 수 있는 end-to-end toddler-ready APK로 확장한다.

## Delivery principles

- child 화면은 탭만 사용
- 텍스트보다 큰 시각 요소와 소리 중심
- 첫 탭은 즉시 반응, 연타는 방어
- `build-apk.yml`의 `push.paths` 범위 변경은 main에 push되면, 또는 `workflow_dispatch`로 실행하면 GitHub Actions APK artifact까지 이어지게 유지
- 작은 커밋으로 자주 push
- 각 run은 review/push 가능한 작은 slice 하나를 목표로 하고, slice마다 바뀐 범위에 맞는 smallest relevant verification만 수행
- full `./scripts/prepare_assets.sh` + `/home/openc/sdk/flutter/bin/flutter pub get` + full `/home/openc/sdk/flutter/bin/flutter test` / `/home/openc/sdk/flutter/bin/flutter analyze` / release APK build는 final integration gate G에서만 요구

## Planned slices

### Slice 0 — docs + CI alignment
- README 최신화
- handoff 최신화
- 이 계획 문서 추가
- Actions trigger에 docs/script 변경 포함
- asset prep를 `scripts/prepare_assets.sh`로 통일

### Slice 1 — toddler interaction foundation
- 공통 tap cooldown / toddler-safe throttle
- child-facing 버튼과 카드에 중복 탭 방어 적용
- quiz answer 처리 중 추가 입력 잠금
- 정답/오답 피드백 오버레이 + 짧은 dwell 후 자동 진행

### Slice 2 — persistence + parent controls foundation
- shared_preferences 기반 progress/settings 저장소 추가
- 스티커 수, lesson best score, recent mistakes, audio settings 저장
- app root에서 서비스 주입 구조 추가
- 부모 화면에서 소리 on/off, progress 요약, reset/exit 최소 기능 제공

### Slice 3 — alphabet playable MVP
- alphabet manifest / repository 추가
- alphabet learn screen
- alphabet quiz screen
- category hub에서 alphabet learn/game 실제 연결
- 관련 widget/unit 테스트 추가

### Slice 4 — numbers playable MVP
- numbers manifest / repository 추가
- numbers learn screen
- numbers quiz screen
- category hub에서 numbers learn/game 실제 연결
- 관련 widget/unit 테스트 추가

### Slice 5 — audio-first prompt layer
- speech cue service 인터페이스 + production/noop 구현
- prompt replay button
- screen 진입/문제 진입 시 prompt 요청
- parent settings와 연동
- tests는 fake/noop audio로 유지

### Slice 6 — end-to-end polish
- parent dashboard 정보 정리 완료
- home/category/hub garage UI 정리 완료
- 집계 chip / 최근 보상 / 가장 헷갈린 세트 요약 callout(카테고리/세트 메타데이터) + `이 세트 다시 보기` quick retry 흐름 정리 완료
- parent settings의 bgmEnabled persistence + 배경 음악 설정 토글 UI follow-up이 live repo와 focused tests에 반영됨
- docs cleanup 완료
- docs-only HEAD `1523559` / 코드 스냅샷 `5696c1f`의 historical Gate G provenance, docs-only checkout `f1e23c3` 로컬 full rerun(`0c15caf` 코드 일치), docs-only HEAD `9d4c035` 로컬 full rerun(`d81a2ec` 코드 일치), docs-only HEAD `7487a97` 로컬 full rerun(`610a6aa` 코드 일치)까지 historical reference로 확보됐고, latest fresh rerun은 docs-only HEAD `9df0082`에서 app code `2450e81`를 다시 검증했다

## Verification approach

작은 per-run slice 원칙
- 각 run은 committable한 작은 범위로 자른다.
- docs-only 또는 국소 기능 변경은 해당 변경과 직접 연결된 최소 검증만 수행한다.
- 예: docs-only slice는 exact diff 확인과 관련 문서 wording alignment 확인 정도만 남기고, 국소 feature/UI slice는 관련 targeted test만 실행한다.
- full gate를 실제로 다시 돌린 경우에만 full `./scripts/prepare_assets.sh` → `/home/openc/sdk/flutter/bin/flutter pub get` → `flutter test` / `flutter analyze` / release build 재검증을 했다고 기록한다.

### Gate G — final integration checklist

- 아래 provenance / spot-check 명령은 모두 repo root(`/home/openc/kids-play-app`) 기준이다.
- 이 게이트의 historical provenance는 docs-only HEAD `1523559` / 코드 스냅샷 `5696c1f`, docs-only checkout `f1e23c3` 로컬 full rerun, docs-only HEAD `9d4c035` 로컬 full rerun, docs-only HEAD `7487a97` 로컬 full rerun까지 확보돼 있었다. latest full Gate G provenance는 verified docs-only HEAD `9df0082` fresh local rerun이고, `2450e81..9df0082`가 docs-only 범위였기 때문에 그 rerun이 다시 검증한 앱 코드는 `2450e81`과 동일했다. later docs-only refresh가 생겨도 fresh Gate G claim은 `9df0082`에 anchor해서 읽어야 한다.

- current queue-head incremental spot check (full Gate G 이전/병행에 남겨둔 focused verification)
  - `./scripts/prepare_assets.sh` => succeeded
  - `/home/openc/sdk/flutter/bin/flutter test test/features/numbers` => passed
  - `/home/openc/sdk/flutter/bin/flutter test test/app/services/progress_store_test.dart --plain-name "memory progress store setBgmEnabled persists the flag and reset restores true"` => `00:00 +1: All tests passed!`
  - `/home/openc/sdk/flutter/bin/flutter test test/app/services/progress_store_test.dart --plain-name "shared preferences progress store persists bgm across reload and reset restores true"` => `00:00 +1: All tests passed!`
  - `/home/openc/sdk/flutter/bin/flutter test test/app/services/progress_store_test.dart --plain-name "snapshot json and copyWith preserve bgm and default missing payloads to true"` => `00:00 +1: All tests passed!`
  - `/home/openc/sdk/flutter/bin/flutter test test/features/avatar/presentation/avatar_setup_screen_test.dart --plain-name "lets parent toggle background music separately"` => `00:01 +1: All tests passed!`

- latest full Gate G rerun (`9df0082`, app code matched `2450e81` because `2450e81..9df0082` only touched docs)
  - `./scripts/prepare_assets.sh` => succeeded
  - `/home/openc/sdk/flutter/bin/flutter pub get` => succeeded
  - full `/home/openc/sdk/flutter/bin/flutter test` => `00:42 +279: All tests passed!`
  - full `/home/openc/sdk/flutter/bin/flutter analyze` => `No issues found! (ran in 5.2s)`
  - `/home/openc/sdk/flutter/bin/flutter build apk --release --target-platform android-arm64` => `build/app/outputs/flutter-apk/app-release.apk` (18.1MB / `18112444` bytes)

- previous full Gate G rerun (`7487a97`, app code matched `610a6aa`)
  - `./scripts/prepare_assets.sh` => succeeded
  - `/home/openc/sdk/flutter/bin/flutter pub get` => succeeded
  - full `/home/openc/sdk/flutter/bin/flutter test` => `00:39 +275: All tests passed!`
  - full `/home/openc/sdk/flutter/bin/flutter analyze` => `No issues found! (ran in 5.0s)`
  - `/home/openc/sdk/flutter/bin/flutter build apk --release --target-platform android-arm64` => `build/app/outputs/flutter-apk/app-release.apk` (18.5MB / `18538008` bytes)

- same app-code snapshot `610a6aa` earlier pre-rerun targeted recheck (numbers / home flow / design-system / parent-summary spot checks, full Gate G 재실행 아님)
  - `./scripts/prepare_assets.sh` => succeeded
  - `/home/openc/sdk/flutter/bin/flutter test test/features/numbers` => passed
  - `/home/openc/sdk/flutter/bin/flutter test test/widget_test.dart` => passed
  - `/home/openc/sdk/flutter/bin/flutter test test/app/ui` => passed
  - `/home/openc/sdk/flutter/bin/flutter test test/features/avatar/presentation/avatar_setup_screen_test.dart` => passed
  - `/home/openc/sdk/flutter/bin/flutter test test/app/services/progress_store_test.dart` => passed

```bash
cd /home/openc/kids-play-app
./scripts/prepare_assets.sh
/home/openc/sdk/flutter/bin/flutter pub get
/home/openc/sdk/flutter/bin/flutter test
/home/openc/sdk/flutter/bin/flutter analyze
/home/openc/sdk/flutter/bin/flutter build apk --release --target-platform android-arm64
```

- 이전 로컬 full rerun 기록 (docs-only HEAD `9d4c035`, 검증된 앱 코드는 `d81a2ec`와 동일)
  - `./scripts/prepare_assets.sh` 성공
  - `/home/openc/sdk/flutter/bin/flutter pub get` 성공
  - full `/home/openc/sdk/flutter/bin/flutter test` => `00:34 +253: All tests passed!`
  - full `/home/openc/sdk/flutter/bin/flutter analyze` => `No issues found! (ran in 2.1s)`
  - `/home/openc/sdk/flutter/bin/flutter build apk --release --target-platform android-arm64` => `build/app/outputs/flutter-apk/app-release.apk` (16.8MB / `16774218` bytes)
- 그 이전 로컬 full rerun 기록 (docs-only checkout `f1e23c3`, 검증된 앱 코드는 `0c15caf`와 동일)
  - `./scripts/prepare_assets.sh` 성공
  - `/home/openc/sdk/flutter/bin/flutter pub get` 성공
  - full `/home/openc/sdk/flutter/bin/flutter test` => `00:33 +249: All tests passed!`
  - full `/home/openc/sdk/flutter/bin/flutter analyze` => `No issues found! (ran in 3.1s)`
  - `/home/openc/sdk/flutter/bin/flutter build apk --release --target-platform android-arm64` => `build/app/outputs/flutter-apk/app-release.apk` (16.8MB / `16774218` bytes)
- `9d4c035` full rerun 전 임시 targeted verification for `d81a2ec`
  - `/home/openc/sdk/flutter/bin/flutter test test/features/lesson/presentation/generic_learn_screen_test.dart` => `00:01 +6: All tests passed!`
  - `/home/openc/sdk/flutter/bin/flutter analyze lib/features/lesson/presentation/generic_learn_screen.dart test/features/lesson/presentation/generic_learn_screen_test.dart` => `No issues found! (ran in 1.1s)`
- historical reference
  - docs-only HEAD `1523559`에서 위 순서의 명령이 모두 성공했고, GitHub Actions run `24617840783` / artifact `kids-play-app-arm64-v8a-release` 확인까지 끝났다.

## Release handoff expectation

최종적으로 남겨야 하는 것
- 동작하는 앱 코드
- 최신 README
- 최신 handoff
- Actions success run URL
- 다운로드 가능한 APK artifact 이름
- 어떤 커밋에서 어떤 기능이 들어갔는지에 대한 짧은 요약
