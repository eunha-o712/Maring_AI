package com.maring.api.user.controller;

import com.maring.api.user.dto.CreateUserRequest;
import com.maring.api.user.dto.SetMbtiRequest;
import com.maring.api.user.dto.SetSpeechStyleRequest;
import com.maring.api.user.dto.UserResponse;
import com.maring.api.user.service.UserService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    /** 회원 생성 (온보딩) */
    @PostMapping
    public ResponseEntity<UserResponse> create(@Valid @RequestBody CreateUserRequest request) {
        return ResponseEntity.ok(UserResponse.from(userService.create(request)));
    }

    /** 사용자 조회 */
    @GetMapping("/{id}")
    public ResponseEntity<UserResponse> get(@PathVariable UUID id) {
        return ResponseEntity.ok(UserResponse.from(userService.get(id)));
    }

    /** MBTI 설정 (온보딩 진단 결과 반영) */
    @PutMapping("/{id}/mbti")
    public ResponseEntity<UserResponse> setMbti(@PathVariable UUID id,
                                                @Valid @RequestBody SetMbtiRequest request) {
        return ResponseEntity.ok(UserResponse.from(userService.setMbti(id, request.mbtiType())));
    }

    /** 말투 설정 (반말/존댓말, 온보딩) */
    @PutMapping("/{id}/speech-style")
    public ResponseEntity<UserResponse> setSpeechStyle(@PathVariable UUID id,
                                                       @Valid @RequestBody SetSpeechStyleRequest request) {
        return ResponseEntity.ok(UserResponse.from(userService.setSpeechStyle(id, request.speechStyle())));
    }
}
