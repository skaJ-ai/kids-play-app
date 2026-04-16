# Local development setup for 승원이의 빵빵 놀이터

이 프로젝트는 Flutter 기반 Android APK 앱이다.
현재 우선 타깃은 Galaxy S24이며, 다른 안드로이드 폰/태블릿도 지원 범위에 포함한다.

## 현재 이 머신에서 확인된 상태

2026-04-16 기준:
- Flutter 미설치
- Java 미설치
- Android SDK 미확인

확인 명령:

```bash
flutter --version
java -version
```

## 권장 버전

- Flutter stable 최신 버전
- Java 17
- Android SDK + platform tools + cmdline tools
- Android Studio 또는 최소 SDK command-line setup

## Ubuntu 24.04 기준 권장 준비 순서

### 1. Java 17 설치

예시:

```bash
sudo apt update
sudo apt install -y openjdk-17-jdk unzip xz-utils zip libglu1-mesa curl git
java -version
```

### 2. Flutter SDK 설치

옵션 A: 직접 다운로드 후 홈 디렉토리에 배치

```bash
cd ~
mkdir -p sdk
cd sdk
curl -LO https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.29.3-stable.tar.xz
rm -rf flutter
tar -xf flutter_linux_3.29.3-stable.tar.xz
```

PATH 추가:

```bash
echo 'export PATH="$HOME/sdk/flutter/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
flutter --version
```

### 3. Android Studio 또는 SDK 준비

가장 쉬운 방법:
- Android Studio 설치
- SDK Manager에서 Android SDK, Platform Tools, Build Tools, cmdline-tools 설치

필수 점검:

```bash
flutter doctor
```

### 4. Android licenses 승인

```bash
flutter doctor --android-licenses
```

### 5. 프로젝트 실행 준비

Flutter 설치 후 repo 루트에서:

```bash
./scripts/prepare_assets.sh
flutter pub get
flutter run
```

## 이 repo에서 개발할 때의 기본 규칙

1. 실제 얼굴/민감 자산은 `assets/local_private/` 에 둔다.
2. 앱 번들링 전에는 `./scripts/prepare_assets.sh` 를 실행한다.
3. 코드에서는 `assets/generated/` 기준 경로만 참조한다.
4. git에는 placeholder/public 자산만 커밋한다.

## 향후 추가 예정

Flutter 스캐폴딩이 생성되면 아래도 이 문서에 추가한다.
- Android device 연결/adb 확인
- debug APK 실행
- release keystore 생성
- release APK 빌드
