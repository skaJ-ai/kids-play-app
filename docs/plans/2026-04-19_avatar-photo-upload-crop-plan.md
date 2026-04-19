# Avatar Photo Upload + Crop Status Note

이 문서는 2026-04-19 avatar photo upload/crop 작업의 현재 상태와 provenance를 간단히 정리한 기록이다.
원래 Task 1-6 계획이었고, live repo에서는 이미 Task 1-5 코드가 landed 상태이며 이번 docs-only commit이 Task 6 문서 정리를 맡는다.

## 현재 상태

- 기준 live repo HEAD at docs refresh: `19a6f1d`
- 범위: 부모 전용 `AvatarSetupScreen`의 5개 표정 카드, 갤러리 import, 정사각형 crop, 표정별 저장/지우기, hero 얼굴 fallback chain
- 비범위: `HomeScreen`용 별도 얼굴 슬롯 UI, build-time asset pipeline 확장
- 검증 수준: full repo Gate G를 새로 주장하지 않고, current live code의 avatar/hero slice만 targeted verification으로 재확인

## Task 상태

- [x] Task 1 — avatar photo snapshot store 추가
  - `AvatarPhotoStore.storageKey == 'avatar_photos_v1'`
  - 구현 파일: `lib/features/avatar/data/avatar_photo_store.dart`
  - 관련 도메인: `lib/features/avatar/domain/avatar_photo_entry.dart`, `lib/features/avatar/domain/avatar_photo_snapshot.dart`
- [x] Task 2 — 런타임 파일 저장소 + avatar photo service 추가
  - 구현 파일: `lib/features/avatar/data/avatar_photo_repository.dart`, `lib/features/avatar/data/local_avatar_photo_repository.dart`, `lib/features/avatar/application/avatar_photo_service.dart`
  - 앱 wiring: `lib/main.dart`, `lib/app/services/app_services.dart`
- [x] Task 3 — 갤러리 import 추가
  - 구현 파일: `lib/features/avatar/application/avatar_photo_picker.dart`
  - 의존성: `image_picker`
- [x] Task 4 — 정사각형 crop 화면 추가
  - 구현 파일: `lib/features/avatar/presentation/avatar_crop_screen.dart`
  - 의존성: `crop_your_image`
- [x] Task 5 — 부모 표정 카드 + hero fallback 연결
  - 구현 파일: `lib/features/avatar/presentation/avatar_setup_screen.dart`, `lib/features/avatar/presentation/widgets/avatar_expression_card.dart`, `lib/features/avatar/presentation/widgets/avatar_face_image.dart`
  - hero fallback 확인: 현재 `HeroScreen`은 smile/neutral 우선순위에서 저장된 runtime file을 찾고, 없으면 `assets/generated/images/hero/hero_face.png` 경로 asset으로 fallback
- [x] Task 6 — docs/provenance refresh
  - 이번 docs-only commit에서 `README.md`, `handoff.md`, `docs/asset-pipeline.md`, `docs/local-dev-setup.md`, 이 파일을 정리

## 런타임 저장 계약

- build-time asset pipeline 입력: `assets/public/`, `assets/local_private/`
- build-time asset pipeline 출력: `assets/generated/`
- runtime avatar photos: 위 asset pipeline과 별개인 app-private 파일
- 실제 파일 저장 root: `LocalAvatarPhotoRepository(getApplicationSupportDirectory)`
- relative file naming: `avatar_photos/<expression>.png`
- metadata 저장: shared_preferences key `avatar_photos_v1`
- reset 분리: avatar photo metadata는 progress store와 분리되어 `진도 초기화`와 독립적으로 유지

즉, avatar photo는 `assets/public/`, `assets/local_private/`, `assets/generated/`에 넣는 자산이 아니라, 앱 실행 중 부모 화면에서 저장되는 런타임 파일이다.

## Current targeted verification on live code (`19a6f1d`)

- `./scripts/prepare_assets.sh` + `/home/openc/sdk/flutter/bin/flutter pub get` 성공
- targeted test
  - `/home/openc/sdk/flutter/bin/flutter test test/features/avatar/application/avatar_photo_service_test.dart test/features/avatar/data/avatar_photo_store_test.dart test/features/avatar/data/local_avatar_photo_repository_test.dart test/features/avatar/presentation/avatar_crop_screen_test.dart test/features/avatar/presentation/avatar_setup_screen_test.dart test/features/avatar/presentation/widgets/avatar_face_image_test.dart test/features/hero/presentation/hero_screen_test.dart`
  - 결과: passed
- targeted analyze
  - `/home/openc/sdk/flutter/bin/flutter analyze lib/features/avatar lib/features/hero/presentation/hero_screen.dart test/features/avatar test/features/hero/presentation/hero_screen_test.dart`
  - 결과: clean (`No issues found!`)

## Historical full-gate reference

- full Gate G reference는 docs-only HEAD `9d4c035`에 남아 있다.
- 해당 rerun이 검증한 코드 스냅샷은 `d81a2ec`였다.
- 이번 문서 정리는 그 historical full-gate record를 덮어쓰지 않고, current live repo의 avatar runtime photo 상태를 보완 설명한다.
