package com.gestorhorarios.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Configuration;
import org.springframework.validation.annotation.Validated;

import jakarta.annotation.PostConstruct;
import java.util.ArrayList;
import java.util.List;

@Configuration
@ConfigurationProperties(prefix = "app.cors")
@EnableConfigurationProperties
@Validated
public class CorsProperties {
    private List<String> allowedOrigins = new ArrayList<>();
    private List<String> allowedOriginPatterns = new ArrayList<>();
    private List<String> allowedMethods = new ArrayList<>();
    private List<String> allowedHeaders = new ArrayList<>();
    private List<String> exposedHeaders = new ArrayList<>();
    private boolean allowCredentials = false;
    private Long maxAge = 3600L;

    // Getters and Setters
    public List<String> getAllowedOrigins() {
        return allowedOrigins;
    }

    public void setAllowedOrigins(List<String> allowedOrigins) {
        this.allowedOrigins = allowedOrigins;
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

    public List<String> getAllowedOriginPatterns() {
        return allowedOriginPatterns;
    }

    public void setAllowedOriginPatterns(List<String> allowedOriginPatterns) {
        this.allowedOriginPatterns = allowedOriginPatterns;
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
    
    @PostConstruct
    public void validate() {
        if (allowCredentials) {
            // If credentials are allowed, we must have explicit origins or origin patterns
            boolean hasOrigins = allowedOrigins != null && !allowedOrigins.isEmpty();
            boolean hasOriginPatterns = allowedOriginPatterns != null && !allowedOriginPatterns.isEmpty();
            
            if (!hasOrigins && !hasOriginPatterns) {
                throw new IllegalStateException(
                    "CORS configuration error: allowCredentials is true but no allowedOrigins or allowedOriginPatterns are defined. " +
                    "When allowCredentials is true, you must explicitly configure allowed origins.");
            }
            
            // Check for wildcard in allowedOrigins when credentials are enabled
            if (hasOrigins && allowedOrigins.contains("*")) {
                throw new IllegalStateException(
                    "CORS configuration error: Cannot use wildcard ('*') in allowedOrigins when allowCredentials is true. " +
                    "Use allowedOriginPatterns instead with specific patterns.");
            }
        }
    }
    
    @Override
    public String toString() {
        return "CorsProperties{" +
                "allowedOrigins=" + allowedOrigins +
                ", allowedMethods=" + allowedMethods +
                ", allowedHeaders=" + allowedHeaders +
                ", exposedHeaders=" + exposedHeaders +
                ", allowCredentials=" + allowCredentials +
                '}';
    }
}
