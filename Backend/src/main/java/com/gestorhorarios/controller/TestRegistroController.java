package com.gestorhorarios.controller;

import com.gestorhorarios.model.Role;
import com.gestorhorarios.model.User;
import com.gestorhorarios.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/test")
@CrossOrigin(origins = {"http://localhost:3000", "http://localhost:8080", "http://192.168.1.40:8080", "http://192.168.1.40:3000"})
public class TestRegistroController {

    @Autowired
    private UserRepository userRepository;
    
    // Ya no necesitamos el PasswordEncoder porque no estamos encriptando contraseñas
    // @Autowired
    // private PasswordEncoder passwordEncoder;

    // Endpoint super simplificado para probar solo la conexión a la base de datos
    @GetMapping("/test-db")
    public ResponseEntity<?> testDatabase() {
        try {
            long count = userRepository.count();  // Simplemente contar usuarios
            return ResponseEntity.ok("Conexión a base de datos exitosa. Total usuarios: " + count);
        } catch (Exception e) {
            e.printStackTrace();
            StringWriter sw = new StringWriter();
            e.printStackTrace(new PrintWriter(sw));
            return ResponseEntity.status(500).body("Error de base de datos: " + e.getMessage() + "\n\nStack trace: " + sw.toString());
        }
    }
    
    // Endpoint ultra simplificado para crear un usuario de prueba sin datos complejos
    @PostMapping("/usuario-minimo")
    public ResponseEntity<?> crearUsuarioMinimo() {
        try {
            // Usar timestamp para hacer username único
            String timestamp = String.valueOf(System.currentTimeMillis());
            String testUsername = "test_" + timestamp;
            
            System.out.println("Creando usuario de prueba mínimo: " + testUsername);
            
            // Crear un usuario mínimo con solo los campos obligatorios
            User user = new User();
            user.setUsername(testUsername);
            user.setEmail(testUsername + "@test.com");
            // Guardar la contraseña sin encriptar (sólo para desarrollo)
            String plainPassword = "Test1234";
            user.setPassword(plainPassword);
            System.out.println("Guardando contraseña sin encriptar: " + plainPassword);
            user.setNombre("Test");
            user.setApellidos("User");
            user.setCentroTrabajo("Test Hospital");
            user.setLocalidad("Test City");
            user.setTelefono("123456789");
            
            // Asignar rol (ROLE_USER)
            user.setRole(Role.ROLE_USER);
            
            // Guardar el usuario de prueba
            User savedUser = userRepository.save(user);
            
            return ResponseEntity.ok(Map.of(
                "message", "Usuario de prueba registrado exitosamente",
                "userId", savedUser.getId(),
                "username", savedUser.getUsername()
            ));
        } catch (Exception e) {
            e.printStackTrace();
            StringWriter sw = new StringWriter();
            e.printStackTrace(new PrintWriter(sw));
            String fullError = "Error al crear usuario: " + e.getMessage() + "\n\nStack trace: " + sw.toString();
            System.err.println(fullError);
            return ResponseEntity.status(500).body(fullError);
        }
    }
    
    @PostMapping("/login-simple")
    public ResponseEntity<?> loginSimple(@RequestBody Map<String, String> credenciales) {
        try {
            String username = credenciales.get("username");
            String password = credenciales.get("password");
            
            System.out.println("Intento de login para: " + username);
            
            // Buscar usuario por username
            Optional<User> userOpt = userRepository.findByUsername(username);
            
            if (userOpt.isPresent()) {
                User user = userOpt.get();
                // Verificar contraseña (sin encriptar en este ejemplo)
                if (password.equals(user.getPassword())) {
                    // Login exitoso
                    return ResponseEntity.ok(Map.of(
                        "success", true,
                        "message", "Login exitoso",
                        "userId", user.getId(),
                        "username", user.getUsername(),
                        "nombre", user.getNombre(),
                        "apellidos", user.getApellidos()
                    ));
                }
            }
            
            // Si llegamos aquí, las credenciales son incorrectas
            return ResponseEntity.status(401).body(Map.of(
                "success", false,
                "message", "Usuario o contraseña incorrectos"
            ));
            
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body(Map.of(
                "success", false,
                "message", "Error en el servidor: " + e.getMessage()
            ));
        }
    }
    
    @PostMapping("/registro-simple")
    public ResponseEntity<?> registroSimple(@RequestBody Map<String, Object> datos) {
        try {
            // Imprimir los datos recibidos para depuración
            System.out.println("Datos recibidos en registro-simple: " + datos);
            
            // Extraer datos básicos
            String username = (String) datos.get("username");
            String email = (String) datos.get("email");
            String password = (String) datos.get("password");
            String nombre = (String) datos.get("nombre");
            String apellidos = (String) datos.get("apellidos");
            String centroTrabajo = (String) datos.get("centroTrabajo");
            String localidad = (String) datos.get("localidad");
            String telefono = (String) datos.get("telefono");
            
            System.out.println("Valores extraidos - username: " + username + ", email: " + email);
            
            // Verificar si el usuario ya existe
            if (userRepository.existsByUsername(username)) {
                return ResponseEntity.badRequest().body("El nombre de usuario ya está en uso");
            }
            if (userRepository.existsByEmail(email)) {
                return ResponseEntity.badRequest().body("El correo electrónico ya está registrado");
            }
            
            // Crear un nuevo usuario
            User user = new User();
            user.setUsername(username);
            user.setEmail(email);
            // Guardar la contraseña sin encriptar (sólo para desarrollo)
            user.setPassword(password); // Sin encriptar
            System.out.println("Guardando contraseña sin encriptar: " + password);
            user.setNombre(nombre);
            user.setApellidos(apellidos);
            user.setCentroTrabajo(centroTrabajo);
            user.setLocalidad(localidad);
            user.setTelefono(telefono);
            
            // Asignar rol (ROLE_ADMIN)
            user.setRole(Role.ROLE_ADMIN);
            
            System.out.println("Usuario preparado para guardar: " + user);
            
            // Guardar el usuario
            User savedUser = userRepository.save(user);
            
            System.out.println("Usuario guardado exitosamente con ID: " + savedUser.getId());
            
            return ResponseEntity.ok(Map.of(
                "message", "Usuario registrado exitosamente",
                "userId", savedUser.getId(),
                "username", savedUser.getUsername()
            ));
            
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body(
                "Error al registrar: " + e.getMessage() + " - " + e.getClass().getName()
            );
        }
    }
    

}
