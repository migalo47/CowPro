package com.example.sharechannel_backend.auth;

import com.example.sharechannel_backend.dto.LoginRequest;
import com.example.sharechannel_backend.dto.LoginResponse;
import com.example.sharechannel_backend.model.Usuario;
import com.example.sharechannel_backend.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class AuthService {

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtUtil jwtUtil;

    public LoginResponse login(LoginRequest request) {
        Optional<Usuario> optionalUsuario = usuarioRepository.findByCorreo(request.getCorreo());

        if (optionalUsuario.isEmpty()) {
            return new LoginResponse("Usuario no encontrado", null, null, null, null);
        }

        Usuario usuario = optionalUsuario.get();

        if (!passwordEncoder.matches(request.getContrasena(), usuario.getContrasena())) {
            return new LoginResponse("Contraseña incorrecta", null, null, null, null);
        }

        // Convertimos enum TipoUsuario a String
        String rol = usuario.getTipoUsuario().name();

        String token = jwtUtil.generateToken(usuario.getCorreo(), rol); // ✅ Creamos token con rol

        return new LoginResponse(
                "Login exitoso",
                usuario.getIdUsuario(),
                usuario.getNombre(),
                usuario.getCorreo(), // <- Asegúrate que lo tienes en el DTO
                token
        );
    }
}
