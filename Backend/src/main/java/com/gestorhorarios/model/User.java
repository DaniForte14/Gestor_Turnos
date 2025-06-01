package com.gestorhorarios.model;

import com.fasterxml.jackson.annotation.JsonIdentityInfo;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.ObjectIdGenerators;
import jakarta.persistence.*;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

@Data
@Entity
@Table(name = "users")
@JsonIdentityInfo(
    generator = ObjectIdGenerators.PropertyGenerator.class,
    property = "id"
)
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class User {
    
    private static final Logger logger = LoggerFactory.getLogger(User.class);
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "El nombre de usuario es obligatorio")
    @Column(unique = true, nullable = false, length = 50)
    private String username;

    @NotBlank(message = "La contraseña es obligatoria")
    @Column(nullable = false)
    private String password;

    @NotBlank(message = "El nombre es obligatorio")
    @Column(nullable = false, length = 100)
    private String nombre;

    @NotBlank(message = "Los apellidos son obligatorios")
    @Column(nullable = false, length = 100)
    private String apellidos;

    @NotBlank(message = "El email es obligatorio")
    @Email(message = "El formato del email no es válido")
    @Column(unique = true, nullable = false, length = 100)
    private String email;

    @NotBlank(message = "El centro de trabajo es obligatorio")
    @Column(name = "centro_trabajo", nullable = false, length = 100)
    private String centroTrabajo;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vehicle_id")
    @JsonIgnoreProperties({"passengers", "conductor"}) // Ignorar propiedades que pueden causar referencia circular
    private Vehicle vehicle;

    @ManyToMany
    @JoinTable(
        name = "user_vehicle_passengers",
        joinColumns = @JoinColumn(name = "user_id"),
        inverseJoinColumns = @JoinColumn(name = "vehicle_id")
    )
    @JsonIgnore
    private Set<Vehicle> vehiclesAsPassenger = new HashSet<>();

    @NotBlank(message = "La localidad es obligatoria")
    @Column(nullable = false, length = 100)
    private String localidad;

    @Column(length = 20)
    private String telefono;

    @Deprecated
    @Transient
    @JsonIgnore
    private Role role; // Mantenido para compatibilidad, usar roles en su lugar

    @CreationTimestamp
    @Column(name = "fecha_creacion", updatable = false, nullable = false)
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    @Column(name = "fecha_actualizacion", nullable = false)
    private LocalDateTime updatedAt;

    @ElementCollection(targetClass = Role.class, fetch = FetchType.EAGER)
    @Enumerated(EnumType.STRING)
    @CollectionTable(name = "user_roles", joinColumns = @JoinColumn(name = "user_id"))
    @Column(name = "role")
    private Set<Role> roles = new HashSet<>(Set.of(Role.ROLE_USER));
    
    /**
     * Obtiene el rol principal del usuario (para compatibilidad con código existente)
     * @return El primer rol del conjunto o ROLE_USER si no hay roles
     */
    @JsonIgnore
    public Role getRole() {
        return roles.isEmpty() ? Role.ROLE_USER : roles.iterator().next();
    }
    
    /**
     * Establece el rol del usuario (para compatibilidad con código existente)
     * @param role El rol a establecer
     */
    @JsonIgnore
    public void setRole(Role role) {
        this.roles.clear();
        if (role != null) {
            this.roles.add(role);
        }
    }
    
    @JsonIgnore
    public String getPassword() {
        return password;
    }
    
    @JsonIgnore
    public Set<Vehicle> getVehiclesAsPassenger() {
        return vehiclesAsPassenger;
    }
    
    public void setVehiclesAsPassenger(Set<Vehicle> vehiclesAsPassenger) {
        this.vehiclesAsPassenger = vehiclesAsPassenger;
    }
    
    // Helper methods for vehicle operations
    public boolean isInVehicle(Long vehicleId) {
        if (vehicle != null && vehicle.getId().equals(vehicleId)) {
            return true;
        }
        return vehiclesAsPassenger.stream()
            .anyMatch(v -> v.getId().equals(vehicleId));
    }
    
    public void leaveCurrentVehicle() {
        if (vehicle != null) {
            vehicle = null;
        }
        // Remove from any vehicle's passenger list
        new HashSet<>(vehiclesAsPassenger).forEach(v -> 
            v.getPassengers().remove(this)
        );
        vehiclesAsPassenger.clear();
    }

    /**
     * Verifica si el usuario tiene un rol específico
     * @param role Rol a verificar
     * @return true si el usuario tiene el rol especificado
     */
    public boolean hasRole(Role role) {
        return this.role == role;
    }

    /**
     * Verifica si el usuario es administrador
     * @return true si el usuario tiene el rol de administrador
     */
    public boolean isAdmin() {
        return this.role == Role.ROLE_ADMIN;
    }

    /**
     * Añade un vehículo a la lista de vehículos donde el usuario es pasajero
     * @param vehiculo El vehículo a añadir
     * @return true si el vehículo fue añadido, false si ya estaba en la lista
     */
    public boolean añadirVehiculoComoPasajero(Vehicle vehiculo) {
        if (vehiculo == null) {
            logger.warn("Attempted to add null vehicle to user's passenger vehicles");
            return false;
        }
        
        // Inicializar el conjunto si es nulo
        if (vehiclesAsPassenger == null) {
            logger.debug("Initializing vehiclesAsPassenger set for user {}", this.id);
            vehiclesAsPassenger = new HashSet<>();
        }
        
        // Verificar si el vehículo ya está en el conjunto
        if (vehiclesAsPassenger.contains(vehiculo)) {
            logger.debug("User {} is already a passenger in vehicle {}", this.id, vehiculo.getId());
            return false;
        }
        
        logger.debug("Adding vehicle {} to user {}'s passenger vehicles", vehiculo.getId(), this.id);
        boolean added = vehiclesAsPassenger.add(vehiculo);
        
        // Asegurarse de que el vehículo también tenga al usuario como pasajero
        if (added) {
            vehiculo.añadirPasajero(this);
        }
        
        return added;
    }
    
    /**
     * Elimina un vehículo de la lista de vehículos donde el usuario es pasajero
     * @param vehiculo El vehículo a eliminar
     * @return true si el vehículo fue eliminado, false si no estaba en la lista
     */
    public boolean eliminarVehiculoComoPasajero(Vehicle vehiculo) {
        if (vehiculo == null) {
            return false;
        }
        
        boolean removed = vehiclesAsPassenger.remove(vehiculo);
        
        // Asegurarse de que el vehículo también elimine al usuario de sus pasajeros
        if (removed) {
            vehiculo.eliminarPasajero(this);
        }
        
        return removed;
    }
    
    /**
     * Verifica si el usuario es pasajero de un vehículo específico
     * @param vehiculo El vehículo a verificar
     * @return true si el usuario es pasajero del vehículo, false en caso contrario
     */
    public boolean esPasajeroDe(Vehicle vehiculo) {
        return vehiculo != null && 
               vehiclesAsPassenger != null && 
               vehiclesAsPassenger.contains(vehiculo);
    }
}
