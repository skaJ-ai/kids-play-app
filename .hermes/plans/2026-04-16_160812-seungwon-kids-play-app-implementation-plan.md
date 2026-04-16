# 승원이의 빵빵 놀이터 Implementation Plan

> For Hermes: planning and scaffolding should proceed in small pushable units. Keep placeholder assets in git, private assets outside git or under ignored local overrides.

작성 시각: 2026-04-16 16:08 KST
저장 목적: 요구사항이 거의 고정된 상태에서 실제 구현을 위한 구조/순서/검증 기준을 명확히 잡는다.

## Goal

갤럭시 S24를 포함한 안드로이드 폰/태블릿에서 가로모드 고정으로 동작하는, 27개월 아이용 오프라인 학습 앱을 만든다.
앱 이름은 `승원이의 빵빵 놀이터`이며, 한글/알파벳/숫자 카테고리를 제공하고, 학습 모드와 게임 모드를 분리한다.
조작은 탭 중심으로 극단적으로 단순해야 하며, 나중에 콘텐츠를 쉽게 추가할 수 있는 구조가 핵심이다.

## Locked decisions

### Product / UX
- 대상: 27개월 남자아이
- 핵심 목표: 글자와 숫자에 친숙해지기
- 사용 방식: 아이 혼자 주 사용, 가끔 보호자 지도
- 한 화면 버튼 수는 매우 제한적으로 유지
- 드래그/슬라이드 없음, 탭만 사용
- 뒤로/종료/복잡한 메뉴는 일반 화면에서 숨김
- 가로모드 고정
- immersive full-screen 2단계 전략 사용
- 오프라인 전용 / 로그인 없음 / 광고 없음 / 개인정보 기능 없음

### Learning content
- 카테고리: 한글 / 알파벳 / 숫자
- 홈 구조: 첫 화면에서 카테고리 선택, 카테고리 내부에서 학습/게임 분리
- 한글 우선순위가 가장 높음
- 한글 레벨 순서:
  1. 기본 자음
  2. 기본 모음
  3. 쌍자음
  4. 복모음
  5. 음절
- 자음 음성: `기역, ㄱ` 형태
- 모음은 입모양/혀 위치 느낌의 설명 필요
- 알파벳은 대소문자 함께 제시
- 알파벳 음성은 letter name 기준
- 숫자는 학습 카드보다 게임형 수학 개념 위주
- 숫자 1차 범위는 1~10 안에서 시작
- 숫자 단계: 그림 중심 → 그림+식 → 숫자식 중심

### Game rules
- 첫 버전부터 4지선다 고정
- 세트당 5문제
- 정답 후 자동 다음 문제 이동
- 오답 시 화면 흔들림 + X 표시
- 세트 종료 시 폭죽/반짝이 + 자동차 스티커 1개 지급
- 패널티/시간 제한/목숨 없음
- 레벨 해금: 80% 이상 맞으면 자동 해금 + 보호자 메뉴 수동 변경 가능

### Visual / audio
- 자동차/타요 감성
- 파스텔 톤
- 히어로 인트로 3~4초 권장
- 아이 얼굴은 인트로 + 홈 대표 캐릭터에 사용
- 얼굴 합성은 컷아웃/스티커 느낌으로 정리
- 음성 필수, 여성 톤 선호
- 한글 세트/알파벳 세트 내 음성 톤 일관 유지
- 효과음은 풍성한 게임 스타일
- 배경음악은 학습/게임 중 계속 재생

### Parent mode
- 진입: 특정 아이콘 5번 탭
- 제공 기능:
  - 진도 바꾸기
  - 틀린 것만 다시 5문제
  - 카테고리별 헷갈리는 항목 보기
  - 앱 종료

### Repo / asset strategy
- GitHub repo is private
- Flutter로 구현
- placeholder 자산은 git에 커밋
- 실제 얼굴/민감 자산/교체 예정 자산은 gitignore 경로 또는 repo 밖에서 관리
- 자세한 내용은 `docs/asset-pipeline.md`

## Recommended tech stack

### App framework
- Flutter

### State management
- flutter_riverpod

### Data/content modeling
- json_annotation
- json_serializable
- build_runner

### Audio
- audioplayers

### Animation / reward effects
- flutter_animate
- confetti

### Local persistence
- isar
- 필요 시 간단한 설정값은 shared_preferences

### Optional helper packages
- path_provider
- collection
- freezed (모델이 커질 경우)

## Why Flutter fits this app

- Android APK 빌드가 쉬움
- 폰/태블릿 대응이 쉬움
- landscape lock / immersive full-screen 처리가 단순함
- 오프라인 asset 중심 앱에 적합함
- 카드/퀴즈/애니메이션 UI를 빠르게 만들 수 있음
- 나중에 콘텐츠 팩 구조로 확장하기 좋음

## Environment findings on this machine

