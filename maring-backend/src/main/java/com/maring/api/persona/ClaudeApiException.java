package com.maring.api.persona;

/**
 * Claude API 호출 실패(설정 누락, 네트워크 오류, 4xx/5xx 등)를 감싸는 예외.
 * PersonaService 가 이를 잡아 규칙 기반 폴백 응답으로 대체한다.
 */
public class ClaudeApiException extends RuntimeException {

    public ClaudeApiException(String message) {
        super(message);
    }

    public ClaudeApiException(String message, Throwable cause) {
        super(message, cause);
    }
}
