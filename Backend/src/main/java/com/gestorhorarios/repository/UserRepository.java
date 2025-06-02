package com.gestorhorarios.repository;

import com.gestorhorarios.model.Role;
import com.gestorhorarios.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.Set;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByUsername(String username);
    Optional<User> findByEmail(String email);
    Optional<User> findByUsernameOrEmail(String username, String email);
    boolean existsByUsername(String username);
    boolean existsByEmail(String email);
    List<User> findByRolesIn(Set<Role> roles);
    List<User> findByRolesContaining(Role role);
    
    /**
     * Check if a user is a passenger of a specific vehicle
     * @param userId The ID of the user
     * @param vehicleId The ID of the vehicle
     * @return true if the user is a passenger of the vehicle, false otherwise
     */
    @Query("SELECT COUNT(u) > 0 FROM User u JOIN u.vehiclesAsPassenger v WHERE u.id = :userId AND v.id = :vehicleId")
    boolean isUserPassengerOfVehicle(@Param("userId") Long userId, @Param("vehicleId") Long vehicleId);
    
    /**
     * Find all users who have a specific vehicle assigned to them
     * @param vehicleId The ID of the vehicle to search for
     * @return List of users who have the specified vehicle assigned
     */
    @Query("SELECT u FROM User u WHERE u.vehicle.id = :vehicleId")
    List<User> findByVehicleId(@Param("vehicleId") Long vehicleId);
}
