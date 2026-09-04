package com.maring.api.conversation.service;

import com.maring.api.conversation.domain.Conversation;
import com.maring.api.conversation.domain.Message;
import com.maring.api.conversation.domain.MessageRole;
import com.maring.api.conversation.dto.ChatResponse;
import com.maring.api.conversation.repository.ConversationRepository;
import com.maring.api.conversation.repository.MessageRepository;
import com.maring.api.persona.PersonaService;
import com.maring.api.persona.PersonaTurn;
import com.maring.api.safety.RiskLevel;
import com.maring.api.safety.SafetyClassifier;
import com.maring.api.safety.SafetyService;
import com.maring.api.user.domain.User;
import com.maring.api.user.service.UserService;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.UUID;
import java.util.stream.Collectors;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 대화 오케스트레이터.
 * 요청 처리 순서(명세 4.2): 입력 → 위기 분류기 선통과 → (위기면 안전 플로우) → 아니면 페르소나 응답 → 저장.
 */
@Service
public class ConversationService {

    private final ConversationRepository conversationRepository;
    private final MessageRepository messageRepository;
    private final SafetyClassifier safetyClassifier;
    private final SafetyService safetyService;
    private final PersonaService personaService;
    private final UserService userService;

    public ConversationService(ConversationRepository conversationRepository,
                               MessageRepository messageRepository,
                               SafetyClassifier safetyClassifier,
                               SafetyService safetyService,
                               PersonaService personaService,
                               UserService userService) {
        this.conversationRepository = conversationRepository;
        this.messageRepository = messageRepository;
        this.safetyClassifier = safetyClassifier;
        this.safetyService = safetyService;
        this.personaService = personaService;
        this.userService = userService;
    }

    @Transactional
    public Conversation start(UUID userId) {
        userService.get(userId); // 존재 검증
        return conversationRepository.save(new Conversation(userId));
    }

    @Transactional
    public ChatResponse sendMessage(UUID conversationId, String text) {
        Conversation conversation = conversationRepository.findById(conversationId)
                .orElseThrow(() -> new NoSuchElementException("대화를 찾을 수 없습니다: " + conversationId));
        User user = userService.get(conversation.getUserId());

        // 1) 위기 분류기 선통과
        RiskLevel risk = safetyClassifier.classify(text);

        // 페르소나 호출에 쓸 이전 대화 턴 (이번 사용자 발화 저장 전에 조회)
        List<PersonaTurn> history = messageRepository.findByConversationIdOrderByCreatedAtAsc(conversationId)
                .stream()
                .map(m -> new PersonaTurn(m.getRole() == MessageRole.USER ? "user" : "assistant", m.getContent()))
                .collect(Collectors.toList());

        // 사용자 메시지 저장 (risk 태깅)
        Message userMessage = messageRepository.save(
                new Message(conversationId, MessageRole.USER, text, risk));

        // 2) 위기(medium 이상) → 안전 플로우
        if (risk.requiresSafetyFlow()) {
            String crisisReply = safetyService.buildCrisisMessage();
            messageRepository.save(new Message(conversationId, MessageRole.ASSISTANT, crisisReply, risk));
            safetyService.recordEvent(user.getId(), userMessage.getId(), risk);
            return new ChatResponse(crisisReply, risk, true, safetyService.getCrisisResources());
        }

        // 3) 정상 → 페르소나 응답 (LLM 호출, 실패 시 규칙 기반 폴백)
        String reply = personaService.reply(
                user.getMbtiType(), user.getNickname(), user.getSpeechStyle(), history, text);
        messageRepository.save(new Message(conversationId, MessageRole.ASSISTANT, reply, RiskLevel.NONE));

        return new ChatResponse(reply, risk, false, List.of());
    }

    @Transactional(readOnly = true)
    public List<Message> history(UUID conversationId) {
        return messageRepository.findByConversationIdOrderByCreatedAtAsc(conversationId);
    }
}
