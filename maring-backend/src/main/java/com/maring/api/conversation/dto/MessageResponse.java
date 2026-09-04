package com.maring.api.conversation.dto;

import com.maring.api.conversation.domain.Message;
import com.maring.api.safety.RiskLevel;
import java.time.LocalDateTime;
import java.util.UUID;

public record MessageResponse(
        UUID id,
        String role,
        String content,
        RiskLevel riskLevel,
        LocalDateTime createdAt
) {
    public static MessageResponse from(Message message) {
        return new MessageResponse(
                message.getId(),
                message.getRole().name(),
                message.getContent(),
                message.getRiskLevel(),
                message.getCreatedAt());
    }
}
