# Child UX / Audio-First Overhaul Implementation Plan

> For Hermes: Use this as the execution plan. Keep commits incremental and preserve GitHub Actions APK artifact generation after each meaningful round.

**Goal:** 숫자 카테고리를 레퍼런스로 삼아 `승원이의 빵빵 놀이터`를 audio-first toddler play loop로 재설계하고, 이후 한글/알파벳으로 확장 가능한 공통 뼈대를 만든다.

**Architecture:** 이번 1차 실행은 `numbers`를 기준 카테고리로 사용한다. child-facing 흐름은 `play shell + audio service + reward snapshot` 3축으로 정리하고, 최소한의 공통화는 지금 바로 시작한다. 다만 hangul/alphabet 전체 이식은 레퍼런스 완성 후 2차로 분리한다.

**Tech Stack:** Flutter, shared_preferences, flutter_tts fallback, asset-based audio placeholders, GitHub Actions APK build

**Assumptions fixed for this plan:**
- 레퍼런스 카테고리: `numbers`
- 오디오 범위: `실오디오 슬롯 + TTS fallback`
- 보상 범위: `스티커 수집/최근 획득 표시`까지 1차 반영

---

## Current context / prerequisites

확인된 현재 상태:
- `flutter analyze`는 통과
- `flutter test`는 실패
- 실패 원인: `assets/public/manifest/numbers_lessons.json`과 `assets/generated/manifest/numbers_lessons.json` 불일치
- `scripts/prepare_assets.sh`는 public → generated 복사 후 private overlay 구조
- 현재 `numbers_quiz_screen.dart`는 826 LOC로 비대하고, 오디오/피드백/보상/레이아웃 로직이 한 파일에 결합되어 있음
- 현재 `AppServices`는 `progressStore`, `speechCueService`만 제공

실행 전 규칙:
- 각 task 후 가능한 한 작은 commit
- 각 단계에서 최소 `flutter test` 또는 관련 test 타깃 확인
- 중간에도 Actions APK artifact가 깨지지 않도록 유지

---

## Phase 0. Baseline 복구

### Task 1: generated numbers manifest 계약 복구

**Objective:** 현재 failing baseline을 green으로 되돌린다.

**Files:**
- Verify: `assets/public/manifest/numbers_lessons.json`
- Modify: `assets/generated/manifest/numbers_lessons.json`
- Verify: `scripts/prepare_assets.sh`
- Test: `test/features/numbers/data/numbers_lesson_repository_test.dart`

**Step 1: 자산 계약 확인**
- public manifest는 lesson 4개
- generated manifest는 lesson 1개
- `prepare_assets.sh`는 원칙상 public을 그대로 복사해야 함

**Step 2: failing test 고정**
Run:
`/home/openc/sdk/flutter/bin/flutter test test/features/numbers/data/numbers_lesson_repository_test.dart -r compact`
Expected: FAIL on manifest mismatch

**Step 3: generated manifest 복구**
선호 순서:
1. `./scripts/prepare_assets.sh`로 generated 재생성
2. 그래도 mismatch면 생성 파이프라인/로컬 override 여부 확인
3. `assets/generated/manifest/numbers_lessons.json`이 public과 일치하도록 복구

**Step 4: 회귀 확인**
Run:
`/home/openc/sdk/flutter/bin/flutter test test/features/numbers/data/numbers_lesson_repository_test.dart -r compact`
Expected: PASS

**Step 5: 전체 baseline 확인**
Run:
`/home/openc/sdk/flutter/bin/flutter test -r compact`
Expected: 전체 green

**Step 6: Commit**
```bash
git add assets/generated/manifest/numbers_lessons.json scripts/prepare_assets.sh test/features/numbers/data/numbers_lesson_repository_test.dart
git commit -m "fix: restore generated numbers manifest baseline"
```

---

## Phase 1. Audio/Reward foundation 도입

### Task 2: AppServices에 audio abstraction 추가

**Objective:** quiz/learn 화면이 직접 `speechCueService` 세부 구현에 묶이지 않도록 공통 audio entrypoint를 만든다.

**Files:**
- Create: `lib/app/audio/audio_cue.dart`
- Create: `lib/app/audio/audio_service.dart`
- Modify: `lib/app/services/app_services.dart`
- Test: `test/app/audio/audio_service_test.dart`

