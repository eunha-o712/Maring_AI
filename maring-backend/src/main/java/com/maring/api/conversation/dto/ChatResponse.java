package com.maring.api.conversation.dto;

import com.maring.api.safety.CrisisResource;
import com.maring.api.safety.RiskLevel;

import java.util.List;

/**
 * 대화 응답. 위기 감지 시 safetyTriggered=true 이며 crisisResources 가 채워진다.
 */
public record ChatResponse(
        String reply,
        RiskLevel riskLevel,
        boolean safetyTriggered,
        List<CrisisResource> crisisResources
) {
}
