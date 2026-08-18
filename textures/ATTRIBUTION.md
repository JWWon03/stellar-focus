# 텍스처 출처 및 라이선스

이 폴더의 이미지는 **Solar System Scope** 에서 배포하는 천체 텍스처를
1024×512로 축소해 사용한 것입니다.

- 출처: https://www.solarsystemscope.com/textures/
- 라이선스: **Creative Commons Attribution 4.0 International (CC BY 4.0)**
  https://creativecommons.org/licenses/by/4.0/
- 원본 자료는 NASA 등의 공개 관측 데이터를 바탕으로 제작되었습니다.

CC BY 4.0은 출처 표기를 조건으로 상업적 이용을 포함한 자유로운 사용·수정·재배포를
허용합니다. 이 문서와 앱 내 도감 화면의 출처 표기가 그 조건을 충족합니다.

## 수록 목록

실제 관측에 기반한 텍스처만 포함했습니다. Solar System Scope가 `_fictional`로
표기한 상상도(세레스·에리스·하우메아·마케마케 등)는 **의도적으로 제외**했습니다 —
실제 사진이라고 오해할 수 있기 때문입니다.

| 파일 | 천체 |
|---|---|
| `st_sun.jpg` | 태양 |
| `pl_mercury.jpg` | 수성 |
| `pl_venus.jpg` | 금성 (대기층) |
| `pl_earth.jpg` | 지구 |
| `pl_mars.jpg` | 화성 |
| `pl_jupiter.jpg` | 목성 |
| `pl_saturn.jpg` | 토성 |
| `pl_uranus.jpg` | 천왕성 |
| `pl_neptune.jpg` | 해왕성 |
| `mn_moon.jpg` | 달 |

나머지 77종은 실제 표면 지도가 공개되어 있지 않거나(외계행성·항성) 상상도만
존재하므로, 관측된 물리량에 근거해 코드로 그립니다.

## 파일 이름 규칙

파일명은 앱의 천체 id와 정확히 일치해야 합니다 (`STAR_POOL` / `PLANET_POOL` /
`MOON_POOL`의 `id` 값 + `.jpg`). 앱은 이 규칙으로 텍스처를 찾고, 파일이 없으면
자동으로 절차적 렌더링으로 넘어갑니다.
