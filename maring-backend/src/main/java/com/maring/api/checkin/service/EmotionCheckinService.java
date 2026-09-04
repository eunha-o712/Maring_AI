package com.maring.api.checkin.service;

import com.maring.api.checkin.domain.EmotionCheckin;
import com.maring.api.checkin.repository.EmotionCheckinRepository;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 하루 1회 감정 체크인. 같은 날 재요청 시 값을 갱신한다(1일 1회 유니크 정책).
 */
@Service
public class EmotionCheckinService {

    private final EmotionCheckinRepository checkinRepository;

    public EmotionCheckinService(EmotionCheckinRepository checkinRepository) {
        this.checkinRepository = checkinRepository;
    }

    @Transactional
    public EmotionCheckin checkin(UUID userId, String emotionCard, int intensity) {
        LocalDate today = LocalDate.now();
        return checkinRepository.findByUserIdAndCheckinDate(userId, today)
                .map(existing -> {
                    existing.update(emotionCard, intensity);
                    return existing;
                })
                .orElseGet(() -> checkinRepository.save(
                        new EmotionCheckin(userId, emotionCard, intensity, today)));
    }

    @Transactional(readOnly = true)
    public List<EmotionCheckin> history(UUID userId) {
        return checkinRepository.findByUserIdOrderByCheckinDateDesc(userId);
    }
}
