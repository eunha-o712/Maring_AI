package com.maring.api.persona;

/**
 * Claude API 로 보낼 대화 한 턴. role 은 "user" 또는 "assistant".
 */
public record PersonaTurn(String role, String content) {
}
