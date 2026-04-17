# Kids Play App 전면 재설계 — 마스터 설계안

> For Hermes: planning only. Do not implement from this file without a separate execution go-ahead per phase.

**Branch:** `claude/product-overhaul` (from `main` @ `ea8ff71`)
**Reference category:** **alphabet** — 1차 완성 대상. hangul/numbers는 공통 엔진 완성 후 수평 확장.
**Source of truth for problems:** `origin/claude/review-main-branch-0UMTv:26.417_review.md` + `2026-04-17_114725-product-overhaul-discovery.md`

---

## 0. 이 문서의 위치

- 진단: `2026-04-17_114725-product-overhaul-discovery.md` — 리뷰가 지적한 6가지가 실제로 맞는지 수치 검증
- child-UX 방향 단독안: `2026-04-17_114959-child-ux-audio-first-overhaul-plan.md` — 오디오 퍼스트 관점만 단독으로 정리
- **이 문서(마스터 설계안):** 리뷰의 6가지 키포인트를 모두 아우르는 제품 전면 재설계의 **단일 통합 설계서**. 위 두 문서를 대체하지는 않고 상위로 포괄한다.

---

## 1. 확정된 결정

| # | 항목 | 결정 |
|---|------|------|
| D1 | 작업 브랜치 | `claude/product-overhaul` (main에서 신규 분기) |
| D2 | 설계 문서 형태 | 6가지 키포인트를 포괄하는 신규 마스터 설계안 (이 문서) |
| D3 | 1차 레퍼런스 카테고리 | **alphabet** |
| D4 | 다른 카테고리 | hangul/numbers는 공통 엔진 완성 후 얇은 어댑터만 남기고 마이그레이션 |
| D5 | 아키텍처 기조 | 화면 polish가 아니라 `공통 학습 엔진 + 오디오 파이프라인 + 디자인 토큰 + child/parent UX 분리 + 라우팅 정리 + 자산 파이프라인` 재설계 |

---

## 2. 리뷰 6대 이슈 ↔ 이번 설계의 대응

| 리뷰 지적 | 실측 | 이번 설계의 대응 |
|-----------|------|-------------------|
| (1) learn/quiz 3벌 복붙 | learn 368 × 3 (유사도 98~99%), quiz 777 × 2 + 826 × 1 (유사도 94~99%) | `features/lesson/*` 공통 도메인·프리젠테이션 추출. category별 코드는 **얇은 adapter + manifest** 만 남김 |
| (2) 디자인 시스템 없음 | 매직넘버 흩뿌림, `kid_theme.dart` 144 LOC + inline Container 위주 | `app/theme/design_tokens.dart` 도입. spacing/radius/duration/opacity/palette 토큰화 + `ToyButton`/`ToyPanel` 재구성 |
| (3) 자산 1장 + 오디오 0개 | `hero_face.png` 1장 외 이미지 없음, voice/sfx/music 폴더 전부 `.keep` | `app/audio/*` 서비스 계층 + `audio_assets` 레지스트리 + `asset_register.csv` 확장. 실 녹음 음성은 별도 트랙, TTS fallback 유지 |
| (4) 음성 cue = flutter_tts wrapper | `speech_cue_service.dart` 가 `flutter_tts.speak(locale: ko-KR)` | `AudioService` 추상화: `prompt / success / error / reward / idle / bgm` 타입별 큐. fallback 체인(recorded → TTS). 음소거 정책 |
| (5) 스티커 = int 카운터 | `stickerCount` 숫자 + 180ms 페이드인 텍스트 | `features/rewards/*` 도메인 + 획득 이벤트 + 수집 장면 + 카테고리별 보상 정체성 |
| (6) 라우팅 = ad-hoc `Navigator.push` | hero/home/category/lesson picker 전 화면에 분산 | `app/routing/app_router.dart` 중앙 route map. 최소한 named route 계층 + child/parent/replay flow 분리 |

보조 이슈:
- **parent 화면 비대화** (`avatar_setup_screen.dart` 1152~1338 LOC) → `features/parent/*` 섹션 분해
- **테스트가 스모크 위주** → 도메인 엔진 추출 후 unit test 층 추가 (채점 룰, 진도 룰, 보상 룰 독립 검증)

---

## 3. 성공 기준

이번 전면 재설계가 끝났을 때 아래가 참이면 성공:

