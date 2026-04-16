# handoff.md

## 1) 최초 사용자 프롬프트(원문)

> 27개월 남자아기가 사용할 학습용 앱을 만들려고 해. 갤럭시 s24에서 사용할 앱이고 가로모드가 디폴트였으면 좋겠어. 플레이스토어로 등록하지 않고 개인용으로 쓰도록 apk 만들면될 것 같아. 학습 컨텐츠는 한글과 알파벳, 숫자로 총 3가지야. 일단 내가 준 배경설명에서 부족한 것들에 대해 여러가지 물어봐. 계획이 구체적일수록 내가 원하는대로 만들 수 있을테니

이 프롬프트 이후 여러 차례 인터뷰/질의응답을 통해 아래 요구사항이 확정되거나 선호로 드러남.

---

## 2) 프로젝트 한 줄 요약

27개월 남자아이를 위한 가로모드 고정 안드로이드 오프라인 학습 앱 `승원이의 빵빵 놀이터`를 만든다. 카테고리는 한글 / 알파벳 / 숫자이며, 탭만으로 조작 가능하고, 개인 설치용 APK로 배포한다.

---

## 3) 제품/사용 환경 핵심 요구사항

### 대상 사용자
- 27개월 남자아이
- 혼자 주로 사용, 가끔 보호자 지도
- 조작 복잡도는 극단적으로 낮아야 함

### 플랫폼 / 배포
- Android APK 개인 설치용
- Play Store 등록하지 않음
- Galaxy S24 우선 타깃
- 다른 안드로이드 폰/태블릿도 고려
- 가로모드 기본 / 사실상 고정
- immersive full-screen 선호
- 오프라인 전용
- 로그인 / 광고 / 개인정보 기능 없음

### 조작 UX
- 탭만 사용
- 드래그 / 슬라이드 없음
- 일반 화면에서 뒤로가기 / 종료 / 복잡한 메뉴는 숨김
- 한 화면에 버튼은 1~2개 수준으로 단순화하는 방향 선호
- 정답 후 자동으로 다음 문제로 이동
- 시간 제한 / 패널티 / 목숨 시스템 없음

---

## 4) 앱 구조 / IA

### 메인 구조
- 첫 화면에서 카테고리 선택
  - 한글
  - 알파벳
  - 숫자
- 각 카테고리 안에서
  - 학습하기
  - 게임하기
 2개 모드로 분리

### 히어로/인트로
- 앱 이름: `승원이의 빵빵 놀이터`
- 자동차가 달리는 느낌의 진입 연출 선호
- 히어로 인트로 길이는 3~4초가 적절하다고 합의됨
- 인트로 뒤에 로고 / 플레이 버튼 노출

---

## 5) 비주얼 / 브랜딩 / 감성 선호

### 기본 선호
- 파스텔 톤
- 자동차 / 타요 감성
- 심플하지만 아기자기해야 함
- 유아용 앱답게 친근해야 함

### 캐릭터/개인화
- 실제 아이 얼굴 사진을 캐릭터처럼 활용하고 싶어함
- 얼굴은 컷아웃 / 스티커 느낌으로 정리하는 방향
- 사용 범위는 최종적으로
  - 인트로
  - 홈 대표 캐릭터
  정도가 적절하다고 결정됨

### 참고 / 레퍼런스
- 참고 앱: `별별한글`
- 별별한글에서 특히 참고하고 싶다고 한 요소
  - 카드 디자인
  - 음성 톤

### 사용자 불만(매우 중요)
가장 최근 피드백:
- 현재 구현된 UI를 보고 사용자가 “디자인, ui ux가 거의 대학교 1학년생 작품인데?”라고 평가함
- 즉, 현재 프로토타입 수준의 generic Flutter/Material 화면은 절대 만족하지 않음
- 앞으로의 최우선 과제는 기능 추가보다 `완성도 높은 kid-friendly production-quality UI/UX 리디자인`임
- 싸구려 프로토타입 느낌, 샘플앱 느낌, 기본 Material 느낌을 강하게 싫어함

이건 현재 가장 중요한 선호사항이다.

---

## 6) 사운드 / 음성 요구사항

