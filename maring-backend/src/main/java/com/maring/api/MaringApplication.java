package com.maring.api;

import com.maring.api.persona.ClaudeProperties;
import com.maring.api.safety.SafetyProperties;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

/**
 * 마링(Maring) 백엔드 진입점.
 * MBTI AI 상담 캐릭터 앱의 API 서버.
 */
@EnableJpaAuditing
@EnableConfigurationProperties({SafetyProperties.class, ClaudeProperties.class})
@SpringBootApplication
public class MaringApplication {

    public static void main(String[] args) {
        SpringApplication.run(MaringApplication.class, args);
    }
}
