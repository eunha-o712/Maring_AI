package com.maring.api;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Map;
import java.util.UUID;

import static org.hamcrest.Matchers.containsString;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest(properties = {"maring.claude.api-key=", "spring.jpa.show-sql=false"})
@AutoConfigureMockMvc
class ApiFlowTest {
    @Autowired MockMvc mvc;
    @Autowired ObjectMapper json;

    private String createUser() throws Exception {
        String body = mvc.perform(post("/api/users").contentType(MediaType.APPLICATION_JSON)
                .content("{\"nickname\":\"마링친구\"}"))
                .andExpect(status().is2xxSuccessful()).andReturn().getResponse().getContentAsString();
        return json.readTree(body).path("id").asText();
    }

    @Test
    void onboardingCheckinConversationAndSafetyFlow() throws Exception {
        String userId = createUser();
        mvc.perform(put("/api/users/{id}/speech-style", userId).contentType(MediaType.APPLICATION_JSON)
                .content("{\"speechStyle\":\"JONDAENMAL\"}"))
                .andExpect(status().isOk());
        mvc.perform(put("/api/users/{id}/mbti", userId).contentType(MediaType.APPLICATION_JSON)
                .content("{\"mbtiType\":\"INFP\"}"))
                .andExpect(status().isOk()).andExpect(jsonPath("$.mbtiType").value("INFP"));

        for (String emotion : new String[]{"sad", "calm"}) {
            mvc.perform(post("/api/checkins").contentType(MediaType.APPLICATION_JSON)
                    .content(json.writeValueAsString(Map.of("userId", userId, "emotionCard", emotion, "intensity", 3))))
                    .andExpect(status().is2xxSuccessful());
        }
        mvc.perform(get("/api/checkins").param("userId", userId))
                .andExpect(status().isOk()).andExpect(jsonPath("$.length()").value(1))
                .andExpect(jsonPath("$[0].emotionCard").value("calm"));

        String body = mvc.perform(post("/api/conversations").param("userId", userId))
                .andExpect(status().isOk()).andReturn().getResponse().getContentAsString();
        String conversationId = json.readTree(body).path("conversationId").asText();
        mvc.perform(post("/api/conversations/{id}/messages", conversationId).contentType(MediaType.APPLICATION_JSON)
                .content("{\"message\":\"오늘 조금 피곤해요\"}"))
                .andExpect(status().isOk()).andExpect(jsonPath("$.safetyTriggered").value(false))
                .andExpect(jsonPath("$.reply", containsString("고마워요")));
        mvc.perform(post("/api/conversations/{id}/messages", conversationId).contentType(MediaType.APPLICATION_JSON)
                .content("{\"message\":\"다 사라지고 싶어\"}"))
                .andExpect(status().isOk()).andExpect(jsonPath("$.safetyTriggered").value(true))
                .andExpect(jsonPath("$.crisisResources").isNotEmpty());
        mvc.perform(get("/api/conversations/{id}/messages", conversationId))
                .andExpect(status().isOk()).andExpect(jsonPath("$.length()").value(4));
    }

    @Test
    void checkinRejectsUnknownUserAndUnsupportedEmotion() throws Exception {
        mvc.perform(post("/api/checkins").contentType(MediaType.APPLICATION_JSON)
                .content(json.writeValueAsString(Map.of("userId", UUID.randomUUID(), "emotionCard", "joy", "intensity", 3))))
                .andExpect(status().isNotFound());
        String userId = createUser();
        mvc.perform(post("/api/checkins").contentType(MediaType.APPLICATION_JSON)
                .content(json.writeValueAsString(Map.of("userId", userId, "emotionCard", "invalid", "intensity", 3))))
                .andExpect(status().isBadRequest());
        mvc.perform(get("/api/checkins").param("userId", userId))
                .andExpect(jsonPath("$.length()").value(0));
    }

    @Test
    void unknownConversationHistoryIsNotFound() throws Exception {
        mvc.perform(get("/api/conversations/{id}/messages", UUID.randomUUID()))
                .andExpect(status().isNotFound());
    }
}
