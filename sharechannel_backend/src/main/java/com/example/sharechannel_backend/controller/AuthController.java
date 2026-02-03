package com.example.sharechannel_backend.controller;

import com.example.sharechannel_backend.auth.AuthService;
import com.example.sharechannel_backend.dto.LoginRequest;
import com.example.sharechannel_backend.dto.LoginResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin
public class AuthController {

    @Autowired
    private AuthService authService;

    @PostMapping("/login")
    public LoginResponse login(@RequestBody LoginRequest request) {
        return authService.login(request);
    }
}
