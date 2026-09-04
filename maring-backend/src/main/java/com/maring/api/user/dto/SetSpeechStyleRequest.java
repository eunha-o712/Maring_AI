package com.maring.api.user.dto;

import com.maring.api.user.domain.SpeechStyle;
import jakarta.validation.constraints.NotNull;

public record SetSpeechStyleRequest(
        @NotNull SpeechStyle speechStyle
) {
}