- 음성은 반드시 필요
- 여성 목소리 선호
- 한글 세트 / 알파벳 세트 내 음성 톤 일관성 중요
- 효과음은 풍성한 게임 스타일 선호
- 배경음악은 학습/게임 중 계속 재생되길 원함
- 실제 동요 기반 BGM 10곡 정도 구성을 희망한 적 있음
- 숫자 영역에서는 숫자 낭독보다 문제 안내 음성이 더 중요하다고 함

---

## 7) 학습 콘텐츠 요구사항 상세

### 7-1. 한글 (최우선)
가장 우선순위가 높은 카테고리.

확정/선호 사항:
- 1차는 자음 / 모음 중심
- 쌍자음 / 복모음은 후반 레벨
- 음절은 더 뒤 레벨에서 도입
- 자음 음성은 `기역, ㄱ`처럼 이름 + 글자를 같이 제시
- 모음은 입모양 / 혀 위치 느낌을 시각적으로 설명하는 방향 선호
- 학습 순서:
  1. 기본 자음
  2. 기본 모음
  3. 쌍자음
  4. 복모음
  5. 음절
- 게임은 처음부터 4지선다
- 큰 카드 + 탭 중심 + 소리 듣고 맞히기 형태 선호

권장 레벨 구조로 정리된 내용:
- Level 1: 기본 자음 14
- Level 2: 기본 모음 10
- Level 3: 쌍자음 5
- Level 4: 복모음 11
- Level 5+: 쉬운 음절

### 7-2. 알파벳
확정/선호 사항:
- 대문자 / 소문자 함께 제시
- 퀴즈는 대소문자 섞어서 출제
- 음성은 letter name 기준
- 대/소문자 구분 없이 같은 소리로 읽음 (예: A/a 모두 에이)
- 1단계는 소리 듣고 글자 맞히기
- 이후 확장 가능 항목:
  - 대문자 보고 소문자 찾기
  - 소문자 보고 대문자 찾기
  - 짝맞추기
- 단어 연결은 다음 단계로 미룸

### 7-3. 숫자 / 수학
확정/선호 사항:
- 숫자 학습 카드 자체는 생략 가능
- 바로 게임형 수학 개념으로 진입
- 다루고 싶은 개념:
  - 개수 세기
  - 순서 맞추기
  - 크다/작다
  - 간단한 부등호
  - 덧셈/뺄셈
- 숫자 1차 범위는 1~10
- 개수 비교는 20개 이하
- 숫자 비교는 단계적으로 3자리 수까지 확장 가능
- 전개 방향:
  - 그림 중심
  - 그림 + 식
  - 숫자식 중심

---

## 8) 게임 UX / 보상 요구사항

- 기본 문제 형식은 4지선다
- 맞히면 축하 연출 선호
- 틀리면 흔들림 / X표시 선호
- 세트 완료 시 폭죽 / 반짝이 연출 선호
- 자동차 스티커 보상 원함
- 매 문제보다 세트 단위 보상/연출을 더 선호

초기 합의된 기본 규칙:
- 세트당 5문제
- 세트 종료 후 자동차 스티커 1개 지급
- 레벨 해금은 80% 이상 정답 시 자동 해금 + 보호자 수동 변경 가능

---

## 9) 보호자 기능 요구사항

보호자 메뉴 진입 방식:
- 특정 아이콘 5번 탭

보호자 메뉴에서 원하는 기능:
- 진도 바꾸기
- 틀린 것만 다시 5문제
- 카테고리별 헷갈리는 항목 보기
- 앱 종료

추가로 있으면 좋다고 정리된 항목:
- 레벨 잠금/해제
- 볼륨 토글(후순위)

---

## 10) 자산 / IP 관련 인터뷰 내용

사용자가 원한 것:
- 타요 캐릭터/이미지/분위기 사용 희망
- 실제 동요 기반 BGM 사용 희망
- 실제 아이 얼굴 사진을 앱 캐릭터 일부로 사용

현재 구현/설계 상 원칙:
- 실제 민감 자산은 git에 올리지 않고 local/private 자산으로 관리
- placeholder 자산과 private 자산을 분리하는 구조를 채택
- 나중에 교체 가능한 구조로 설계

