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

- 우선순위 큐 A-F 범위는 live repo 기준으로 완료 상태이며, 숫자/라우팅·design-system UI·hero/home/parent 핵심 흐름은 선별 테스트로 다시 확인했고 README·handoff·plan 정합성 cleanup도 현재 상태 기준으로 반영 완료했습니다.
- Gate G 최종 통합 검증은 docs-only HEAD `1523559`에서 완료됐고, 앱 코드는 마지막 코드 커밋 `5696c1f` (`fix(ui): remove tap cooldown analyze blocker`) 이후 변경되지 않았습니다.
- Gate G 실행 결과:
  - `./scripts/prepare_assets.sh` + `/home/openc/sdk/flutter/bin/flutter pub get` 성공
  - full `/home/openc/sdk/flutter/bin/flutter test` => `00:33 +236: All tests passed!`
  - full `/home/openc/sdk/flutter/bin/flutter analyze` => `No issues found!`
  - `/home/openc/sdk/flutter/bin/flutter build apk --release --target-platform android-arm64` => `build/app/outputs/flutter-apk/app-release.apk` (16.8MB)
  - GitHub Actions run `24617840783` 성공, artifact `kids-play-app-arm64-v8a-release` 확인

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
- A-F 범위는 live repo 기준으로 완료 상태이며, 코드 관련 핵심 흐름은 선별 테스트로 재확인했고 문서 정합성 cleanup도 반영 완료
- 이전 기록으로 docs-only HEAD `c5879e9`에서는 `./scripts/prepare_assets.sh` 후 full `/home/openc/sdk/flutter/bin/flutter test`가 `00:32 +227: All tests passed!`로 통과했습니다.
- 이후 마지막 코드 변경은 `5696c1f` (`fix(ui): remove tap cooldown analyze blocker`)였고, 이 커밋은 `lib/app/ui/tap_cooldown.dart`, `test/app/ui/tap_cooldown_test.dart`를 변경했습니다.
- `5696c1f` 기준 코드 스냅샷에 대해서는 먼저 `/home/openc/sdk/flutter/bin/flutter test test/app/ui/tap_cooldown_test.dart` => `00:00 +9: All tests passed!`, `/home/openc/sdk/flutter/bin/flutter analyze lib/app/ui/tap_cooldown.dart test/app/ui/tap_cooldown_test.dart` => `No issues found!`를 선별 재확인했습니다.
- 그 뒤 docs-only HEAD `1523559`에서 Gate G 최종 통합 검증을 다시 실행했고, 앱 코드는 `5696c1f` 이후 변경되지 않았습니다.
- Gate G 결과:
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

- 아래 명령 블록은 `docs/local-dev-setup.md` 및 `.github/workflows/build-apk.yml` 과 같은 순서의 재현용 체크리스트입니다. Gate G 완료 기준 증거는 docs-only HEAD `1523559`의 full test/analyze/release build와 해당 HEAD의 GitHub Actions run `24617840783` / artifact `kids-play-app-arm64-v8a-release`입니다.

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
