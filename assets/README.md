# Assets layout

이 폴더는 3계층 자산 구조를 따른다.

- `public/`: git에 커밋하는 placeholder / safe asset
- `local_private/`: gitignore되는 실제 얼굴/민감 자산 override
- `generated/`: 빌드 직전에 합쳐지는 최종 자산 폴더

기본 사용 순서:
1. `public/` 에 placeholder 유지
2. 필요 시 `local_private/` 에 override 파일 배치
3. `./scripts/prepare_assets.sh` 실행
4. 앱은 `generated/` 경로만 사용
