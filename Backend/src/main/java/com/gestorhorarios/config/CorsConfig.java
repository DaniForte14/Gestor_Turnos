package com.gestorhorarios.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@Configuration
@ConfigurationProperties(prefix = "app.cors")
@EnableConfigurationProperties
@Validated
public class CorsConfig {
    private static final Logger logger = LoggerFactory.getLogger(CorsConfig.class);
    
    private List<String> allowedOrigins = new ArrayList<>();
    private List<String> allowedOriginPatterns = new ArrayList<>();
    private List<String> allowedMethods = new ArrayList<>();
    private List<String> allowedHeaders = new ArrayList<>();
    private List<String> exposedHeaders = new ArrayList<>();
    private boolean allowCredentials = true;
    private Long maxAge = 3600L;

    @Bean
    public CorsFilter corsFilter() {
        logger.info("Configurando CORS...");
        logger.info("Orígenes permitidos: {}", allowedOrigins);
        logger.info("Métodos permitidos: {}", allowedMethods);
        logger.info("Headers permitidos: {}", allowedHeaders);
        logger.info("Headers expuestos: {}", exposedHeaders);
        logger.info("Credenciales permitidas: {}", allowCredentials);
        
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        CorsConfiguration config = new CorsConfiguration();
        
        // Configuración de orígenes permitidos
        if (allowedOrigins != null && !allowedOrigins.isEmpty()) {
            allowedOrigins.forEach(origin -> {
                logger.info("Agregando origen permitido: {}", origin);
                config.addAllowedOrigin(origin);
            });
        } else {
            logger.warn("No se configuraron orígenes específicos, permitiendo todos los orígenes");
            config.addAllowedOrigin("*");
        }
        
        // Configuración de patrones de orígenes permitidos
        if (allowedOriginPatterns != null && !allowedOriginPatterns.isEmpty()) {
            allowedOriginPatterns.forEach(pattern -> {
                logger.info("Agregando patrón de origen permitido: {}", pattern);
                config.addAllowedOriginPattern(pattern);
            });
        }
        
        // Configuración de métodos HTTP permitidos
        if (allowedMethods != null && !allowedMethods.isEmpty()) {
            config.setAllowedMethods(allowedMethods);
        } else {
            logger.info("Usando métodos HTTP permitidos por defecto");
            config.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH", "HEAD"));
        }
        
        // Configuración de headers permitidos
        if (allowedHeaders != null && !allowedHeaders.isEmpty()) {
            config.setAllowedHeaders(allowedHeaders);
        } else {
            logger.info("Usando headers permitidos por defecto");
            config.setAllowedHeaders(Arrays.asList("*"));
        }
        
        // Configuración de headers expuestos
        if (exposedHeaders != null && !exposedHeaders.isEmpty()) {
            config.setExposedHeaders(exposedHeaders);
        } else {
            logger.info("Usando headers expuestos por defecto");
            config.setExposedHeaders(Arrays.asList("Authorization", "Content-Type", "Content-Disposition"));
        }
        
        // Configuración de credenciales
        config.setAllowCredentials(allowCredentials);
        
        // Configuración de max age
        if (maxAge != null && maxAge > 0) {
            config.setMaxAge(maxAge);
        } else {
            logger.info("Usando maxAge por defecto: 3600 segundos");
            config.setMaxAge(3600L);
        }
        
        // Aplicar configuración a todas las rutas
        source.registerCorsConfiguration("/**", config);
        
        logger.info("Configuración CORS aplicada correctamente");
        return new CorsFilter(source);
    }
    
    // Getters y Setters
    public List<String> getAllowedOrigins() {
        return allowedOrigins;
    }

    public void setAllowedOrigins(List<String> allowedOrigins) {
        this.allowedOrigins = allowedOrigins;
    }

    public List<String> getAllowedOriginPatterns() {
        return allowedOriginPatterns;
    }

    public void setAllowedOriginPatterns(List<String> allowedOriginPatterns) {
        this.allowedOriginPatterns = allowedOriginPatterns;
    }

    public List<String> getAllowedMethods() {
        return allowedMethods;
    }

    public void setAllowedMethods(List<String> allowedMethods) {
        this.allowedMethods = allowedMethods;
    }

    public List<String> getAllowedHeaders() {
        return allowedHeaders;
    }

    public void setAllowedHeaders(List<String> allowedHeaders) {
        this.allowedHeaders = allowedHeaders;
    }

    public List<String> getExposedHeaders() {
        return exposedHeaders;
    }

    public void setExposedHeaders(List<String> exposedHeaders) {
        this.exposedHeaders = exposedHeaders;
    }

    public boolean isAllowCredentials() {
        return allowCredentials;
    }

    public void setAllowCredentials(boolean allowCredentials) {
        this.allowCredentials = allowCredentials;
    }

    public Long getMaxAge() {
        return maxAge;
    }

    public void setMaxAge(Long maxAge) {
        this.maxAge = maxAge;
    }
}
