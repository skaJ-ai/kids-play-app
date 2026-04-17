# Child UX / Audio-First 전면 개편 실행 계획

> For Hermes: planning only. Do not implement from this file without an explicit execution go-ahead.

**선택된 우선순위:** child UX/audio-first 전면 재설계

**Goal:** `승원이의 빵빵 놀이터`를 “텍스트 기반 데모형 학습 앱”에서 “27개월 아이가 혼자 눌러도 몰입 가능한 오디오 퍼스트 놀이 경험”으로 재정의한다.

**Architecture:** 1차 라운드는 child-facing experience를 제품의 중심으로 재설계한다. 다만 현재 카테고리별 복붙 구조를 그대로 둔 채 UX만 바꾸면 동일 작업이 3배 반복되므로, UX 우선 전략 안에서도 공통 play shell / 공통 quiz rule / 공통 audio service는 함께 추출한다.

**Tech Stack:** Flutter, shared_preferences, flutter_tts(임시 fallback), JSON manifest, GitHub Actions APK build

---

## 1. 목표 재정의

이번 라운드의 성공 기준은 다음과 같다.

1. 아이가 글을 읽지 않아도 소리와 큰 선택지만으로 플레이 흐름을 이해할 수 있다.
2. 정답/오답/재시도/완료 순간마다 즉각적인 청각·시각 반응이 있다.
3. 화면마다 UX가 달라 보이지 않고 같은 놀이 시스템처럼 느껴진다.
4. 한글/알파벳/숫자 중 최소 1개 카테고리에서 완성된 경험을 먼저 만든 뒤, 다른 카테고리로 확장 가능한 구조여야 한다.
5. parent 기능은 child 플레이를 방해하지 않는 별도 운영 레이어로 후퇴시킨다.

---

## 2. 현재 기준 핵심 문제

### 2-1. child UX가 아직 텍스트/화면 설명 의존이 남아 있음
- main은 여전히 제목/설명/상태 텍스트 비중이 큼
- branch의 audio-first 시도는 거의 `hangul_quiz_screen` 1개 화면에 국한됨

### 2-2. 보상 루프가 약함
- `stickerCount`는 저장되지만 실제 수집 장면/쇼케이스/애니메이션 루프가 약함
- 아이 입장에서는 “맞췄다”의 감각적 보상이 충분하지 않음

### 2-3. category별 경험이 각각 따로 구현되어 있음
- same UX rule을 3군데에서 반복 구현해야 하는 구조
- child UX를 다듬을수록 유지비가 폭증함

### 2-4. 오디오는 아직 제품 레벨 시스템이 아님
- 현재는 TTS wrapper 수준
- prompt / success / error / replay / idle attract / completion sound를 체계적으로 다루지 못함

---

## 3. 1차 개편 원칙

### 원칙 A. 글 대신 소리와 레이아웃으로 안내한다
- child-facing 화면의 설명 문구는 최소화
- 핵심 지시는 음성으로 제공
- 화면은 “무엇을 눌러야 하는지”가 즉시 보이게 설계

### 원칙 B. 눌렀을 때 반드시 반응한다
- 모든 정답/오답/탭 성공/잠금/완료 상태에 즉각 반응
- 최소 반응 세트: 사운드 + 색 변화 + 스케일/흔들림 모션

### 원칙 C. 한 화면 완성보다 한 놀이 루프 완성이 우선이다
- hero → category 선택 → lesson 선택 → 문제 풀이 → 보상 → 다음 플레이
- 이 전체 루프가 “재미있고 명확한지”가 우선

### 원칙 D. 한 카테고리에서 완성 후 수평 확장한다
- 우선 한글 또는 숫자 1개 카테고리를 기준 레퍼런스로 완성
- 이후 alphabet/numbers/hangul 전체 적용

---

## 4. 권장 실행 순서

## Phase 0. 기준선 안정화

**Objective:** 개편 전에 baseline을 고정하고 회귀 기준을 세운다.

**Files:**
- Modify: `assets/public/manifest/numbers_lessons.json`
- Modify: `assets/generated/manifest/numbers_lessons.json`
- Modify: `test/features/numbers/data/numbers_lesson_repository_test.dart` (필요 시 계약 재정의)

**작업:**
1. 현재 `flutter test` 실패 원인인 numbers manifest/test 계약 불일치를 정리
2. baseline을 green 상태로 고정
3. child UX 개편 전 스냅샷용 체크리스트 작성

