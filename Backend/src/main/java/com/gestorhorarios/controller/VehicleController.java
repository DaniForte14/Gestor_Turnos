package com.gestorhorarios.controller;

import com.gestorhorarios.dto.VehicleDTO;
import com.gestorhorarios.service.VehicleService;
import org.springframework.beans.factory.annotation.Autowired;
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
    
    @GetMapping("/{id}/check")
    public ResponseEntity<Boolean> checkUserVehicle(@PathVariable Long id, @CurrentUser UserPrincipal currentUser) {
        boolean hasVehicle = vehicleService.doesUserOwnVehicle(currentUser.getId(), id);
        return ResponseEntity.ok(hasVehicle);
    }
    
    @PostMapping("/{id}/join")
    public ResponseEntity<?> joinVehicle(
            @PathVariable Long id,
            @CurrentUser UserPrincipal currentUser) {
        try {
            boolean success = vehicleService.joinVehicle(currentUser.getId(), id);
            if (success) {
                return ResponseEntity.ok().build();
            } else {
                return ResponseEntity.badRequest().body("No se pudo unir al vehículo. Puede que no haya asientos disponibles o ya estés en este vehículo.");
            }
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}