중요 메모:
- 사용자는 개인 소장용이라 저작권 이슈가 실질적으로 없다고 보는 경향을 보였음
- 하지만 다음 LLM/작업자는 실제 구현·배포·보관 관점에서 리스크를 별도로 판단해야 함

---

## 11) 기술 스택 / 아키텍처 관련 인터뷰 결과

최종 기술 선택:
- Flutter

선정 이유:
- Android APK 제작 용이
- landscape lock / immersive full-screen 대응 쉬움
- 오프라인 asset 앱에 적합
- 폰/태블릿 대응 수월
- JSON 기반 콘텐츠 확장 구조 만들기 좋음

아키텍처 방향:
- 콘텐츠는 data-driven
- category / level / question / reward / audio / image 를 JSON + asset registry 기반으로 관리
- 진도/오답/헷갈림 통계는 로컬 저장소 기반
- placeholder-first 구조 유지

---

## 12) 레포 / 자산 구조 관련 합의 내용

레포:
- GitHub private repo
- 원격: `git@github.com:skaJ-ai/kids-play-app.git`
- 로컬 경로: `/home/openc/kids-play-app`

자산 구조:
- `assets/public`
- `assets/local_private`
- `assets/generated`
- `asset_sources/private`
- `asset_sources/licensed`

정책:
- placeholder 자산은 git에 커밋
- 실제 얼굴/민감 자산/교체 예정 자산은 local_private 등 gitignore 영역 관리
- 코드에서는 generated 기준으로 읽음
- `scripts/prepare_assets.sh` 로 public + local_private -> generated 병합

실제 개인 자산 예:
- `/home/openc/kids-play-app/assets/local_private/images/hero/hero_face.png`

---

## 13) 인터뷰를 통해 고정된 구현/운영 방향

### 앱 운영
- 작은 단위로 커밋/푸시하면서 진행
- 사용자는 Telegram만으로 주로 확인/지시함
- APK를 직접 내려받거나 GitHub에서 다운로드해서 실기기 테스트함

### 구현 우선순위
- 한글이 1순위
- 그 다음 알파벳 / 숫자
- 최근 사용자 피드백 기준으로는 이제 기능 추가보다 UI/UX 리디자인 우선

### 지금 절대 놓치면 안 되는 사용자 기대치
- “애가 눌러보고 싶게 생긴” 화면이어야 함
- generic한 Flutter demo, 대학 과제 느낌이면 실패
- production-quality, polished, kid-friendly visual system이 필요함

---

## 14) 현재까지 구현된 것(다른 LLM이 알면 좋은 현재 상태)

이미 push된 주요 진행:
- repo bootstrap / 문서화 / asset pipeline 정리
- Flutter Android 앱 스캐폴드 생성
- landscape lock / immersive 설정
- hero / home / category hub 기본 흐름
- 한글 레슨 JSON 기반 구조
- 한글 학습 카드 흐름
- 한글 4지선다 퀴즈 5문제 세트
- compact landscape에서 4지선다 4개가 모두 보이도록 수정
- arm64 release APK 산출 및 GitHub deliverables에 업로드

현재 GitHub 최신 커밋(작성 시점 확인값):
- `4854bd0` fix: make hangul quiz fit compact landscape screens

다운로드 가능한 APK:
- 로컬: `/home/openc/kids-play-app/deliverables/kids-play-app-arm64-v8a-release.apk`
- GitHub: `https://github.com/skaJ-ai/kids-play-app/blob/main/deliverables/kids-play-app-arm64-v8a-release.apk`

---

## 15) 현재 미커밋 로컬 작업 상태(중요)

이 handoff를 작성하는 현재 시점에는, 이미 push된 최신 커밋 이후에 `UI 리디자인 작업을 시작한 로컬 변경분`이 존재한다.

