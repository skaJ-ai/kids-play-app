# Kids Play App 전면 개편 사전 진단 메모

> For Hermes: planning only. Do not implement from this file without a separate execution decision.

**Goal:** `26.417_review.md`와 `main` 외 branch들을 바탕으로 현재 제품 상태를 진단하고, 전면 개편 계획 수립 전에 무엇을 결정해야 하는지 정리한다.

**Architecture:** 현재 코드는 카테고리별 화면/레포지토리 복제가 많고, branch들은 공통 엔진화 없이 개별 화면 polish에 치우쳐 있다. 따라서 이번 개편은 화면 polish가 아니라 `공통 학습 엔진 + 오디오/자산 체계 + child/parent UX 재분리`를 축으로 재설계하는 쪽이 맞다.

**Tech Stack:** Flutter, shared_preferences, flutter_tts, JSON manifest assets, GitHub Actions APK build

---

## 1. 확인한 대상

### 저장소
- repo: `/home/openc/kids-play-app`
- current HEAD: `ea8ff71` (`feat(parent): add manual lesson unlock flow`)

### 확인한 non-main branches
- `origin/claude/review-main-branch-0UMTv`
- `origin/feature/ui-redesign-v2`
- `origin/claude/review-handoff-status-Rd9py`

### 리뷰 문서 위치
- 문서는 working tree에 없고, 다음 커밋/branch에만 존재함
- commit: `8925c5f251ecb069de8047538e6c5b7e38809371`
- path: `origin/claude/review-main-branch-0UMTv:26.417_review.md`

---

## 2. 리뷰 문서 핵심 주장 검증 결과

### 2-1. 구조적 복붙 문제는 사실상 맞음
실제 main 기준 측정 결과:
- `hangul_learn_screen.dart`: 368 LOC
- `alphabet_learn_screen.dart`: 368 LOC
- `numbers_learn_screen.dart`: 368 LOC
- learn screen 유사도: 98.4% ~ 99.0%

- `hangul_quiz_screen.dart`: 777 LOC
- `alphabet_quiz_screen.dart`: 777 LOC
- `numbers_quiz_screen.dart`: 826 LOC
- quiz screen 유사도:
  - hangul ↔ alphabet: 99.26%
  - hangul ↔ numbers: 94.21%
  - alphabet ↔ numbers: 94.20%

- `hangul_lesson_repository.dart`: 73 LOC
- `alphabet_lesson_repository.dart`: 73 LOC
- `numbers_lesson_repository.dart`: 73 LOC

판단:
- 현재는 카테고리만 바뀐 거의 동일한 구현이 3벌 존재함
- 전면 개편을 한다면 1순위는 반드시 `generic learn/quiz engine`화여야 함
- 그렇지 않으면 UI/보상/오디오/룰 변경이 3배 비용으로 계속 누적됨

### 2-2. parent 화면 비대화도 사실상 맞음
- `lib/features/avatar/presentation/avatar_setup_screen.dart`: 1338 LOC

판단:
- parent 운영 화면이 지나치게 커졌고, child-facing experience보다 구조적으로 더 무거운 화면이 됨
- 개편 시 parent 영역은 `개요`, `진도/해금`, `오답 재도전`, `자산/아바타`, `설정` 등으로 분리 필요

### 2-3. 자산 부족 지적도 대체로 맞음
실파일 확인 결과:
- 실이미지: `hero_face.png` 중심
- manifest JSON은 존재
- `assets/generated/audio/voice/prompts`, `audio/sfx`, `audio/music`는 실파일 없음

판단:
- 현재 앱은 실제 감각 자산보다는 `텍스트 + TTS + 컬러 UI` 중심
- toddler 전용 제품으로 밀어붙이려면 시각/청각 자산 레이어가 별도 트랙으로 필요함

### 2-4. 음성은 실제로 flutter_tts 래퍼 수준
- `lib/app/services/speech_cue_service.dart`는 `flutter_tts`에 대한 얇은 wrapper
- locale/rate/pitch 조절 후 `speak(text)` 호출하는 구조

판단:
- “오디오 퍼스트” 지향은 보이지만 아직 `디바이스 TTS 의존` 단계
- 실제 음성 에셋, 효과음, 재생 정책, 캐싱, fallback 정책은 아직 제품 수준으로 정리되지 않음

### 2-5. 라우팅 단순화 지적도 맞음
검색 결과:
- `Navigator.of(context).push(MaterialPageRoute(...))` 패턴이 hero/home/category/lesson picker 등 주요 화면에 직접 분산

판단:
- 규모가 더 커지면 child flow / parent flow / deep link성 진입 / replay flow 관리가 어려워짐
- 전체 개편 시 최소한 named route 계층 또는 중앙 라우트 맵은 필요

