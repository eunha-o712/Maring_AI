package com.maring.api.user.service;

import com.maring.api.user.domain.User;
import com.maring.api.user.dto.CreateUserRequest;
import com.maring.api.user.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.NoSuchElementException;
import java.util.UUID;

@Service
public class UserService {

    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Transactional
    public User create(CreateUserRequest request) {
        return userRepository.save(new User(request.email(), request.nickname()));
    }

    @Transactional(readOnly = true)
    public User get(UUID id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new NoSuchElementException("사용자를 찾을 수 없습니다: " + id));
    }

    @Transactional
    public User setMbti(UUID id, String mbtiType) {
        User user = get(id);
        user.setMbtiType(mbtiType.toUpperCase());
        return user;
    }

    @Transactional
    public User setSpeechStyle(UUID id, com.maring.api.user.domain.SpeechStyle speechStyle) {
        User user = get(id);
        user.setSpeechStyle(speechStyle);
        return user;
    }
}
