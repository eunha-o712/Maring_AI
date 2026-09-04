package com.maring.api.safety;

import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

/**
 * 안전 서비스. 위기 자원 제공 + 안전 이벤트 기록 + 위기 응답 메시지 생성.
 * 원칙: medium 이상은 공감 → 자원 안내(존댓말) → 이벤트 기록.
 */
@Service
public class SafetyService {

    private final SafetyProperties properties;
    private final SafetyEventRepository safetyEventRepository;

    public SafetyService(SafetyProperties properties, SafetyEventRepository safetyEventRepository) {
        this.properties = properties;
        this.safetyEventRepository = safetyEventRepository;
    }

    public List<CrisisResource> getCrisisResources() {
        return properties.getCrisisResources();
    }

    public void recordEvent(UUID userId, UUID messageId, RiskLevel riskLevel) {
        safetyEventRepository.save(new SafetyEvent(userId, messageId, riskLevel, "RESOURCE_SHOWN"));
    }

    /**
     * 위기 상황 응답 메시지 (사전검수 스크립트에 해당). 존댓말로 공감 + 자원 안내.
     * ⚠️ 실제 서비스에서는 CMS로 관리되는 검수된 스크립트를 사용한다.
     */
    public String buildCrisisMessage() {
        StringBuilder sb = new StringBuilder();
        sb.append("지금 정말 많이 힘드시군요. 그 마음을 꺼내주셔서 고마워요. ");
        sb.append("혼자 견디지 않으셨으면 해요. 지금 바로 도움을 받을 수 있는 곳이 있어요:\n");
        for (CrisisResource r : properties.getCrisisResources()) {
            sb.append("· ").append(r.getName()).append(" ")
              .append(r.getNumber()).append(" (").append(r.getHours()).append(")\n");
        }
        sb.append("제가 옆에 있을게요. 지금 곁에 함께 있어줄 수 있는 사람이 있을까요?");
        return sb.toString();
    }
}
