package com.gestorhorarios.controller;

import com.gestorhorarios.dto.LoginRequest;
import com.gestorhorarios.dto.SignUpRequest;
import com.gestorhorarios.exception.AppException;
import com.gestorhorarios.model.Role;
import com.gestorhorarios.model.User;
import com.gestorhorarios.security.JwtTokenProvider;
import com.gestorhorarios.service.UserService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

/**
 * Controller for handling authentication requests
 */
@RestController
@RequestMapping("/api/auth")
public class AuthController {
    private static final Logger logger = LoggerFactory.getLogger(AuthController.class);

    private final UserService userService;
    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider tokenProvider;

    public AuthController(UserService userService, 
                         AuthenticationManager authenticationManager,
                         JwtTokenProvider tokenProvider) {
        this.userService = userService;
        this.authenticationManager = authenticationManager;
        this.tokenProvider = tokenProvider;
    }

    /**
     * Authenticate user and return JWT token
     * @param loginRequest Login credentials
     * @return JWT token and user details
     */
    @PostMapping("/signin")
    public ResponseEntity<?> authenticateUser(@Validated @RequestBody LoginRequest loginRequest) {
        logger.info("Login attempt for user: {}", loginRequest.getUsernameOrEmail());
        
        try {
            // Authenticate user
            Authentication authentication = authenticate(loginRequest.getUsernameOrEmail(), loginRequest.getPassword());
            
            // Get user details from database
            User user = userService.getUserByUsernameOrEmail(
                loginRequest.getUsernameOrEmail(), 
                loginRequest.getUsernameOrEmail()
            );
            
            logger.info("User found: {} with role: {}", user.getUsername(), user.getRole());
            
            // Generate JWT token with user details
            String jwt = tokenProvider.generateToken(authentication);
            
            // Build response with user data from database
            return createSuccessResponse(user, jwt);
            
        } catch (BadCredentialsException e) {
            logger.error("Invalid credentials for user: {}", loginRequest.getUsernameOrEmail());
            return createErrorResponse("Credenciales inválidas", HttpStatus.UNAUTHORIZED);
        } catch (UsernameNotFoundException e) {
            logger.error("User not found: {}", loginRequest.getUsernameOrEmail());
            return createErrorResponse("Usuario no encontrado", HttpStatus.NOT_FOUND);
        } catch (DisabledException e) {
            logger.error("User account is disabled: {}", loginRequest.getUsernameOrEmail());
            return createErrorResponse("La cuenta está deshabilitada", HttpStatus.FORBIDDEN);
        } catch (Exception e) {
            logger.error("Error during authentication", e);
            return createErrorResponse("Error en el servidor: " + e.getMessage(), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
    
    /**
     * Authenticate user with Spring Security
     */
    private Authentication authenticate(String username, String password) throws AuthenticationException {
        Objects.requireNonNull(username);
        Objects.requireNonNull(password);
        
        try {
            Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(username, password)
            );
            
            SecurityContextHolder.getContext().setAuthentication(authentication);
            return authentication;
            
        } catch (DisabledException e) {
            throw new AppException("Usuario deshabilitado", e, HttpStatus.FORBIDDEN);
        } catch (BadCredentialsException e) {
            throw new AppException("Credenciales inválidas", e, HttpStatus.UNAUTHORIZED);
        }
    }
    
    /**
     * Create success response with user details and JWT token
     */
    private ResponseEntity<Map<String, Object>> createSuccessResponse(User user, String jwt) {
        return createSuccessResponse(user, jwt, "Operación exitosa");
    }
    
    /**
     * Create success response with user details, JWT token and custom message
     */
    private ResponseEntity<Map<String, Object>> createSuccessResponse(User user, String jwt, String message) {
        Map<String, Object> response = new HashMap<>();
        boolean isAdmin = user.getRole() == Role.ROLE_ADMIN;
        
        response.put("success", true);
        response.put("isAdmin", isAdmin);
        response.put("userId", user.getId());
        response.put("username", user.getUsername());
        response.put("email", user.getEmail());
        response.put("nombre", user.getNombre());
        response.put("apellidos", user.getApellidos());
        response.put("role", user.getRole().name());
        response.put("token", jwt);
        response.put("message", message);
        
        logger.info("Operation successful for user: {}", user.getUsername());
        return ResponseEntity.ok(response);
    }
    

    
    /**
     * Create error response
     */
    private ResponseEntity<Map<String, Object>> createErrorResponse(String message, HttpStatus status) {
        Map<String, Object> response = new HashMap<>();
        response.put("success", false);
        response.put("message", message);
        return ResponseEntity.status(status).body(response);
    }

    /**
     * Register a new user
     * @param signUpRequest User registration details
     * @return Success or error response
     */
    @PostMapping("/signup")
    public ResponseEntity<?> registerUser(@Validated @RequestBody SignUpRequest signUpRequest) {
        logger.info("Registration attempt for user: {}", signUpRequest.getUsername());
        
        try {
            // Check if username is already taken
            if (userService.existsByUsername(signUpRequest.getUsername())) {
                logger.warn("Username already in use: {}", signUpRequest.getUsername());
                return createErrorResponse("El nombre de usuario ya está en uso", HttpStatus.BAD_REQUEST);
            }

            // Check if email is already registered
            if (userService.existsByEmail(signUpRequest.getEmail())) {
                logger.warn("Email already in use: {}", signUpRequest.getEmail());
                return createErrorResponse("El correo electrónico ya está en uso", HttpStatus.BAD_REQUEST);
            }
            
            // Create new user with all required fields
            User user = new User();
            user.setUsername(signUpRequest.getUsername().trim());
            user.setEmail(signUpRequest.getEmail().trim());
            user.setPassword(signUpRequest.getPassword());
            user.setNombre(signUpRequest.getNombre().trim());
            user.setApellidos(signUpRequest.getApellidos().trim());
            
            // Set required fields with validation
            if (signUpRequest.getCentroTrabajo() == null || signUpRequest.getCentroTrabajo().trim().isEmpty()) {
                throw new IllegalArgumentException("El centro de trabajo es obligatorio");
            }
            user.setCentroTrabajo(signUpRequest.getCentroTrabajo().trim());
            
            if (signUpRequest.getLocalidad() == null || signUpRequest.getLocalidad().trim().isEmpty()) {
                throw new IllegalArgumentException("La localidad es obligatoria");
            }
            user.setLocalidad(signUpRequest.getLocalidad().trim());
            
            user.setTelefono(signUpRequest.getTelefono() != null ? signUpRequest.getTelefono().trim() : "");
            
            // Set roles
            if (signUpRequest.getRoleNames() != null && !signUpRequest.getRoleNames().isEmpty()) {
                user.getRoles().clear();
                Set<Role> roles = signUpRequest.getRoles();
                if (roles.isEmpty()) {
                    user.setRole(Role.ROLE_USER);
                } else {
                    user.getRoles().addAll(roles);
                }
            } else {
                user.setRole(Role.ROLE_USER);
            }
            
            logger.info("Creating user with username: {}, email: {}, roles: {}", 
                user.getUsername(), user.getEmail(), user.getRoles());
            
            // Save user
            User createdUser = userService.createUser(user);
            
            // Authenticate the newly registered user
            Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                    signUpRequest.getUsername(),
                    signUpRequest.getPassword()
                )
            );
            
            SecurityContextHolder.getContext().setAuthentication(authentication);
            String jwt = tokenProvider.generateToken(authentication);
            
            // Return success response with user details and token
            return createSuccessResponse(createdUser, jwt, "Usuario registrado exitosamente");
            
        } catch (AuthenticationException e) {
            logger.error("Authentication failed after registration", e);
            return createErrorResponse("Error al autenticar al usuario después del registro", HttpStatus.INTERNAL_SERVER_ERROR);
        } catch (Exception e) {
            logger.error("Error during user registration", e);
            return createErrorResponse("Error al registrar el usuario: " + e.getMessage(), 
                                     HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}
