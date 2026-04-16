# Asset pipeline for 승원이의 빵빵 놀이터

상태: researched / agreed direction
기준 시각: 2026-04-16 16:08 KST

## 왜 이 문서가 필요한가

이 프로젝트는 아래 자산이 섞인다.
- 실제 아이 얼굴 사진
- 카테고리 음성
- 효과음
- 배경음악
- 향후 교체 가능한 캐릭터/차량/배경 이미지

레포는 private이지만, APK 안에 들어간 자산은 결국 추출 가능하다.
그래서 "git에 안 올린다"와 "기기 안에서 완전히 비공개다"는 같은 뜻이 아니다.
이 문서는 안전성과 유지보수성을 동시에 잡는 자산 구조를 정의한다.

## 핵심 원칙

1. 코드가 참조하는 자산 경로는 항상 고정한다.
2. git에는 placeholder 자산만 올려도 앱이 동작해야 한다.
3. 실제 얼굴 사진/민감 자산/교체 예정 자산은 git 밖 또는 gitignore 경로에 둔다.
4. 빌드 직전에 placeholder + private override를 합쳐서 최종 번들 자산을 만든다.
5. 나중에 자산을 바꾸더라도 앱 코드 수정 없이 파일 교체만으로 대응 가능해야 한다.

## 권장 폴더 구조

```text
kids-play-app/
  assets/
    public/
      images/
        hero/
          hero_bg_car.webp
          hero_face.webp
        categories/
          hangul_card_placeholder.webp
          alphabet_card_placeholder.webp
          numbers_card_placeholder.webp
      audio/
        voice/
          hangul/
            consonant_giyeok.ogg
          alphabet/
            letter_a.ogg
          prompts/
            choose_answer.ogg
        sfx/
          tap.ogg
          success.ogg
          wrong.ogg
          sticker_reward.ogg
        music/
          drive_loop_01.ogg
      manifest/
        asset_register.csv

    local_private/
      images/
        hero/
          hero_face.webp
      audio/
        voice/
        music/

    generated/
      .keep

  asset_sources/
    README.md
    private/
      .keep
    licensed/
      .keep

  scripts/
    prepare_assets.sh
```

## 각 폴더의 역할

### assets/public/
- git에 커밋하는 안전한 기본 자산
- placeholder 이미지/음성 포함
- 이 폴더만으로도 앱이 실행 가능해야 함

### assets/local_private/
- gitignore 대상
- 같은 상대 경로/파일명으로 public 자산을 덮어씀
- 실제 승원이 얼굴, 가족 녹음 음성, 테스트용 사설 자산 등을 넣는 곳

### assets/generated/
- gitignore 대상
- Flutter가 실제로 번들하는 최종 자산 폴더
- public을 복사한 뒤 local_private를 overlay 해서 생성

### asset_sources/
- 앱에 바로 넣지 않는 원본 보관용
- PSD, SVG, WAV 마스터, 라이선스 파일, 영수증, 고해상도 원본 사진 등
- 가능하면 repo 밖에 별도 보관하는 것이 가장 좋음

## 히어로 연출용 이미지 구조

히어로 화면은 1장의 완성 이미지보다 레이어 분리가 낫다.

권장 레이어:
- hero_bg_car.webp: 도로/자동차/배경
- hero_face.webp: 승원이 얼굴 cutout

이유:
- placeholder 얼굴과 실제 얼굴을 쉽게 교체 가능
- 사진 없이도 기본 UI 개발 가능
- 나중에 캐릭터 스타일을 바꿔도 레이아웃 코드 수정이 적음

## git에 올릴 placeholder 원칙

placeholder도 실제 계약과 동일해야 한다.
즉 아래를 맞춘다.
- 파일명 동일
- 대략적인 비율 동일
- 투명 배경 여부 동일
- 오디오 길이/용도 비슷
- BGM은 loop 가능 형태 유지

예:
- assets/public/images/hero/hero_face.webp
  - generic cartoon driver silhouette
- assets/public/audio/prompts/choose_answer.ogg
  - neutral placeholder voice
- assets/public/audio/music/drive_loop_01.ogg
  - short royalty-free placeholder loop

