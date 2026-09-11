# 마링 Spring Boot API

마링 Flutter 앱의 사용자, 감정 체크인, 대화와 안전 플로우를 제공하는 Java 17 / Spring Boot 3.3 API다.

## 로컬 실행

저장소 루트에서 다음 스크립트를 실행하는 방법이 가장 재현 가능하다.

```powershell
.\tools\run-backend-local.ps1
```

스크립트는 실행 JAR을 패키징한 뒤 `local` 프로필로 시작한다. 데이터는 `maring-backend/data/maring.mv.db`에 보존되며 Git에는 포함되지 않는다. 빌드를 생략하려면 이미 패키징된 JAR이 있는 상태에서 `-SkipBuild`를 쓴다.

직접 실행하려면:

```powershell
mvn -B -pl maring-backend package "-DskipTests"
java -jar .\maring-backend\target\maring-api-0.0.1-SNAPSHOT.jar --spring.profiles.active=local
```

기본 프로필은 인메모리 H2를 사용한다. 로컬 프로필의 H2 콘솔은 `http://localhost:8080/h2-console`이며 JDBC URL은 `jdbc:h2:file:./data/maring`이다.

## Claude 연동

```powershell
$env:ANTHROPIC_API_KEY = 'sk-ant-...'
$env:ANTHROPIC_MODEL = '<사용할 모델 ID>'
```

키가 없거나 호출이 실패하면 규칙 기반 공감 답변으로 안전하게 폴백한다. `infp.md`는 전용 프롬프트가 있고 나머지 유형은 현재 `default.md`를 사용한다.

## 주요 API

- `POST /api/users`, `GET /api/users/{id}`
- `PUT /api/users/{id}/mbti`, `PUT /api/users/{id}/speech-style`
- `POST /api/checkins`, `GET /api/checkins?userId=...`
- `POST /api/conversations?userId=...`
- `POST /api/conversations/{id}/messages`
- `GET /api/conversations/{id}/messages`
- `GET /api/safety/resources`

대화는 먼저 독립 안전 분류기를 거친다. MEDIUM 이상이면 LLM 응답 대신 고정 안전 문구와 위기 자원을 반환하고 이벤트를 기록한다.

## 테스트

저장소 루트에서:

```powershell
mvn -B test
```

통합 테스트는 온보딩, 같은 날짜 체크인 덮어쓰기, 정상 대화 폴백, 위기 안전 플로우, 잘못된 사용자/감정/대화 ID를 검증한다.

## 출시 전 과제

- 16개 MBTI별 시스템 프롬프트 완성 및 평가
- 키워드 분류기를 검증된 위기 분류 체계로 교체
- 인증, PostgreSQL/Flyway, 대화 데이터 암호화와 보존 정책
- 위기 자원 번호·운영시간·안전 문구의 최신성 및 전문가 검토
- 운영 관측성, 비밀 관리, 부하/복구 테스트
