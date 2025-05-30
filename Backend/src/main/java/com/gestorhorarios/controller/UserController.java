package com.gestorhorarios.controller;

import com.gestorhorarios.model.User;
import com.gestorhorarios.security.CurrentUser;
import com.gestorhorarios.security.UserPrincipal;
import com.gestorhorarios.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.List;

/**
 * Controlador para gestionar las operaciones relacionadas con los usuarios.
 */
@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    /**
     * Obtiene el perfil del usuario actualmente autenticado.
     * 
     * @param currentUser Usuario autenticado
     * @return Perfil del usuario
     */
    @GetMapping("/me")
    public User getCurrentUser(@CurrentUser UserPrincipal currentUser) {
        return userService.findUserById(currentUser.getId());
    }

    /**
     * Obtiene todos los usuarios del sistema.
     * 
     * @return Lista de usuarios
     */
    @GetMapping
    public List<User> getAllUsers() {
        return userService.findAllUsers();
    }

    /**
     * Obtiene un usuario por su ID.
     * 
     * @param id ID del usuario
     * @return Usuario encontrado
     */
    @GetMapping("/{id}")
    public ResponseEntity<User> getUserById(@PathVariable Long id) {
        return ResponseEntity.ok(userService.findUserById(id));
    }

    /**
     * Actualiza la información de un usuario existente.
     * 
     * @param id ID del usuario a actualizar
     * @param userDetails Datos actualizados del usuario
     * @param currentUser Usuario actualmente autenticado
     * @return Usuario actualizado
     */
    @PutMapping("/{id}")
    public ResponseEntity<User> updateUser(
            @CurrentUser UserPrincipal currentUser,
            @PathVariable Long id,
            @Valid @RequestBody User userDetails) {
        userDetails.setId(id);
        return ResponseEntity.ok(userService.updateUser(userDetails));
    }

    /**
     * Elimina un usuario por su ID.
     * 
     * @param id ID del usuario a eliminar
     * @return Respuesta vacía con estado 200 si se eliminó correctamente
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteUser(@PathVariable Long id) {
        userService.deleteUser(id);
        return ResponseEntity.ok().build();
    }
}
