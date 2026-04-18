# Local development setup for 승원이의 빵빵 놀이터

이 프로젝트는 Flutter 기반 Android 앱이다. 이 문서는 `/home/openc/kids-play-app` 기준의 현재 로컬 개발 루프와, 새 머신에서 맞춰야 하는 최소 setup 기준을 함께 정리한다.

## 이 머신에서 확인된 툴체인

2026-04-19 기준:
- Flutter 3.41.6 (`/home/openc/sdk/flutter`)
- Java 17
- Android SDK 가 `flutter doctor` 에서 인식되는 로컬 개발 환경
- GitHub Actions `.github/workflows/build-apk.yml` 도 Flutter 3.41.6 을 고정 사용

확인 명령:

```bash
/home/openc/sdk/flutter/bin/flutter --version
java -version
/home/openc/sdk/flutter/bin/flutter doctor -v
```

## 새 머신에서 맞춰야 하는 최소 기준

- Flutter stable 3.41.6
- Java 17
- Android SDK + platform tools + cmdline tools
- `flutter doctor -v` 에서 Android toolchain 이 정상이어야 함
- Android 라이선스 승인이 필요하면 `flutter doctor --android-licenses` 실행

가장 짧은 준비 순서:
1. Java 17 설치
2. Flutter stable 3.41.6 설치 후 `flutter` 를 PATH 에 추가
3. Android Studio 또는 command-line tools 로 Android SDK 설치
4. `flutter doctor -v` 와 `flutter doctor --android-licenses` 로 toolchain 상태 확인

이 문서의 repo-specific 예시는 현재 검증된 로컬 경로를 같이 적지만, 다른 머신에서는 같은 명령을 자신의 Flutter 경로 또는 PATH 기준 `flutter` 로 바꿔 실행하면 된다.

## 이 repo에서 기억할 점

- `scripts/prepare_assets.sh` 는 `assets/public/` 와 선택적 `assets/local_private/` 를 합쳐 `assets/generated/` 를 다시 만든다.
- 앱 코드에서는 `assets/generated/` 기준 경로만 참조한다.
- 민감 자산은 `assets/local_private/` 에 두고, public/placeholder 자산만 git 에 유지한다.
- 자산이 바뀌었거나 `assets/` / `scripts/prepare_assets.sh` 관련 변경을 pull 했다면, 이 repo의 표준 순서와 CI 순서에 맞춰 `test`, `analyze`, `build` 전에 먼저 `./scripts/prepare_assets.sh` 를 실행한다. 필요하면 같은 흐름에서 `pub get` 전에 함께 실행해도 된다.

## 현재 머신에서 바로 쓰는 명령

```bash
REPO_ROOT=/home/openc/kids-play-app
FLUTTER_BIN=/home/openc/sdk/flutter/bin/flutter
```

다른 머신이라면:
- `REPO_ROOT` 는 자신의 checkout 경로로 바꾸고
- `FLUTTER_BIN` 은 자신의 Flutter binary 경로로 바꾸거나 `flutter` 로 대체한다.

## 로컬 개발 루프

프로젝트 루트에서 보통 이렇게 진행한다:

```bash
cd "$REPO_ROOT"

# 자산 관련 변경이 있거나 CI 순서에 맞춰 재확인할 때
./scripts/prepare_assets.sh

"$FLUTTER_BIN" pub get
"$FLUTTER_BIN" test <targeted-test-or-directory>
"$FLUTTER_BIN" analyze
"$FLUTTER_BIN" run
```

매번 전체 테스트를 다 돌릴 필요는 없다. 평소 개발 중에는 관련 테스트만 골라서 실행하고, shared UI/서비스 레이어를 건드렸을 때만 `analyze` 범위를 넓히는 식으로 운영해도 된다.

예시:

```bash
cd "$REPO_ROOT"
./scripts/prepare_assets.sh
"$FLUTTER_BIN" test test/features/numbers/presentation/numbers_quiz_screen_test.dart
```

## 최종 통합 게이트 기준

머지 전 최종 확인 기대치는 현재 CI 와 동일하다:

```bash
cd "$REPO_ROOT"
./scripts/prepare_assets.sh
"$FLUTTER_BIN" pub get
"$FLUTTER_BIN" test
"$FLUTTER_BIN" analyze
"$FLUTTER_BIN" build apk --release --target-platform android-arm64
```

GitHub Actions 의 `.github/workflows/build-apk.yml` 도 Java 17 을 설정하고 Flutter 3.41.6 을 사용한 뒤, `./scripts/prepare_assets.sh` → `flutter pub get` → `flutter test` → `flutter analyze` → `flutter build apk --release --target-platform android-arm64` 순서로 실행한다.

이 문서는 현재 기대 절차를 맞춘 것이며, docs-only 변경만으로 위 전체 게이트가 다시 실행되었다고 주장하지 않는다.
