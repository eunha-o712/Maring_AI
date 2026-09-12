# 마링(Maring)

[![CI](https://github.com/eunha-o712/Maring_AI/actions/workflows/ci.yml/badge.svg?branch=develop)](https://github.com/eunha-o712/Maring_AI/actions/workflows/ci.yml)

마링은 감정 체크인과 MBTI 말투 기반 대화를 제공하는 Flutter + Spring Boot MVP다. 캐릭터 방향은 기존 GLB 3D 시안이 아니라, 원본의 둥근 실루엣과 파스텔 질감을 유지한 **투명 PNG 기반 2.5D 표정 세트**로 확정했다.

## 현재 구성

- `maring-frontend/`: Flutter 앱. 온보딩, MBTI/말투 설정, 부화, 홈, 감정 체크인, 대화, 안전 안내, 마음 기록을 포함한다.
- `maring-backend/`: Spring Boot API. 사용자, 체크인, 대화, 안전 분류와 Claude API/로컬 폴백을 포함한다.
- `maring-frontend/assets/maring/`: 감정 표정 9종과 성장 단계 5종.
- `docs/`: 캐릭터 생성 프롬프트, 콘택트 시트, 적용 기록.
- `3d-model/`: 앱에서 사용하지 않는 초기 3D 연구 시안.
- `tools/`: 자산 정규화, 콘택트 시트, 테스트와 로컬 실행 도구.

## 빠른 실행

JDK 17 이상, Maven, Flutter SDK가 필요하다. 첫 터미널에서 로컬 API를 실행한다.

```powershell
.\tools\run-backend-local.ps1
```

두 번째 터미널에서 앱을 실행한다.

```powershell
Set-Location .\maring-frontend
flutter pub get
flutter run --dart-define=MARING_API_BASE_URL=http://localhost:8080
```

Android 에뮬레이터는 주소 지정 없이 실행해도 기본값 `http://10.0.2.2:8080`을 사용한다. 실제 기기는 PC와 같은 네트워크의 PC IP를 지정해야 한다.

`ANTHROPIC_API_KEY`가 없으면 서버는 규칙 기반 공감 답변으로 동작하므로 전체 로컬 흐름을 바로 확인할 수 있다.

## 검증

```powershell
mvn -B test
.\tools\test-flutter.ps1
Set-Location .\maring-frontend
flutter analyze --no-pub
flutter build web --no-pub
flutter build apk --debug --no-pub
```

캐릭터만 빠르게 확인하려면 `MARING_CHARACTER_PREVIEW=true`로 웹 빌드한다. 자세한 자산 기준과 재생성 절차는 [2.5d-character-implementation.md](docs/2.5d-character-implementation.md)에 있다.

이번 구현의 실제 통과 항목과 브라우저 전체 흐름 결과는 [verification-report.md](docs/verification-report.md)에 기록했다.

## 출시 전 남은 범위

현재 결과물은 동작하는 MVP다. 체크인 누적으로 5단계 성장하며, 운영 출시 전에는 성장 상태의 서버 저장, 인증, PostgreSQL/Flyway, 대화 데이터 보호, 릴리스 서명과 고유 앱 ID, 16개 MBTI 프롬프트 완성, 안전 분류기·위기 연락처의 전문가 검토가 필요하다. 상점/구독, 자동 일기와 주간 리포트는 후속 제품 범위다.
