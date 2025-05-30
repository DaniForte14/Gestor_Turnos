package com.gestorhorarios.security;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

import java.security.Key;
import java.util.Date;

@Component
public class JwtTokenProvider {

    @Value("${jwt.secret}")
    private String jwtSecret;

    @Value("${jwt.expiration}")
    private long jwtExpirationInMs;

    private Key key;

    @PostConstruct
    public void init() {
        try {
            System.out.println("Inicializando clave JWT con secreto de longitud: " + jwtSecret.length());
            
            // Para HS512, necesitamos una clave de al menos 64 bytes
            if (jwtSecret.length() < 64) {
                System.out.println("ADVERTENCIA: La clave secreta es demasiado corta para HS512, rellenando...");
                StringBuilder paddedSecret = new StringBuilder(jwtSecret);
                while (paddedSecret.length() < 64) {
                    paddedSecret.append(jwtSecret);
                }
                jwtSecret = paddedSecret.substring(0, 64);
                System.out.println("Clave secreta rellenada a longitud: " + jwtSecret.length());
            }
            
            this.key = Keys.hmacShaKeyFor(jwtSecret.getBytes());
            System.out.println("Clave JWT inicializada correctamente");
        } catch (Exception e) {
            System.err.println("Error al inicializar la clave JWT: " + e.getMessage());
            e.printStackTrace();
            // Crear una clave predeterminada en caso de error
            this.key = Keys.secretKeyFor(SignatureAlgorithm.HS512);
            System.out.println("Se ha creado una clave JWT predeterminada debido a un error");
        }
    }


    public String generateToken(Authentication authentication) {
        try {
            System.out.println("Generando token JWT para: " + authentication.getName());
            System.out.println("Autoridades del usuario: " + authentication.getAuthorities());
            
            UserDetails userPrincipal = (UserDetails) authentication.getPrincipal();
            System.out.println("UserDetails obtenido: " + userPrincipal.getUsername());
            
            Date now = new Date();
            Date expiryDate = new Date(now.getTime() + jwtExpirationInMs);
            System.out.println("Token válido hasta: " + expiryDate);
            
            // Verificar que la clave secreta no sea nula
            if (key == null) {
                System.err.println("ERROR: La clave JWT es nula. La inicialización falló.");
                throw new IllegalStateException("La clave JWT no está inicializada correctamente");
            }
            
            String token = Jwts.builder()
                    .setSubject(userPrincipal.getUsername())
                    .setIssuedAt(now)
                    .setExpiration(expiryDate)
                    .signWith(key, SignatureAlgorithm.HS512)
                    .compact();
                    
            System.out.println("Token JWT generado exitosamente");
            return token;
        } catch (Exception e) {
            System.err.println("Error al generar token JWT: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
    }

    public String getUsernameFromToken(String token) {
        Claims claims = Jwts.parserBuilder()
                .setSigningKey(key)
                .build()
                .parseClaimsJws(token)
                .getBody();
        return claims.getSubject();
    }

    public boolean validateToken(String authToken) {
        try {
            Jwts.parserBuilder()
                .setSigningKey(key)
                .build()
                .parseClaimsJws(authToken);
            return true;
        } catch (Exception ex) {
            return false;
        }
    }
}
