package com.maring.api.user.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CreateUserRequest(
        @Email String email,
        @NotBlank @Size(max = 20) String nickname
) {
}