**Step 1: failing test 작성**
새 테스트에서 아래 contract를 검증:
- `AudioService.playPrompt(text: ...)`
- recorded asset가 없으면 TTS fallback 호출
- SFX cue는 asset key만 요청

**Step 2: 최소 구현 추가**
권장 타입:
- `AudioCueType { prompt, success, error, reward, tap }`
- `AudioPromptRequest(categoryId, lessonId, symbol, fallbackText)`
- `AudioService` interface
- `FallbackAudioService` implementation

**Step 3: AppServices wiring**
- `speechCueService`는 내부 fallback dependency로 후퇴
- 화면은 앞으로 `audioService`를 우선 사용

**Step 4: 테스트 실행**
Run:
`/home/openc/sdk/flutter/bin/flutter test test/app/audio/audio_service_test.dart -r compact`

**Step 5: Commit**
```bash
git add lib/app/audio lib/app/services/app_services.dart test/app/audio/audio_service_test.dart
git commit -m "feat: add audio service abstraction with tts fallback"
```

### Task 3: reward snapshot 모델 확장

**Objective:** 단순 `stickerCount` 외에 “방금 얻은 보상”을 child flow에서 바로 보여줄 수 있게 만든다.

**Files:**
- Modify: `lib/app/services/progress_store.dart`
- Test: `test/app/services/progress_store_test.dart`

**Step 1: failing test 작성**
새 검증 포인트:
- quiz completion 후 `lastEarnedReward` 또는 동등한 구조 저장
- reset 시 해당 상태 초기화

**Step 2: 최소 구현 추가**
권장 필드 예시:
- `RecentReward(kind, amount, lessonId, earnedAt)`
- `AppProgressSnapshot.lastEarnedReward`

**Step 3: 기존 stickerCount 흐름 유지**
- 하위호환을 위해 `stickerCount`는 유지
- summary/reward scene에서 `lastEarnedReward`를 사용

**Step 4: 테스트 실행**
Run:
`/home/openc/sdk/flutter/bin/flutter test test/app/services/progress_store_test.dart -r compact`

**Step 5: Commit**
```bash
git add lib/app/services/progress_store.dart test/app/services/progress_store_test.dart
git commit -m "feat: persist recent reward snapshot for child flow"
```

---

## Phase 2. Child play shell 컴포넌트화

### Task 4: 공통 play feedback layer 생성

**Objective:** 정답/오답 반응을 공통 컴포넌트로 분리한다.

**Files:**
- Create: `lib/app/play/play_feedback_kind.dart`
- Create: `lib/app/ui/play_feedback_layer.dart`
- Modify: `lib/app/ui/answer_feedback_overlay.dart` 또는 대체 제거
- Test: `test/app/ui/play_feedback_layer_test.dart`

**Step 1: failing test 작성**
검증 포인트:
- correct → success icon/text/style
- wrong → error style
- visible false일 때 interaction 차단 없음

**Step 2: 새 layer 구현**
포함 요소:
- duration token
- success/error visual style
- optional label suppression mode

**Step 3: 기존 overlay 정리**
- numbers quiz에서 교체 가능한 형태로 유지

**Step 4: 테스트 실행**
Run:
`/home/openc/sdk/flutter/bin/flutter test test/app/ui/play_feedback_layer_test.dart -r compact`

**Step 5: Commit**
```bash
git add lib/app/play lib/app/ui/play_feedback_layer.dart lib/app/ui/answer_feedback_overlay.dart test/app/ui/play_feedback_layer_test.dart
git commit -m "feat: add reusable play feedback layer"
```

### Task 5: 공통 play choice card 생성

**Objective:** toddler-sized choice 버튼을 숫자 퀴즈 기준으로 공통화한다.

**Files:**
- Create: `lib/app/ui/play_choice_card.dart`
- Test: `test/app/ui/play_choice_card_test.dart`

**Step 1: failing test 작성**
검증 포인트:
- compact landscape에서 최소 탭 영역 유지
- disabled 상태 스타일 보장
- symbol 텍스트 overflow 방지

**Step 2: 최소 구현 작성**
props 예시:
- `label`
- `accentIndex`
- `compact`
- `disabled`
- `onTap`

**Step 3: 테스트 실행**
Run:
`/home/openc/sdk/flutter/bin/flutter test test/app/ui/play_choice_card_test.dart -r compact`

