package com.example.sharechannel_backend.config;

import com.example.sharechannel_backend.auth.JwtUtil;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.JwtException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    @Autowired
    private JwtUtil jwtUtil;

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain)
            throws ServletException, IOException {

        String authHeader = request.getHeader("Authorization");

        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            System.out.println("❌ No Authorization header or does not start with Bearer");
            filterChain.doFilter(request, response);
            return;
        }

        String token = authHeader.substring(7);
        String correo;
        String rol;

        try {
            correo = jwtUtil.getCorreoFromToken(token);
            rol = jwtUtil.getRolFromToken(token);
        } catch (ExpiredJwtException e) {
            System.out.println("⚠️ Token expirado: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED); // 401
            response.getWriter().write("Token expirado");
            return; // 🛑 No continuar con el filtro
        } catch (JwtException e) {
            System.out.println("⚠️ Token inválido: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED); // 401
            response.getWriter().write("Token inválido");
            return; // 🛑 No continuar con el filtro
        }

        if (correo != null && SecurityContextHolder.getContext().getAuthentication() == null) {
            if (jwtUtil.isTokenValid(token, correo)) {
                System.out.println("🔐 Token válido, autenticando...");

                List<SimpleGrantedAuthority> authorities = List.of(new SimpleGrantedAuthority("ROLE_" + rol));

                UsernamePasswordAuthenticationToken authToken =
                        new UsernamePasswordAuthenticationToken(correo, null, authorities);

                authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                SecurityContextHolder.getContext().setAuthentication(authToken);
            } else {
                System.out.println("❌ Token inválido");
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write("Token inválido");
                return; // 🛑 No continuar
            }
        } else {
            System.out.println("⚠️ Correo es null o ya hay auth en SecurityContextHolder");
        }

        filterChain.doFilter(request, response);
    }
}
