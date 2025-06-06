package com.gestorhorarios.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import lombok.Data;

/**
 * DTO for creating or updating a vehicle
 */
@Data
public class VehicleRequest {
    
    @NotBlank(message = "Brand is required")
    private String brand;
    
    @NotBlank(message = "Model is required")
    private String model;
    
    @NotBlank(message = "License plate is required")
    private String licensePlate;
    
    @NotNull(message = "Total seats is required")
    @PositiveOrZero(message = "Total seats must be greater than or equal to 0")
    private Integer totalSeats;
    
    // Getters and Setters (generated by Lombok @Data)
}
