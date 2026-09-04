package com.maring.api.safety;

import com.maring.api.common.BaseTimeEntity;
import jakarta.persistence.*;

import java.util.UUID;

/**
 * 위기 감지 이벤트 로그. 모니터링·감사 대상.
 */
@Entity
@Table(name = "safety_events")
public class SafetyEvent extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private UUID userId;

    private UUID messageId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private RiskLevel riskLevel;

    /** 취해진 조치 (예: RESOURCE_SHOWN) */
    private String actionTaken;

    protected SafetyEvent() {
    }

    public SafetyEvent(UUID userId, UUID messageId, RiskLevel riskLevel, String actionTaken) {
        this.userId = userId;
        this.messageId = messageId;
        this.riskLevel = riskLevel;
        this.actionTaken = actionTaken;
    }

    public UUID getId() {
        return id;
    }

    public UUID getUserId() {
        return userId;
    }

    public UUID getMessageId() {
        return messageId;
    }

    public RiskLevel getRiskLevel() {
        return riskLevel;
    }

    public String getActionTaken() {
        return actionTaken;
    }
}