**Step 4: Commit**
```bash
git add lib/app/ui/play_choice_card.dart test/app/ui/play_choice_card_test.dart
git commit -m "feat: add reusable toddler choice card"
```

### Task 6: 공통 prompt panel 축소형/표준형 정리

**Objective:** 현재 `audio_prompt_panel.dart`와 numbers quiz의 tight panel 중복을 하나의 contract로 정리한다.

**Files:**
- Modify: `lib/app/ui/audio_prompt_panel.dart`
- Possibly create: `lib/app/ui/play_prompt_panel.dart`
- Test: `test/app/ui/play_prompt_panel_test.dart`

**Step 1: failing test 작성**
검증 포인트:
- compact/tight 변형 모두 렌더링
- replay tap 동작
- title/subtitle 생략 모드 허용

**Step 2: 구현**
- `variant: standard | compact | tight`
- symbol spotlight optional

**Step 3: 테스트 실행**
Run:
`/home/openc/sdk/flutter/bin/flutter test test/app/ui/play_prompt_panel_test.dart -r compact`

**Step 4: Commit**
```bash
git add lib/app/ui/audio_prompt_panel.dart lib/app/ui/play_prompt_panel.dart test/app/ui/play_prompt_panel_test.dart
git commit -m "feat: unify prompt panel variants for child play screens"
```

---

## Phase 3. Numbers quiz reference screen 재작성

### Task 7: numbers quiz state logic 분리

**Objective:** `numbers_quiz_screen.dart`에서 상태 전이 로직을 widget tree 바깥으로 옮긴다.

**Files:**
- Create: `lib/features/numbers/presentation/numbers_quiz_session.dart`
- Modify: `lib/features/numbers/presentation/numbers_quiz_screen.dart`
- Test: `test/features/numbers/presentation/numbers_quiz_session_test.dart`

**Step 1: failing test 작성**
검증 포인트:
- wrong answer → recentMistakes append
- correct answer → score increment
- final question → complete state
- 80% 이상 → sticker earned

**Step 2: session 모델 구현**
예시 API:
- `NumbersQuizSession.start(cards, mistakeSymbols)`
- `submit(choiceSymbol)`
- `advance()`
- `earnedSticker`

**Step 3: screen에서 session 사용**
- widget은 렌더링과 user input만 담당

**Step 4: 테스트 실행**
Run:
`/home/openc/sdk/flutter/bin/flutter test test/features/numbers/presentation/numbers_quiz_session_test.dart -r compact`

**Step 5: Commit**
```bash
git add lib/features/numbers/presentation/numbers_quiz_session.dart lib/features/numbers/presentation/numbers_quiz_screen.dart test/features/numbers/presentation/numbers_quiz_session_test.dart
git commit -m "refactor: extract numbers quiz session state"
```

### Task 8: numbers quiz를 audio-first play shell로 교체

**Objective:** 숫자 퀴즈를 child-first 기준 화면으로 재작성한다.

**Files:**
- Modify: `lib/features/numbers/presentation/numbers_quiz_screen.dart`
- Modify: `test/features/numbers/presentation/numbers_quiz_screen_test.dart`
- Maybe modify: `test/widget_test.dart`

**Step 1: failing widget test 추가/수정**
추가 검증 포인트:
- 첫 문제 로드 시 prompt replay affordance 표시
- wrong answer 시 즉시 error feedback 후 prompt replay
- correct answer 시 success feedback 후 자동 진행
- 완료 시 reward scene 표시

**Step 2: 화면 재배치**
권장 레이아웃:
- 좌측: 큰 스피커/prompt 영역
- 우측: 2x2 choice card
- 상단 카운터는 child 방해 최소화
- 안내 문구 최소화

**Step 3: 오디오 연결**
- 문제 진입 시 `audioService.playPrompt(...)`
- 오답 시 `audioService.playErrorCue()` 후 prompt replay
- 정답 시 `audioService.playSuccessCue()`

**Step 4: 보상 연결**
- 마지막 문제 후 `progressStore.recordQuizResult`
- sticker 획득 시 `recordRecentReward` 또는 동일 효과 반영
- summary는 reward-first copy로 변경

**Step 5: 테스트 실행**
Run:
`/home/openc/sdk/flutter/bin/flutter test test/features/numbers/presentation/numbers_quiz_screen_test.dart -r compact`

