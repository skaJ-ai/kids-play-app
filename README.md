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

## 현재 구현 범위

이미 구현된 것
- hero → home → category hub 흐름
- kid-friendly 공통 디자인 시스템
- 한글 학습 카드 1세트
- 한글 4지선다 퀴즈 1세트
- compact landscape 대응 테스트
- 보호자용 아바타 표정 셸 화면
- GitHub Actions APK 빌드 파이프라인

아직 확장 중인 것
- 알파벳 playable flow
- 숫자 playable flow
- audio-first prompt 시스템
- toddler-safe tap cooldown / debounce
- 로컬 진도/오답/보상 저장
- 보호자 메뉴 기능 확장

## 이번 라운드의 구현 목표

이 라운드는 아래 순서로 끝까지 진행합니다.

1. 문서/CI 정합성 업데이트
- README / handoff / 구현 계획 문서 최신화
- docs/script 변경만으로도 Actions APK가 생성되도록 워크플로 정리

2. toddler interaction foundation
- 공통 탭 쿨타임/연타 방지
- 정답/오답 즉시 피드백 오버레이
- 로컬 progress/settings 저장소
- 음성 cue 서비스 골격

3. 카테고리 end-to-end 확장
- 알파벳 학습/게임 활성화
- 숫자 학습/게임 활성화
- 카테고리 허브에서 3개 카테고리 모두 실제 진입 가능하게 연결

4. 보호자 기능 강화
- 진도/보상 요약
- 소리 설정
- 최근 오답 복습 진입점
- 앱 종료/리셋 등 최소 운영 기능

5. 최종 검증
- flutter test
- flutter analyze
- flutter build apk --release --target-platform android-arm64
- GitHub Actions 성공 + APK artifact 확인

## 실행 방법

### 로컬 개발
```bash
cd /home/openc/kids-play-app
./scripts/prepare_assets.sh
/home/openc/sdk/flutter/bin/flutter pub get
/home/openc/sdk/flutter/bin/flutter run
```

### 테스트
```bash
/home/openc/sdk/flutter/bin/flutter test
/home/openc/sdk/flutter/bin/flutter analyze
```

### 릴리즈 APK 빌드
```bash
/home/openc/sdk/flutter/bin/flutter build apk --release --target-platform android-arm64
```

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
./scripts/prepare_assets.sh
```

## 참고 문서

- handoff: `handoff.md`
- 구현 계획: `docs/plans/2026-04-16_full-mvp-delivery-plan.md`
- 자산 파이프라인: `docs/asset-pipeline.md`
- 히어로 얼굴 자산 가이드: `docs/hero-face-asset-spec.md`
- 로컬 개발 환경: `docs/local-dev-setup.md`
