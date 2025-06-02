package com.gestorhorarios.model;

import jakarta.persistence.*;
import lombok.*;
import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonIdentityInfo;
import com.fasterxml.jackson.annotation.ObjectIdGenerators;
import com.fasterxml.jackson.annotation.JsonInclude;
import java.util.List;
import java.util.stream.Collectors;

@Entity
@Table(name = "vehicles")
@Data
@Builder(toBuilder = true)
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonIdentityInfo(
    generator = ObjectIdGenerators.PropertyGenerator.class,
    property = "id"
)
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class Vehicle implements Serializable {
    private static final long serialVersionUID = 1L;
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    private Long id;
    
    @Column(nullable = false)
    private String brand;
    
    @Column(nullable = false)
    private String model;
    
    @Column(name = "license_plate", nullable = false, unique = true)
    private String licensePlate;
    
    private String color;
    
    @Column(name = "total_seats", nullable = false)
    @Builder.Default
    private int totalSeats = 4;
    
    @Column(name = "available_seats", nullable = false)
    @Builder.Default
    private int availableSeats = 3;
    
    private String observations;
    
    @Column(nullable = false)
    @Builder.Default
    private boolean active = true;
    
    public boolean isActive() {
        return active;
    }
    
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id", nullable = false)
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler", "vehicle", "vehiclesAsPassenger"})
    @ToString.Exclude
    private User owner;
    
    @ManyToMany(mappedBy = "vehiclesAsPassenger", fetch = FetchType.LAZY)
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler", "vehicle", "vehiclesAsPassenger"})
    @ToString.Exclude
    @JsonIgnore
    @Builder.Default
    private Set<User> passengers = new HashSet<>();
    
    // Helper methods for managing passengers
    public boolean addPassenger(User user) {
        if (user == null) {
            return false;
        }
        if (passengers == null) {
            passengers = new HashSet<>();
        }
        boolean added = passengers.add(user);
        if (added) {
            user.addVehicleAsPassenger(this);
        }
        return added;
    }
    
    public boolean removePassenger(User user) {
        if (user == null || passengers == null) {
            return false;
        }
        boolean removed = passengers.remove(user);
        if (removed) {
            user.removeVehicleAsPassenger(this);
        }
        return removed;
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
    
    // No duplicate methods needed - using the ones above with bidirectional relationship support
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
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