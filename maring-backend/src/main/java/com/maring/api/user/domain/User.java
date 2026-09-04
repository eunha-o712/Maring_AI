package com.maring.api.user.domain;

import com.maring.api.common.BaseTimeEntity;
import jakarta.persistence.*;

import java.util.UUID;

/**
 * 사용자 계정.
 */
@Entity
@Table(name = "users")
public class User extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(unique = true)
    private String email;

    @Column(nullable = false)
    private String nickname;

    /** 말투 선택: 반말 / 존댓말 */
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SpeechStyle speechStyle = SpeechStyle.BANMAL;

    /** MBTI 유형 코드 (예: INFP). 온보딩 후 세팅. */
    @Column(length = 4)
    private String mbtiType;

    protected User() {
    }

    public User(String email, String nickname) {
        this.email = email;
        this.nickname = nickname;
    }

    public void setMbtiType(String mbtiType) {
        this.mbtiType = mbtiType;
    }

    public void setSpeechStyle(SpeechStyle speechStyle) {
        this.speechStyle = speechStyle;
    }

    public UUID getId() {
        return id;
    }

    public String getEmail() {
        return email;
    }

    public String getNickname() {
        return nickname;
    }

    public SpeechStyle getSpeechStyle() {
        return speechStyle;
    }

    public String getMbtiType() {
        return mbtiType;
    }
}
