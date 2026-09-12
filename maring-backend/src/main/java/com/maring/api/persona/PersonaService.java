package com.maring.api.persona;

import com.maring.api.user.domain.SpeechStyle;
import java.util.ArrayList;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

/**
 * MBTI 톤이 반영된 마링이의 응답 생성.
 * Claude API 로 실제 대화를 생성하며, API 미설정·호출 실패 시
 * 최소한의 규칙 기반 응답으로 폴백해 서비스가 끊기지 않게 한다.
 */
@Service
public class PersonaService {

    private static final Logger log = LoggerFactory.getLogger(PersonaService.class);

    private final ClaudeClient claudeClient;
    private final PersonaPromptProvider promptProvider;

    public PersonaService(ClaudeClient claudeClient, PersonaPromptProvider promptProvider) {
        this.claudeClient = claudeClient;
        this.promptProvider = promptProvider;
    }

    /**
     * @param mbtiType    사용자 MBTI (예: INFP). null 이면 기본 페르소나.
     * @param nickname    사용자 닉네임 (프롬프트 치환용)
     * @param speechStyle 말투(반말/존댓말)
     * @param history     이전 대화 턴(오래된 순), 최신 사용자 발화는 포함하지 않는다.
     * @param userText    이번 사용자 발화
     * @return 공감 우선 응답
     */
    public String reply(String mbtiType, String nickname, SpeechStyle speechStyle,
                         List<PersonaTurn> history, String userText) {
        try {
            String systemPrompt = promptProvider.buildSystemPrompt(mbtiType, nickname, speechStyle);
            List<PersonaTurn> turns = new ArrayList<>(history);
            turns.add(new PersonaTurn("user", userText));
            return claudeClient.generateReply(systemPrompt, turns);
        } catch (ClaudeApiException e) {
            log.warn("Claude API 호출 실패, 규칙 기반 응답으로 폴백합니다: {}", e.getMessage());
            return fallbackReply(mbtiType, speechStyle);
        }
    }

    private String fallbackReply(String mbtiType, SpeechStyle speechStyle) {
        if (speechStyle == SpeechStyle.JONDAENMAL) {
            return "이야기해 주셔서 고마워요. 지금 어떤 마음인지 조금 더 들려주실래요? "
                    + "편한 속도로 말씀해 주세요. 곁에서 듣고 있을게요.";
        }
        String type = mbtiType == null ? "" : mbtiType.toUpperCase();

        if (type.equals("INFP")) {
            return "그런 마음이 들 만큼 힘든 하루였구나. "
                    + "천천히, 지금 제일 무거운 게 뭔지 같이 들여다볼까? "
                    + "말이 잘 안 나오면 떠오르는 단어 하나여도 괜찮아.";
        }

        return "얘기해줘서 고마워. 지금 느끼는 그 마음, 충분히 그럴 만해. "
                + "조금 더 들려줄래? 내가 옆에서 들을게.";
    }
}
