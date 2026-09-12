# 마링 Flutter 앱

감정 체크인과 MBTI 말투 기반 대화를 제공하는 모바일 MVP다. Android, iOS, web 등 Flutter 플랫폼 폴더가 이미 포함되어 있으며 `maring-backend` API와 연결된다.

## 실행

백엔드를 먼저 `http://localhost:8080`에서 실행한 뒤:

```powershell
flutter pub get
flutter run --dart-define=MARING_API_BASE_URL=http://localhost:8080
```

- Android 에뮬레이터 기본값: `http://10.0.2.2:8080`
- iOS 시뮬레이터/web 기본값: `http://localhost:8080`
- 실제 기기: `--dart-define=MARING_API_BASE_URL=http://<PC의-사설-IP>:8080`

## 2.5D 캐릭터

`assets/maring/`의 표정 PNG 9종과 `assets/maring/growth/`의 성장 PNG 5종을 사용한다. 모두 1024×1024 투명 RGBA다. `MaringCharacter`가 표정/성장 전환, 글로우와 호흡 모션, 동작 줄이기 설정을 공통 처리한다.

새 사용자는 작은 `구름 씨앗`으로 시작하며 서로 다른 날짜의 체크인이 3·7·14·30일 쌓일 때 몸집과 색이 변한다. 홈의 새싹 아이콘에서 전체 성장 단계를 확인할 수 있다.

표정 갤러리를 앱 대신 바로 띄우는 웹 빌드:

```powershell
flutter build web --no-pub --dart-define=MARING_CHARACTER_PREVIEW=true
node ..\tools\preview.mjs
```

## 구현 화면

| 화면 | 내용 |
|---|---|
| S-01 | 닉네임과 고지 동의 온보딩 |
| S-02 | 16개 MBTI 직접 선택과 반말/존댓말 설정 |
| S-03 | 캐릭터 부화와 설정 저장 |
| S-04 | 오늘 감정을 반영하는 2.5D 홈 |
| S-05 | 감정 8종과 강도 체크인 |
| S-06 | 대화 및 히스토리 |
| S-07 | 위기 감지 시 전화 연결 버튼이 있는 안전 안내 |
| S-08 | 월별 감정 캘린더와 상세 보기 |

## 품질 확인

Windows에서 한글 사용자 경로로 인한 Flutter 테스트 엔진 종료를 피하려면 루트의 래퍼를 사용한다.

```powershell
..\tools\test-flutter.ps1
flutter analyze --no-pub
flutter build web --no-pub
flutter build apk --debug --no-pub
```

테스트는 표정 9종과 성장 5종 이미지의 디코딩/투명 모서리, 성장 단계의 크기 증가와 체크인 임계값, 작은 화면 온보딩, 갤러리 표정 전환, 세션 복구와 온보딩 저장 순서를 확인한다.

## 알려진 후속 범위

- 간이 MBTI 진단 문항은 아직 없고 유형 직접 선택만 제공한다.
- 자동 감정 일기와 주간 리포트는 아직 없다.
- 성장 이미지는 구현됐지만 운영용 성장 포인트와 보상은 아직 서버에 저장하지 않는다.
- 상점, 구독, 관계상담은 준비 중 화면만 있다.
- 전화 연결은 실제 전화 기능이 있는 기기에서 최종 확인해야 한다.
- 운영 출시 전 안전 문구와 연락처는 전문가가 다시 검토해야 한다.
