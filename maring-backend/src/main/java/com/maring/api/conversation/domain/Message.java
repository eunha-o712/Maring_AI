package com.maring.api.conversation.domain;

import com.maring.api.common.BaseTimeEntity;
import com.maring.api.safety.RiskLevel;
import jakarta.persistence.*;

import java.util.UUID;

/**
 * 대화 메시지.
 * ⚠️ content 는 민감 정보다. 실제 서비스에서는 저장 시 암호화(🔒)해야 한다.
 */
@Entity
@Table(name = "messages")
public class Message extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private UUID conversationId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private MessageRole role;

    @Column(columnDefinition = "text")
    private String content;

    /** 감정 태깅 결과 (후처리 파이프라인에서 세팅) */
    private String emotionTag;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private RiskLevel riskLevel = RiskLevel.NONE;

    protected Message() {
    }

    public Message(UUID conversationId, MessageRole role, String content, RiskLevel riskLevel) {
        this.conversationId = conversationId;
        this.role = role;
        this.content = content;
        this.riskLevel = riskLevel;
    }

    public void setEmotionTag(String emotionTag) {
        this.emotionTag = emotionTag;
    }

    public UUID getId() {
        return id;
    }

    public UUID getConversationId() {
        return conversationId;
    }

    public MessageRole getRole() {
        return role;
    }

    public String getContent() {
        return content;
    }

    public String getEmotionTag() {
        return emotionTag;
    }

    public RiskLevel getRiskLevel() {
        return riskLevel;
    }
}
