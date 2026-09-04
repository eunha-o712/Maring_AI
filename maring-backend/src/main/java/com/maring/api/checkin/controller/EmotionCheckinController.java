package com.maring.api.checkin.controller;

import com.maring.api.checkin.dto.CheckinRequest;
import com.maring.api.checkin.dto.CheckinResponse;
import com.maring.api.checkin.service.EmotionCheckinService;
import jakarta.validation.Valid;
import java.util.List;
import java.util.UUID;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/checkins")
public class EmotionCheckinController {

    private final EmotionCheckinService checkinService;

    public EmotionCheckinController(EmotionCheckinService checkinService) {
        this.checkinService = checkinService;
    }

    /** 오늘의 감정 체크인 (S-05). 이미 체크인했으면 갱신. */
    @PostMapping
    public ResponseEntity<CheckinResponse> checkin(@Valid @RequestBody CheckinRequest request) {
        var checkin = checkinService.checkin(request.userId(), request.emotionCard(), request.intensity());
        return ResponseEntity.ok(CheckinResponse.from(checkin));
    }

    /** 감정 캘린더용 히스토리 (S-08) */
    @GetMapping
    public ResponseEntity<List<CheckinResponse>> history(@RequestParam UUID userId) {
        List<CheckinResponse> result = checkinService.history(userId).stream()
                .map(CheckinResponse::from)
                .toList();
        return ResponseEntity.ok(result);
    }
}
