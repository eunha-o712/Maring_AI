package com.maring.api.checkin.repository;

import com.maring.api.checkin.domain.EmotionCheckin;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;

public interface EmotionCheckinRepository extends JpaRepository<EmotionCheckin, UUID> {
    List<EmotionCheckin> findByUserIdOrderByCheckinDateDesc(UUID userId);

    Optional<EmotionCheckin> findByUserIdAndCheckinDate(UUID userId, LocalDate checkinDate);
}