**Step 6: Commit**
```bash
git add lib/features/numbers/presentation/numbers_quiz_screen.dart test/features/numbers/presentation/numbers_quiz_screen_test.dart test/widget_test.dart
git commit -m "feat: redesign numbers quiz as audio-first toddler play screen"
```

### Task 9: reward summary를 collection-oriented scene으로 확장

**Objective:** 숫자 카운터 요약을 “방금 스티커를 얻었다” 경험으로 바꾼다.

**Files:**
- Create: `lib/features/rewards/presentation/reward_summary_panel.dart`
- Modify: `lib/features/numbers/presentation/numbers_quiz_screen.dart`
- Test: `test/features/rewards/presentation/reward_summary_panel_test.dart`

**Step 1: failing test 작성**
검증 포인트:
- recent reward가 있으면 축하 UI 노출
- 다시하기 / 다음놀이 CTA 노출
- reward 없는 완료 시 fallback copy 노출

**Step 2: 최소 구현 작성**
표시 요소:
- 획득 스티커 수
- 전체 스티커 누적 수
- “다시하기”, “다른 세트 하기” CTA

**Step 3: 테스트 실행**
Run:
`/home/openc/sdk/flutter/bin/flutter test test/features/rewards/presentation/reward_summary_panel_test.dart -r compact`

**Step 4: Commit**
```bash
git add lib/features/rewards/presentation/reward_summary_panel.dart lib/features/numbers/presentation/numbers_quiz_screen.dart test/features/rewards/presentation/reward_summary_panel_test.dart
git commit -m "feat: add reward-first completion scene for quiz"
```

---

## Phase 4. Numbers learn 및 진입 흐름 정리

### Task 10: numbers learn을 audio-first 톤으로 최소 정리

**Objective:** quiz만 튀지 않도록 learn 화면도 같은 child UX 문법으로 맞춘다.

**Files:**
- Modify: `lib/features/numbers/presentation/numbers_learn_screen.dart`
- Test: `test/features/numbers/presentation/numbers_learn_screen_test.dart`

**Step 1: failing test 추가/수정**
검증 포인트:
- 첫 카드에서 자동 음성 재생
- compact landscape에서 큰 숫자와 replay affordance 유지
- 마지막 카드에서 다음 플레이 유도 문구 표시

**Step 2: 구현**
- 설명 텍스트 축소
- replay affordance 강화
- 완료 시 “퀴즈로 이어하기” CTA 고려

**Step 3: 테스트 실행**
Run:
`/home/openc/sdk/flutter/bin/flutter test test/features/numbers/presentation/numbers_learn_screen_test.dart -r compact`

**Step 4: Commit**
```bash
git add lib/features/numbers/presentation/numbers_learn_screen.dart test/features/numbers/presentation/numbers_learn_screen_test.dart
git commit -m "feat: align numbers learn screen with audio-first play flow"
```

### Task 11: lesson picker copy와 flow를 child-first로 조정

**Objective:** 세트 선택 화면도 텍스트 설명을 줄이고 즉시 선택 중심으로 바꾼다.

**Files:**
- Modify: `lib/features/home/presentation/lesson_picker_screen.dart`
- Modify: `test/features/home/presentation/category_lesson_picker_flow_test.dart`

**Step 1: failing test 추가/수정**
검증 포인트:
- 숫자 세트 카드가 더 큰 탭 카드로 보임
- 잠금/해금 표시가 child를 혼란스럽게 하지 않음
- compact landscape에서 overflow 없음

**Step 2: 구현**
- 상단 설명 문구 최소화
- 카드 중심 선택 UI 강화
- 잠금 상태는 parent-facing 텍스트보다 icon/state 중심으로 축소

**Step 3: 테스트 실행**
Run:
`/home/openc/sdk/flutter/bin/flutter test test/features/home/presentation/category_lesson_picker_flow_test.dart -r compact`

**Step 4: Commit**
```bash
git add lib/features/home/presentation/lesson_picker_screen.dart test/features/home/presentation/category_lesson_picker_flow_test.dart
git commit -m "feat: simplify lesson picker for child-first set selection"
```

---

## Phase 5. Asset/audio slots 연결

### Task 12: public audio asset slots 추가

**Objective:** 이후 실녹음 음성과 효과음을 꽂을 수 있게 public/generated 구조를 먼저 마련한다.

