# 안드로이드 앱으로 만들기

저장소 루트의 웹 앱을 그대로 감싸 APK를 뽑습니다. 루트는 건드리지 않으므로
GitHub Pages 배포는 그대로 유지됩니다.

## 왜 앱으로 감싸나

**알림 때문입니다.** 웹(PWA)은 앱을 완전히 종료하면 예약 알림을 띄울 수 없습니다.
브라우저가 죽으면 타이머도 같이 죽기 때문이고, 이걸 넘으려면 푸시 서버가 필요합니다.

앱으로 감싸면 `@capacitor/local-notifications`가 **안드로이드 OS에 알림을 예약**합니다.
앱을 종료해도, 화면을 꺼도, 도즈 모드에 들어가도 (`allowWhileIdle`) 제때 옵니다.
그 외의 기능은 웹과 완전히 동일합니다 — 같은 `index.html`을 씁니다.

## 준비물 (한 번만)

| | 받는 곳 | 크기 |
|---|---|---|
| JDK 17 | https://adoptium.net (Temurin 17 LTS) | 약 200 MB |
| Node.js LTS | https://nodejs.org | 약 30 MB |
| Android Studio | https://developer.android.com/studio | 약 1 GB + SDK 1 GB |

Android Studio는 SDK를 받기 위해 필요합니다. 처음 실행 시 나오는 설치 마법사를
기본값으로 끝내면 SDK가 함께 깔립니다. 설치 후 **터미널을 새로 열어야**
`java` / `node` 명령이 잡힙니다.

확인:

```bash
java -version && node -v && npm -v
```

## 빌드

```bash
cd mobile && npm install
```

```bash
npm run sync-web && npx cap add android
```

`npx cap add android`는 최초 1회만 하면 됩니다. 이후에는 아래만 반복합니다.

```bash
npm run apk
```

APK가 여기 생깁니다:

```text
mobile/android/app/build/outputs/apk/debug/app-debug.apk
```

이 파일을 카톡·메일로 보내면 상대가 바로 설치할 수 있습니다. 받는 쪽에서
"출처를 알 수 없는 앱" 설치를 한 번 허용해야 합니다.

## 웹 코드를 고친 뒤

루트 `index.html`을 수정했다면 다시 `npm run apk`만 하면 됩니다.
`sync-web.mjs`가 루트에서 최신 파일을 다시 긁어 옵니다.

## Android Studio로 열기

에뮬레이터에서 돌려 보거나 서명된 릴리스 APK를 만들려면:

```bash
npm run open-android
```

릴리스 빌드는 Build → Generate Signed Bundle / APK 에서 키스토어를 만들어
진행합니다. 지인 배포 수준이면 위의 debug APK로 충분합니다.

## 구조

| 파일 | 하는 일 |
|---|---|
| `sync-web.mjs` | 루트의 `index.html`·`textures/`·`icons/`를 `www/`로 복사. 서비스워커 등록을 꺼서 앱을 새로 깔아도 낡은 화면이 남지 않게 한다 |
| `install-res.mjs` | 알림 스몰 아이콘을 안드로이드 `res/`에 넣는다. `cap add android` 이후에만 동작 |
| `res-notification/` | 알림 아이콘 원본 (흰색 실루엣 + 투명 배경 — 색이 들어가면 OS가 흰 사각형으로 뭉갠다) |
| `capacitor.config.json` | 앱 id·이름·알림 아이콘 설정 |

`www/`, `android/`, `node_modules/`는 생성물이라 git에 올리지 않습니다.

## 주의

- `appId`(`io.github.jwwon03.stellarfocus`)를 바꾸면 기존 설치본과 다른 앱이 되어
  **저장된 항성계가 보이지 않습니다.** 계정 로그인 상태라면 클라우드에서 복구됩니다.
- 앱 안의 데이터는 웹 브라우저와 별개 저장소를 씁니다. 둘을 오가려면 계정
  기능으로 동기화하세요.