로컬 변경/추가된 항목:
- `lib/app/app.dart` 수정
- `lib/features/hero/presentation/hero_screen.dart` 수정
- `lib/features/home/presentation/home_screen.dart` 수정
- `lib/features/home/presentation/category_hub_screen.dart` 수정
- `lib/features/hangul/presentation/hangul_learn_screen.dart` 수정
- `test/features/hangul/presentation/hangul_quiz_screen_test.dart` 수정
- `test/widget_test.dart` 수정
- `lib/app/ui/` 신규 디렉토리(공통 UI 컴포넌트 초안)
- `test/app/` 신규 디렉토리(공통 UI 테스트 초안)
- `.hermes/plans/2026-04-16_kids-play-app-ui-redesign-plan.md` 신규 문서

즉, 다음 LLM이 이어받는다면 아래 2가지 중 하나를 명확히 선택해야 한다.

1. 이미 push된 기준(`4854bd0`)에서 안정적으로 이어가기
2. 로컬 미커밋 UI 리디자인 초안을 검토/정리해서 계속 진행하기

---

## 16) 가장 최근 사용자 피드백과 의미

사용자 최신 발화:
- “디자인, ui ux가 거의 대학교 1학년생 작품인데?”
- 이후 리디자인 제안에 대해 “오케이”라고 승인함

이 의미:
- 현재 MVP는 기능은 검증되지만 시각 완성도는 사실상 불합격
- 앞으로는 ‘잘 돌아간다’보다 ‘보는 순간 괜찮아 보인다’가 더 중요함
- 다음 반복에서 해야 할 핵심은 다음과 같음:
  - 공통 kid-friendly design system 수립
  - hero/home/category/learn/quiz 전체의 통일된 비주얼 언어 정리
  - generic Material 느낌 제거
  - 장난감/그림책/자동차 놀이터 감성 강화

---

## 17) 다른 LLM이 바로 이해해야 할 핵심 요약

### 제품적으로
- 유아 혼자 쓰는 앱이다.
- 복잡하면 안 된다.
- 예쁘고 직관적이고 눌러보고 싶어야 한다.

### 콘텐츠적으로
- 한글이 제일 중요하다.
- 알파벳/숫자는 확장 카테고리다.
- 게임은 처음부터 4지선다다.

### 구현적으로
- Flutter 앱이다.
- landscape 고정이다.
- 오프라인 APK다.
- data-driven 구조를 유지해야 한다.

### 디자인적으로
- 현재 가장 중요한 문제는 디자인 퀄리티 부족이다.
- 유저는 현재 UI를 매우 낮게 평가했다.
- 이후 작업의 최우선은 polished redesign이다.

---

## 18) 추천 다음 액션

다른 LLM이 이어받는다면 추천 순서:

1. 현재 로컬 미커밋 리디자인 초안 파일 검토
2. 공통 디자인 토큰 / UI 컴포넌트 정리
3. HangulQuizScreen, HeroScreen, HomeScreen 순으로 비주얼 리디자인
4. 기존 widget tests 유지 + responsive 테스트 보강
5. release APK 재빌드
6. 작은 단위로 commit / push
7. 사용자의 Telegram 피드백 반영 반복

---

## 19) 참고 문서

이미 레포 안에 존재하는 유용한 문서:
- `.hermes/plans/2026-04-16_155236-seungwon-kids-play-app-discovery.md`
- `.hermes/plans/2026-04-16_160812-seungwon-kids-play-app-implementation-plan.md`
- `.hermes/plans/2026-04-16_kids-play-app-ui-redesign-plan.md`
- `docs/asset-pipeline.md`
- `docs/hero-face-asset-spec.md`
- `docs/local-dev-setup.md`

---

## 20) 주의사항

- Flutter 실행 시 이 머신에서는 `flutter`가 PATH에 없을 수 있음
- 전체 경로 사용 권장:
  - `/home/openc/sdk/flutter/bin/flutter`
- GitHub는 SSH push가 정상 동작함
- `gh` 토큰 인증은 불안정할 수 있으므로 git+ssh가 더 안전함

---

## 21) 마지막 메모

이 프로젝트는 단순히 “유아용 학습 기능이 있는 앱”이 아니라,
사용자 입장에서는 `자기 아이를 위한 사적인 선물 같은 앱`에 가깝다.
그래서 기능보다도 감성, 완성도, 친근함, 개인화가 매우 중요하다.

다음 작업자는 이 점을 놓치지 말 것.
