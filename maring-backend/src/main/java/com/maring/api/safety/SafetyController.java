package com.maring.api.safety;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/safety")
public class SafetyController {

    private final SafetyService safetyService;

    public SafetyController(SafetyService safetyService) {
        this.safetyService = safetyService;
    }

    /** 위기 상담 자원 목록 (앱에서 상시 노출 가능) */
    @GetMapping("/resources")
    public ResponseEntity<List<CrisisResource>> resources() {
        return ResponseEntity.ok(safetyService.getCrisisResources());
    }
}