**검증:**
- `/home/openc/sdk/flutter/bin/flutter test`
- `/home/openc/sdk/flutter/bin/flutter analyze`

---

## Phase 1. Child Play Shell 정의

**Objective:** 모든 child-facing 화면이 공유할 공통 UX 골격을 만든다.

**Files:**
- Likely create: `lib/app/play/play_session.dart`
- Likely create: `lib/app/play/play_feedback.dart`
- Likely create: `lib/app/play/play_audio_policy.dart`
- Likely create: `lib/app/ui/play_shell.dart`
- Likely create: `lib/app/ui/play_choice_card.dart`
- Likely create: `lib/app/ui/play_prompt_panel.dart`
- Likely create: `lib/app/ui/play_reward_banner.dart`
- Modify: `lib/app/app.dart`
- Modify: `lib/app/ui/*`

**설계 포인트:**
1. 공통 상단 정보는 child에게 꼭 필요한 것만 남김
2. 문제 prompt는 텍스트보다 스피커/카드/하이라이트 중심
3. choice card는 한 손가락 큰 탭 영역 기준으로 통일
4. 정답/오답 반응 시간, 다음 문제 전환 시간, 재생 규칙을 공통 정책으로 정의
5. compact landscape 기준 spacing 규칙을 shell 수준에서 통일

**검증:**
- compact landscape golden/geometry 성격의 widget 테스트 추가
- tap, feedback, auto-advance, replay 동작 테스트

---

## Phase 2. Audio-First 시스템화

**Objective:** 오디오를 “부가 기능”이 아니라 화면 흐름의 핵심 엔진으로 만든다.

**Files:**
- Likely create: `lib/app/audio/audio_service.dart`
- Likely create: `lib/app/audio/audio_cue.dart`
- Likely create: `lib/app/audio/audio_assets.dart`
- Modify or replace: `lib/app/services/speech_cue_service.dart`
- Modify: `pubspec.yaml`

**설계 포인트:**
1. prompt audio / feedback sfx / reward audio / bgm를 타입별로 분리
2. 우선순위 정책 정의
   - 새 문제 시작 시 prompt 우선
   - 오답 시 error cue 후 prompt replay
   - 정답 시 success cue 후 auto-advance
3. 초기에는 `recorded audio 있으면 우선`, 없으면 `TTS fallback` 구조 허용
4. 설정에서 voice/effect/music 토글은 유지하되 child flow는 깨지지 않게 fallback 설계

**검증:**
- NoOp/Fake audio service 기반 테스트
- question load 시 1회 재생, wrong answer 시 replay, correct answer 시 success cue 검증

---

## Phase 3. Quiz UX 레퍼런스 1종 완성

**Objective:** 가장 중요한 놀이 화면 하나를 제품 기준으로 완성한다.

**권장 대상:** `numbers_quiz` 또는 `hangul_quiz` 중 하나를 레퍼런스 스크린으로 선정

**Files:**
- Modify or replace: `lib/features/hangul/presentation/hangul_quiz_screen.dart`
- Or modify/replace: `lib/features/numbers/presentation/numbers_quiz_screen.dart`
- Modify: 대응 테스트 파일

**필수 경험:**
1. 문제 진입 즉시 음성 prompt 재생
2. choice 4개가 항상 한 화면 안에서 안정적으로 보임
3. 오답 시 즉각 shake / error tone / prompt replay
4. 정답 시 flash / success cue / 짧은 celebratory micro-animation
5. 문제 종료 시 “잘했어 → 보상 획득 → 다음 단계 유도” 흐름 제공

**검증:**
- wrong/correct/replay/finish 동작 test
- compact layout test
- progress update test

---

## Phase 4. Reward Loop 실체화

**Objective:** 스티커/보상이 숫자 카운터가 아니라 실제 놀이 동기로 작동하게 만든다.

**Files:**
- Likely create: `lib/features/rewards/domain/*`
- Likely create: `lib/features/rewards/presentation/*`
- Modify: `lib/app/services/progress_store.dart`
- Modify: quiz completion 화면들
- Modify: parent summary 일부

**설계 포인트:**
1. 단순 `stickerCount` 외에 최근 획득 보상 정보 저장
2. completion 순간에 새로 얻은 보상이 시각적으로 등장
3. “다시하기” 외에 “다음 놀이” 유도 CTA 추가
4. 가능한 경우 카테고리별 보상 정체성 부여

**검증:**
- quiz 완료 시 보상 snapshot 갱신 테스트
- reward banner/collection 진입 테스트

---

## Phase 5. 공통 엔진 추출

