# handoff.md

## 프로젝트 요약

`승원이의 빵빵 놀이터`는 27개월 유아가 Galaxy S24에서 가로 화면으로 사용하는 개인용 오프라인 학습 APK입니다.

핵심 원칙
- child-facing 화면은 탭만 사용
- 텍스트 최소화, 소리/즉시 피드백 중심
- 한글 / 알파벳 / 숫자 3개 카테고리
- 보호자 메뉴는 숨김 진입
- GitHub Actions에서 매 라운드 APK artifact 유지

---

## 현재 기준 상태

레포
- local: `/home/openc/kids-play-app`
- remote: `git@github.com:skaJ-ai/kids-play-app.git`

현재 기준 최신 커밋
- `e39d3dd` `ci: prepare generated assets in apk workflow`

현재 이미 동작하는 것
- landscape 고정 + immersive full-screen
- hero / home / category hub
- 한글 학습 1세트
- 한글 퀴즈 1세트
- compact landscape 대응
- 보호자용 아바타 표정 셸 화면
- GitHub Actions APK 빌드

현재 부족한 것
- 알파벳 playable flow 없음
- 숫자 playable flow 없음
- audio-first UX 부족
- tap debounce 없음
- 로컬 progress / settings 저장 없음
- 보호자 메뉴 기능이 표정 셸 수준에 머물러 있음

---

## 이번 구현 라운드의 목표

이번 라운드는 아래를 끝까지 만드는 것을 목표로 진행합니다.

### 1. 문서/CI 정합성
- README 최신화
- handoff 최신화
- 구체 구현 계획 문서 추가
- docs/script 변경만으로도 Actions APK가 생성되도록 workflow 정리

### 2. toddler interaction foundation
- 공통 탭 쿨타임/연타 방지
- quiz 정답/오답 피드백 dwell + 자동 진행
- 보호자 설정/진도용 로컬 저장소
- 음성 cue 서비스 골격

### 3. 카테고리 확장
- 알파벳 학습 / 게임
- 숫자 학습 / 게임
- 홈의 3개 카테고리가 모두 실제 플레이 가능하도록 연결

### 4. 보호자 기능 확장
- 스티커/점수/진도 요약
- 소리 설정
- 오답 복습 진입점
- 앱 종료/리셋 최소 기능

### 5. 검증
- `flutter test`
- `flutter analyze`
- `flutter build apk --release --target-platform android-arm64`
- GitHub Actions success + artifact 확인

---

## 구현 기준 / BM 반영 사항

BM으로 반영할 기준
- toddler-safe tap-only UX
- 큰 터치 영역
- 눌렀을 때 즉시 반응하는 시각 피드백
- 마구 눌러도 멈추지 않는 debounce 방어
- 오디오 퍼스트 구조
- 세트 완료 시 짧고 강한 보상 피드백

에셋/소스 방향
- 이미지: Flaticon / Freepik / Pixabay 계열 무료 소스 우선
- 음성: Clova Dubbing / Edge TTS 계열 참고
- 효과음: Freesound 계열 참고
- 폰트: Noonnu 계열 둥근 폰트 참고

현재 스택 선택
- 구현은 Flutter 유지
- 참고 앱/오픈소스는 UX/로직/BM 용도로 해석하고 Flutter에 맞게 재구현

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

Flutter 경로
- `/home/openc/sdk/flutter/bin/flutter`

기본 명령
```bash
cd /home/openc/kids-play-app
./scripts/prepare_assets.sh
/home/openc/sdk/flutter/bin/flutter pub get
/home/openc/sdk/flutter/bin/flutter test
/home/openc/sdk/flutter/bin/flutter analyze
/home/openc/sdk/flutter/bin/flutter build apk --release --target-platform android-arm64
```

---

## GitHub Actions

workflow
- `.github/workflows/build-apk.yml`

artifact
- `kids-play-app-arm64-v8a-release`

원칙
- 구현 라운드마다 가능한 한 Actions에서 APK artifact가 계속 생성되어야 한다.
- 사용자는 다음날 커밋/푸시 순서대로 작업물을 확인한다.

---

## 다음 작업자가 놓치면 안 되는 포인트

- 이 앱은 데모가 아니라 실제 아이가 눌러보는 앱이다.
- generic한 Flutter 샘플 느낌이면 실패다.
- 하지만 지금 단계에서는 디자인만이 아니라 실제 playable flow 완성이 중요하다.
- 즉, 이번 라운드의 핵심은
  1) toddler interaction foundation
  2) 3개 카테고리 playable 연결
  3) parent 기능 최소 완성
  4) APK deliverability 유지
이다.
