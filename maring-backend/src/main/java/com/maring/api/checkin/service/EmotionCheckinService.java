package com.maring.api.checkin.service;

import com.maring.api.checkin.domain.EmotionCheckin;
import com.maring.api.checkin.repository.EmotionCheckinRepository;
import com.maring.api.user.service.UserService;
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
    private final UserService userService;

    public EmotionCheckinService(EmotionCheckinRepository checkinRepository, UserService userService) {
        this.checkinRepository = checkinRepository;
        this.userService = userService;
    }

    @Transactional
    public EmotionCheckin checkin(UUID userId, String emotionCard, int intensity) {
        userService.get(userId);
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
        userService.get(userId);
        return checkinRepository.findByUserIdOrderByCheckinDateDesc(userId);
    }
}
