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
- `ea8ff71` `feat(parent): add manual lesson unlock flow`
- `00ec1dc` `feat(content): add multi-lesson curriculum flow`

현재 이미 동작하는 것
- landscape 고정 + immersive full-screen
- hero / home / category hub garage flow
- 홈 / 카테고리 허브에서 한글 / 알파벳 / 숫자 3개 카테고리 배우기/퀴즈 라우팅 완료
- 한글 / 알파벳 / 숫자 다중 세트 학습
- 한글 / 알파벳 / 숫자 다중 세트 퀴즈
- 세트 선택 화면 추가
- compact landscape 대응 + 회귀 테스트
- toddler-safe tap cooldown / 즉시 피드백 오버레이
- 음성 cue / 다시 듣기 버튼
- shared_preferences 기반 progress / settings / sticker 저장
- 보호자 메뉴의 진행 요약, 음성/효과 토글, 세트별 진도 조절, 오답 다시 풀기, 오답 비우기, 세트별 수동 해금, 앱 종료/리셋
- GitHub Actions APK 빌드

아직 남은 확장 후보
- 오답 다시 풀기 결과를 별도 통계/보상과 연결
- 실제 표정 사진 업로드/크롭 파이프라인
- richer reward / 효과음 / 배경음악 polish

---

## 현재 큐 기준 상태

### queue 기준 상태
- A-E 범위(숫자 feature/라우팅, home/category 연결, design-system theme/button/panel 정리, hero/home/category 리디자인, 보호자 summary/settings/retry/unlock 흐름)는 live repo 기준으로 완료 상태이며, 일부 핵심 흐름은 선별 테스트로 다시 확인된 상태다
- F 문서 정리는 진행 중인 cleanup 범위다
- G 최종 통합 게이트는 아직 미완료다. docs-only HEAD `c5879e9`에서 full `flutter test` 재통과 기록은 남아 있지만, 이후 코드 커밋 `5696c1f` (`fix(ui): remove tap cooldown analyze blocker`)가 `lib/app/ui/tap_cooldown.dart`, `test/app/ui/tap_cooldown_test.dart`를 변경했다. 검증 기준 코드 스냅샷은 `5696c1f`이며, 이 코드 스냅샷에서는 targeted test/analyze만 다시 확인됐다. `5696c1f` 기준 코드 스냅샷에 대한 full `flutter test` / full `flutter analyze` / release APK build / APK artifact 확인은 아직 남아 있다

### 1. 문서/CI 정합성
- docs/script 변경도 APK workflow에 포함되도록 정리됨
- handoff / 구현 계획 문서는 현재 상태에 맞춰 정리 중

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
- 세트별 최근 오답 비우기 제공
- 세트별 수동 해금 제공
- 앱 종료/리셋 최소 운영 기능 제공

### 5. 최근 UI polish
- hero / home / category hub를 garage tone으로 재정렬
- compact landscape 360px 높이에서 overflow 없이 보이도록 조정

---

## 선별 검증 + recent full test 메모

최근 문서화된 선별 재확인 기록 (최종 통합 게이트 아님)
- numbers + routing
  - `/home/openc/sdk/flutter/bin/flutter test test/features/numbers/data/numbers_lesson_repository_test.dart test/features/numbers/presentation/numbers_learn_screen_test.dart test/features/numbers/presentation/numbers_quiz_screen_test.dart test/features/home/presentation/category_lesson_picker_flow_test.dart`
  - 결과: passed
- design system
  - `/home/openc/sdk/flutter/bin/flutter test test/app/ui/kid_theme_test.dart test/app/ui/kid_theme_typography_test.dart test/app/ui/toy_button_test.dart test/app/ui/toy_panel_test.dart test/app/ui/toy_button_api_surface_test.dart test/app/ui/toy_panel_api_surface_test.dart test/app/ui/toy_button_label_centering_test.dart`
  - 결과: passed
- hero / home / parent entry + parent summary controls
  - `/home/openc/sdk/flutter/bin/flutter test test/features/hero/presentation/hero_screen_test.dart test/features/home/presentation/home_redesign_test.dart test/features/avatar/presentation/avatar_setup_screen_test.dart`
  - 결과: passed
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
- 이후 코드 변경
  - `5696c1f` `fix(ui): remove tap cooldown analyze blocker`
  - 변경 파일: `lib/app/ui/tap_cooldown.dart`, `test/app/ui/tap_cooldown_test.dart`
- `5696c1f` 기준 코드 스냅샷 targeted verification
  - `/home/openc/sdk/flutter/bin/flutter test test/app/ui/tap_cooldown_test.dart`
  - 결과: `00:00 +9: All tests passed!`
  - `/home/openc/sdk/flutter/bin/flutter analyze lib/app/ui/tap_cooldown.dart test/app/ui/tap_cooldown_test.dart`
  - 결과: `No issues found!`

아직 남은 최종 통합 확인
- 아래 `로컬 실행 / 검증` 블록과 같은 변수 기준으로 `5696c1f` 기준 코드 스냅샷에 대한 full `flutter test`, full `flutter analyze`, release APK build, GitHub Actions APK artifact 확인이 아직 남아 있다

release build output path (when generated)
- `build/app/outputs/flutter-apk/app-release.apk`

artifact name (when workflow passes)
- `kids-play-app-arm64-v8a-release`

---

## 자산 구조

- `assets/public`
- `assets/local_private`
- `assets/generated`

규칙
- 앱은 `assets/generated`만 읽는다.
- 빌드/실행 전에 `./scripts/prepare_assets.sh`를 실행한다.
- 실제 얼굴/민감 자산은 `assets/local_private`에 둔다.

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
1. 오답 다시 풀기 결과를 별도 통계/보상과 연결
2. 실제 표정 사진 업로드/크롭
3. richer reward / 효과음 / 배경음악 polish

주의
- 이 앱은 데모가 아니라 실제 아이가 눌러보는 앱이다.
- generic한 Flutter 샘플 느낌이면 실패다.
- compact landscape 회귀를 깨지 않는 것이 중요하다.
- 변경 후에는 해당 slice에 맞는 최소 검증을 우선하고, 최종 handoff/merge 전에는 test / analyze / release apk까지 확인하는 것이 가장 안전하다.
