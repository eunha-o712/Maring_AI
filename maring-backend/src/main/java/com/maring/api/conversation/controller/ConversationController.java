package com.maring.api.conversation.controller;

import com.maring.api.conversation.dto.ChatRequest;
import com.maring.api.conversation.dto.ChatResponse;
import com.maring.api.conversation.dto.MessageResponse;
import com.maring.api.conversation.service.ConversationService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/conversations")
public class ConversationController {

    private final ConversationService conversationService;

    public ConversationController(ConversationService conversationService) {
        this.conversationService = conversationService;
    }

    /** 대화 세션 시작 */
    @PostMapping
    public ResponseEntity<Map<String, UUID>> start(@RequestParam UUID userId) {
        UUID id = conversationService.start(userId).getId();
        return ResponseEntity.ok(Map.of("conversationId", id));
    }

    /** 메시지 전송 → 위기 분류 → (안전 플로우 or 페르소나 응답) */
    @PostMapping("/{conversationId}/messages")
    public ResponseEntity<ChatResponse> send(@PathVariable UUID conversationId,
                                             @Valid @RequestBody ChatRequest request) {
        return ResponseEntity.ok(conversationService.sendMessage(conversationId, request.message()));
    }

    /** 대화 히스토리 조회 (S-08 마음 기록) */
    @GetMapping("/{conversationId}/messages")
    public ResponseEntity<List<MessageResponse>> history(@PathVariable UUID conversationId) {
        List<MessageResponse> result = conversationService.history(conversationId).stream()
                .map(MessageResponse::from)
                .toList();
        return ResponseEntity.ok(result);
    }
}
