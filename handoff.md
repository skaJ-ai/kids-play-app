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

최근 기능 커밋
- `4cc5bb2` `feat(parent): add lesson progress controls`
- `eb7aaf5` `feat(ui): polish garage home flow`

현재 이미 동작하는 것
- landscape 고정 + immersive full-screen
- hero / home / category hub garage flow
- 한글 / 알파벳 / 숫자 학습 1세트씩
- 한글 / 알파벳 / 숫자 퀴즈 1세트씩
- compact landscape 대응 + 회귀 테스트
- toddler-safe tap cooldown / 즉시 피드백 오버레이
- 음성 cue / 다시 듣기 버튼
- shared_preferences 기반 progress / settings / sticker 저장
- 보호자 메뉴의 진행 요약, 음성/효과 토글, 세트별 진도 조절, 오답 다시 풀기, 오답 비우기, 앱 종료/리셋
- GitHub Actions APK 빌드

아직 남은 확장 후보
- 해금 수동 제어 / 더 세밀한 보호자 운영 기능
- 실제 표정 사진 업로드/크롭 파이프라인
- richer reward / 효과음 / 배경음악 polish

---

## 이번 라운드까지 완료된 범위

### 1. 문서/CI 정합성
- docs/script 변경도 APK workflow에 포함되도록 정리됨
- README / handoff / 구현 계획 문서는 계속 최신화 중

### 2. toddler interaction foundation
- 공통 탭 쿨타임/연타 방지 적용
- quiz 정답/오답 피드백 dwell + 자동 진행 적용
- 보호자 설정/진도용 로컬 저장소 적용
- 음성 cue 서비스 적용

### 3. 카테고리 확장
- 알파벳 학습 / 게임 구현 완료
- 숫자 학습 / 게임 구현 완료
- 홈의 3개 카테고리가 모두 실제 플레이 가능하도록 연결 완료

### 4. 보호자 기능 확장
- 스티커/점수/진도 요약 제공
- 소리 설정 제공
- 세트별 진도 앞뒤 조절 제공
- 세트별 오답 다시 풀기 제공
- 세트별 최근 오답 비우기 제공
- 앱 종료/리셋 최소 운영 기능 제공

### 5. 최근 UI polish
- hero / home / category hub를 garage tone으로 재정렬
- compact landscape 360px 높이에서 overflow 없이 보이도록 조정

---

## 검증 결과

최근 코드 기준 검증 완료
- `/home/openc/sdk/flutter/bin/flutter test`
- `/home/openc/sdk/flutter/bin/flutter analyze`
- `/home/openc/sdk/flutter/bin/flutter build apk --release --target-platform android-arm64`

로컬 APK
- `build/app/outputs/flutter-apk/app-release.apk`

GitHub Actions artifact
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

## 다음 작업자가 바로 이어갈 포인트

우선순위 추천
1. 해금 수동 제어 / 보호자 고급 운영
2. 실제 표정 사진 업로드/크롭
3. richer reward / 효과음 / 배경음악 polish
4. 오답 다시 풀기 결과를 별도 통계/보상과 연결

주의
- 이 앱은 데모가 아니라 실제 아이가 눌러보는 앱이다.
- generic한 Flutter 샘플 느낌이면 실패다.
- compact landscape 회귀를 깨지 않는 것이 중요하다.
- 변경 후에는 항상 test / analyze / release apk까지 확인하는 것이 안전하다.
