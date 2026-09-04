package com.maring.api.conversation.dto;

import jakarta.validation.constraints.NotBlank;

public record ChatRequest(
        @NotBlank String message
) {
}
