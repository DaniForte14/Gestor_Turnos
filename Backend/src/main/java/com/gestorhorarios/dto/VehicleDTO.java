package com.gestorhorarios.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import java.time.LocalDateTime;

@Data
public class VehicleDTO {
    private Long id;
    
    @JsonProperty("marca")
    private String brand;
    
    @JsonProperty("modelo")
    private String model;
    
    @JsonProperty("matricula")
    private String licensePlate;
    
    @JsonProperty("color")
    private String color;
    
    @JsonProperty("totalAsientos")
    private Integer totalSeats;
    
    @JsonProperty("asientosDisponibles")
    private Integer availableSeats;
    
    @JsonProperty("observaciones")
    private String observations;
    
    @JsonProperty("activo")
    private Boolean active = true;
    
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // Add getters that ensure non-null values for required fields
    public Integer getTotalSeats() {
        return totalSeats != null ? totalSeats : 0;
    }
    
    public Integer getAvailableSeats() {
        return availableSeats != null ? availableSeats : 0;
    }
    
    public Boolean getActive() {
        return active != null ? active : true;
    }
}