**Files:**
- Modify: `pubspec.yaml`
- Modify: `assets/public/manifest/asset_register.csv`
- Create or modify: `assets/public/audio/voice/prompts/*`
- Create or modify: `assets/public/audio/sfx/*`
- Verify: `scripts/prepare_assets.sh`
- Test: asset load smoke if needed

**Step 1: 슬롯 결정**
최소 슬롯:
- `audio/voice/prompts/choose_number.ogg`
- `audio/sfx/success.ogg`
- `audio/sfx/error.ogg`
- `audio/sfx/reward.ogg`

**Step 2: placeholder 자산 등록**
- 실제 파일이 아직 없으면 최소 placeholder asset로 계약만 유지
- `asset_register.csv`에 source/license/replace notes 기록

**Step 3: generated 반영 확인**
Run:
`./scripts/prepare_assets.sh`

**Step 4: smoke verify**
Run:
`/home/openc/sdk/flutter/bin/flutter test test/features/numbers/presentation/numbers_quiz_screen_test.dart -r compact`

**Step 5: Commit**
```bash
git add pubspec.yaml assets/public assets/generated scripts/prepare_assets.sh
git commit -m "feat: add placeholder audio asset slots for child play flow"
```

---

## Phase 6. Regression + APK validation

### Task 13: targeted regression sweep

**Objective:** numbers reference flow 변경이 전체 앱을 깨지 않았는지 확인한다.

**Files:**
- No code changes expected unless regression found

**Run exactly:**
```bash
/home/openc/sdk/flutter/bin/flutter test test/features/numbers/presentation/numbers_quiz_screen_test.dart -r compact
/home/openc/sdk/flutter/bin/flutter test test/features/numbers/presentation/numbers_learn_screen_test.dart -r compact
/home/openc/sdk/flutter/bin/flutter test test/features/home/presentation/category_lesson_picker_flow_test.dart -r compact
/home/openc/sdk/flutter/bin/flutter test test/app/services/progress_store_test.dart -r compact
/home/openc/sdk/flutter/bin/flutter analyze
/home/openc/sdk/flutter/bin/flutter test -r compact
```
Expected:
- all PASS

### Task 14: release APK 검증

**Objective:** 실제 디바이스 배포 가능 상태 유지

**Run exactly:**
```bash
./scripts/prepare_assets.sh
/home/openc/sdk/flutter/bin/flutter build apk --release --target-platform android-arm64
```
Expected:
- `build/app/outputs/flutter-apk/app-release.apk` 생성

### Task 15: final commit and push

**Objective:** 1차 reference implementation을 GitHub Actions artifact까지 연결한다.

**Step 1: commit**
```bash
git add .
git commit -m "feat: deliver audio-first numbers reference experience"
```

**Step 2: push**
```bash
git push origin HEAD
```

**Step 3: Actions 확인**
- workflow: `Build Android APK`
- artifact 생성 여부 확인

---

## Rollout after reference passes

reference 완료 후 다음 순서로 확장:
1. `hangul_quiz_screen.dart` → same play shell로 포팅
2. `alphabet_quiz_screen.dart` → same play shell로 포팅
3. 공통 `generic_quiz_screen` / `generic_learn_screen` 추출
4. `avatar_setup_screen.dart` 분해

---

## Risks / tradeoffs

1. `numbers_quiz_screen.dart`만 먼저 개선하면 일시적으로 카테고리 간 UX 격차가 생긴다.
   - 허용 이유: reference를 빨리 확보해야 전체 확장이 안전해짐

2. recorded audio가 실제로 아직 준비되지 않았을 수 있다.
   - 대응: asset slot + TTS fallback로 먼저 구조 완성

3. reward snapshot을 너무 크게 설계하면 parent/store와 충돌할 수 있다.
   - 대응: 1차는 `recent reward + sticker count` 수준으로 제한

4. generated assets가 다시 drift할 수 있다.
   - 대응: prepare script 실행을 validation pipeline에 포함

---

## Definition of done for this round

아래를 만족하면 이번 1차 목표 달성으로 본다.
- baseline tests green
- numbers learn/quiz가 audio-first toddler flow로 동작
- prompt / success / error / reward 오디오 경로 존재
- sticker reward가 숫자 카운터가 아닌 child-visible scene으로 노출
- compact landscape regression 없음
- release APK build 가능
- GitHub Actions artifact 유지
