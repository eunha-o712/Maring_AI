package com.maring.api.checkin.dto;

import com.maring.api.checkin.domain.EmotionCheckin;
import java.time.LocalDate;
import java.util.UUID;

public record CheckinResponse(
        UUID id,
        String emotionCard,
        int intensity,
        LocalDate checkinDate
) {
    public static CheckinResponse from(EmotionCheckin checkin) {
        return new CheckinResponse(
                checkin.getId(), checkin.getEmotionCard(), checkin.getIntensity(), checkin.getCheckinDate());
    }
}
