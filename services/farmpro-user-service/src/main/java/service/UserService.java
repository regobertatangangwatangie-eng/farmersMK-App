package com.farmpro.user.service;

import com.farmpro.user.dto.AuthResponse;
import com.farmpro.user.dto.LoginRequest;
import com.farmpro.user.dto.UserRequest;
import com.farmpro.user.model.User;
import com.farmpro.user.repository.UserRepository;
import com.farmpro.user.util.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Locale;
import java.util.Optional;

import java.util.List;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JwtUtil jwtUtil;

    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    public User createUser(UserRequest request) {
        User user = new User();
        user.setName(request.getName());
        user.setEmail(request.getEmail() == null ? null : request.getEmail().trim().toLowerCase(Locale.ROOT));
        user.setRole(request.getRole() == null || request.getRole().isBlank() ? "User" : request.getRole());
        String rawPassword = request.getPassword() == null || request.getPassword().isBlank()
                ? "change-me"
                : request.getPassword();
        user.setPassword(passwordEncoder.encode(rawPassword));
        return userRepository.save(user);
    }

    public AuthResponse register(UserRequest request) {
        validateRegisterRequest(request);

        String email = request.getEmail().trim().toLowerCase(Locale.ROOT);
        Optional<User> existing = userRepository.findByEmailIgnoreCase(email);
        if (existing.isPresent()) {
            throw new IllegalArgumentException("A user with this email already exists.");
        }

        User user = new User();
        user.setName(request.getName().trim());
        user.setEmail(email);
        user.setRole(request.getRole() == null || request.getRole().isBlank() ? "User" : request.getRole().trim());
        user.setPassword(passwordEncoder.encode(request.getPassword()));

        User saved = userRepository.save(user);
        String token = jwtUtil.generateToken(saved.getEmail(), saved.getRole());

        return new AuthResponse(token, saved.getId(), saved.getName(), saved.getEmail(), saved.getRole());
    }

    public AuthResponse login(LoginRequest request) {
        if (request.getEmail() == null || request.getEmail().isBlank() ||
                request.getPassword() == null || request.getPassword().isBlank()) {
            throw new IllegalArgumentException("Email and password are required.");
        }

        String email = request.getEmail().trim().toLowerCase(Locale.ROOT);
        User user = userRepository.findByEmailIgnoreCase(email)
                .orElseThrow(() -> new IllegalArgumentException("Invalid email or password."));

        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new IllegalArgumentException("Invalid email or password.");
        }

        String token = jwtUtil.generateToken(user.getEmail(), user.getRole());
        return new AuthResponse(token, user.getId(), user.getName(), user.getEmail(), user.getRole());
    }

    private void validateRegisterRequest(UserRequest request) {
        if (request.getName() == null || request.getName().isBlank()) {
            throw new IllegalArgumentException("Name is required.");
        }
        if (request.getEmail() == null || request.getEmail().isBlank()) {
            throw new IllegalArgumentException("Email is required.");
        }
        if (request.getPassword() == null || request.getPassword().length() < 6) {
            throw new IllegalArgumentException("Password must be at least 6 characters.");
        }
    }

    public List<User> getAllUsers() {
        return userRepository.findAll();
    }
}