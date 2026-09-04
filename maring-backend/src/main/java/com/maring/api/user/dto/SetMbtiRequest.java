package com.maring.api.user.dto;

import jakarta.validation.constraints.Pattern;

public record SetMbtiRequest(
        @Pattern(regexp = "^[EI][SN][TF][JP]$", message = "MBTI 4글자 코드여야 합니다 (예: INFP)")
        String mbtiType
) {
}
