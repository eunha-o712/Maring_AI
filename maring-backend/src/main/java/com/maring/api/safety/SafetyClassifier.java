package com.maring.api.safety;

import org.springframework.stereotype.Component;

import java.util.List;

/**
 * 위기 표현 분류기 (스텁).
 *
 * ⚠️ 실제 서비스에서는 이 키워드 방식 대신 별도의 학습된 분류 모델을 사용해야 한다.
 * 명세 원칙: 안전은 프롬프트만이 아니라 "분류기 + 사전검수 스크립트"로 이중화한다.
 * 여기서는 파이프라인 구조를 보여주기 위한 최소 구현이다.
 */
@Component
public class SafetyClassifier {

    private static final List<String> HIGH_RISK = List.of(
            "죽고 싶", "자살", "죽어버리", "목숨", "뛰어내리", "약을 먹고"
    );

    private static final List<String> MEDIUM_RISK = List.of(
            "사라지고 싶", "없어지고 싶", "다 끝내고 싶", "살기 싫", "의미 없", "포기하고 싶"
    );

    public RiskLevel classify(String text) {
        if (text == null || text.isBlank()) {
            return RiskLevel.NONE;
        }
        String normalized = text.replaceAll("\\s+", "");
        for (String kw : HIGH_RISK) {
            if (normalized.contains(kw.replaceAll("\\s+", ""))) {
                return RiskLevel.HIGH;
            }
        }
        for (String kw : MEDIUM_RISK) {
            if (normalized.contains(kw.replaceAll("\\s+", ""))) {
                return RiskLevel.MEDIUM;
            }
        }
        return RiskLevel.NONE;
    }
}
