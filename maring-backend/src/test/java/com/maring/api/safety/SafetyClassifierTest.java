package com.maring.api.safety;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class SafetyClassifierTest {

    private final SafetyClassifier classifier = new SafetyClassifier();

    @Test
    void 일반_메시지는_위험없음() {
        assertEquals(RiskLevel.NONE, classifier.classify("오늘 좀 피곤했어"));
    }

    @Test
    void 중간위험_표현_감지() {
        RiskLevel level = classifier.classify("그냥 다 사라지고 싶어");
        assertEquals(RiskLevel.MEDIUM, level);
        assertTrue(level.requiresSafetyFlow());
    }

    @Test
    void 고위험_표현_감지() {
        assertEquals(RiskLevel.HIGH, classifier.classify("죽고 싶다는 생각이 들어"));
    }
}
