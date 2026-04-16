# 승원이의 빵빵 놀이터

27개월 남자아기를 위한 가로모드 고정 학습/퀴즈 앱 프로젝트.

현재 방향:
- Android APK 개인 설치용
- Galaxy S24 우선, 다른 안드로이드 폰/태블릿 대응
- 오프라인 전용
- 한글 / 알파벳 / 숫자 3개 카테고리
- 학습 모드와 게임 모드 분리
- 아기 혼자 써도 되도록 버튼 수 최소화
- 자동차/타요 감성의 파스텔 톤 UI
- Flutter 기반 구현
- private asset / placeholder 분리 전략 사용

진행 원칙:
- 요구사항과 콘텐츠 구조를 먼저 고정
- 작은 단위로 커밋/푸시
- 나중에 콘텐츠를 쉽게 추가할 수 있게 데이터 중심 구조로 설계
- 실제 얼굴/민감 자산은 git 밖 또는 gitignore 경로로 관리

현재 문서:
- 상세 기획/결정 메모: `.hermes/plans/2026-04-16_155236-seungwon-kids-play-app-discovery.md`
- 구현 계획: `.hermes/plans/2026-04-16_160812-seungwon-kids-play-app-implementation-plan.md`
- 자산 파이프라인: `docs/asset-pipeline.md`
- 히어로 얼굴 자산 가이드: `docs/hero-face-asset-spec.md`
- 로컬 개발 환경 준비: `docs/local-dev-setup.md`
