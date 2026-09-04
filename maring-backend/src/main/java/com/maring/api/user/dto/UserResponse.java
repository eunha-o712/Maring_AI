package com.maring.api.user.dto;

import com.maring.api.user.domain.User;

import java.util.UUID;

public record UserResponse(
        UUID id,
        String email,
        String nickname,
        String speechStyle,
        String mbtiType
) {
    public static UserResponse from(User user) {
        return new UserResponse(
                user.getId(),
                user.getEmail(),
                user.getNickname(),
                user.getSpeechStyle().name(),
                user.getMbtiType()
        );
    }
}
