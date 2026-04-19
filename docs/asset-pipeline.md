# Asset pipeline guide

이 문서는 현재 레포에서 실제로 사용하는 build-time asset pipeline을 정리한 운영 가이드다.
Flutter 번들과 build-time asset 참조는 `assets/generated/` 기준으로 맞추고, `scripts/prepare_assets.sh`가 `assets/public/`와 선택적인 `assets/local_private/`를 합쳐 최종 자산을 만든다.

> 런타임 avatar photo carve-out: 부모 설정 화면의 5개 표정 사진은 이 build-time asset pipeline과 별개다. `main.dart`는 `LocalAvatarPhotoRepository(getApplicationSupportDirectory)`를 주입하고, import/crop 결과 파일은 app-private root 아래 `avatar_photos/<expression>.png` 경로 규칙으로 저장한다. 메타데이터는 shared_preferences key `avatar_photos_v1`에 저장되며, `AvatarFaceImage`/hero 렌더는 configured expression priority에서 찾은 runtime file을 우선 보고 없으면 `assets/generated/images/hero/hero_face.png` 경로의 bundled/generated hero face asset으로 fallback 한다. 따라서 runtime avatar photos를 `assets/public/`, `assets/local_private/`, `assets/generated/`에 넣거나 `prepare_assets.sh`가 관리한다고 가정하지 않는다.

## 현재 디렉터리 계약

```text
assets/
  public/         git에 커밋하는 기본 자산
  local_private/  머신별 private override
  generated/      prepare step가 다시 만드는 최종 자산
```

### `assets/public/`
- 모든 clone에서 안전하게 공유되는 기본 자산 위치다.
- 현재 레포에는 아래 예시가 이미 있다.
  - `assets/public/manifest/hangul_lessons.json`
  - `assets/public/manifest/alphabet_lessons.json`
  - `assets/public/manifest/numbers_lessons.json`
  - `assets/public/manifest/home_categories.json`
  - `assets/public/manifest/asset_register.csv`
  - `assets/public/images/hero/hero_face.png`
- `images/categories/`, `audio/voice/prompts/`, `audio/sfx/`, `audio/music/` 같은 경로도 현재 구조에 포함되어 있으며, 지금은 비어 있거나 placeholder만 있더라도 같은 경로 계약 아래에서 나중에 자산을 추가할 수 있다.

### `assets/local_private/`
- gitignore되는 로컬 override 위치다.
- `public/`와 **같은 상대 경로와 파일명**을 사용하면 prepare step에서 덮어쓴다.
- 예: 개인화된 히어로 이미지를 쓰려면 `assets/local_private/images/hero/hero_face.png`에 둔다.

### `assets/generated/`
- prepare step가 매번 다시 만드는 최종 결과물이다.
- Flutter `pubspec.yaml`과 build-time asset 참조 경로는 이쪽 기준으로 맞춘다.
- clean checkout 직후에는 필요한 하위 디렉터리가 아직 없을 수 있으므로, asset 구조를 바꿨거나 새 clone이라면 먼저 prepare step를 실행한다.

## 실제 prepare script

현재 레포에서 쓰는 스크립트는 `scripts/prepare_assets.sh`다.
핵심은 현재 working directory가 아니라 **스크립트 위치 기준으로 repo root를 계산**한다는 점이다.

```bash
#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PUBLIC_DIR="$ROOT_DIR/assets/public"
PRIVATE_DIR="$ROOT_DIR/assets/local_private"
GENERATED_DIR="$ROOT_DIR/assets/generated"

if [[ ! -d "$PUBLIC_DIR" ]]; then
  echo "Missing public assets directory: $PUBLIC_DIR" >&2
  exit 1
fi

rm -rf "$GENERATED_DIR"
mkdir -p "$GENERATED_DIR"

rsync -a --delete "$PUBLIC_DIR/" "$GENERATED_DIR/"

if [[ -d "$PRIVATE_DIR" ]]; then
  rsync -a "$PRIVATE_DIR/" "$GENERATED_DIR/"
fi
```

