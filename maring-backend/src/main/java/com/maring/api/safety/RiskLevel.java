package com.maring.api.safety;

/**
 * 위기 위험 수준. Columbia(C-SSRS) 개념을 단순화한 4단계.
 * medium 이상이면 안전 플로우(공감 → 자원 안내)로 전환한다.
 */
public enum RiskLevel {
    NONE,
    LOW,
    MEDIUM,
    HIGH;

    public boolean requiresSafetyFlow() {
        return this == MEDIUM || this == HIGH;
    }
}
