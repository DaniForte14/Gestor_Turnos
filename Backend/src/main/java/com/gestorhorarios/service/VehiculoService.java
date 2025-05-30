package com.gestorhorarios.service;

import com.gestorhorarios.exception.ResourceNotFoundException;
import com.gestorhorarios.model.User;
import com.gestorhorarios.model.Vehiculo;
import com.gestorhorarios.repository.VehiculoRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class VehiculoService {

    @Autowired
    private VehiculoRepository vehiculoRepository;

    @Autowired
    private UserService userService;

    public List<Vehiculo> obtenerVehiculosPorPropietario(User propietario) {
        return vehiculoRepository.findByPropietario(propietario);
    }
    
    public List<Vehiculo> obtenerVehiculosPorPropietarioId(Long propietarioId) {
        User propietario = userService.findUserById(propietarioId);
        return vehiculoRepository.findByPropietario(propietario);
    }

    public List<Vehiculo> obtenerVehiculosDisponibles() {
        return vehiculoRepository.findByActivoTrue();
    }

    @Transactional
    public Vehiculo registrarVehiculo(Vehiculo vehiculo, Long propietarioId) {
        User propietario = userService.findUserById(propietarioId);
        vehiculo.setPropietario(propietario);
        
        if (vehiculoRepository.existsByMatricula(vehiculo.getMatricula())) {
            throw new IllegalArgumentException("Ya existe un vehículo con esta matrícula: " + vehiculo.getMatricula());
        }
        
        // Establecer valores por defecto si no está activo
        if (!vehiculo.isActivo()) {
            vehiculo.setActivo(true);
        }
        
        return vehiculoRepository.save(vehiculo);
    }

    @Transactional
    public Vehiculo actualizarVehiculo(Vehiculo vehiculo, Long propietarioId) {
        Vehiculo vehiculoExistente = obtenerVehiculoPorId(vehiculo.getId());
        
        // Verificar que el vehículo pertenece al propietario
        if (!vehiculoExistente.getPropietario().getId().equals(propietarioId)) {
            throw new AccessDeniedException("No tienes permiso para modificar este vehículo");
        }
        
        // Verificar que si se cambió la matrícula, no exista otra igual
        if (!vehiculoExistente.getMatricula().equals(vehiculo.getMatricula()) && 
            vehiculoRepository.existsByMatricula(vehiculo.getMatricula())) {
            throw new IllegalArgumentException("Ya existe un vehículo con esta matrícula: " + vehiculo.getMatricula());
        }
        
        // Actualizar solo los campos permitidos
        vehiculoExistente.setMarca(vehiculo.getMarca());
        vehiculoExistente.setModelo(vehiculo.getModelo());
        vehiculoExistente.setMatricula(vehiculo.getMatricula());
        vehiculoExistente.setColor(vehiculo.getColor());
        vehiculoExistente.setAsientosDisponibles(vehiculo.getAsientosDisponibles());
        vehiculoExistente.setObservaciones(vehiculo.getObservaciones());
        vehiculoExistente.setActivo(vehiculo.isActivo());
        
        return vehiculoRepository.save(vehiculoExistente);
    }

    @Transactional
    public void eliminarVehiculo(Long id, Long propietarioId) {
        Vehiculo vehiculo = obtenerVehiculoPorId(id);
        
        // Verificar que el vehículo pertenece al propietario
        if (!vehiculo.getPropietario().getId().equals(propietarioId)) {
            throw new AccessDeniedException("No tienes permiso para eliminar este vehículo");
        }
        
        // En lugar de eliminar físicamente, marcamos como inactivo
        vehiculo.setActivo(false);
        vehiculoRepository.save(vehiculo);
    }

    @Transactional
    public void eliminarVehiculoFisicamente(Long id, Long propietarioId) {
        Vehiculo vehiculo = obtenerVehiculoPorId(id);
        
        // Verificar que el vehículo pertenece al propietario o es administrador
        if (!vehiculo.getPropietario().getId().equals(propietarioId)) {
            throw new AccessDeniedException("No tienes permiso para eliminar este vehículo");
        }
        
        vehiculoRepository.delete(vehiculo);
    }
    
    public Vehiculo obtenerVehiculoPorMatricula(String matricula) {
        return vehiculoRepository.findByMatricula(matricula)
                .orElseThrow(() -> new ResourceNotFoundException("Vehículo", "matrícula", matricula));
    }

    public Vehiculo obtenerVehiculoPorId(Long id) {
        return vehiculoRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Vehículo", "id", id));
    }
}
