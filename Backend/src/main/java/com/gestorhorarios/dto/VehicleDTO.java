package com.gestorhorarios.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import java.time.LocalDateTime;

@Data
public class VehicleDTO {
    private Long id;
    
    @JsonProperty("brand")
    private String brand;
    
    @JsonProperty("model")
    private String model;
    
    @JsonProperty("licensePlate")
    private String licensePlate;
    
    @JsonProperty("color")
    private String color;
    
    @JsonProperty("totalSeats")
    private Integer totalSeats;
    
    @JsonProperty("availableSeats")
    private Integer availableSeats;
    
    @JsonProperty("observations")
    private String observations;
    
    @JsonProperty("active")
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