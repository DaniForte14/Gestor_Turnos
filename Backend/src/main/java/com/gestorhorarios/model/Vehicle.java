package com.gestorhorarios.model;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;
import com.fasterxml.jackson.annotation.JsonIgnore;
import java.util.List;
import java.util.stream.Collectors;

@Data
@Entity
@Table(name = "vehicles")
public class Vehicle {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false)
    private String brand;
    
    @Column(nullable = false)
    private String model;
    
    @Column(name = "license_plate", nullable = false, unique = true)
    private String licensePlate;
    
    private String color;
    
    @Column(name = "total_seats", nullable = false)
    private Integer totalSeats;
    
    @Column(name = "available_seats", nullable = false)
    private Integer availableSeats;
    
    private String observations;
    
    @Column(nullable = false)
    private Boolean active = true;
    
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id")
    @JsonIgnore
    private User owner;
    
    @ManyToMany(mappedBy = "vehiclesAsPassenger", fetch = FetchType.LAZY)
    @JsonIgnore
    private Set<User> passengers = new HashSet<>();
    
    // Helper methods for managing passengers
    public boolean addPassenger(User user) {
        if (availableSeats <= 0) {
            return false;
        }
        if (passengers.add(user)) {
            user.setVehicle(this);
            availableSeats--;
            return true;
        }
        return false;
    }
    
    public boolean removePassenger(User user) {
        if (passengers.remove(user)) {
            user.setVehicle(null);
            availableSeats++;
            return true;
        }
        return false;
    }
    
    /**
     * Añade un pasajero al vehículo
     * @param user El usuario a añadir como pasajero
     * @return true si el usuario fue añadido, false si ya era pasajero
     */
    public boolean añadirPasajero(User user) {
        return passengers.add(user);
    }
    
    /**
     * Elimina un pasajero del vehículo
     * @param user El usuario a eliminar de los pasajeros
     * @return true si el usuario fue eliminado, false si no era pasajero
     */
    public boolean eliminarPasajero(User user) {
        return passengers.remove(user);
    }
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
    
    @Override
    public String toString() {
        return "Vehicle{" +
                "id=" + id +
                ", brand='" + brand + '\'' +
                ", model='" + model + '\'' +
                ", licensePlate='" + licensePlate + '\'' +
                ", totalSeats=" + totalSeats +
                ", availableSeats=" + availableSeats +
                ", active=" + active +
                '}';
    }
    
    // JSON view methods
    public Long getOwnerId() {
        return owner != null ? owner.getId() : null;
    }
    
    public List<Long> getPassengerIds() {
        return passengers.stream()
            .map(User::getId)
            .collect(Collectors.toList());
    }
    
    public Set<User> getPassengers() {
        return passengers;
    }
    
    public void setPassengers(Set<User> passengers) {
        this.passengers = passengers;
    }
}