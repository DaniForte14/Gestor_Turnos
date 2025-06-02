package com.gestorhorarios.service;

import com.gestorhorarios.dto.VehicleDTO;
import com.gestorhorarios.dto.VehicleResponseDTO;
import com.gestorhorarios.model.User;
import com.gestorhorarios.model.Vehicle;
import com.gestorhorarios.repository.UserRepository;
import com.gestorhorarios.repository.VehicleRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class VehicleService {
    
    @Autowired
    private VehicleRepository vehicleRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    @Transactional
    public VehicleDTO createVehicle(VehicleDTO vehicleDTO, Long userId) {
        System.out.println("=== INICIO createVehicle ===");
        System.out.println("Vehicle DTO recibido: " + vehicleDTO);
        
        try {
            // Validar que los asientos sean válidos
            if (vehicleDTO.getTotalSeats() == null || vehicleDTO.getTotalSeats() <= 0) {
                String errorMsg = "El número total de asientos debe ser mayor que cero";
                System.out.println(errorMsg);
                throw new RuntimeException(errorMsg);
            }
            
            // Verificar si ya existe un vehículo con la misma matrícula
            if (vehicleRepository.existsByLicensePlate(vehicleDTO.getLicensePlate())) {
                String errorMsg = "Ya existe un vehículo con la matrícula: " + vehicleDTO.getLicensePlate();
                System.out.println(errorMsg);
                throw new RuntimeException(errorMsg);
            }
            
            // Obtener el propietario
            User owner = userRepository.findById(userId)
                .orElseThrow(() -> {
                    String errorMsg = "Usuario no encontrado con ID: " + userId;
                    System.out.println(errorMsg);
                    return new RuntimeException(errorMsg);
                });
            
            // Verificar si el usuario ya tiene un vehículo
            if (vehicleRepository.existsByOwner(owner)) {
                String errorMsg = "El usuario ya tiene un vehículo registrado. ID de usuario: " + userId;
                System.out.println(errorMsg);
                throw new RuntimeException(errorMsg);
            }
            
            // Crear y configurar el vehículo
            Vehicle vehicle = new Vehicle();
            System.out.println("Antes de mapear DTO a entidad");
            mapDtoToEntity(vehicleDTO, vehicle);
            
            // Asegurar que los asientos disponibles sean iguales al total al crear
            vehicle.setAvailableSeats(vehicle.getTotalSeats());
            
            // Establecer el propietario
            vehicle.setOwner(owner);
            System.out.println("Vehículo después del mapeo: " + vehicle);
            
            // Guardar el vehículo
            System.out.println("Guardando vehículo en la base de datos...");
            vehicle = vehicleRepository.save(vehicle);
            System.out.println("Vehículo guardado exitosamente con ID: " + vehicle.getId());
            
            // Actualizar la referencia en el usuario
            owner.setVehicle(vehicle);
            userRepository.save(owner);
            
            return mapEntityToDto(vehicle);
            
        } catch (Exception e) {
            System.err.println("Error en createVehicle: " + e.getMessage());
            e.printStackTrace();
            throw e; // Relanzar la excepción para manejarla en el controlador
        } finally {
            System.out.println("=== FIN createVehicle ===");
        }
    }
    
    public List<VehicleDTO> getAllVehicles() {
        return vehicleRepository.findAll().stream()
                .map(this::mapEntityToDto)
                .collect(Collectors.toList());
    }
    
    public List<VehicleResponseDTO> getAvailableVehicles() {
        // Cargar todos los vehículos con sus pasajeros para evitar el problema N+1
        List<Vehicle> availableVehicles = vehicleRepository.findAllWithPassengers().stream()
                .filter(v -> v.getAvailableSeats() > 0)
                .collect(Collectors.toList());
                
        return availableVehicles.stream()
                .map(VehicleResponseDTO::fromEntity)
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
        System.out.println("=== INICIO joinVehicle ===");
        System.out.println("Uniendo usuario " + userId + " al vehículo " + vehicleId);
        
        try {
            // 1. Cargar el usuario sin sus relaciones para evitar referencias circulares
            User user = userRepository.findById(userId)
                .orElseThrow(() -> {
                    String error = "Usuario no encontrado con ID: " + userId;
                    System.out.println(error);
                    return new RuntimeException(error);
                });
            
            System.out.println("Usuario cargado: " + user.getUsername());
            
            // 2. Cargar el vehículo con sus pasajeros usando una consulta optimizada
            Vehicle vehicle = vehicleRepository.findByIdWithPassengers(vehicleId)
                .orElseThrow(() -> {
                    String error = "Vehículo no encontrado con ID: " + vehicleId;
                    System.out.println(error);
                    return new RuntimeException(error);
                });
                
            System.out.println("Vehículo cargado: " + vehicle.getLicensePlate() + 
                           ", Asientos disponibles: " + vehicle.getAvailableSeats());
            
            // 3. Verificar disponibilidad
            if (vehicle.getAvailableSeats() <= 0) {
                String error = "No hay asientos disponibles en este vehículo";
                System.out.println(error);
                throw new RuntimeException(error);
            }
            
            // 4. Verificar si el usuario ya está en este vehículo
            if (vehicle.getPassengers().stream().anyMatch(p -> p.getId().equals(userId))) {
                String error = "El usuario ya es pasajero de este vehículo";
                System.out.println(error);
                throw new RuntimeException(error);
            }
            
            // 5. Si el usuario está en otro vehículo, salir primero
            if (user.getVehicle() != null && !user.getVehicle().getId().equals(vehicleId)) {
                System.out.println("Usuario está en otro vehículo, saliendo primero...");
                leaveVehicle(user.getId(), user.getVehicle().getId());
                // Recargar el usuario después de salir del vehículo anterior
                user = userRepository.findById(userId).orElseThrow();
            }
            
            // 6. Actualizar las relaciones
            // Añadir el usuario a la lista de pasajeros del vehículo
            vehicle.getPassengers().add(user);
            vehicle.setAvailableSeats(vehicle.getAvailableSeats() - 1);
            
            // Actualizar la relación en el usuario
            user.setVehicle(vehicle);
            
            // 7. Guardar los cambios
            System.out.println("Guardando cambios...");
            vehicleRepository.save(vehicle);
            userRepository.save(user);
            
            System.out.println("Usuario " + userId + " unido exitosamente al vehículo " + vehicleId);
            return true;
            
        } catch (Exception e) {
            System.err.println("Error en joinVehicle: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Error al unirse al vehículo: " + e.getMessage(), e);
        } finally {
            System.out.println("=== FIN joinVehicle ===");
        }
    }
    
    private void mapDtoToEntity(VehicleDTO dto, Vehicle entity) {
        try {
            System.out.println("Iniciando mapeo de DTO a entidad...");
            System.out.println("DTO recibido: " + dto);
            
            // Validar y establecer la marca
            if (dto.getBrand() == null || dto.getBrand().trim().isEmpty()) {
                throw new IllegalArgumentException("La marca del vehículo es obligatoria");
            }
            entity.setBrand(dto.getBrand().trim());
            
            // Validar y establecer el modelo
            if (dto.getModel() == null || dto.getModel().trim().isEmpty()) {
                throw new IllegalArgumentException("El modelo del vehículo es obligatorio");
            }
            entity.setModel(dto.getModel().trim());
            
            // Validar y establecer la matrícula
            if (dto.getLicensePlate() == null || dto.getLicensePlate().trim().isEmpty()) {
                throw new IllegalArgumentException("La matrícula del vehículo es obligatoria");
            }
            entity.setLicensePlate(dto.getLicensePlate().trim().toUpperCase());
            
            // Establecer color (opcional)
            entity.setColor(dto.getColor() != null ? dto.getColor().trim() : null);
            
            // Validar y establecer el número total de asientos
            if (dto.getTotalSeats() == null || dto.getTotalSeats() <= 0) {
                throw new IllegalArgumentException("El número total de asientos debe ser mayor que cero");
            }
            entity.setTotalSeats(dto.getTotalSeats());
            
            // Establecer asientos disponibles (por defecto igual al total)
            entity.setAvailableSeats(dto.getTotalSeats());
            
            // Establecer observaciones (opcional)
            entity.setObservations(dto.getObservations() != null ? dto.getObservations().trim() : null);
            
            // Establecer si está activo (por defecto true)
            entity.setActive(dto.getActive() != null ? dto.getActive() : true);
            
            System.out.println("Mapeo completado exitosamente");
            System.out.println("Total Seats: " + entity.getTotalSeats() + 
                             ", Available Seats: " + entity.getAvailableSeats() +
                             ", Active: " + entity.isActive());
            
        } catch (Exception e) {
            System.err.println("Error en mapDtoToEntity: " + e.getMessage());
            e.printStackTrace();
            throw e; // Relanzar la excepción para manejarla en el método que llama
        }
    }
    
    @Transactional(readOnly = true)
    public VehicleDTO getVehicleById(Long id) {
        return vehicleRepository.findById(id)
            .map(this::mapEntityToDto)
            .orElseThrow(() -> new RuntimeException("Vehículo no encontrado con ID: " + id));
    }
    
    @Transactional
    public void deleteVehicle(Long vehicleId, Long userId) {
        try {
            System.out.println("=== INICIO deleteVehicle ===");
            System.out.println("Eliminando vehículo ID: " + vehicleId + " por usuario ID: " + userId);
            
            // Cargar el vehículo con sus relaciones
            Vehicle vehicle = vehicleRepository.findByIdWithRelations(vehicleId)
                .orElseThrow(() -> new RuntimeException("Vehículo no encontrado con ID: " + vehicleId));
                
            // Verificar que el usuario sea el propietario del vehículo
            if (!vehicle.getOwner().getId().equals(userId)) {
                throw new RuntimeException("No tienes permiso para eliminar este vehículo");
            }
            
            // 1. Actualizar todos los usuarios que tienen este vehículo como vehicle_id
            List<User> usersWithThisVehicle = userRepository.findByVehicleId(vehicleId);
            for (User user : usersWithThisVehicle) {
                user.setVehicle(null);
                userRepository.save(user);
            }
            
            // 2. Eliminar las relaciones con los pasajeros
            Set<User> passengers = new HashSet<>(vehicle.getPassengers());
            for (User passenger : passengers) {
                passenger.getVehiclesAsPassenger().remove(vehicle);
                userRepository.save(passenger);
            }
            vehicle.getPassengers().clear();
            
            // 3. Actualizar la referencia del vehículo en el propietario
            User owner = vehicle.getOwner();
            if (owner != null && owner.getVehicle() != null && owner.getVehicle().getId().equals(vehicleId)) {
                owner.setVehicle(null);
                userRepository.save(owner);
            }
            
            // 4. Guardar los cambios en el vehículo
            vehicle = vehicleRepository.save(vehicle);
            
            // 5. Forzar el flush para asegurar que todas las operaciones se completen
            vehicleRepository.flush();
            userRepository.flush();
            
            // 6. Finalmente, eliminar el vehículo
            vehicleRepository.delete(vehicle);
            
            System.out.println("Vehículo eliminado exitosamente");
            
        } catch (Exception e) {
            System.err.println("Error en deleteVehicle: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Error al eliminar el vehículo: " + e.getMessage(), e);
        } finally {
            System.out.println("=== FIN deleteVehicle ===");
        }
    }
    
    @Transactional
    public boolean leaveVehicle(Long userId, Long vehicleId) {
        try {
            // Cargar el usuario y el vehículo con sus relaciones
            User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
                
            Vehicle vehicle = vehicleRepository.findByIdWithPassengers(vehicleId)
                .orElseThrow(() -> new RuntimeException("Vehículo no encontrado"));
            
            // Verificar que el usuario es pasajero de este vehículo y eliminarlo
            if (!vehicle.getPassengers().removeIf(u -> u.getId().equals(userId))) {
                throw new RuntimeException("El usuario no es pasajero de este vehículo");
            }
            
            // Incrementar los asientos disponibles
            vehicle.setAvailableSeats(vehicle.getAvailableSeats() + 1);
            
            // Guardar los cambios
            vehicleRepository.save(vehicle);
            userRepository.save(user);
            
            return true;
            
        } catch (Exception e) {
            System.err.println("Error en leaveVehicle: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Error al abandonar el vehículo: " + e.getMessage(), e);
        }
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
        dto.setActive(entity.isActive());
        dto.setCreatedAt(entity.getCreatedAt());
        dto.setUpdatedAt(entity.getUpdatedAt());
        return dto;
    }
}