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
| `ring_saturn.png` | 토성 고리 (가로축 = 안쪽→바깥쪽 반경) |

## NASA 공개 도메인 (Wikimedia Commons 경유)

아래는 미국 정부 저작물로 **퍼블릭 도메인**입니다.

| 파일 | 천체 | 출처 |
|---|---|---|
| `pl_pluto.jpg` | 명왕성 | New Horizons 컬러 모자이크 |
| `mn_europa.jpg` | 유로파 | Voyager / Galileo SSI 글로벌 모자이크 |
| `mn_enceladus.jpg` | 엔셀라두스 | Cassini 컬러 맵 |

**명왕성 남반구 보정**: 뉴호라이즌스 통과 당시 남반구가 극야여서 촬영되지
않았습니다. 원본은 그 영역이 완전히 검게 비어 있어 구에 입히면 절반이
새까맣게 보입니다. 경계 부근의 색을 이어받아 극으로 갈수록 어두워지도록
채워 넣었습니다 — **이 부분은 관측 자료가 아니라 보간한 값**입니다.

**세레스 제외**: 확보한 자료가 좌표 격자와 축 눈금이 그려진 false-color
지형도라 사용할 수 없었습니다. 자연색 글로벌 모자이크를 찾지 못해
절차적 렌더링으로 되돌렸습니다.

나머지 77종은 실제 표면 지도가 공개되어 있지 않거나(외계행성·항성) 상상도만
존재하므로, 관측된 물리량에 근거해 코드로 그립니다.

## 파일 이름 규칙

파일명은 앱의 천체 id와 정확히 일치해야 합니다 (`STAR_POOL` / `PLANET_POOL` /
`MOON_POOL`의 `id` 값 + `.jpg`). 앱은 이 규칙으로 텍스처를 찾고, 파일이 없으면
자동으로 절차적 렌더링으로 넘어갑니다.

---

## `m13.jpg` — 다른 출처

가챠 연출(망원경 시야)의 성단 배경입니다. **위의 Solar System Scope 자료가
아니라 별도 출처**이므로 따로 적습니다.

- 대상: **M13 (NGC 6205)** · 헤르쿨레스자리 구상성단
- 출처: https://noirlab.edu/public/images/noao0103a/
- 크레딧: **N.A.Sharp, REU program/NOIRLab/NSF/AURA**
- 라이선스: **Creative Commons Attribution 4.0 International (CC BY 4.0)**
  https://creativecommons.org/licenses/by/4.0/

미국 국립과학재단(NSF)의 키트피크 국립천문대에서 케이스웨스턴리저브대학
버렐 슈미트 망원경으로 촬영한 CCD 영상입니다. 시야는 30.5 × 23.1 분각.

원본 1800×1366 을 정사각으로 중앙 크롭한 뒤 1200×1200 으로 줄이고 품질 82로
다시 압축했습니다 (761 KB → 211 KB). 원형 시야로 잘려 나가므로 좌우 여백은
어차피 보이지 않습니다.

**크레딧 표기를 지우지 말 것** — CC BY 4.0 의 조건입니다. 이 문서와 함께
연출 화면 아래에 `M13 · NOIRLab/NSF/AURA` 로 표시하고 있습니다.

이 파일이 없어도 앱은 정상 동작합니다 — 절차적으로 그린 성단만 남습니다.