현재 작업 머신에서 확인한 결과:
- `flutter` not installed
- `java` not installed

즉, 실제 앱 스캐폴딩 전에 로컬 개발 환경 준비 단계가 필요하다.

## Proposed repo structure

```text
kids-play-app/
  .hermes/
    plans/
      ...

  docs/
    asset-pipeline.md

  scripts/
    prepare_assets.sh

  assets/
    public/
      images/
      audio/
      manifest/
    local_private/
    generated/

  lib/
    app/
      app.dart
      routes.dart
      theme/
        app_theme.dart
      shell/
        immersive_shell.dart

    core/
      constants/
        app_constants.dart
      models/
      utils/

    data/
      content/
        models/
        repositories/
        sources/
      progress/
        models/
        repositories/
      audio/
        audio_service.dart

    features/
      hero/
        presentation/
      home/
        presentation/
      categories/
        hangul/
        alphabet/
        numbers/
      parent/
        presentation/
      rewards/
        presentation/

    main.dart

  test/
    smoke/
    features/
```

## Core architecture principles

1. Content is data-driven
- 화면이 하드코딩된 문항 목록을 직접 가지지 않는다.
- 카테고리/레벨/문항/오디오/이미지는 JSON + asset registry 기반으로 읽는다.

2. Stable IDs everywhere
- 모든 카테고리/레벨/문항/선택지는 string id를 가진다.
- 진도 저장도 index가 아니라 id 기준으로 한다.

3. Placeholder-first repo
- 실제 얼굴/최종 BGM/최종 음성이 없어도 앱은 실행 가능해야 한다.

4. Audio channels separated
- BGM, voice prompt, SFX를 분리 플레이어로 관리한다.

5. Tap-first interaction
- 모든 문제 풀이는 탭만으로 해결 가능해야 한다.

## Data model design

### Content pack top level

```json
{
  "packId": "hangul",
  "title": "한글",
  "levels": ["hangul-consonants-1", "hangul-vowels-1"]
}
```

### Level manifest example

```json
{
  "id": "hangul-consonants-1",
  "category": "hangul",
  "mode": "learn_and_quiz",
  "title": "자음 1단계",
  "unlockRule": {
    "type": "score_threshold",
    "value": 0.8
  },
  "items": [
    {
      "id": "hangul-giyeok",
      "label": "ㄱ",
      "displayText": "기역, ㄱ",
      "imageAsset": "images/hangul/giyeok_card.webp",
      "audioAsset": "audio/voice/hangul/giyeok.ogg",
      "hintAsset": "images/hangul/giyeok_mouth.webp"
    }
  ]
}
```

### Quiz item example

```json
{
  "questionId": "q-hangul-giyeok-01",
  "promptAudio": "audio/voice/hangul/giyeok.ogg",
  "questionType": "listen_and_choose",
  "options": [
    "hangul-giyeok",
    "hangul-nieun",
    "hangul-digeut",
    "hangul-rieul"
  ],
  "correctOptionId": "hangul-giyeok"
}
```

### Progress entities
- category progress
- level unlock state
- recent sessions
- wrong-answer counters per item
- confusing-items summary per category
- sticker inventory

## Feature plan

### Phase 0 — local environment bootstrap

Objective:
로컬 머신에 Flutter Android 개발 환경을 준비한다.

Deliverables:
- Flutter SDK 설치
- Java 17 설치
- Android SDK/command-line tools 설치
- `flutter doctor` green 또는 actionable yellow 수준 확보

Validation:
- `flutter --version`
- `flutter doctor`
- `java -version`

### Phase 1 — app bootstrap

Objective:
repo 안에 Flutter 앱 기본 골격을 만든다.

Files likely to create:
- `pubspec.yaml`
- `lib/main.dart`
- `android/`
- `test/`

Key setup:
- landscape lock
- immersive sticky mode
- base theme
- route skeleton

Validation:
- `flutter run`
- `flutter test`
- basic Android debug launch

### Phase 2 — asset pipeline skeleton

Objective:
placeholder-first asset structure와 generated asset merge 흐름을 만든다.

Files likely to create:
- `.gitignore`
- `scripts/prepare_assets.sh`
- `assets/public/...`
- `assets/local_private/.keep`
- `assets/generated/.keep`
- `asset_sources/README.md`
- `assets/public/manifest/asset_register.csv`

Validation:
- prepare script 실행
- generated assets로 앱 실행 가능

### Phase 3 — content schema + repositories

Objective:
카테고리/레벨/문항을 JSON으로 읽는 구조를 만든다.

Files likely to create:
- `lib/data/content/models/...`
- `lib/data/content/repositories/content_repository.dart`
- `lib/data/content/sources/asset_content_source.dart`
- sample JSON packs under `assets/public/content/`

Validation:
- unit tests for JSON parsing
- app start 시 sample categories 로드 확인

### Phase 4 — hero + home shell

