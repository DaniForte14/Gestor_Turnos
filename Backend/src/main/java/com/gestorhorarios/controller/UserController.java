package com.gestorhorarios.controller;

import com.gestorhorarios.model.Horario;
import com.gestorhorarios.model.User;
import com.gestorhorarios.security.CurrentUser;
import com.gestorhorarios.security.UserPrincipal;
import com.gestorhorarios.service.HorarioService;
import com.gestorhorarios.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.time.LocalDate;
import java.util.List;

/**
 * Controlador para gestionar las operaciones relacionadas con los usuarios.
 */
@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*")
public class UserController {

    private final UserService userService;
    private final HorarioService horarioService;

    public UserController(UserService userService, HorarioService horarioService) {
        this.userService = userService;
        this.horarioService = horarioService;
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
    
    /**
     * Obtiene los horarios de un usuario específico.
     * 
     * @param id ID del usuario
     * @return Lista de horarios del usuario
     */
    @GetMapping("/{id}/schedules")
    public ResponseEntity<List<Horario>> getUserSchedules(
            @PathVariable Long id,
            @RequestParam(required = false) LocalDate startDate,
            @RequestParam(required = false) LocalDate endDate) {
        
        User user = userService.findUserById(id);
        if (user == null) {
            return ResponseEntity.notFound().build();
        }
        
        List<Horario> schedules;
        if (startDate != null && endDate != null) {
            schedules = horarioService.findByUsuarioAndFechaBetween(user, startDate, endDate);
        } else {
            schedules = horarioService.findByUsuario(user);
        }
        
        return ResponseEntity.ok(schedules);
    }
}