### 2-6. 테스트 평가는 '완전 스모크만'은 아니지만 구조 보호에는 부족
확인 결과:
- `test/` 아래 20개 파일 존재
- `progress_store_test.dart` 같이 상태 저장 검증도 있음
- `category_lesson_picker_flow_test.dart` 같이 flow 테스트도 있음

하지만:
- 여전히 위젯/플로우 중심이 강함
- 공통 도메인 엔진이 없어서 “학습 룰 / 보상 룰 / 진도 룰 / 문제 생성 룰”을 독립적으로 방어하는 테스트 층이 얕음

판단:
- 리뷰 문서의 방향성은 맞지만, 테스트가 완전히 없는 상태는 아님
- 다만 전면 개편을 버티게 해 줄 테스트 아키텍처는 아직 아님

---

## 3. branch별 의미 정리

### A. `origin/claude/review-main-branch-0UMTv`
성격:
- 코드 변경 없음
- `26.417_review.md` 문서 1개만 추가

의미:
- 구현 branch가 아니라 “현재 main에 대한 냉정한 코드 리뷰 메모”
- 전면 개편의 문제 정의 문서로 활용 가치 있음

### B. `origin/feature/ui-redesign-v2`
main 대비 변경:
- APK build workflow 추가
- Android signing 관련 파일 추가
- `hero/home/category_hub/hangul learn/hangul quiz` 위주 UI 재디자인
- `app_colors.dart`, `play_background.dart` 추가

의미:
- 시각 톤/무드 방향성 실험 branch
- 그러나 범위가 hangul + 홈 계열 중심이라 제품 전체 공통 구조 개편은 아님
- alphabet/numbers까지 일관된 시스템으로 확장된 상태는 아님

판단:
- “디자인 방향 참고 branch”로는 유효
- “전면 개편의 기반 branch”로 바로 삼기에는 구조 개선이 부족

### C. `origin/claude/review-handoff-status-Rd9py`
`feature/ui-redesign-v2` 위에 추가된 것:
- `tts_service.dart` 추가
- `hangul_quiz_screen.dart` 재작성 수준 수정
- `app_colors.dart`에 Tayo blue 계열 토큰 추가
- test 일부 수정

의미:
- child-facing 화면을 더 audio-first로 가져가려는 실험
- 하지만 변경이 거의 `hangul quiz` 한 화면에 집중됨

판단:
- 이 branch는 “오디오 퍼스트 인터랙션 프로토타입”으로 볼 수 있음
- 제품 전체 아키텍처나 전 카테고리 체계로 확장된 해법은 아직 아님

---

## 4. 현재 main 건강 상태

### 정적 분석
- `/home/openc/sdk/flutter/bin/flutter analyze` → PASS

### 테스트
- `/home/openc/sdk/flutter/bin/flutter test` → FAIL
- 직접 확인된 실패 원인:
  - `test/features/numbers/data/numbers_lesson_repository_test.dart`
  - 테스트는 `numbers_lessons.json`이 최소 2개 이상의 lesson을 가진다고 기대
  - 실제 `assets/generated/manifest/numbers_lessons.json`은 현재 1개 lesson만 포함

판단:
- 전면 개편 시작 전 baseline을 “green”으로 맞추는 Phase 0가 필요
- 지금 상태에서 바로 대수술을 시작하면 기존 회귀 검증선이 흐려짐

---

## 5. 전면 개편 관점의 핵심 결론

### 결론 1. 이번 작업은 '폴리시'가 아니라 '기초 구조 재설계'여야 함
지금 가장 큰 병목은:
- 3카테고리 복붙 구조
- parent 화면 비대화
- 자산/오디오 실체 부족
- child flow와 parent ops가 한 구조 안에서 뒤엉킨 점

### 결론 2. branch들은 방향성 힌트는 주지만, 그대로 merge할 완성 해법은 아님
- review branch: 문제 정의용
- ui-redesign-v2: 시각 톤 참고용
- review-handoff-status: audio-first interaction 참고용

즉, next step은 단순 merge 전략이 아니라:
- 어떤 요소를 채택할지 추출하고
- 새 목표 아키텍처를 먼저 정한 뒤
- 그 구조로 다시 재조립하는 방식이 적합

### 결론 3. 개편 우선순위는 아래 순서가 맞음
1. 공통 lesson/quiz 엔진화
2. child-facing interaction model 재정의 (audio-first, tap-only, reward loop)
3. parent console 분해
4. route/state/content 구조 정리
5. 실제 자산/음성 파이프라인 도입
6. 그 다음에 시각 polish 확장

---

## 6. 권장 개편 프레임

### Phase 0. Baseline 안정화
목표:
- 현재 main을 다시 green 상태로 만들 기준선 확보

