package com.example.sharechannel_backend.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

@Configuration
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthenticationFilter;

    public SecurityConfig(JwtAuthenticationFilter jwtAuthenticationFilter) {
        this.jwtAuthenticationFilter = jwtAuthenticationFilter;
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .csrf(csrf -> csrf.disable())
                .sessionManagement(session -> session
                        .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                )
                .authorizeHttpRequests(auth -> auth

                        // ==== Públicos ====
                        .requestMatchers(
                                "/api/auth/login",
                                "/equipos",
                                "/equipos/{id}",
                                "/equipos/disponibles",
                                "/equipos/tipo/**",
                                "/espacios",
                                "/espacios/{id}",
                                "/espacios/tipo/**",
                                "/reservas/disponibilidad",
                                "/usuarios"
                        ).permitAll()

                        // ==== CLIENTE ====
                        .requestMatchers(
                                "/cliente/**",
                                "/facturas/usuario/**",
                                "/facturas/buscar/**",
                                "reservas/fechasNoDisponibles",
                                "/reservas/usuario/**",
                                "/reservas/{id}",
                                "reservas/disponibilidadEquipo",
                                "reservas/disponibilidad",
                                "/reservas",
                                "/pagos/**",
                                "/espacios/disponibles",
                                "/historial/usuario/**",
                                "/notificaciones/usuario/**",
                                "notificaciones/{id}/**",
                                "/usuarios/correo/{correo}",
                                "/usuarios/{id}",
                                "facturas/reserva/**",
                                "notificaciones/todos"
                        ).hasAnyRole("ADMIN","CLIENTE")


                        // ==== ADMIN ====
                        .requestMatchers(
                                "/facturas/**",
                                "/reservas/**",
                                "/equipos/**",
                                "/espacios/**",
                                "/historial/**",
                                "/pagos/**",
                                "/notificaciones/**",
                                "/usuarios/**"
                        ).hasRole("ADMIN")

                        .anyRequest().authenticated()
                )
                .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }
}
