package com.gestorhorarios.security;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import com.gestorhorarios.config.JwtProperties;

import java.security.Key;
import java.util.Date;

@Component
public class JwtTokenProvider {
    private static final Logger logger = LoggerFactory.getLogger(JwtTokenProvider.class);

    private final String jwtSecret;
    private final long jwtExpirationInMs;
    private final Key key;

    public JwtTokenProvider(JwtProperties jwtProperties) {
        this.jwtSecret = jwtProperties.getSecret();
        this.jwtExpirationInMs = jwtProperties.getExpirationMs();
        
        try {
            System.out.println("Inicializando clave JWT con secreto de longitud: " + this.jwtSecret.length());
            
            // Verify minimum key length for HS512 (64 bytes = 512 bits)
            int minKeyLength = 64; // 512 bits / 8 = 64 bytes
            if (this.jwtSecret.length() < minKeyLength) {
                System.err.println("ADVERTENCIA: El secreto JWT es demasiado corto para HS512. Se generará una clave segura.");
                // Generate a secure random key
                this.key = Keys.secretKeyFor(SignatureAlgorithm.HS512);
                System.out.println("Clave JWT generada automáticamente para HS512");
            } else {
                // Use the provided secret if it's long enough
                this.key = Keys.hmacShaKeyFor(this.jwtSecret.getBytes());
                System.out.println("Clave JWT inicializada correctamente desde la configuración");
            }
            
            System.out.println("Tiempo de expiración configurado: " + this.jwtExpirationInMs + " ms");
        } catch (Exception e) {
            System.err.println("Error al inicializar la clave JWT: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("No se pudo inicializar el proveedor JWT", e);
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
            if (!StringUtils.hasText(authToken)) {
                logger.warn("JWT token is empty or null");
                return false;
            }
            
            logger.info("Validating JWT token");
            logger.debug("Token to validate: {}", authToken);
            
            // First, try to parse the token to check its structure
            Jws<Claims> jws = Jwts.parserBuilder()
                .setSigningKey(key)
                .build()
                .parseClaimsJws(authToken);
                
            // Get claims
            Claims claims = jws.getBody();
            
            // Log token details
            logger.info("JWT Token validated for user: {}", claims.getSubject());
            logger.debug("Token issued at: {}", claims.getIssuedAt());
            logger.debug("Token expires at: {}", claims.getExpiration());
            
            // Check expiration
            if (claims.getExpiration() == null) {
                logger.error("Token has no expiration date");
                return false;
            }
            
            if (claims.getExpiration().before(new Date())) {
                logger.error("Token expired on: {}", claims.getExpiration());
                return false;
            }
            
            // Additional validation - check required claims
            if (claims.getSubject() == null || claims.getSubject().isEmpty()) {
                logger.error("Token has no subject (username)");
                return false;
            }
            
            logger.info("JWT token is valid");
            return true;
            
        } catch (MalformedJwtException ex) {
            logger.error("Invalid JWT token: {}", ex.getMessage());
            logger.debug("Token parsing failed", ex);
        } catch (ExpiredJwtException ex) {
            logger.error("Expired JWT token: {}", ex.getMessage());
            logger.debug("Token expired at: {}", ex.getClaims().getExpiration());
        } catch (UnsupportedJwtException ex) {
            logger.error("Unsupported JWT token: {}", ex.getMessage());
        } catch (IllegalArgumentException ex) {
            logger.error("JWT claims string is empty: {}", ex.getMessage());
        } catch (Exception ex) {
            logger.error("Unexpected error validating JWT token: {}", ex.getMessage(), ex);
        }
        return false;
    }
}
