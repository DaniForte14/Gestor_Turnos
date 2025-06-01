package com.gestorhorarios.service;

import com.gestorhorarios.model.User;
import com.gestorhorarios.model.Role;
import com.gestorhorarios.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.logging.Logger;

@Service
public class UserService {
    private static final Logger logger = Logger.getLogger(UserService.class.getName());
    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Transactional
    public User createUser(User user) {
        try {
            // Validar que el usuario no exista
            if (userRepository.existsByUsername(user.getUsername())) {
                throw new RuntimeException("El nombre de usuario ya está en uso");
            }
            if (userRepository.existsByEmail(user.getEmail())) {
                throw new RuntimeException("El correo electrónico ya está registrado");
            }
            
            // En producción, deberíamos codificar la contraseña aquí
            // user.setPassword(passwordEncoder.encode(user.getPassword()));
            
            // Para desarrollo, mantenemos la contraseña en texto plano
            // ya que estamos usando NoOpPasswordEncoder
            
            // Establecer el rol por defecto si no se especifica
            if (user.getRole() == null) {
                user.setRole(Role.ROLE_USER);
            }
            
            // Guardar el usuario
            User savedUser = userRepository.save(user);
            logger.info("Usuario creado exitosamente con ID: " + savedUser.getId());
            return savedUser;
            
        } catch (Exception e) {
            logger.severe("Error al registrar usuario: " + e.getMessage());
            throw new RuntimeException("Error al registrar el usuario: " + e.getMessage(), e);
        }
    }

    public Optional<User> findByUsername(String username) {
        return userRepository.findByUsername(username);
    }
    
    public User getByUsername(String username) {
        return userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado: " + username));
    }

    public User findByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado con el email: " + email));
    }
    
    public Optional<User> findByUsernameOrEmail(String username, String email) {
        System.out.println("Buscando usuario por username o email: " + username + " / " + email);
        return userRepository.findByUsernameOrEmail(username, email);
    }
    
    public User getUserByUsernameOrEmail(String username, String email) {
        System.out.println("Buscando usuario por username o email: " + username + " / " + email);
        return userRepository.findByUsernameOrEmail(username, email)
                .orElseThrow(() -> {
                    System.err.println("Usuario no encontrado con username o email: " + username + " / " + email);
                    return new RuntimeException("Usuario no encontrado con username o email: " + username + " / " + email);
                });
    }

    public User findUserById(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado con el id: " + id));
    }

    public List<User> findAllUsers() {
        return userRepository.findAll();
    }

    public boolean existsByUsername(String username) {
        return userRepository.existsByUsername(username);
    }

    public boolean existsByEmail(String email) {
        return userRepository.existsByEmail(email);
    }

    @Transactional
    public User updateUser(User user) {
        try {
            User existingUser = findUserById(user.getId());
            
            // Actualizar solo los campos permitidos
            existingUser.setNombre(user.getNombre());
            existingUser.setApellidos(user.getApellidos());
            
            // Verificar si el email ha cambiado
            if (!existingUser.getEmail().equals(user.getEmail()) && 
                userRepository.existsByEmail(user.getEmail())) {
                throw new RuntimeException("El correo electrónico ya está en uso");
            }
            existingUser.setEmail(user.getEmail());
            
            // Actualizar otros campos opcionales
            if (user.getCentroTrabajo() != null) {
                existingUser.setCentroTrabajo(user.getCentroTrabajo());
            }
            if (user.getLocalidad() != null) {
                existingUser.setLocalidad(user.getLocalidad());
            }
            if (user.getTelefono() != null) {
                existingUser.setTelefono(user.getTelefono());
            }
            
            // Actualizar contraseña si se proporciona una nueva
            if (user.getPassword() != null && !user.getPassword().isEmpty()) {
                logger.warning("ATENCIÓN: Actualizando contraseña en texto plano - NO USAR EN PRODUCCIÓN");
                existingUser.setPassword(user.getPassword());
            }
            
            // Actualizar la fecha de modificación
            existingUser.setUpdatedAt(java.time.LocalDateTime.now());
            
            return userRepository.save(existingUser);
            
        } catch (Exception e) {
            logger.severe("Error al actualizar usuario: " + e.getMessage());
            throw new RuntimeException("Error al actualizar el usuario: " + e.getMessage(), e);
        }
    }

    @Transactional
    public void deleteUser(Long id) {
        userRepository.deleteById(id);
    }
    
    /**
     * Checks if a user has a specific role
     * @param userId The ID of the user to check
     * @param roleName The name of the role to check (e.g., "ROLE_MEDICO")
     * @return true if the user has the role, false otherwise
     */
    @Transactional(readOnly = true)
    public boolean hasRole(Long userId, String roleName) {
        try {
            User user = findUserById(userId);
            if (user == null || user.getRole() == null) {
                return false;
            }
            // Convert roleName to Role enum and compare
            Role targetRole = Role.valueOf(roleName);
            return user.getRole() == targetRole;
        } catch (IllegalArgumentException e) {
            // Role name doesn't match any enum value
            logger.warning("Invalid role name: " + roleName);
            return false;
        } catch (Exception e) {
            logger.severe("Error checking user role: " + e.getMessage());
            return false;
        }
    }
}
