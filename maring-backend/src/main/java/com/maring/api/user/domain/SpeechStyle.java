package com.maring.api.user.domain;

/**
 * 마링이의 말투. 기본은 반말, 위기·안전 안내 시 존댓말로 전환하는 정책과 연동.
 */
public enum SpeechStyle {
    BANMAL,     // 반말
    JONDAENMAL  // 존댓말
}
