package com.maring.api.persona;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;

/**
 * Anthropic Messages API 호출 클라이언트.
 * 실제 서비스에서는 스트리밍(SSE)으로 전환 가능하나, 여기서는 단순 요청/응답으로 구현한다.
 */
@Component
public class ClaudeClient {

    private static final String ANTHROPIC_VERSION = "2023-06-01";

    private final ClaudeProperties properties;
    private final ObjectMapper objectMapper;
    private final RestClient restClient;

    public ClaudeClient(ClaudeProperties properties, ObjectMapper objectMapper) {
        this.properties = properties;
        this.objectMapper = objectMapper;
        this.restClient = RestClient.create(properties.getBaseUrl());
    }

    public String generateReply(String systemPrompt, List<PersonaTurn> turns) {
        if (!properties.isConfigured()) {
            throw new ClaudeApiException("Claude API 키가 설정되지 않았습니다 (ANTHROPIC_API_KEY).");
        }

        Map<String, Object> requestBody = Map.of(
                "model", properties.getModel(),
                "max_tokens", properties.getMaxTokens(),
                "system", systemPrompt,
                "messages", turns.stream()
                        .map(t -> Map.of("role", t.role(), "content", t.content()))
                        .collect(Collectors.toList())
        );

        String rawResponse;
        try {
            rawResponse = restClient.post()
                    .uri("/v1/messages")
                    .header("x-api-key", properties.getApiKey())
                    .header("anthropic-version", ANTHROPIC_VERSION)
                    .header("content-type", "application/json")
                    .body(requestBody)
                    .retrieve()
                    .body(String.class);
        } catch (RestClientException e) {
            throw new ClaudeApiException("Claude API 호출 실패", e);
        }

        return extractText(rawResponse);
    }

    private String extractText(String rawResponse) {
        try {
            JsonNode root = objectMapper.readTree(rawResponse);
            JsonNode content = root.path("content");
            if (content.isArray() && !content.isEmpty()) {
                return content.get(0).path("text").asText();
            }
            throw new ClaudeApiException("Claude 응답에 content 가 없습니다: " + rawResponse);
        } catch (ClaudeApiException e) {
            throw e;
        } catch (Exception e) {
            throw new ClaudeApiException("Claude 응답 파싱 실패", e);
        }
    }
}
