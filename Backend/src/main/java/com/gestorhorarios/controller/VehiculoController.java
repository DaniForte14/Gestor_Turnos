package com.gestorhorarios.controller;

import com.gestorhorarios.model.Vehiculo;
import com.gestorhorarios.security.CurrentUser;
import com.gestorhorarios.security.UserPrincipal;
import com.gestorhorarios.service.UserService;
import com.gestorhorarios.service.VehiculoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.List;

@RestController
@RequestMapping("/api/vehiculos")
@CrossOrigin(origins = "*")
public class VehiculoController {

    @Autowired
    private VehiculoService vehiculoService;
    
    @Autowired
    private UserService userService;

    @GetMapping
    @PreAuthorize("hasRole('MEDICO') or hasRole('ENFERMERO') or hasRole('TCAE')")
    public ResponseEntity<List<Vehiculo>> obtenerVehiculosDisponibles() {
        return ResponseEntity.ok(vehiculoService.obtenerVehiculosDisponibles());
    }

    @GetMapping("/mis-vehiculos")
    @PreAuthorize("hasRole('MEDICO') or hasRole('ENFERMERO') or hasRole('TCAE')")
    public ResponseEntity<List<Vehiculo>> obtenerMisVehiculos(@CurrentUser UserPrincipal currentUser) {
        return ResponseEntity.ok(vehiculoService.obtenerVehiculosPorPropietarioId(currentUser.getId()));
    }
    
    @GetMapping("/{id}")
    @PreAuthorize("hasRole('MEDICO') or hasRole('ENFERMERO') or hasRole('TCAE')")
    public ResponseEntity<Vehiculo> obtenerVehiculoPorId(
            @CurrentUser UserPrincipal currentUser,
            @PathVariable Long id) {
        
        Vehiculo vehiculo = vehiculoService.obtenerVehiculoPorId(id);
        
        // Solo permitir acceso al propietario o a los administradores (médicos)
        if (!vehiculo.getPropietario().getId().equals(currentUser.getId()) && 
            !userService.hasRole(currentUser.getId(), "ROLE_MEDICO")) {
            return ResponseEntity.status(403).build();
        }
        
        return ResponseEntity.ok(vehiculo);
    }
    
    @GetMapping("/matricula/{matricula}")
    @PreAuthorize("hasRole('MEDICO')")
    public ResponseEntity<Vehiculo> obtenerVehiculoPorMatricula(
            @PathVariable String matricula) {
        return ResponseEntity.ok(vehiculoService.obtenerVehiculoPorMatricula(matricula));
    }

    @PostMapping
    @PreAuthorize("hasRole('MEDICO') or hasRole('ENFERMERO') or hasRole('TCAE')")
    public ResponseEntity<Vehiculo> registrarVehiculo(
            @CurrentUser UserPrincipal currentUser,
            @Valid @RequestBody Vehiculo vehiculo) {
        return ResponseEntity.ok(vehiculoService.registrarVehiculo(vehiculo, currentUser.getId()));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('MEDICO') or hasRole('ENFERMERO') or hasRole('TCAE')")
    public ResponseEntity<Vehiculo> actualizarVehiculo(
            @CurrentUser UserPrincipal currentUser,
            @PathVariable Long id,
            @Valid @RequestBody Vehiculo vehiculo) {
        vehiculo.setId(id);
        return ResponseEntity.ok(vehiculoService.actualizarVehiculo(vehiculo, currentUser.getId()));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('MEDICO') or hasRole('ENFERMERO') or hasRole('TCAE')")
    public ResponseEntity<?> eliminarVehiculo(
            @CurrentUser UserPrincipal currentUser,
            @PathVariable Long id) {
        vehiculoService.eliminarVehiculo(id, currentUser.getId());
        return ResponseEntity.ok().build();
    }
    
    @DeleteMapping("/{id}/permanente")
    @PreAuthorize("hasRole('MEDICO')")
    public ResponseEntity<?> eliminarVehiculoPermanente(
            @CurrentUser UserPrincipal currentUser,
            @PathVariable Long id) {
        vehiculoService.eliminarVehiculoFisicamente(id, currentUser.getId());
        return ResponseEntity.ok().build();
    }
    
    @PutMapping("/{id}/activo/{activo}")
    @PreAuthorize("hasRole('MEDICO') or hasRole('ENFERMERO') or hasRole('TCAE')")
    public ResponseEntity<Vehiculo> cambiarEstadoActivo(
            @CurrentUser UserPrincipal currentUser,
            @PathVariable Long id,
            @PathVariable boolean activo) {
        
        Vehiculo vehiculo = vehiculoService.obtenerVehiculoPorId(id);
        
        // Solo permitir cambio por el propietario o administradores
        if (!vehiculo.getPropietario().getId().equals(currentUser.getId()) && 
            !userService.hasRole(currentUser.getId(), "ROLE_MEDICO")) {
            return ResponseEntity.status(403).build();
        }
        
        vehiculo.setActivo(activo);
        return ResponseEntity.ok(vehiculoService.actualizarVehiculo(vehiculo, vehiculo.getPropietario().getId()));
    }
}
