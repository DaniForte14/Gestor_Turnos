package com.gestorhorarios.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.Set;
import java.util.stream.Collectors;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
public class VehicleResponseDTO {
    private Long id;
    private String brand;
    private String model;
    private String licensePlate;
    private String color;
    private Integer totalSeats;
    private Integer availableSeats;
    private String observations;
    private Boolean active;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private Long ownerId;
    private String ownerName;
    private Set<Long> passengerIds;

    public static VehicleResponseDTO fromEntity(com.gestorhorarios.model.Vehicle vehicle) {
        if (vehicle == null) return null;
        
        VehicleResponseDTO dto = new VehicleResponseDTO();
        dto.setId(vehicle.getId());
        dto.setBrand(vehicle.getBrand());
        dto.setModel(vehicle.getModel());
        dto.setLicensePlate(vehicle.getLicensePlate());
        dto.setColor(vehicle.getColor());
        dto.setTotalSeats(vehicle.getTotalSeats());
        dto.setAvailableSeats(vehicle.getAvailableSeats());
        dto.setObservations(vehicle.getObservations());
        dto.setActive(vehicle.isActive());
        dto.setCreatedAt(vehicle.getCreatedAt());
        dto.setUpdatedAt(vehicle.getUpdatedAt());
        
        if (vehicle.getOwner() != null) {
            dto.setOwnerId(vehicle.getOwner().getId());
            dto.setOwnerName(vehicle.getOwner().getNombre() + " " + vehicle.getOwner().getApellidos());
        }
        
        if (vehicle.getPassengers() != null) {
            dto.setPassengerIds(vehicle.getPassengers().stream()
                .map(com.gestorhorarios.model.User::getId)
                .collect(Collectors.toSet()));
        }
        
        return dto;
    }
}
