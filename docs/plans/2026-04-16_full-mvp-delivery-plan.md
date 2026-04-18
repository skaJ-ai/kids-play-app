# Full MVP Delivery Plan

> For Hermes: execute this plan incrementally with small, committable slices, keep GitHub Actions generating an APK artifact after each meaningful slice, use the smallest relevant verification for each run, and reserve the full `./scripts/prepare_assets.sh` + `/home/openc/sdk/flutter/bin/flutter pub get` + `flutter test` / `flutter analyze` / release build gate for final integration gate G.

## Status update

완료되었거나 live repo에서 재확인된 slice
- Slice 0 — docs + CI alignment
- Slice 1 — toddler interaction foundation
- Slice 2 — persistence + parent controls foundation
- Slice 3 — alphabet playable MVP
- Slice 4 — numbers playable MVP
- Slice 5 — audio-first prompt layer
- Slice 6 기능 범위 중 home/category/hub garage UI 정리, 보호자 진행 요약/진도 제어/오답 다시 풀기/오답 비우기/수동 해금, 다중 세트와 3개 카테고리 라우팅 확장까지 반영 및 재확인됨

현재 큐 기준 상태
- 우선순위 A-E 범위는 live repo와 targeted tests 기준으로 완료 상태
- F — docs cleanup 진행 중이며, 이 범위는 문서 정합성을 맞추는 작은 committable slice들로 나눠 진행하고 각 run에서는 바뀐 문서/명령에 맞는 최소 검증만 남김
- G — final integration gate. full `flutter test`는 이번 docs 정리 직전 HEAD `c5879e9`(README-only docs commit, 앱 코드는 마지막 코드 커밋 `a7767c8` 이후 동일)에서 재통과했고, full `flutter analyze` / release build / current-head APK artifact 확인은 아직 남아 있음
- HEAD `c5879e9`에서 `./scripts/prepare_assets.sh` 후 full `/home/openc/sdk/flutter/bin/flutter test`가 `00:32 +227: All tests passed!`로 끝난 상태

남은 확장 후보
- 오답 다시 풀기 결과를 별도 통계/보상과 연결
- 실제 표정 사진 업로드/크롭
- richer reward / 효과음 / 배경음악 polish

## Goal

현재 한글/알파벳/숫자 라우팅까지 완료된 `승원이의 빵빵 놀이터`를, 사용자가 다음날 순차적으로 확인할 수 있는 end-to-end toddler-ready APK로 확장한다.

## Delivery principles

- child 화면은 탭만 사용
- 텍스트보다 큰 시각 요소와 소리 중심
- 첫 탭은 즉시 반응, 연타는 방어
- 가능한 모든 변경은 GitHub Actions APK artifact까지 이어지게 유지
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
- 기본 summary/reward 흐름 정리 완료
- docs cleanup 진행 중
- final full `flutter test`는 이번 docs 정리 직전 HEAD `c5879e9`(README-only docs commit, 앱 코드는 마지막 코드 커밋 `a7767c8` 이후 동일)에서 재통과했고, analyze/release build + Actions/APK 확인은 마지막 게이트로 남아 있음

## Verification approach

작은 per-run slice 원칙
- 각 run은 committable한 작은 범위로 자른다.
- docs-only 또는 국소 기능 변경은 해당 변경과 직접 연결된 최소 검증만 수행한다.
- 예: docs-only slice는 exact diff 확인과 관련 문서 wording alignment 확인 정도만 남기고, 국소 feature/UI slice는 관련 targeted test만 실행한다.
- full gate를 실제로 다시 돌린 경우에만 full `./scripts/prepare_assets.sh` → `/home/openc/sdk/flutter/bin/flutter pub get` → `flutter test` / `flutter analyze` / release build 재검증을 했다고 기록한다.

### Gate G — final integration checklist

이 게이트는 F docs cleanup까지 끝난 뒤 current HEAD에서 README / `handoff.md` / `docs/local-dev-setup.md` / `.github/workflows/build-apk.yml` 와 같은 순서(`./scripts/prepare_assets.sh` → `/home/openc/sdk/flutter/bin/flutter pub get` → `flutter test` → `flutter analyze` → release APK build)로 한 번에 수행하는 최종 통합 확인이다.

```bash
cd /home/openc/kids-play-app
./scripts/prepare_assets.sh
/home/openc/sdk/flutter/bin/flutter pub get
/home/openc/sdk/flutter/bin/flutter test
/home/openc/sdk/flutter/bin/flutter analyze
/home/openc/sdk/flutter/bin/flutter build apk --release --target-platform android-arm64
```

- 위 순서의 명령과 current-head GitHub Actions APK artifact 확인까지 끝나야 G를 완료로 기록한다.

## Release handoff expectation

최종적으로 남겨야 하는 것
- 동작하는 앱 코드
- 최신 README
- 최신 handoff
- Actions success run URL
- 다운로드 가능한 APK artifact 이름
- 어떤 커밋에서 어떤 기능이 들어갔는지에 대한 짧은 요약