실제 동작은 아래와 같다.
1. `assets/public/`가 없으면 바로 실패한다.
2. `assets/generated/`를 지우고 다시 만든다.
3. `assets/public/` 전체를 `assets/generated/`로 복사한다.
4. `assets/local_private/`가 있으면 같은 경로의 파일을 overlay 한다.
5. private overlay 단계는 `--delete`를 쓰지 않으므로, private 쪽은 public 기본 자산을 선택적으로 덮어쓰는 용도다.

## Runtime avatar photo carve-out

build-time asset pipeline과 별도로, 부모 설정의 avatar photo upload/crop flow는 아래 계약을 사용한다.

- source import: `ImagePickerAvatarPhotoPicker.pickFromGallery()`
- crop UI: `AvatarCropScreen` (`crop_your_image` 기반 정사각형 crop)
- file storage: `LocalAvatarPhotoRepository(getApplicationSupportDirectory)`
- relative file names: `avatar_photos/<expression>.png`
- metadata store: `AvatarPhotoStore.storageKey == 'avatar_photos_v1'`
- hero/avatar rendering fallback: configured expression priority에서 찾은 runtime file 우선, 없으면 `assets/generated/images/hero/hero_face.png`

즉, avatar photo는 **런타임 app-private 파일**이고 build-time asset 입력(`public`, `local_private`)이나 build-time 출력(`generated`)이 아니다.

## 복사해서 바로 쓸 수 있는 실행 예시

`assets/README.md`와 동일하게, 팀 기본 사용법은 **repo root로 이동한 다음** 스크립트를 실행하는 것이다. `assets/` 디렉터리 안으로 들어가서 실행하지 않는다.

```bash
REPO_ROOT="/path/to/kids-play-app"
cd "$REPO_ROOT"
./scripts/prepare_assets.sh
```

절대/상대 경로로 스크립트를 직접 호출해도 동작 자체는 repo-root-safe 하다. 그래도 문서와 팀 사용 예시는 위처럼 `cd "$REPO_ROOT"` 후 실행하는 방식을 기준으로 둔다.

```bash
REPO_ROOT="/path/to/kids-play-app"
"$REPO_ROOT/scripts/prepare_assets.sh"
```

prepare step를 다시 돌려야 하는 대표적인 경우:
- `assets/public/` 내용을 바꿨을 때
- `assets/local_private/`에 override를 추가하거나 교체했을 때
- 새 clone에서 아직 `assets/generated/`가 준비되지 않았을 때

## Flutter asset registration gotcha

현재 `pubspec.yaml`은 `assets/generated/` 전체를 한 번에 등록하지 않고, **구체적인 하위 디렉터리만 명시적으로 등록**한다.

```yaml
flutter:
  assets:
    - assets/generated/images/hero/
    - assets/generated/images/categories/
    - assets/generated/audio/voice/prompts/
    - assets/generated/audio/sfx/
    - assets/generated/audio/music/
    - assets/generated/manifest/
```

이 방식이 현재 레포 기준 권장값이다.

- `assets/generated/` 한 줄로 넓게 등록하면 임시 파일이나 의도하지 않은 산출물을 함께 묶기 쉬워진다.
- 어떤 generated 하위 트리가 앱 계약의 일부인지 `pubspec.yaml`에서 바로 읽을 수 있다.
- 현재 레포는 manifest와 hero 이미지 예시가 이미 있고, categories/audio 경로도 같은 generated-path 계약 아래에서 이후 placeholder나 실자산을 추가할 수 있다.

## 자산 추가/교체 규칙

1. 기본 자산은 `assets/public/` 아래에 둔다.
2. 머신 전용 민감 자산은 `assets/local_private/` 아래의 같은 상대 경로에 둔다.
3. `./scripts/prepare_assets.sh`를 실행해 `assets/generated/`를 다시 만든다.
4. 코드와 `pubspec.yaml`은 build-time asset을 참조할 때 계속 `assets/generated/...` 경로를 사용한다.

핵심은 **입력 경로(`public`, `local_private`)와 앱이 읽는 build-time 출력 경로(`generated`)를 분리**하는 것이다. 이렇게 두면 현재처럼 manifest + hero 이미지 중심의 최소 자산 세트로도 앱 계약을 유지할 수 있고, 이후 categories/audio placeholder나 private override를 추가할 때도 코드 경로를 바꿀 필요가 없다. 별도의 runtime avatar photo는 위 carve-out처럼 app-private 파일로 다룬다.
