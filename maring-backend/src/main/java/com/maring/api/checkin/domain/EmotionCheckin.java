package com.maring.api.checkin.domain;

import com.maring.api.common.BaseTimeEntity;
import jakarta.persistence.*;
import java.time.LocalDate;
import java.util.UUID;

/**
 * 일일 감정 체크인 (FR-B1). 하루 1회, 감정 카드 선택 + 강도(1~5).
 */
@Entity
@Table(name = "emotion_checkins", uniqueConstraints = @UniqueConstraint(columnNames = {"user_id", "checkin_date"}))
public class EmotionCheckin extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private UUID userId;

    @Column(nullable = false)
    private String emotionCard;

    @Column(nullable = false)
    private int intensity;

    @Column(nullable = false)
    private LocalDate checkinDate;

    protected EmotionCheckin() {
    }

    public EmotionCheckin(UUID userId, String emotionCard, int intensity, LocalDate checkinDate) {
        this.userId = userId;
        this.emotionCard = emotionCard;
        this.intensity = intensity;
        this.checkinDate = checkinDate;
    }

    public void update(String emotionCard, int intensity) {
        this.emotionCard = emotionCard;
        this.intensity = intensity;
    }

    public UUID getId() {
        return id;
    }

    public UUID getUserId() {
        return userId;
    }

    public String getEmotionCard() {
        return emotionCard;
    }

    public int getIntensity() {
        return intensity;
    }

    public LocalDate getCheckinDate() {
        return checkinDate;
    }
}
