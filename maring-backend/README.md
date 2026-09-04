# 마링(Maring) 백엔드 — Spring Boot 뼈대

MBTI AI 상담 캐릭터 앱 '마링'의 API 서버 스캐폴드.
개발명세서(요구사항·테이블·구조)를 기반으로 **동작하는 최소 뼈대**를 구성했습니다.

## 기술 스택
- Java 17, Spring Boot 3.3.5
- Spring Web / Spring Data JPA / Validation
- H2 (인메모리, 별도 설치 불필요) — 운영 전환 시 PostgreSQL

## Claude API 연동
`PersonaService` 가 실제 대화를 생성하려면 환경변수로 API 키를 설정해야 합니다.
```bash
# PowerShell
$env:ANTHROPIC_API_KEY = "sk-ant-..."
# bash
export ANTHROPIC_API_KEY="sk-ant-..."
```
키가 없으면 자동으로 규칙 기반 폴백 응답(`PersonaService.fallbackReply`)을 사용해 서버는 계속 동작합니다.
모델·토큰 한도는 `application.yml` 의 `maring.claude.*` 에서 조정하세요.
MBTI 유형별 시스템 프롬프트는 `src/main/resources/personas/*.md` 에 있으며, 현재 `infp.md` 만 상세 작성되어 있고
나머지 유형은 `default.md` 로 폴백합니다.

## 실행 방법

### STS(Spring Tool Suite) / IntelliJ
1. `File > Import > Existing Maven Project` (STS) 또는 폴더 열기(IntelliJ)로 `maring-backend` 선택
2. 의존성 다운로드 후 `MaringApplication` 실행 (JDK 17 필요)

### 커맨드라인 (Maven 설치 시)
```bash
mvn spring-boot:run
```
> ⚠️ 이 저장소에는 Maven Wrapper(mvnw)를 포함하지 않았습니다. STS 내장 Maven 또는 로컬 Maven을 사용하세요.

실행 후:
- 서버: http://localhost:8080
- H2 콘솔: http://localhost:8080/h2-console (JDBC URL `jdbc:h2:mem:maring`)

## 프로젝트 구조
```
com.maring.api
├─ MaringApplication.java        # 진입점 (@EnableJpaAuditing)
├─ common/                       # 공통(BaseTimeEntity, 예외처리)
├─ user/                         # 사용자·MBTI (domain/repository/service/controller/dto)
├─ conversation/                 # 대화 세션·메시지 (오케스트레이터)
├─ safety/                       # ★ 안전 파이프라인 (분류기·자원·이벤트)
└─ persona/                      # MBTI 톤 응답 (LLM 연동 자리)
```

## 핵심 설계 — 안전 파이프라인
명세 원칙대로 **안전은 프롬프트가 아니라 별도 분류기 + 스크립트로 이중화**했습니다.
대화 흐름(`ConversationService.sendMessage`):
1. `SafetyClassifier` 로 위기 수준 분류 (NONE/LOW/MEDIUM/HIGH)
2. **MEDIUM 이상** → 안전 플로우: 존댓말 공감 + 위기자원(109·1577-0199) 안내 + `safety_events` 기록
3. 정상 → `PersonaService` 가 MBTI 톤 응답 (지금은 스텁, **실제 구현 시 이 자리에서 LLM 호출**)

## API 빠른 확인 (curl)
```bash
# 1) 회원 생성
curl -X POST localhost:8080/api/users \
  -H "Content-Type: application/json" \
  -d '{"email":"a@b.com","nickname":"은하"}'
# → { "id": "<USER_ID>", ... }

# 2) MBTI 설정
curl -X PUT localhost:8080/api/users/<USER_ID>/mbti \
  -H "Content-Type: application/json" -d '{"mbtiType":"INFP"}'

# 3) 대화 시작
curl -X POST "localhost:8080/api/conversations?userId=<USER_ID>"
# → { "conversationId": "<CONV_ID>" }

# 4) 메시지 — 일반
curl -X POST localhost:8080/api/conversations/<CONV_ID>/messages \
  -H "Content-Type: application/json" -d '{"message":"오늘 좀 지쳤어"}'
# → INFP 톤 공감 응답, riskLevel: NONE

# 5) 메시지 — 위기 감지(안전 플로우)
curl -X POST localhost:8080/api/conversations/<CONV_ID>/messages \
  -H "Content-Type: application/json" -d '{"message":"다 사라지고 싶어"}'
# → safetyTriggered: true, 위기자원 포함 응답

# 6) 위기 자원 목록
curl localhost:8080/api/safety/resources
```

## 다음 단계 (TODO)
- [x] `PersonaService` → 실제 LLM API 연동(유형별 시스템 프롬프트 주입) — 스트리밍은 아직 미구현
- [ ] INFP 외 나머지 15개 MBTI 유형 시스템 프롬프트 작성 (`personas/*.md`)
- [ ] `SafetyClassifier` → 키워드 대신 학습된 위기 분류 모델
- [ ] 캐릭터 성장/감정 리포트/구독 도메인 추가 (명세 Ⅰ·Ⅱ 참조)
- [ ] 인증(JWT), PostgreSQL + Flyway 마이그레이션, 대화 content 암호화
- [ ] 위기자원 번호·운영시간 최신화 및 전문가 검토

---
⚠️ 본 스캐폴드는 기획서·명세 기반 초안입니다. 안전·개인정보 관련 로직은 출시 전 반드시 전문가 검토가 필요합니다.