1. `hangul/alphabet/numbers`의 learn/quiz 중복 코드 합계 **< 200 LOC** (현재 ~3,000 LOC 상당 중복)
2. 새 카테고리 추가 비용이 “manifest 1개 + theme/asset pack 1개” 수준으로 내려감
3. child flow(hero → home → category → lesson → play → reward) 전 구간에서 **텍스트 없이도** 다음 동작을 추론 가능
4. 모든 정답/오답/완료 이벤트에 사운드 + 모션 반응이 걸림 (TTS fallback 포함)
5. 매직넘버가 토큰으로 교체되어 `grep -E '\b(0\.[0-9]+|[12][0-9]\.0)\b'` 빈도가 child-facing 화면에서 급감
6. `avatar_setup_screen.dart` 단일 파일이 **< 300 LOC** 수준으로 분해
7. `flutter analyze` + `flutter test` green, APK 빌드 artifact 계속 생성

---

## 4. 타겟 아키텍처

### 4-1. 레이어 뷰

```
┌───────────────────────────────────────────────────────────────┐
│ Presentation (screens, shells, cards)                         │
│   - child flow: hero / home / category hub / lesson play      │
│   - parent flow: overview / progress / mistakes / assets      │
├───────────────────────────────────────────────────────────────┤
│ Application / Play engine (state, session, rules)             │
│   - PlaySession · QuizController · LearnController            │
│   - RewardCoordinator · ProgressService                       │
├───────────────────────────────────────────────────────────────┤
│ Domain                                                         │
│   - Lesson · LessonItem · QuizItem · Choice · Reward          │
│   - QuizRuleSet · ProgressRecord                              │
├───────────────────────────────────────────────────────────────┤
│ Infrastructure / Services                                      │
│   - AudioService · ProgressStore · ContentLoader · Router      │
├───────────────────────────────────────────────────────────────┤
│ Assets (generated pipeline)                                   │
│   - manifest JSON · audio packs · image packs · theme tokens  │
└───────────────────────────────────────────────────────────────┘
```

### 4-2. 목표 디렉터리 구조

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── audio/                     [NEW]
│   │   ├── audio_service.dart
│   │   ├── audio_cue.dart
│   │   ├── audio_assets.dart
│   │   └── tts_fallback_audio_service.dart
│   ├── play/                      [NEW]
│   │   ├── play_session.dart
│   │   ├── play_feedback.dart
│   │   └── play_audio_policy.dart
│   ├── routing/                   [NEW]
│   │   ├── app_router.dart
│   │   └── routes.dart
│   ├── services/
│   │   ├── progress_store.dart    (확장)
│   │   ├── app_services.dart      (DI wiring)
│   │   └── speech_cue_service.dart → AudioService로 편입
│   ├── theme/                     [NEW]
│   │   ├── design_tokens.dart
│   │   ├── kid_theme.dart         (리팩터)
│   │   └── palette.dart
│   └── ui/
│       ├── play_shell.dart        [NEW]
│       ├── play_prompt_panel.dart [NEW]
│       ├── play_choice_card.dart  [NEW]
│       ├── play_reward_banner.dart[NEW]
│       ├── toy_button.dart        (토큰 기반 재구성)
│       └── toy_panel.dart         (토큰 기반 재구성)
├── features/
│   ├── lesson/                    [NEW — 제품 중심]
│   │   ├── domain/
│   │   │   ├── lesson_models.dart
│   │   │   ├── quiz_models.dart
│   │   │   └── quiz_rules.dart
│   │   ├── application/
│   │   │   ├── learn_controller.dart
│   │   │   └── quiz_controller.dart
│   │   ├── data/
│   │   │   ├── lesson_content_loader.dart
│   │   │   └── category_registry.dart
│   │   └── presentation/
│   │       ├── generic_learn_screen.dart
│   │       └── generic_quiz_screen.dart
│   ├── rewards/                   [NEW]
│   │   ├── domain/reward_models.dart
│   │   ├── application/reward_coordinator.dart
│   │   └── presentation/
│   │       ├── reward_banner.dart
│   │       └── collection_screen.dart
│   ├── parent/                    [NEW, avatar_setup 분해]
│   │   └── presentation/
│   │       ├── parent_home_screen.dart
│   │       ├── progress_section.dart
│   │       ├── unlock_section.dart
│   │       ├── mistakes_section.dart
│   │       ├── assets_section.dart
│   │       └── settings_section.dart
│   ├── alphabet/                  [얇은 adapter만 남김]
│   │   └── data/alphabet_category.dart
│   ├── hangul/                    [얇은 adapter만 남김]
│   ├── numbers/                   [얇은 adapter만 남김]
│   ├── hero/
│   └── home/
└── …
```

---

## 5. 공통 엔진 — 핵심 컨트랙트

### 5-1. Domain models (스케치)

```dart
// lib/features/lesson/domain/lesson_models.dart
class LessonCategory {
  final String id;                 // 'alphabet'
  final String label;              // '알파벳'
  final String manifestPath;       // 'assets/generated/manifest/alphabet_lessons.json'
  final CategoryThemeToken theme;  // palette/accent token
  final AudioPackId audioPack;     // 'alphabet_v1'
  final RewardPackId rewardPack;   // 'alphabet_sticker_v1'
}