**Objective:** child UX 개편 결과를 3카테고리에 확장 가능한 구조로 만든다.

**Files:**
- Likely create: `lib/features/lesson/domain/lesson_models.dart`
- Likely create: `lib/features/lesson/domain/quiz_models.dart`
- Likely create: `lib/features/lesson/presentation/generic_learn_screen.dart`
- Likely create: `lib/features/lesson/presentation/generic_quiz_screen.dart`
- Likely create: `lib/features/lesson/data/lesson_content_loader.dart`
- Modify: `lib/features/{hangul,alphabet,numbers}/**`

**설계 포인트:**
1. 카테고리별 차이는 manifest/config/theme token으로 주입
2. 공통 quiz rule은 한 군데만 유지
3. category-specific 표현만 adapter로 분리

**검증:**
- shared quiz behavior를 category별 fixture로 검증
- duplication 감소 확인

---

## Phase 6. Parent 레이어 재배치

**Objective:** child experience를 완성한 뒤, parent 기능을 운영도구로 재정리한다.

**Files:**
- Modify/split: `lib/features/avatar/presentation/avatar_setup_screen.dart`
- Likely create: `lib/features/parent/presentation/*`
- Modify: hidden entry flow related files

**설계 포인트:**
1. parent 정보는 child 화면과 시각적으로 분리
2. 진도/해금/오답/설정/자산을 섹션화
3. 숨김 진입 UX는 accidental tap 방지와 피드백을 함께 설계

---

## 5. 추천 레퍼런스 채택 방향

### `origin/feature/ui-redesign-v2`에서 가져올 것
- play background 계열의 시각 방향성
- home/category/hero 톤 정리 아이디어

### `origin/claude/review-handoff-status-Rd9py`에서 가져올 것
- audio-first quiz 레이아웃 실험
- `TtsService` 분리 아이디어
- Tayo blue 계열 child-facing 강조 컬러 감각

### 그대로 가져오지 말 것
- hangul 하나만 바꾼 부분 최종안처럼 간주하는 것
- 카테고리별 별도 구현을 유지한 채 UI만 교체하는 것

---

## 6. 변경 가능성이 큰 파일 목록

### 반드시 재검토할 파일
- `lib/app/app.dart`
- `lib/app/services/progress_store.dart`
- `lib/app/services/speech_cue_service.dart`
- `lib/features/hangul/presentation/hangul_quiz_screen.dart`
- `lib/features/numbers/presentation/numbers_quiz_screen.dart`
- `lib/features/alphabet/presentation/alphabet_quiz_screen.dart`
- `lib/features/home/presentation/lesson_picker_screen.dart`
- `lib/features/hero/presentation/hero_screen.dart`
- `lib/features/avatar/presentation/avatar_setup_screen.dart`
- `test/features/*quiz*_test.dart`
- `test/app/services/progress_store_test.dart`

### 새로 생길 가능성이 큰 파일
- `lib/app/audio/*`
- `lib/app/play/*`
- `lib/features/lesson/*`
- `lib/features/rewards/*`
- `lib/features/parent/*`

---

## 7. 검증 전략

모든 phase에서 아래를 유지한다.

1. `flutter analyze` green 유지
2. `flutter test` green 유지
3. compact landscape 회귀 테스트 유지
4. category별 공통 behavior 테스트 강화
5. release APK artifact가 계속 생성되도록 Actions 유지

검증 명령:
- `/home/openc/sdk/flutter/bin/flutter test`
- `/home/openc/sdk/flutter/bin/flutter analyze`
- `/home/openc/sdk/flutter/bin/flutter build apk --release --target-platform android-arm64`

---

## 8. 바로 다음 미팅에서 확정할 3가지

1. 레퍼런스 카테고리를 무엇으로 잡을지
   - hangul
   - numbers

2. 오디오 범위를 어디까지 넣을지
   - TTS fallback 중심
   - 최소 녹음 음성 + 효과음

3. 보상 루프 강도를 어느 수준까지 넣을지
   - completion banner 수준
   - 스티커 수집/진열까지

---

## 9. 실행 권장 순서 요약

1. baseline green 복구
2. child play shell 정의
3. audio system 도입
4. quiz 레퍼런스 1종 완성
5. reward loop 실체화
6. 공통 엔진 추출 및 타 카테고리 확장
7. parent console 재배치

이 순서가 가장 현실적이다. child UX를 먼저 잡되, 공통 엔진을 너무 늦게 미루지 않아야 중복 재작업을 막을 수 있다.
