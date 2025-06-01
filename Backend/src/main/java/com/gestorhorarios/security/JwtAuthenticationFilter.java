package com.gestorhorarios.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpHeaders;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Enumeration;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {
    private static final Logger logger = LoggerFactory.getLogger(JwtAuthenticationFilter.class);
    private static final String BEARER_PREFIX = "Bearer ";

    private final JwtTokenProvider tokenProvider;
    private final UserDetailsService userDetailsService;

    public JwtAuthenticationFilter(JwtTokenProvider tokenProvider, UserDetailsService userDetailsService) {
        this.tokenProvider = tokenProvider;
        this.userDetailsService = userDetailsService;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        
        logRequestDetails(request);
        final String requestURI = request.getRequestURI();
        logger.info("Processing request to: {}", requestURI);
        
        // Handle CORS preflight requests
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            logger.debug("Handling CORS preflight request");
            response.setStatus(HttpServletResponse.SC_OK);
            filterChain.doFilter(request, response);
            return;
        }

        try {
            String jwt = getJwtFromRequest(request);
            
            if (StringUtils.hasText(jwt)) {
                logger.debug("JWT token found in request");
                
                if (tokenProvider.validateToken(jwt)) {
                    logger.debug("JWT token is valid, extracting username");
                    String username = tokenProvider.getUsernameFromToken(jwt);
                    
                    if (username != null) {
                        logger.debug("Loading user details for: {}", username);
                        
                        if (SecurityContextHolder.getContext().getAuthentication() == null) {
                            try {
                                UserDetails userDetails = userDetailsService.loadUserByUsername(username);
                                
                                if (userDetails != null) {
                                    logger.debug("Creating authentication for user: {}", username);
                                    UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(
                                        userDetails, null, userDetails.getAuthorities());
                                    authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                                    
                                    SecurityContextHolder.getContext().setAuthentication(authentication);
                                    logger.info("Successfully authenticated user: {} for URI: {}", username, requestURI);
                                } else {
                                    logger.error("User details not found for username: {}", username);
                                    response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "User details not found");
                                    return;
                                }
                            } catch (UsernameNotFoundException ex) {
                                logger.error("User not found: {}", username, ex);
                                response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "User not found");
                                return;
                            } catch (Exception ex) {
                                logger.error("Error loading user details for: {}", username, ex);
                                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading user details");
                                return;
                            }
                        } else {
                            logger.debug("User already authenticated in current context");
                        }
                    } else {
                        logger.error("Username is null from token");
                        response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Invalid token: no username");
                        return;
                    }
                } else {
                    logger.warn("Invalid or expired JWT token");
                    response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Invalid or expired token");
                    return;
                }
            } else {
                logger.debug("No JWT token found in request headers");
                if (requiresAuthentication(request)) {
                    logger.warn("Authentication required but no token provided for: {}", requestURI);
                    response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Authentication required");
                    return;
                }
            }
        } catch (Exception ex) {
            logger.error("Error processing authentication token for request: " + requestURI, ex);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error processing authentication token");
            return;
        }

        // Continue with the filter chain
        filterChain.doFilter(request, response);
    }
    
    private boolean requiresAuthentication(HttpServletRequest request) {
        String path = request.getRequestURI();
        // Add paths that don't require authentication
        return !path.startsWith("/api/auth/") && 
               !path.startsWith("/v3/api-docs") && 
               !path.startsWith("/swagger-ui") &&
               !path.startsWith("/swagger-ui.html");
    }

    private String getJwtFromRequest(HttpServletRequest request) {
        String bearerToken = request.getHeader(HttpHeaders.AUTHORIZATION);
        if (StringUtils.hasText(bearerToken) && bearerToken.startsWith(BEARER_PREFIX)) {
            return bearerToken.substring(BEARER_PREFIX.length());
        }
        
        // Also check URL parameter for token (useful for WebSocket connections)
        String token = request.getParameter("token");
        if (StringUtils.hasText(token)) {
            return token;
        }
        
        return null;
    }
    
    private void logRequestDetails(HttpServletRequest request) {
        if (logger.isDebugEnabled()) {
            logger.debug("Processing request: {} {}", request.getMethod(), request.getRequestURI());
            
            // Log headers
            Enumeration<String> headerNames = request.getHeaderNames();
            while (headerNames.hasMoreElements()) {
                String headerName = headerNames.nextElement();
                if (headerName.equalsIgnoreCase("authorization")) {
                    logger.debug("Header: {} = [PROTECTED]", headerName);
                } else {
                    logger.debug("Header: {} = {}", headerName, request.getHeader(headerName));
                }
            }
            
            // Log parameters
            request.getParameterMap().forEach((key, values) -> {
                if (key.equalsIgnoreCase("token")) {
                    logger.debug("Parameter: {} = [PROTECTED]", key);
                } else {
                    logger.debug("Parameter: {} = {}", key, String.join(", ", values));
                }
            });
        }
    }
}
