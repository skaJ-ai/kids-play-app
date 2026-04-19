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
- live repo follow-up으로 avatar runtime photo flow(`2c78d5f`~`faff2ce`), quiz prompt replay audio service(`19a6f1d`), numbers learn prompt audio service(`610a6aa`)까지 main에 반영됨

현재 큐 기준 상태
- 우선순위 A-E 앱 기능은 latest live app-code snapshot `610a6aa`에 반영돼 있다
- F — docs cleanup은 이번 refresh에서 README / handoff / plan provenance wording을 latest live app-code snapshot `610a6aa`와 current targeted verification evidence에 맞춰 다시 정리했다
- latest live app-code snapshot은 `610a6aa`(`fix(numbers): route learn prompts through audio service`)이고, historical full Gate G provenance는 docs-only HEAD `9d4c035`가 검증한 앱 code snapshot `d81a2ec`로 별도 유지된다
- 이번 docs-only refresh에서는 latest live app-code snapshot `610a6aa`에 대해 numbers / home flow / design-system / parent-summary 관련 targeted recheck만 다시 남겼다
- G — fresh full integration rerun on latest live app-code snapshot `610a6aa` (`./scripts/prepare_assets.sh` + full `flutter test` / `flutter analyze` / release build) 은 아직 pending이다. 따라서 current app-code snapshot 기준으로 A-G 전체 완료를 새로 주장하지 않는다
- provenance 메모: historical progression은 `c5879e9`(README-only full test 재확인) → docs-only HEAD `1523559` / 코드 스냅샷 `5696c1f`(Gate G + historical GitHub Actions provenance) → docs-only checkout `f1e23c3` 로컬 full rerun(`0c15caf` 코드 일치) → docs-only HEAD `9d4c035` 로컬 full rerun(`d81a2ec` 코드 일치) 순서로 누적됐다. 세부 명령 결과는 아래 Gate G checklist에 정리한다
- parent summary 관련 `test/features/avatar/presentation/avatar_setup_screen_test.dart`에는 가장 헷갈린 세트 요약 렌더링과 `이 세트 다시 보기` quick retry가 해당 retry flow를 여는 케이스가 포함된다

남은 확장 후보
- richer reward / 효과음 / 배경음악 polish

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
- docs cleanup 완료
- docs-only HEAD `1523559` / 코드 스냅샷 `5696c1f`의 historical Gate G provenance, docs-only checkout `f1e23c3` 로컬 full rerun(`0c15caf` 코드 일치), docs-only HEAD `9d4c035` 로컬 full rerun(`d81a2ec` 코드 일치)까지 historical reference로 확보됐다

## Verification approach

작은 per-run slice 원칙
- 각 run은 committable한 작은 범위로 자른다.
- docs-only 또는 국소 기능 변경은 해당 변경과 직접 연결된 최소 검증만 수행한다.
- 예: docs-only slice는 exact diff 확인과 관련 문서 wording alignment 확인 정도만 남기고, 국소 feature/UI slice는 관련 targeted test만 실행한다.
- full gate를 실제로 다시 돌린 경우에만 full `./scripts/prepare_assets.sh` → `/home/openc/sdk/flutter/bin/flutter pub get` → `flutter test` / `flutter analyze` / release build 재검증을 했다고 기록한다.

### Gate G — final integration checklist

- 이 게이트의 historical provenance는 docs-only HEAD `1523559` / 코드 스냅샷 `5696c1f`, docs-only checkout `f1e23c3` 로컬 full rerun, 그리고 docs-only HEAD `9d4c035` 로컬 full rerun까지 확보됐다. `9d4c035`의 HEAD diff는 README / handoff / plan docs뿐이어서 그 Gate G rerun이 검증한 앱 코드는 latest code-changing commit `d81a2ec`와 동일하다. latest live app-code snapshot `610a6aa`에서는 아래 targeted recheck만 새로 확보됐고, full Gate G sequence는 아직 rerun pending이다. 아래 명령 순서는 current app-code snapshot에서 Gate G를 다시 돌릴 때 쓰는 reference checklist다.

- current app-code snapshot targeted recheck (`610a6aa`, numbers / home flow / design-system / parent-summary spot checks, full Gate G 재실행 아님)
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

- 최신 로컬 full rerun 기록 (docs-only HEAD `9d4c035`, 검증된 앱 코드는 `d81a2ec`와 동일)
  - `./scripts/prepare_assets.sh` 성공
  - `/home/openc/sdk/flutter/bin/flutter pub get` 성공
  - full `/home/openc/sdk/flutter/bin/flutter test` => `00:34 +253: All tests passed!`
  - full `/home/openc/sdk/flutter/bin/flutter analyze` => `No issues found! (ran in 2.1s)`
  - `/home/openc/sdk/flutter/bin/flutter build apk --release --target-platform android-arm64` => `build/app/outputs/flutter-apk/app-release.apk` (16.8MB / `16774218` bytes)
- 이전 로컬 full rerun 기록 (docs-only checkout `f1e23c3`, 검증된 앱 코드는 `0c15caf`와 동일)
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