## private/copyrighted 자산을 git에서 분리해야 하는 이유

private repo여도 아래 문제는 남는다.
- 실수로 공유 가능
- clone된 로컬/백업/히스토리에 남음
- APK에 들어가면 추출 가능

그래서 아래 자산은 원칙적으로 git에 올리지 않는 편이 낫다.
- 실제 아이 얼굴 원본
- 가족 음성 원본
- 구매/라이선스 제약 있는 음원/이미지 원본
- 고해상도 원본 사진/PSD/WAV

## 추천 .gitignore 항목

```gitignore
assets/local_private/*
!assets/local_private/.keep

assets/generated/*
!assets/generated/.keep

asset_sources/private/*
!asset_sources/private/.keep

asset_sources/licensed/*
!asset_sources/licensed/.keep
```

## 빌드 전 자산 합치기 스크립트

예상 스크립트: scripts/prepare_assets.sh

동작:
1. assets/generated 초기화
2. assets/public 전체 복사
3. assets/local_private 존재 시 overlay
4. Flutter는 generated만 참조

예시:

```bash
#!/usr/bin/env bash
set -euo pipefail

rm -rf assets/generated
mkdir -p assets/generated
rsync -a assets/public/ assets/generated/
if [ -d assets/local_private ]; then
  rsync -a assets/local_private/ assets/generated/
fi
```

## 추천 파일 포맷

### 이미지
기본 추천: WebP

#### 실제 얼굴 사진
- WebP lossy
- 품질: 대략 75~85
- 긴 변: 보통 1080~1440px
- EXIF 제거 필수

#### 배경/차량/일러스트
- WebP 우선
- 투명도와 가장자리가 중요하면 PNG 또는 WebP lossless 검토

#### 사용을 줄일 것
- 원본 휴대폰 사진 그대로
- 불필요하게 큰 PNG
- EXIF 남은 사진

### 오디오
기본 추천: OGG Vorbis

#### 음성 클립
- mono
- 24kHz 또는 32kHz
- 48~64 kbps 정도
- 앞뒤 무음 최대한 제거

#### 효과음
- mono 위주
- 48~96 kbps 정도

#### 배경음악
- stereo
- 44.1kHz
- 96~128 kbps 정도
- loop 편집 고려

#### 피할 것
- 대부분의 자산을 WAV로 넣는 것
- 큰 FLAC를 그대로 넣는 것

## 자산 슬롯 기반 네이밍 규칙

브랜드명이나 소스명을 코드 경로에 박지 않는다.
논리 슬롯으로 이름 짓는다.

좋은 예:
- hero_face.webp
- hero_bg_car.webp
- drive_loop_01.ogg
- category_hangul_intro.ogg

피할 예:
- tayo_main_song.mp3
- seungwon_real_face_final_final.png

이유:
- placeholder → private build → licensed replacement 전환이 쉬움
- 코드가 자산 출처와 결합되지 않음

## 자산 레지스터 권장

assets/public/manifest/asset_register.csv 같은 파일로 관리:

```csv
asset_id,relative_path,type,current_variant,source,license,private,ship_ok,notes
hero_face,images/hero/hero_face.webp,image,placeholder,internal,owned,false,true,default placeholder
hero_face,images/hero/hero_face.webp,image,family_private,family_photo,private,true,false,only for trusted family build
bgm_drive_01,audio/music/drive_loop_01.ogg,audio,placeholder,internal,owned,false,true,replace later if needed
```

## 실제 전달/교체 워크플로우

1. 코드/placeholder는 repo에 유지
2. 실제 사진/음성은 별도 보관
3. 필요 시 local_private에 덮어쓰기용 파일만 넣음
4. prepare_assets.sh 실행
5. APK build

## 이 프로젝트에 대한 최종 추천

- repo에는 안전한 placeholder만 커밋
- 실제 승원이 얼굴/민감 음성/교체 예정 자산은 git 밖 또는 local_private에 둠
- Flutter는 generated만 번들링
- 이미지 기본 포맷은 WebP
- 오디오 기본 포맷은 OGG
- personalized APK는 trusted family device용 build로 취급
