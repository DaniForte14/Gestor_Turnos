package com.gestorhorarios.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.gestorhorarios.model.User;
import com.gestorhorarios.model.Vehicle;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * DTO for vehicle responses
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class VehicleResponse {
    private Long id;
    private String brand;
    private String model;
    private String licensePlate;
    private Integer totalSeats;
    private Integer availableSeats;
    private Long ownerId;
    private String ownerName;
    private String ownerEmail;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updatedAt;
    
    /**
     * Creates a VehicleResponse from a Vehicle entity
     * @param vehicle The Vehicle entity
     * @return A new VehicleResponse instance
     */
    public static VehicleResponse fromVehicle(Vehicle vehicle) {
        if (vehicle == null) {
            return null;
        }
        
        VehicleResponseBuilder builder = builder()
                .id(vehicle.getId())
                .brand(vehicle.getBrand())
                .model(vehicle.getModel())
                .licensePlate(vehicle.getLicensePlate())
                .totalSeats(vehicle.getTotalSeats())
                .availableSeats(vehicle.getAvailableSeats())
                .createdAt(vehicle.getCreatedAt())
                .updatedAt(vehicle.getUpdatedAt());
        
        if (vehicle.getOwner() != null) {
            User owner = vehicle.getOwner();
            builder.ownerId(owner.getId())
                   .ownerName(owner.getNombre() + " " + owner.getApellidos())
                   .ownerEmail(owner.getEmail());
        }
        
        return builder.build();
    }
    
    /**
     * Inner class for passenger information
     */
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    @JsonInclude(JsonInclude.Include.NON_NULL)
    public static class PassengerInfo {
        private Long id;
        private String nombreCompleto;
        private String email;
        private String telefono;
        
        public static PassengerInfo fromUser(User user) {
            if (user == null) {
                return null;
            }
            
            return PassengerInfo.builder()
                    .id(user.getId())
                    .nombreCompleto(user.getNombre() + " " + user.getApellidos())
                    .email(user.getEmail())
                    .telefono(user.getTelefono())
                    .build();
        }
    }
}
