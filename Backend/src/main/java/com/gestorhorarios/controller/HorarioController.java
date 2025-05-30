package com.gestorhorarios.controller;

import com.gestorhorarios.model.Horario;
import com.gestorhorarios.model.User;
import com.gestorhorarios.security.CurrentUser;
import com.gestorhorarios.security.UserPrincipal;
import com.gestorhorarios.service.HorarioService;
import com.gestorhorarios.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/horarios")
public class HorarioController {

    @Autowired
    private HorarioService horarioService;
    
    @Autowired
    private UserService userService;

    @GetMapping("/mis-horarios")
    @PreAuthorize("hasRole('MEDICO') or hasRole('ENFERMERO') or hasRole('TCAE')")
    public ResponseEntity<List<Horario>> obtenerMisHorarios(
            @CurrentUser UserPrincipal currentUser,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate inicio,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate fin) {
        
        List<Horario> horarios;
        if (inicio != null && fin != null) {
            horarios = horarioService.getHorariosPorUsuarioId(currentUser.getId(), inicio, fin);
        } else {
            horarios = horarioService.getHorariosPorUsuarioId(currentUser.getId());
        }
        
        return ResponseEntity.ok(horarios);
    }
    
    @GetMapping("/disponibles/rol")
    @PreAuthorize("hasRole('MEDICO') or hasRole('ENFERMERO') or hasRole('TCAE')")
    public ResponseEntity<List<Horario>> obtenerHorariosDisponiblesPorRolYFecha(
            @RequestParam String rol,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate fecha) {
        
        List<Horario> horarios = horarioService.getHorariosDisponiblesPorRolYFecha(rol, fecha);
        return ResponseEntity.ok(horarios);
    }
    
    @GetMapping
    @PreAuthorize("hasRole('MEDICO')")
    public ResponseEntity<List<Horario>> obtenerTodosLosHorarios(
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate inicio,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate fin) {
        
        List<Horario> horarios;
        if (inicio != null && fin != null) {
            horarios = horarioService.getHorariosPorPeriodo(inicio, fin);
        } else {
            horarios = horarioService.getHorariosPorFecha(LocalDate.now());
        }
        
        return ResponseEntity.ok(horarios);
    }
    
    @GetMapping("/fecha/{fecha}")
    @PreAuthorize("hasRole('MEDICO') or hasRole('ENFERMERO') or hasRole('TCAE')")
    public ResponseEntity<List<Horario>> obtenerHorariosPorFecha(
            @PathVariable @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate fecha) {
        
        return ResponseEntity.ok(horarioService.getHorariosPorFecha(fecha));
    }
    
    @GetMapping("/disponibles")
    @PreAuthorize("permitAll()")
    public ResponseEntity<?> obtenerHorariosDisponibles(
            @CurrentUser(required = false) UserPrincipal currentUser,
            @RequestParam(required = false) String rol,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate fecha,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate inicio,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate fin) {
        
        try {
            // Si se proporciona rol y fecha, usar el endpoint de búsqueda por rol
            if (rol != null && fecha != null) {
                return obtenerHorariosDisponiblesPorRolYFecha(rol, fecha);
            }
            
            // Si no hay usuario autenticado, devolver error
            if (currentUser == null) {
                return ResponseEntity.badRequest().body("Se requiere autenticación o parámetros de búsqueda (rol y fecha)");
            }
            
            // Para usuarios autenticados, obtener sus horarios disponibles
            User user = userService.findUserById(currentUser.getId());
            
            List<Horario> horarios;
            if (inicio != null && fin != null) {
                horarios = horarioService.getHorariosDisponibles(user, inicio, fin);
            } else {
                horarios = horarioService.getHorariosDisponibles(user, LocalDate.now(), LocalDate.now().plusMonths(1));
            }
            
            return ResponseEntity.ok(horarios);
            
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("Error al obtener los horarios: " + e.getMessage());
        }
    }
    
    @GetMapping("/{id}")
    @PreAuthorize("hasRole('MEDICO') or hasRole('ENFERMERO') or hasRole('TCAE')")
    public ResponseEntity<Horario> obtenerHorarioPorId(
            @CurrentUser UserPrincipal currentUser,
            @PathVariable Long id) {
        
        Horario horario = horarioService.obtenerHorarioPorId(id);
        
        // Verificar que el usuario tiene permiso para ver este horario
        if (!horario.getUsuario().getId().equals(currentUser.getId()) && 
            !userService.hasRole(currentUser.getId(), "ROLE_MEDICO")) {
            return ResponseEntity.status(403).build();
        }
        
        return ResponseEntity.ok(horario);
    }

    @PostMapping
    @PreAuthorize("hasRole('MEDICO') or hasRole('ENFERMERO') or hasRole('TCAE')")
    public ResponseEntity<Horario> crearHorario(
            @CurrentUser UserPrincipal currentUser,
            @Valid @RequestBody Horario horario) {
        
        User user = userService.findUserById(currentUser.getId());
        horario.setUsuario(user);
        
        return ResponseEntity.ok(horarioService.crearHorario(horario));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('MEDICO') or hasRole('ENFERMERO') or hasRole('TCAE')")
    public ResponseEntity<Horario> actualizarHorario(
            @CurrentUser UserPrincipal currentUser,
            @PathVariable Long id,
            @Valid @RequestBody Horario horario) {
        
        // Verificar que el horario pertenece al usuario actual
        horarioService.verificarPropietario(id, currentUser.getId());
        
        horario.setId(id);
        return ResponseEntity.ok(horarioService.actualizarHorario(horario));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('MEDICO') or hasRole('ENFERMERO') or hasRole('TCAE')")
    public ResponseEntity<?> eliminarHorario(
            @CurrentUser UserPrincipal currentUser,
            @PathVariable Long id) {
        
        // Verificar que el horario pertenece al usuario actual
        horarioService.verificarPropietario(id, currentUser.getId());
        
        horarioService.eliminarHorario(id);
        return ResponseEntity.ok().build();
    }
    
    @PutMapping("/{id}/disponible/{disponible}")
    @PreAuthorize("hasRole('MEDICO') or hasRole('ENFERMERO') or hasRole('TCAE')")
    public ResponseEntity<Horario> cambiarDisponibilidad(
            @CurrentUser UserPrincipal currentUser,
            @PathVariable Long id,
            @PathVariable boolean disponible) {
        
        // Verificar que el horario pertenece al usuario actual
        horarioService.verificarPropietario(id, currentUser.getId());
        
        Horario horario = horarioService.obtenerHorarioPorId(id);
        horario.setDisponible(disponible);
        
        return ResponseEntity.ok(horarioService.actualizarHorario(horario));
    }
}
