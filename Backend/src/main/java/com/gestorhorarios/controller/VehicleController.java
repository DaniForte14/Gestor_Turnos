package com.gestorhorarios.controller;

import com.gestorhorarios.dto.VehicleDTO;
import com.gestorhorarios.dto.VehicleResponseDTO;
import com.gestorhorarios.service.VehicleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.gestorhorarios.security.CurrentUser;
import com.gestorhorarios.security.UserPrincipal;
import java.util.List;

@RestController
@RequestMapping("/api/vehicles")
public class VehicleController {
    
    @Autowired
    private VehicleService vehicleService;
    
    @PostMapping
    public ResponseEntity<?> createVehicle(
            @RequestBody VehicleDTO vehicleDTO,
            @CurrentUser UserPrincipal currentUser) {
        
        System.out.println("Received vehicle creation request from user: " + currentUser.getUsername());
        System.out.println("Vehicle data: " + vehicleDTO);
        
        try {
            VehicleDTO createdVehicle = vehicleService.createVehicle(vehicleDTO, currentUser.getId());
            return ResponseEntity.ok(createdVehicle);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
    
    @GetMapping
    public ResponseEntity<List<VehicleDTO>> getAllVehicles() {
        return ResponseEntity.ok(vehicleService.getAllVehicles());
    }
    
    @GetMapping("/available")
    public ResponseEntity<List<VehicleResponseDTO>> getAvailableVehicles() {
        try {
            List<VehicleResponseDTO> availableVehicles = vehicleService.getAvailableVehicles();
            return ResponseEntity.ok(availableVehicles);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<VehicleDTO> getVehicleById(@PathVariable Long id) {
        try {
            VehicleDTO vehicle = vehicleService.getVehicleById(id);
            return ResponseEntity.ok(vehicle);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
    
    @GetMapping("/{id}/check")
    public ResponseEntity<Boolean> checkUserVehicle(@PathVariable Long id, @CurrentUser UserPrincipal currentUser) {
        boolean hasVehicle = vehicleService.doesUserOwnVehicle(currentUser.getId(), id);
        return ResponseEntity.ok(hasVehicle);
    }
    
    @PostMapping("/{vehicleId}/join/{userId}")
    public ResponseEntity<?> joinVehicle(@PathVariable Long vehicleId, @PathVariable Long userId) {
        try {
            boolean success = vehicleService.joinVehicle(userId, vehicleId);
            if (success) {
                return ResponseEntity.ok().build();
            } else {
                return ResponseEntity.badRequest().body("No se pudo unir al vehículo");
            }
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error al unirse al vehículo");
        }
    }
    
    @PostMapping("/{id}/leave")
    public ResponseEntity<?> leaveVehicle(
            @PathVariable Long id,
            @CurrentUser UserPrincipal currentUser) {
        try {
            boolean success = vehicleService.leaveVehicle(currentUser.getId(), id);
            if (success) {
                return ResponseEntity.ok().build();
            } else {
                return ResponseEntity.badRequest().body("No se pudo salir del vehículo. Puede que no estés en este vehículo.");
            }
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteVehicle(
            @PathVariable Long id,
            @CurrentUser UserPrincipal currentUser) {
        try {
            vehicleService.deleteVehicle(id, currentUser.getId());
            return ResponseEntity.ok().build();
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}