class Lesson {
  final String id;
  final String title;
  final List<LessonItem> items;
}

class LessonItem {
  final String id;          // 'A'
  final String symbol;      // 'A a'
  final String label;       // '에이, A a'
  final String hint;
  final AudioCueRef promptAudio;
}

// lib/features/lesson/domain/quiz_models.dart
class QuizItem {
  final LessonItem target;
  final List<LessonItem> choices;   // 3~4
  final int correctIndex;
}

// lib/features/lesson/domain/quiz_rules.dart
class QuizRuleSet {
  final int choiceCount;            // alphabet: 4
  final int retryLimit;             // 2
  final AdvancePolicy advance;      // autoOnCorrect
  final ReplayPolicy replay;        // promptOnWrong
}
```

### 5-2. Controllers

```dart
// application/quiz_controller.dart
class QuizController extends ChangeNotifier {
  QuizController({
    required this.lesson,
    required this.rules,
    required this.audio,
    required this.progress,
    required this.reward,
  });
  // state: currentItem, wrongCount, phase (prompt|awaiting|correct|wrong|done)
  // actions: start(), select(index), replayPrompt(), next(), finish()
  // on select: grade → audio.cue(success|error) → progress.record → reward.evaluate
}
```

### 5-3. Category registry (category별 차이는 여기로만 흘러든다)

```dart
// data/category_registry.dart
final categoryRegistry = <String, LessonCategory>{
  'alphabet': LessonCategory(
    id: 'alphabet',
    label: '알파벳',
    manifestPath: 'assets/generated/manifest/alphabet_lessons.json',
    theme: CategoryThemeToken.alphabet,
    audioPack: AudioPackId('alphabet_v1'),
    rewardPack: RewardPackId('alphabet_sticker_v1'),
  ),
  // 'hangul': …, 'numbers': …
};
```

**Non-goal (1차 라운드):** 카테고리 runtime 추가, dynamic manifest download, 다국어 확장.

---

## 6. Audio system

### 6-1. 컨트랙트

```dart
abstract class AudioService {
  Future<void> play(AudioCue cue);
  Future<void> stop();
  bool get isMuted;
  set isMuted(bool value);
}

