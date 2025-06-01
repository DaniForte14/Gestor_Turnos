package com.gestorhorarios.service;

import com.gestorhorarios.dto.VehicleDTO;
import com.gestorhorarios.model.User;
import com.gestorhorarios.model.Vehicle;
import com.gestorhorarios.repository.UserRepository;
import com.gestorhorarios.repository.VehicleRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class VehicleService {
    
    @Autowired
    private VehicleRepository vehicleRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    @Transactional
    public VehicleDTO createVehicle(VehicleDTO vehicleDTO, Long userId) {
        System.out.println("Creating vehicle with DTO: " + vehicleDTO);
        
        // Check if license plate already exists
        if (vehicleRepository.existsByLicensePlate(vehicleDTO.getLicensePlate())) {
            throw new RuntimeException("Ya existe un vehículo con esta matrícula");
        }
        
        // Check if user already has a vehicle
        User owner = userRepository.findById(userId)
            .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
            
        if (vehicleRepository.existsByOwner(owner)) {
            throw new RuntimeException("Ya tienes un vehículo registrado. Elimina el vehículo actual antes de crear uno nuevo.");
        }
        
        Vehicle vehicle = new Vehicle();
        System.out.println("Before mapping - Vehicle: " + vehicle);
        mapDtoToEntity(vehicleDTO, vehicle);
        
        // Set the owner of the vehicle
        vehicle.setOwner(owner);
        System.out.println("After mapping - Vehicle: " + vehicle);
        
        vehicle = vehicleRepository.save(vehicle);
        System.out.println("After save - Vehicle: " + vehicle);
        
        return mapEntityToDto(vehicle);
    }
    
    public List<VehicleDTO> getAllVehicles() {
        return vehicleRepository.findByActiveTrue().stream()
            .map(this::mapEntityToDto)
            .collect(Collectors.toList());
    }
    
    /**
     * Check if a user owns a specific vehicle
     * @param userId The ID of the user
     * @param vehicleId The ID of the vehicle to check
     * @return true if the user owns the vehicle, false otherwise
     */
    @Transactional(readOnly = true)
    public boolean doesUserOwnVehicle(Long userId, Long vehicleId) {
        return vehicleRepository.findById(vehicleId)
            .map(vehicle -> {
                User owner = vehicle.getOwner();
                return owner != null && owner.getId().equals(userId);
            })
            .orElse(false);
    }
    
    /**
     * Join a vehicle as a passenger
     * @param userId The ID of the user joining the vehicle
     * @param vehicleId The ID of the vehicle to join
     * @return true if the user successfully joined the vehicle, false otherwise
     */
    @Transactional
    public boolean joinVehicle(Long userId, Long vehicleId) {
        try {
            User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
                
            Vehicle vehicle = vehicleRepository.findById(vehicleId)
                .orElseThrow(() -> new RuntimeException("Vehículo no encontrado"));
                
            // Check if user is already in this vehicle
            if (user.isInVehicle(vehicleId)) {
                return false;
            }
            
            // If user is in another vehicle, leave it first
            if (user.getVehicle() != null) {
                user.leaveCurrentVehicle();
            }
            
            // Add user to the new vehicle
            boolean success = vehicle.addPassenger(user);
            if (success) {
                userRepository.save(user);
                vehicleRepository.save(vehicle);
            }
            
            return success;
        } catch (Exception e) {
            throw new RuntimeException("Error al unirse al vehículo: " + e.getMessage(), e);
        }
    }
    
    private void mapDtoToEntity(VehicleDTO dto, Vehicle entity) {
        entity.setBrand(dto.getBrand());
        entity.setModel(dto.getModel());
        entity.setLicensePlate(dto.getLicensePlate());
        entity.setColor(dto.getColor());
        // Use the getters that ensure non-null values
        entity.setTotalSeats(dto.getTotalSeats());
        entity.setAvailableSeats(dto.getAvailableSeats());
        entity.setObservations(dto.getObservations());
        entity.setActive(dto.getActive());
        
        System.out.println("Mapped DTO to Entity - Total Seats: " + entity.getTotalSeats() + 
                         ", Available Seats: " + entity.getAvailableSeats());
    }
    
    private VehicleDTO mapEntityToDto(Vehicle entity) {
        VehicleDTO dto = new VehicleDTO();
        dto.setId(entity.getId());
        dto.setBrand(entity.getBrand());
        dto.setModel(entity.getModel());
        dto.setLicensePlate(entity.getLicensePlate());
        dto.setColor(entity.getColor());
        dto.setTotalSeats(entity.getTotalSeats());
        dto.setAvailableSeats(entity.getAvailableSeats());
        dto.setObservations(entity.getObservations());
        dto.setActive(entity.getActive());
        dto.setCreatedAt(entity.getCreatedAt());
        dto.setUpdatedAt(entity.getUpdatedAt());
        return dto;
    }
}