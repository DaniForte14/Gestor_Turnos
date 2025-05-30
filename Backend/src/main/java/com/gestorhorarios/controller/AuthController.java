package com.gestorhorarios.controller;

import com.gestorhorarios.dto.LoginRequest;
import com.gestorhorarios.dto.SignUpRequest;
import com.gestorhorarios.model.Role;
import com.gestorhorarios.model.User;
import com.gestorhorarios.service.UserService;

import java.util.Set;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private UserService userService;

    @PostMapping("/signin")
    public ResponseEntity<?> authenticateUser(@RequestBody LoginRequest loginRequest) {
        try {
            // Verificar si es el administrador
            if ("admin".equals(loginRequest.getUsernameOrEmail()) && "admin123".equals(loginRequest.getPassword())) {
                // Crear respuesta para administrador
                Map<String, Object> adminResponse = new HashMap<>();
                adminResponse.put("success", true);
                adminResponse.put("isAdmin", true);
                adminResponse.put("username", "admin");
                adminResponse.put("message", "Inicio de sesión exitoso como administrador");
                return ResponseEntity.ok(adminResponse);
            }
            
            // Para usuarios normales
            User user = userService.findByUsernameOrEmail(loginRequest.getUsernameOrEmail(), loginRequest.getUsernameOrEmail());
            
            // Verificar si la contraseña coincide (comparación en texto plano)
            if (user != null && user.getPassword().equals(loginRequest.getPassword())) {
                // Autenticación exitosa
                Map<String, Object> response = new HashMap<>();
                response.put("success", true);
                response.put("isAdmin", false);
                response.put("userId", user.getId());
                response.put("username", user.getUsername());
                response.put("email", user.getEmail());
                response.put("nombre", user.getNombre());
                response.put("apellidos", user.getApellidos());
                response.put("message", "Inicio de sesión exitoso");
                
                return ResponseEntity.ok(response);
            } else {
                // Credenciales inválidas
                Map<String, Object> response = new HashMap<>();
                response.put("success", false);
                response.put("message", "Credenciales inválidas");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(response);
            }
        } catch (Exception e) {
            // Error en el servidor
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "Error en el servidor: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    @PostMapping("/signup")
    public ResponseEntity<?> registerUser(@RequestBody SignUpRequest signUpRequest) {
        try {
            if (userService.existsByUsername(signUpRequest.getUsername())) {
                Map<String, Object> response = new HashMap<>();
                response.put("success", false);
                response.put("message", "El nombre de usuario ya está en uso");
                return ResponseEntity.badRequest().body(response);
            }

            if (userService.existsByEmail(signUpRequest.getEmail())) {
                Map<String, Object> response = new HashMap<>();
                response.put("success", false);
                response.put("message", "El correo electrónico ya está en uso");
                return ResponseEntity.badRequest().body(response);
            }

            // Crear nueva cuenta de usuario
            User user = new User();
            user.setUsername(signUpRequest.getUsername());
            user.setEmail(signUpRequest.getEmail());
            user.setPassword(signUpRequest.getPassword());
            user.setNombre(signUpRequest.getNombre());
            user.setApellidos(signUpRequest.getApellidos());
            user.setCentroTrabajo(signUpRequest.getCentroTrabajo());
            user.setLocalidad(signUpRequest.getLocalidad());
            user.setTelefono(signUpRequest.getTelefono());
            
            // Obtener y asignar roles al usuario
            // El método getRoles() ya maneja la validación y normalización de roles
            Set<Role> roles = signUpRequest.getRoles();
            System.out.println("Roles asignados al usuario: " + roles);
            user.setRoles(roles);

            User result = userService.registerUser(user);

            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("message", "Usuario registrado exitosamente");
            response.put("userId", result.getId());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            Map<String, Object> response = new HashMap<>();
            response.put("success", false);
            response.put("message", "Error al registrar el usuario: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
}