해야 할 일:
- numbers manifest/test 계약 깨진 부분 정리
- 현재 branch들의 참고 포인트를 문서화
- child flow의 현행 사용자 시나리오를 1장으로 고정

### Phase 1. 공통 도메인/엔진 추출
목표:
- hangul/alphabet/numbers 복붙 3벌 제거

핵심 작업:
- 공통 lesson model 정의
- 공통 repository adapter 또는 content loader 정의
- `generic learn screen`, `generic quiz screen` 도입
- category별 차이는 manifest/config/theme token으로만 주입

### Phase 2. Child UX 재설계
목표:
- toddler용 audio-first play loop를 제품 중심에 둠

핵심 작업:
- text 의존 낮추기
- prompt replay 규칙 정리
- correct/wrong feedback 모션 체계화
- sticker/reward를 실제 collection/scene/feedback로 승격
- compact landscape 기준 UI 규칙 공통화

### Phase 3. Parent console 재분해
목표:
- parent 운영 기능을 child experience와 분리된 구조로 정돈

핵심 작업:
- `avatar_setup_screen.dart` 분해
- 진도/해금/오답/설정/자산 편집을 서브 섹션으로 분리
- 숨김 진입 UX도 안정화

### Phase 4. 자산/오디오 실체화
목표:
- “TTS 데모”가 아니라 실제 아이가 반복 사용 가능한 감각 경험 만들기

핵심 작업:
- 실보이스 vs TTS fallback 전략 결정
- SFX/BGM/보상음 구조 도입
- category/lesson visual asset 규칙 정리
- asset register와 generated pipeline 정비

### Phase 5. 디자인 시스템/라우팅 정리
목표:
- 이후 확장을 버티는 foundation 확보

핵심 작업:
- spacing/radius/duration/elevation/opacity token 정리
- route map 정리
- screen shell / panel / card / choice button 공통 컴포넌트화

---

## 7. 전면 개편 전에 사용자와 확정해야 할 질문

1. 이번 개편의 최우선 목표는 무엇인가?
   - A. 구조 리팩터링 우선
   - B. 아이가 바로 좋아할 UX/보상 강화 우선
   - C. 둘 다 하되 MVP 범위로 자르기

2. 시각 컨셉은 유지인가, 재해석인가?
   - 현재 garage/car 톤 유지
   - 더 명확한 캐릭터/도로/놀이감 톤으로 재구성

3. 오디오는 어디까지 이번 라운드에 넣을 것인가?
   - TTS 개선만
   - 실제 녹음 음성 + 최소 효과음
   - 음성 + 효과음 + BGM까지

4. 카테고리 3종은 그대로 유지하는가?
   - 유지하되 공통 엔진화
   - 우선 1개 카테고리 완성 후 나머지 확장

5. parent 화면은 운영도구 수준으로 둘 것인가, 컨텐츠 관리 콘솔로 키울 것인가?

---

## 8. 이번 계획 수립 미팅에서 바로 결정하면 좋은 안건

### 안건 A. 개편 기준 branch 선택
권장:
- `main`을 사실 기준선으로 두고
- `review-main-branch`는 문제정의 참고
- `feature/ui-redesign-v2`, `review-handoff-status`는 채택 요소만 흡수

비권장:
- 특정 실험 branch를 그대로 전면 개편의 출발점으로 삼는 것

### 안건 B. 1차 개편 범위
권장 범위:
- generic lesson/quiz engine
- child UX shell
- parent screen 분해 설계
- reward/audio framework 뼈대

### 안건 C. 1차 개편에서 미루는 것
후순위 가능:
- 모든 실제 일러스트 최종본
- 모든 음성의 완전 제작
- 과도한 애니메이션 polish

---

## 9. 개편 시 변경 가능성이 큰 파일/영역

### likely modify
- `lib/app/app.dart`
- `lib/app/services/progress_store.dart`
- `lib/app/services/speech_cue_service.dart` 또는 후속 audio service 계층
- `lib/app/ui/*`
- `lib/features/home/presentation/*`
- `lib/features/hero/presentation/*`
- `lib/features/avatar/presentation/*`
- `lib/features/{hangul,alphabet,numbers}/**`
- `assets/public/manifest/*`
- `assets/generated/manifest/*`
- `test/**`

### likely create
- `lib/features/lesson/domain/*`
- `lib/features/lesson/application/*`
- `lib/features/lesson/presentation/generic_*`
- `lib/features/parent/*`
- `lib/app/routing/*`
- `lib/app/audio/*`

---

## 10. 추천 다음 액션

1. 사용자와 개편 목표/우선순위 5개 질문 합의
2. 그 합의에 맞춰 “전면 개편 실행 계획서”를 별도 작성
3. Phase 0부터 순차 실행
4. 각 phase마다 작은 검증 가능 단위로 commit/push 유지