sealed class AudioCue {
  const AudioCue();
}
class PromptCue extends AudioCue { final AudioCueRef ref; }
class SuccessCue extends AudioCue { final AudioTone tone; }
class ErrorCue extends AudioCue {}
class RewardCue extends AudioCue { final RewardPackId pack; }
class IdleAttractCue extends AudioCue {}
class BgmCue extends AudioCue { final bool loop; }
```

### 6-2. 재생 정책 (`PlayAudioPolicy`)

| 이벤트 | 정책 |
|--------|------|
| 문제 로드 | PromptCue 1회 즉시 재생 |
| 오답 | ErrorCue → 짧은 delay → PromptCue 리플레이 (retryLimit 안에서만) |
| 정답 | SuccessCue → auto-advance |
| 레슨 완료 | RewardCue → reward banner 등장 |
| 아이들 attract | n초 idle 후 IdleAttractCue (옵션) |

### 6-3. Fallback 체인

recorded asset 존재 → 재생 / 없으면 → TTS speak(label) / 둘 다 실패 → 무음 + 시각 피드백만.

### 6-4. 테스트 가능성

- `FakeAudioService` 주입 → 어떤 cue가 어떤 순서로 요청됐는지 기록
- quiz_controller 테스트는 FakeAudioService 기반으로 시나리오 검증

---

## 7. Design tokens

```dart
// lib/app/theme/design_tokens.dart
abstract class Space {
  static const xs = 4.0;
  static const s = 8.0;
  static const m = 14.0;
  static const l = 20.0;
  static const xl = 28.0;
}
abstract class Radius {
  static const sm = 10.0;
  static const md = 18.0;
  static const lg = 28.0;
  static const pill = 999.0;
}
abstract class Motion {
  static const fast = Duration(milliseconds: 120);
  static const base = Duration(milliseconds: 220);
  static const slow = Duration(milliseconds: 420);
}
abstract class Opac {
  static const subtle = 0.58;
  static const muted = 0.76;
  static const strong = 0.94;
}
```

이행 규칙:
- **child-facing** 화면의 신규/수정 코드는 magic number 금지 → 토큰 경유만 허용
- existing 매직넘버는 Phase 별로 점진 마이그레이션 (한 번에 전부 바꾸지 않음)

---

## 8. Routing

### 8-1. 선택지

- Option A: `go_router` 도입 (deep link/replay 유리)
- Option B: named routes + 자체 `AppRouter` 랩퍼 (의존성 최소)

**권장:** 1차는 **Option B** — 의존성 늘리지 않고 최소한의 중앙화부터. 3카테고리 마이그레이션 이후 B→A 승격 여지는 열어둠.

### 8-2. Route map (초안)

| name | path (논리) | shell |
|------|-------------|-------|
| `hero` | `/` | HeroScreen |
| `home` | `/home` | HomeScreen |
| `category` | `/category/:id` | CategoryHubScreen |
| `lessonPicker` | `/category/:id/lessons` | LessonPickerScreen |
| `learn` | `/category/:id/lesson/:lid/learn` | GenericLearnScreen |
| `quiz` | `/category/:id/lesson/:lid/quiz` | GenericQuizScreen |
| `reward` | `/category/:id/lesson/:lid/reward` | RewardBannerScreen |
| `parent` | `/parent` | ParentHomeScreen (hidden 진입) |
| `parentSection` | `/parent/:section` | `progress` / `unlock` / `mistakes` / `assets` / `settings` |

### 8-3. Hidden 진입 UX

- hero 얼굴 5회 탭 → 3초 confirm overlay → 성공 피드백 → `parent` 진입
- accidental tap 방지: 2초 cool-down, 탭 간격 너무 빠르면 count 초기화

---

## 9. Reward loop

### 9-1. Domain

```dart
class Reward {
  final String id;              // 'alphabet_sticker_A'
  final RewardPackId pack;
  final String label;           // '알파벳 A 스티커'
  final RewardVisual visual;    // emoji/placeholder/imageRef
}
class RewardEvent {
  final DateTime at;
  final Reward reward;
  final String lessonId;
}
```

### 9-2. Coordinator

- quiz_controller.finish() → RewardCoordinator.evaluate(lesson, score)
- 획득 시 ProgressStore에 event 기록 + 최근 획득 reward snapshot 갱신
- completion 화면 진입 시 RewardBanner 애니메이션 (appear → wiggle → settle)

### 9-3. Collection screen (MVP)

- v1: 카테고리별 reward grid (unlocked/locked 구분)
- 폭죽/캐릭터 풀 애니메이션은 v1 이후

---

## 10. Parent layer 분해

현재 `avatar_setup_screen.dart` 1152~1338 LOC 단일 파일 → 다음 섹션으로 분해:

| 섹션 | 위치 | 핵심 기능 |
|------|------|-----------|
| Overview | `parent_home_screen.dart` | 현재 아이 상태 요약, 각 섹션으로 진입 |
| Progress | `progress_section.dart` | 카테고리별 진도/최근 활동 |
| Unlock | `unlock_section.dart` | 수동 레슨 해금 (기존 feat `manual lesson unlock flow` 흡수) |
| Mistakes | `mistakes_section.dart` | 최근 오답 재도전 (`recent mistake replay flow` 흡수) |
| Assets | `assets_section.dart` | 아바타/자산 편집 |
| Settings | `settings_section.dart` | 음소거/쿨타임/언어 등 |

공통 원칙:
- child flow 색조/타이포와 **시각적으로 구분** (운영도구 톤)
- 섹션 간 네비게이션은 라우팅 레이어 경유

---

## 11. Asset / audio content 파이프라인

v1 스코프:
- `asset_register.csv` 확장 — (category, item, kind, path, status) 컬럼
- `scripts/` 아래 manifest 검증/생성 스크립트 유지
- 이미지는 placeholder shape → 실자산 교체 여지 남김
- 오디오는 `assets/generated/audio/voice/prompts/<category>/<id>.mp3` 규칙 예약. 실제 녹음은 **별도 트랙(이 문서 범위 밖)**, 코드는 TTS fallback으로 동작

Non-goal(1차 라운드): 모든 일러스트 최종본, 모든 음성 녹음 완료, BGM 라이선스 확보.

---

## 12. Phase 계획 (alphabet-first 기준)

각 Phase는 독립 검증 가능 단위로 commit/push, `flutter analyze` + `flutter test` green 유지.

### Phase 0 — Baseline 안정화
- `numbers_lessons.json` manifest ↔ `numbers_lesson_repository_test.dart` 계약 불일치 정리 (현재 test FAIL 원인)
- 현재 branch별 참고 포인트 문서화 스냅샷
- **Exit:** `flutter test` green, APK 빌드 성공

### Phase 1 — Foundation: design tokens + routing + audio 추상화
- `app/theme/design_tokens.dart`
- `app/routing/app_router.dart` + 기존 `Navigator.push` 지점 최소 침습으로 점진 이동
- `app/audio/audio_service.dart` + `TtsFallbackAudioService` (기존 `speech_cue_service` 편입)
- **Exit:** child flow 진입 경로가 모두 Router 경유, 토큰/AudioService 계약 확정

### Phase 2 — Common engine 추출 (alphabet-driven)
- `features/lesson/domain/*`, `features/lesson/application/*`, `features/lesson/data/*`
- `generic_learn_screen` + `generic_quiz_screen`
- **alphabet**만 먼저 generic 엔진에 붙이기 (hangul/numbers는 기존 복붙 경로 유지)
- **Exit:** alphabet 카테고리가 generic 엔진으로 완전히 동작, 동일 수준 위젯 테스트 통과

### Phase 3 — Child UX: alphabet reference 완성
- audio-first prompt, choice card 공통, 오답 shake + replay, 정답 flash + auto-advance
- `ui/play_shell.dart` 완성, compact landscape 기준 golden/geometry test
- **Exit:** 글자 없이도 alphabet quiz 루프를 이해 가능

### Phase 4 — Reward loop 실체화
- `features/rewards/*` 전체
- ProgressStore에 RewardEvent 기록, completion 시 banner
- collection screen MVP
- **Exit:** alphabet 레슨 완료 시 실제 획득한 reward가 수집 화면에서 보임

### Phase 5 — Horizontal expansion: hangul + numbers 마이그레이션
- `hangul`/`numbers`의 learn/quiz 화면을 generic 엔진으로 이전
- 기존 `*_learn_screen.dart` / `*_quiz_screen.dart` 삭제
- repository → `lesson_content_loader` 경유
- **Exit:** 3카테고리 모두 generic engine 기반, 중복 LOC < 200

### Phase 6 — Parent 레이어 분해
- `avatar_setup_screen.dart` 분해 → `features/parent/*`
- hidden 진입 쿨다운/피드백 재설계
- **Exit:** parent 단일 파일 < 300 LOC, 섹션별 라우트 동작

### Phase 7 — Design polish & test 보강
- 남은 매직넘버 토큰화
- domain rule 단위 테스트 (채점/진도/보상) 커버리지 확보
- compact landscape 회귀 golden 재정비
- **Exit:** `flutter analyze`/`flutter test` green, 키포인트 성공 기준(§3) 모두 충족

### Phase 8 (옵션) — 실 자산/음성 트랙 병합
- 별도 트랙으로 진행된 녹음/이미지 자산 합류
- 이 라운드에서 반드시 완료할 필요는 없음

---

## 13. 변경·생성 파일 맵

### 반드시 수정
- `lib/app/app.dart`
- `lib/app/services/progress_store.dart`
- `lib/app/services/speech_cue_service.dart` (→ AudioService로 편입)
- `lib/app/ui/*` (토큰 기반 재구성)
- `lib/features/hero/presentation/hero_screen.dart`
- `lib/features/home/presentation/*`
- `lib/features/avatar/presentation/avatar_setup_screen.dart` (분해)
- `lib/features/alphabet/**` (얇은 어댑터만 남기고 축소)
- `lib/features/hangul/**` / `lib/features/numbers/**` (Phase 5에서 축소)
- `assets/public/manifest/*`, `assets/generated/manifest/*`
- `test/**` (도메인 단위 테스트 층 추가)

### 신규 생성
- `lib/app/audio/*`
- `lib/app/play/*`
- `lib/app/routing/*`
- `lib/app/theme/design_tokens.dart`
- `lib/features/lesson/**`
- `lib/features/rewards/**`
- `lib/features/parent/**`

### 삭제 후보 (Phase 5 이후)
- `lib/features/hangul/presentation/hangul_learn_screen.dart`
- `lib/features/hangul/presentation/hangul_quiz_screen.dart`
- `lib/features/alphabet/presentation/alphabet_learn_screen.dart`
- `lib/features/alphabet/presentation/alphabet_quiz_screen.dart`
- `lib/features/numbers/presentation/numbers_learn_screen.dart`
- `lib/features/numbers/presentation/numbers_quiz_screen.dart`
- category별 repository 3종 (content_loader로 일원화)

---

## 14. 레퍼런스 branch 흡수 정책

| Branch | 흡수할 것 | 버릴 것 |
|--------|-----------|---------|
| `origin/claude/review-main-branch-0UMTv` | 문제 정의 문서(`26.417_review.md`) | 코드 변경 없음 |
| `origin/feature/ui-redesign-v2` | play background 톤, home/category/hero 시각 방향, APK workflow 유지 | hangul-only 부분 완성 상태를 최종안으로 오인하지 말 것 |
| `origin/claude/review-handoff-status-Rd9py` | audio-first 레이아웃 아이디어, Tayo blue 강조 컬러, `TtsService` 분리 감각 | 1개 화면에 국한된 구현을 전체 해법으로 삼지 말 것 |

---

## 15. 검증 전략

모든 phase에서 아래 4가지를 유지:

1. `/home/openc/sdk/flutter/bin/flutter analyze` → green
2. `/home/openc/sdk/flutter/bin/flutter test` → green
3. `/home/openc/sdk/flutter/bin/flutter build apk --release --target-platform android-arm64` → artifact 생성
4. compact landscape 회귀 위젯 테스트

신규 테스트 층:
- `test/features/lesson/domain/quiz_rules_test.dart` — 채점/리플레이/advance 규칙 단위
- `test/features/lesson/application/quiz_controller_test.dart` — FakeAudioService 기반 시나리오
- `test/features/rewards/application/reward_coordinator_test.dart`
- `test/app/audio/audio_policy_test.dart`

---

## 16. 아직 확정 안 된 항목 (다음 미팅에서 확정)

discovery 문서의 5개 질문 중 이번 요청에서 확정된 것: 카테고리 유지(D4), alphabet 우선(D3). 남은 질문:

1. **시각 컨셉** — 기존 garage/car 톤 유지 vs 캐릭터/놀이감 톤으로 재해석
2. **오디오 범위** — TTS fallback만 vs 최소 녹음 음성 + SFX vs 음성 + SFX + BGM 전부
3. **parent 성격** — 운영 도구로 최소화 vs 컨텐츠 관리 콘솔로 확장
4. **라우팅 전환 시점** — Phase 1에서 Option B로 시작한 뒤, Option A(go_router) 승격 시점을 언제로 잡을지
5. **reward 시각 에셋 전략** — 이모지/placeholder로 v1 출시 vs 일러스트 트랙 완료 후 출시

---

## 17. 즉시 착수 가능한 Phase 0 작업 목록

> Phase 0는 비교적 안전해서 별도 승인 없이도 착수 가능하지만, 이 문서는 planning이므로 **사용자 go-ahead 후** 구현 들어간다.

- [ ] `test/features/numbers/data/numbers_lesson_repository_test.dart` 실패 원인 분석 및 계약 재정의
- [ ] `assets/public/manifest/numbers_lessons.json` / `assets/generated/manifest/numbers_lessons.json` 동기화
- [ ] `flutter test` green 확인
- [ ] 이 문서를 `claude/product-overhaul` 브랜치에 commit
- [ ] Phase 1 착수 전 §16의 2~3개 질문 최소 확정

---

## 18. 요약 한 장

> “3카테고리 복붙을 공통 엔진으로 뽑고, 그 엔진을 알파벳에서 먼저 완성한다. 그 위에 토큰 기반 디자인 시스템 · 오디오 퍼스트 큐 · 실제 리워드 루프 · 중앙 라우팅 · 분해된 parent console 을 쌓은 뒤, hangul/numbers를 얇은 어댑터로 떨어뜨려 수평 확장한다.”
