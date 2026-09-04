package com.maring.api.checkin.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.util.UUID;

public record CheckinRequest(
        @NotNull UUID userId,
        @NotBlank String emotionCard,
        @Min(1) @Max(5) int intensity
) {
}
