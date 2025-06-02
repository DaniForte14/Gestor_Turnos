package com.gestorhorarios.repository;

import com.gestorhorarios.model.User;
import com.gestorhorarios.model.Vehicle;
import java.util.Set;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Repository for Vehicle entities
 */
@Repository
public interface VehicleRepository extends JpaRepository<Vehicle, Long> {
    
    @Query("SELECT v FROM Vehicle v LEFT JOIN FETCH v.owner LEFT JOIN FETCH v.passengers WHERE v.id = :id")
    Optional<Vehicle> findByIdWithRelations(@Param("id") Long id);
    
    /**
     * Find all active vehicles
     * @return List of active vehicles
     */
    List<Vehicle> findByActiveTrue();
    
    /**
     * Find all active vehicles with their owners
     * @return List of active vehicles with owner information
     */
    @Query("SELECT v FROM Vehicle v LEFT JOIN FETCH v.owner")
    List<Vehicle> findAllWithOwner();
    
    /**
     * Busca un vehículo por su ID cargando también sus pasajeros
     * @param id ID del vehículo
     * @return El vehículo con sus pasajeros cargados
     */
    @Query("SELECT DISTINCT v FROM Vehicle v LEFT JOIN FETCH v.passengers WHERE v.id = :id")
    Optional<Vehicle> findByIdWithPassengers(@Param("id") Long id);
    
    /**
     * Busca todos los vehículos cargando también sus pasajeros
     * @return Lista de vehículos con sus pasajeros cargados
     */
    @Query("SELECT DISTINCT v FROM Vehicle v LEFT JOIN FETCH v.passengers")
    List<Vehicle> findAllWithPassengers();
    
    /**
     * Find all vehicles with available seats greater than the specified value
     * @param seats Minimum number of available seats
     * @return List of vehicles with available seats greater than the specified value
     */
    List<Vehicle> findByAvailableSeatsGreaterThan(int seats);
    
    /**
     * Find all active vehicles for a specific user by user ID
     * @param usuarioId The owner's user ID
     * @return List of active vehicles for the user
     */
    @Query("SELECT v FROM Vehicle v LEFT JOIN FETCH v.owner WHERE v.owner.id = :ownerId")
    List<Vehicle> findByOwnerId(@Param("ownerId") Long ownerId);
    
    /**
     * Find all vehicles for a specific owner
     * @param owner The owner of the vehicles
     * @return List of vehicles owned by the user
     */
    List<Vehicle> findByOwner(User owner);
    

    
    /**
     * Check if a vehicle with the given license plate exists
     * @param matricula The license plate to check
     * @return true if a vehicle with the given license plate exists, false otherwise
     */
    boolean existsByLicensePlate(String licensePlate);
    
    /**
     * Check if a user already owns a vehicle
     * @param owner The user to check
     * @return true if the user owns a vehicle, false otherwise
     */
    boolean existsByOwner(User owner);
    
    /**
     * Find a vehicle by its license plate
     * @param matricula The license plate to search for
     * @return An Optional containing the vehicle if found, or empty otherwise
     */
    Optional<Vehicle> findByLicensePlate(String licensePlate);
    
    /**
     * Find a vehicle by its ID and active status
     * @param id The vehicle ID
     * @param activo The active status
     * @return An Optional containing the vehicle if found, or empty otherwise
     */
    Optional<Vehicle> findById(Long id);
    
    /**
     * Find all vehicles by active status
     * @param activo The active status to filter by
     * @return List of vehicles with the specified active status
     */

    
    /**
     * Find all vehicles with available seats greater than the specified value
     * @param asientosDisponibles The minimum number of available seats
     * @return List of vehicles with available seats greater than the specified value
     */
    List<Vehicle> findByAvailableSeatsGreaterThan(Integer availableSeats);
    
    /**
     * Find all active vehicles with available seats greater than the specified value
     * @param asientosDisponibles The minimum number of available seats
     * @return List of active vehicles with available seats greater than the specified value
     */

    
    /**
     * Find all vehicles by brand and model
     * @param marca The vehicle brand
     * @param modelo The vehicle model
     * @return List of vehicles matching the brand and model
     */
    List<Vehicle> findByBrandAndModel(String brand, String model);
    
    /**
     * Find all active vehicles by brand and model
     * @param marca The vehicle brand
     * @param modelo The vehicle model
     * @return List of active vehicles matching the brand and model
     */

    
    /**
     * Count all active vehicles
     * @return The count of all active vehicles
     */
    long count();
    
    /**
     * Count all vehicles by owner
     * @param usuario The vehicle owner
     * @return The count of vehicles owned by the specified user
     */
    long countByOwner(User owner);
    
    /**
     * Count all active vehicles by owner
     * @param usuario The vehicle owner
     * @return The count of active vehicles owned by the specified user
     */

    /**
     * Find all passengers of a specific vehicle
     * @param vehicleId The ID of the vehicle
     * @return Set of users who are passengers of the specified vehicle
     */
    @Query("SELECT v.passengers FROM Vehicle v WHERE v.id = :vehicleId")
    Set<User> findPassengersByVehicleId(@Param("vehicleId") Long vehicleId);
}
