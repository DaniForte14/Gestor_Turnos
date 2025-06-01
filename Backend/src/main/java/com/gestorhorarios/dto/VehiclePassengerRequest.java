package com.gestorhorarios.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

/**
 * DTO para las operaciones de pasajeros de vehículos
 */
@Data
public class VehiclePassengerRequest {
    
    @NotNull(message = "El ID del usuario es obligatorio")
    private Long userId;
    
    @NotNull(message = "El ID del vehículo es obligatorio")
    private Long vehicleId;
}
