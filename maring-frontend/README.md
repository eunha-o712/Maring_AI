# 마링(Maring) 프론트엔드 — Flutter

MBTI AI 상담 캐릭터 앱 '마링'의 모바일 클라이언트. 개발명세서 Ⅲ. 화면 스토리보드의 **P1(MVP) 화면
S-01~S-08**을 구현했다. `maring-backend` API 와 연동해서 동작한다.

## 준비물
- Flutter SDK (설치: https://docs.flutter.dev/get-started/install)
- 실행 중인 `maring-backend` 서버 (기본 포트 8080)

이 저장소에는 `lib/`와 `pubspec.yaml`만 있고 `android/`·`ios/` 등 플랫폼 폴더는 없다.
**최초 1회**, 이 폴더에서 아래 명령으로 플랫폼 폴더를 생성해야 한다 (기존 `lib/`, `pubspec.yaml`은 보존됨):

```bash
cd maring-frontend
flutter create .
flutter pub get
```

## 실행
```bash
flutter run
```

### 백엔드 주소 설정
`lib/core/api_config.dart` 의 기본값은 **Android 에뮬레이터** 기준(`http://10.0.2.2:8080`)이다.
다른 환경에서는 실행 시 `--dart-define`으로 오버라이드:

```bash
# iOS 시뮬레이터 / 웹
flutter run --dart-define=MARING_API_BASE_URL=http://localhost:8080

# 실기기 (PC와 같은 Wi-Fi, PC의 사설 IP로)
flutter run --dart-define=MARING_API_BASE_URL=http://192.168.0.10:8080
```

## 구현된 화면 (P1 MVP)
| 화면 | 내용 |
|---|---|
| S-01 | 온보딩 시작 — 닉네임 입력 + 약관/비의료 고지 동의 |
| S-02 | MBTI 설정 — 16유형 그리드 선택 + 말투(반말/존댓말) |
| S-03 | 캐릭터 부화 — 부화 연출 후 서버에 MBTI·말투 저장 |
| S-04 | 홈 — 마링이 캐릭터, 체크인·대화 진입, 하단 탭 |
| S-05 | 감정 체크인 — 감정 카드 + 강도 슬라이더 |
| S-06 | 상담 대화 — 채팅 UI, 대화 히스토리 로드 |
| S-07 | 안전 안내 오버레이 — 위기 감지 시 자동 표시 |
| S-08 | 마음 기록 — 이번 달 감정 캘린더 |

## 알고 있는 제약 (후속 작업)
- **S-02 진단 퀴즈 없음**: 명세의 12~16문항 간이 진단은 콘텐츠가 없어 "유형 직접 선택"만 구현했다.
- **S-07 긴급 연락처 다이얼 없음**: `url_launcher` 등 외부 패키지를 추가하지 않아 전화번호는 텍스트로만 표시된다.
- **자동 감정 일기/주간 리포트(FR-C1, C3) 없음**: LLM 요약 파이프라인이 아직 없어 S-08은 체크인 캘린더까지만 구현했다.
- **캐릭터 성장·상점·구독·관계상담(P2/P3+)**: 하단 탭에 자리만 두고 "준비 중"으로 안내.
- Riverpod 상태는 앱 재시작 시 `SharedPreferences`에 저장된 `userId`로 세션을 복구한다. 백엔드가
  H2 인메모리 DB라 서버를 재시작하면 저장된 `userId`가 무효화되고, 앱이 자동으로 로그아웃 처리한다.

## 아키텍처
```
lib/
├─ core/          # API 클라이언트, 설정, 저장소(MaringRepository)
├─ models/        # 서버 DTO에 대응하는 Dart 모델
├─ state/         # Riverpod StateNotifier/Provider (세션·채팅·체크인)
├─ screens/       # S-01~S-08 화면
└─ widgets/       # 공용 위젯 (안전 오버레이 등)
```
