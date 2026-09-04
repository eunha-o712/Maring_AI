package com.maring.api.persona;

import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * maring.claude.* 설정 바인딩. Claude API 연동 정보.
 */
@ConfigurationProperties(prefix = "maring.claude")
public class ClaudeProperties {

    private String apiKey = "";
    private String model = "claude-sonnet-5";
    private int maxTokens = 1024;
    private String baseUrl = "https://api.anthropic.com";

    public String getApiKey() {
        return apiKey;
    }

    public void setApiKey(String apiKey) {
        this.apiKey = apiKey;
    }

    public String getModel() {
        return model;
    }

    public void setModel(String model) {
        this.model = model;
    }

    public int getMaxTokens() {
        return maxTokens;
    }

    public void setMaxTokens(int maxTokens) {
        this.maxTokens = maxTokens;
    }

    public String getBaseUrl() {
        return baseUrl;
    }

    public void setBaseUrl(String baseUrl) {
        this.baseUrl = baseUrl;
    }

    public boolean isConfigured() {
        return apiKey != null && !apiKey.isBlank();
    }
}
