package com.example.sharechannel_backend.auth;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import org.springframework.stereotype.Component;

import java.security.Key;
import java.util.Date;

@Component
public class JwtUtil {

    private static final String SECRET = "EstaEsUnaClaveSecretaSuperLargaParaJWT123456789";
    private static final long EXPIRATION_TIME = 1000 * 60 * 60 * 24; // 24 horas

    private final Key key = Keys.hmacShaKeyFor(SECRET.getBytes());

    // Generar un token JWT con el correo del usuario
    public String generateToken(String correo, String rol) {
        return Jwts.builder()
                .setSubject(correo)
                .claim("rol", rol) // Añadimos el rol sin el prefijo ROLE_
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + EXPIRATION_TIME))
                .signWith(key)
                .compact();
    }



    public String getRolFromToken(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(key)
                .build()
                .parseClaimsJws(token)
                .getBody()
                .get("rol", String.class);
    }



    // Obtener el correo del token
    public String getCorreoFromToken(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(key)
                .build()
                .parseClaimsJws(token)
                .getBody()
                .getSubject();
    }

    // Validar que el token sea correcto y no esté expirado
    public boolean isTokenValid(String token, String correo) {
        try {
            Claims claims = Jwts.parserBuilder()
                    .setSigningKey(key)
                    .build()
                    .parseClaimsJws(token)
                    .getBody();

            String usernameInToken = claims.getSubject();

            return usernameInToken != null && usernameInToken.equals(correo);
        } catch (JwtException | IllegalArgumentException e) {
            return false;
        }
    }

}