Objective:
인트로/홈/카테고리 진입 뼈대를 만든다.

Features:
- 3~4초 hero intro
- 자동차가 지나가는 느낌
- 얼굴 합성 placeholder 구조
- 플레이하기 버튼
- 카테고리 선택 화면

Validation:
- 앱 시작 → 히어로 → 홈 진입
- 가로모드 고정 확인
- immersive mode 유지 확인

### Phase 5 — Hangul vertical slice

Objective:
한글 1단계(기본 자음) 학습 카드 + 4지선다 퀴즈를 end-to-end로 완성한다.

Features:
- 카드 화면
- 탭 시 음성 재생
- 입모양 설명 영역 placeholder
- listen-and-choose quiz
- 5문제 세트
- 오답/정답/세트 완료 피드백

Validation:
- sample 자음 4~6개로 playable flow 확인
- wrong-answer tracking 저장 확인
- sticker reward 저장 확인

### Phase 6 — Alphabet vertical slice

Objective:
알파벳 대소문자 통합 카드 + 듣고 맞히기 퀴즈를 만든다.

Features:
- A/a 형태 카드
- letter-name 음성
- mixed uppercase/lowercase options

Validation:
- sample letters playable
- BGM/voice/SFX 동시 동작 검증

### Phase 7 — Numbers vertical slice

Objective:
자동차 그림 기반 숫자 게임을 만든다.

Features:
- 그림 개수 비교
- 1~10 범위 덧셈/뺄셈 기초
- 후속 확장을 위한 question type 설계

Validation:
- 숫자 게임 1세트 playable
- 숫자 단계 JSON 구조가 확장 가능한지 확인

### Phase 8 — parent mode

Objective:
보호자 메뉴와 진도/오답 복습 기능을 추가한다.

Features:
- hidden entry via 5 taps
- level override
- retry wrong 5
- confusing items summary
- app exit

Validation:
- 진도 변경 즉시 반영
- 오답 5문제 생성 및 실행

### Phase 9 — polish + release pipeline

Objective:
실기기 테스트와 APK 배포 흐름을 완성한다.

Features:
- touch target / text scale 점검
- S24 + tablet 레이아웃 확인
- signed release APK build
- sideload install guide

Validation:
- `flutter build apk --release`
- 기기 설치 및 첫 실행 검증

## Package recommendations by concern

### Orientation / immersive
- Flutter SDK `SystemChrome`
- AndroidManifest에서 landscape 관련 설정 보강

### Audio strategy
- player 1: looping BGM
- player 2: voice prompt / item audio
- player 3+: SFX

Recommended behavior:
- 음성 재생 시 BGM 볼륨 살짝 duck
- 효과음은 짧고 경쾌하게

### Persistence strategy
Use Isar collections for:
- `LevelProgress`
- `ItemPerformance`
- `StickerReward`
- `SessionSummary`

Use simple settings store for:
- BGM on/off
- SFX on/off
- intro skip flag (if later added)

## APK distribution strategy

개인 설치용 APK 기준 권장 흐름:

1. release keystore 생성
2. Flutter release signing 설정
3. `flutter build apk --release`
4. 초기에는 universal APK 사용
5. 이후 용량이 커지면 ABI split 검토

Why universal first:
- S24 + 기타 폰/태블릿 설치가 가장 단순
- 개인용 배포에 적합

## Risks / tradeoffs

1. Environment not ready yet
- 현재 머신에 Flutter/Java가 없어 바로 스캐폴딩 불가

2. Private assets inside APK are extractable
- git에서 분리해도 APK 배포 시에는 추출 가능
- trusted family build 전제로 관리 필요

3. BGM/voice licensing complexity
- placeholder-first 구조가 꼭 필요

4. Real-face hero can look awkward
- 얼굴 크롭/배경제거/톤 정리가 중요
- 일단 placeholder로 구조를 먼저 만들고 교체 추천

## Immediate next actions

### Recommended next push sequence

1. docs push
- asset pipeline doc
- implementation plan doc

2. bootstrap infra push
- .gitignore
- asset folder skeleton
- prepare_assets.sh
- README update

3. environment setup guide push
- docs/local-dev-setup.md

4. Flutter scaffold push
- once Flutter/Java available

## Verification checklist before coding content-heavy screens

- [ ] Flutter installed
- [ ] Java installed
- [ ] flutter doctor usable
- [ ] repo asset skeleton committed
- [ ] placeholder assets available
- [ ] JSON schema agreed
- [ ] first playable vertical slice scope fixed

## Suggested first playable slice

The first true milestone should be:
- hero intro
- home category selection
- Hangul basic consonant card mode
- Hangul 5-question quiz set
- sticker reward on set completion
- parent menu with wrong-answer replay stub

이렇게 하면 가장 중요한 한글 UX를 빨리 실기기에서 검증할 수 있다.
