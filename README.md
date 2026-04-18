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
- GitHub Actions에서 매 변경마다 설치 가능한 APK artifact를 계속 생성

## 현재 상태

- 우선순위 큐 A-E 범위는 live repo 기준으로 완료 상태이며, 숫자/라우팅·design-system UI·hero/home/parent 핵심 흐름은 선별 테스트로 다시 확인했습니다.
- 현재 진행 중인 작업은 README·handoff·plan 정합성을 맞추는 docs cleanup입니다.
- docs-only HEAD `c5879e9`에서는 `./scripts/prepare_assets.sh` 이후 full `/home/openc/sdk/flutter/bin/flutter test`를 다시 돌려 `00:32 +227: All tests passed!`로 통과했습니다.
- 다만 검증 기준 코드 스냅샷은 그 뒤 코드 커밋 `5696c1f` (`fix(ui): remove tap cooldown analyze blocker`)로 이동했습니다. 이 커밋은 `lib/app/ui/tap_cooldown.dart`, `test/app/ui/tap_cooldown_test.dart`를 변경했습니다.
- `5696c1f` 기준 코드 스냅샷에 대해서는 `/home/openc/sdk/flutter/bin/flutter test test/app/ui/tap_cooldown_test.dart`를 다시 실행해 `00:00 +9: All tests passed!`, `/home/openc/sdk/flutter/bin/flutter analyze lib/app/ui/tap_cooldown.dart test/app/ui/tap_cooldown_test.dart`를 실행해 `No issues found!`를 확인했습니다.
- 따라서 최종 통합 게이트에서 아직 남아 있는 것은 `5696c1f` 기준 코드 스냅샷에 대한 full `/home/openc/sdk/flutter/bin/flutter test`, full `/home/openc/sdk/flutter/bin/flutter analyze`, release APK build, GitHub Actions artifact `kids-play-app-arm64-v8a-release` 확인입니다.

## 현재 구현 범위

이미 구현된 것
- hero → home → category hub의 garage flow
- 홈/카테고리 허브에서 한글 / 알파벳 / 숫자 3개 카테고리 배우기 / 퀴즈 라우팅 완료
- 한글 / 알파벳 / 숫자 다중 세트 학습 카드
- 한글 / 알파벳 / 숫자 다중 세트 4지선다 퀴즈
- 카테고리 진입 뒤 세트 선택 화면
- compact landscape 대응 UI와 회귀 테스트
- toddler-safe tap cooldown / 연타 방지
- 정답/오답 즉시 피드백 오버레이
- 음성 cue + 문제 다시 듣기 버튼
- shared_preferences 기반 진도 / 오답 / 스티커 / 설정 저장
- 보호자 메뉴의 진행 요약, 음성/효과 토글, 세트별 진도 조절, 오답 다시 풀기, 오답 비우기, 세트별 수동 해금, 리셋, 종료
- GitHub Actions APK 빌드 파이프라인

다음 확장 후보
- 오답 다시 풀기 결과를 별도 통계/보상과 연결
- 실제 표정 사진 업로드/크롭 파이프라인
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
- A-E 범위는 live repo와 핵심 선별 테스트 기준으로 재확인 완료
- full `/home/openc/sdk/flutter/bin/flutter test` 재실행 기록은 docs-only HEAD `c5879e9`에서 `./scripts/prepare_assets.sh` 후 `00:32 +227: All tests passed!`였습니다.
- 이후 검증 기준 코드 스냅샷은 `5696c1f`로 이동했습니다. `5696c1f`는 `lib/app/ui/tap_cooldown.dart`, `test/app/ui/tap_cooldown_test.dart`를 변경했습니다. 따라서 위 full test 기록은 `5696c1f` 기준 코드 스냅샷 전체를 대체하는 증거는 아닙니다.
- 대신 `5696c1f` 기준 코드 스냅샷에 대해서는 `/home/openc/sdk/flutter/bin/flutter test test/app/ui/tap_cooldown_test.dart` => `00:00 +9: All tests passed!`, `/home/openc/sdk/flutter/bin/flutter analyze lib/app/ui/tap_cooldown.dart test/app/ui/tap_cooldown_test.dart` => `No issues found!`까지 선별 재검증했습니다.
- 아래 순서는 `docs/local-dev-setup.md` 및 `.github/workflows/build-apk.yml` 기준의 현재 최종 통합 게이트이며, 아직 pending인 것은 `5696c1f` 기준 코드 스냅샷에 대한 full `flutter test` / full `flutter analyze` / release build / GitHub Actions artifact `kids-play-app-arm64-v8a-release` 확인입니다.

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

- `c5879e9`의 full `flutter test` 통과 기록과 `5696c1f` 기준 코드 스냅샷의 tap cooldown targeted 재검증은 각각 따로 남아 있지만, Gate G 완료로 기록하려면 `5696c1f` 기준 코드 스냅샷에 대한 full `flutter test` / full `flutter analyze` / release build / GitHub Actions artifact `kids-play-app-arm64-v8a-release` 확인이 모두 추가로 필요합니다.

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

자산 준비
```bash
REPO_ROOT=/home/openc/kids-play-app
# 다른 머신에서는 REPO_ROOT 를 자신의 checkout root로 교체

cd "$REPO_ROOT"
./scripts/prepare_assets.sh
```

이 머신에서는 위처럼 repo root(`/home/openc/kids-play-app`)를 기준으로 실행한다. 다른 머신도 같은 순서로 자신의 checkout root에서 실행하면 된다.

## 참고 문서

- handoff: `handoff.md`
- 구현 계획: `docs/plans/2026-04-16_full-mvp-delivery-plan.md`
- 자산 파이프라인: `docs/asset-pipeline.md`
- 히어로 얼굴 자산 가이드: `docs/hero-face-asset-spec.md`
- 로컬 개발 환경: `docs/local-dev-setup.md`
