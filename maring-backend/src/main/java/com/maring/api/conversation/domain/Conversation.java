package com.maring.api.conversation.domain;

import com.maring.api.common.BaseTimeEntity;
import jakarta.persistence.*;

import java.util.UUID;

/**
 * 상담 대화 세션.
 */
@Entity
@Table(name = "conversations")
public class Conversation extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private UUID userId;

    protected Conversation() {
    }

    public Conversation(UUID userId) {
        this.userId = userId;
    }

    public UUID getId() {
        return id;
    }

    public UUID getUserId() {
        return userId;
    }
}
