package com.maring.api.persona;

import com.maring.api.user.domain.SpeechStyle;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Component;
import org.springframework.util.StreamUtils;

/**
 * MBTI 유형별 시스템 프롬프트를 classpath(personas/*.md)에서 로드하고,
 * {닉네임}·{말투} 플레이스홀더를 런타임 값으로 치환한다.
 * 유형별 프롬프트가 없으면 default.md 로 폴백한다.
 */
@Component
public class PersonaPromptProvider {

    private final Map<String, String> templateCache = new ConcurrentHashMap<>();

    public String buildSystemPrompt(String mbtiType, String nickname, SpeechStyle speechStyle) {
        String template = templateCache.computeIfAbsent(
                normalize(mbtiType), this::loadTemplate);

        String speechLabel = speechStyle == SpeechStyle.JONDAENMAL ? "존댓말" : "반말";
        return template
                .replace("{닉네임}", nickname == null ? "친구" : nickname)
                .replace("{말투}", speechLabel);
    }

    private String normalize(String mbtiType) {
        return mbtiType == null ? "" : mbtiType.trim().toLowerCase();
    }

    private String loadTemplate(String normalizedType) {
        if (!normalizedType.isBlank()) {
            String loaded = tryLoad("personas/" + normalizedType + ".md");
            if (loaded != null) {
                return loaded;
            }
        }
        String fallback = tryLoad("personas/default.md");
        if (fallback == null) {
            throw new IllegalStateException("기본 페르소나 프롬프트(personas/default.md)를 찾을 수 없습니다.");
        }
        return fallback;
    }

    private String tryLoad(String classpathLocation) {
        ClassPathResource resource = new ClassPathResource(classpathLocation);
        if (!resource.exists()) {
            return null;
        }
        try {
            return StreamUtils.copyToString(resource.getInputStream(), StandardCharsets.UTF_8);
        } catch (IOException e) {
            throw new IllegalStateException("페르소나 프롬프트 로드 실패: " + classpathLocation, e);
        }
    }
}
