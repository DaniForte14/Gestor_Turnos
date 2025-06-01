package com.gestorhorarios.service;

import com.gestorhorarios.exception.ResourceNotFoundException;
import com.gestorhorarios.model.Horario;
import com.gestorhorarios.model.Role;
import com.gestorhorarios.model.User;
import com.gestorhorarios.repository.HorarioRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@Service
public class HorarioService {

    @Autowired
    private HorarioRepository horarioRepository;
    
    @Autowired
    private UserService userService;

    public List<Horario> getHorariosPorUsuario(User usuario) {
        return horarioRepository.findByUsuario(usuario);
    }
    
    public List<Horario> getHorariosPorUsuarioId(Long usuarioId) {
        User usuario = userService.findUserById(usuarioId);
        return horarioRepository.findByUsuario(usuario);
    }
    
    public List<Horario> getHorariosPorUsuarioId(Long usuarioId, LocalDate fechaInicio, LocalDate fechaFin) {
        if (fechaFin.isBefore(fechaInicio)) {
            throw new IllegalArgumentException("La fecha fin no puede ser anterior a la fecha inicio");
        }
        User usuario = userService.findUserById(usuarioId);
        return horarioRepository.findByUsuarioAndFechaBetween(usuario, fechaInicio, fechaFin);
    }

    public List<Horario> getHorariosDisponibles(User usuario, LocalDate fechaInicio, LocalDate fechaFin) {
        if (fechaInicio != null && fechaFin != null) {
            if (fechaFin.isBefore(fechaInicio)) {
                throw new IllegalArgumentException("La fecha fin no puede ser anterior a la fecha inicio");
            }
            return horarioRepository.findByDisponibleTrueAndUsuarioNotAndFechaBetween(usuario, fechaInicio, fechaFin);
        }
        return horarioRepository.findByDisponibleTrueAndUsuarioNot(usuario);
    }
    
    public List<Horario> getHorariosDisponiblesPorRolYFecha(String rol, LocalDate fecha) {
        if (rol == null || rol.isEmpty()) {
            throw new IllegalArgumentException("El rol no puede estar vacío");
        }
        // Normalizar el rol para asegurar que tenga el formato correcto
        String normalizedRol = rol.trim().toUpperCase();
        if (!normalizedRol.startsWith("ROLE_")) {
            normalizedRol = "ROLE_" + normalizedRol;
        }
        try {
            Role role = Role.valueOf(normalizedRol);
            return horarioRepository.findAvailableByRolAndFecha(role, fecha);
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Rol no válido: " + rol, e);
        }
    }
    
    public List<Horario> getHorariosPorFecha(LocalDate fecha) {
        return horarioRepository.findByFecha(fecha);
    }
    
    public List<Horario> getHorariosPorPeriodo(LocalDate fechaInicio, LocalDate fechaFin) {
        if (fechaFin.isBefore(fechaInicio)) {
            throw new IllegalArgumentException("La fecha fin no puede ser anterior a la fecha inicio");
        }
        return horarioRepository.findByFechaBetween(fechaInicio, fechaFin);
    }

    @Transactional
    public Horario crearHorario(Horario horario, String rol) {
        // Validaciones básicas
        if (horario.getFecha() == null) {
            throw new IllegalArgumentException("La fecha del horario es obligatoria");
        }
        if (horario.getHoraInicio() == null || horario.getHoraFin() == null) {
            throw new IllegalArgumentException("Las horas de inicio y fin son obligatorias");
        }
        if (horario.getHoraFin().isBefore(horario.getHoraInicio())) {
            throw new IllegalArgumentException("La hora de fin no puede ser anterior a la hora de inicio");
        }
        
        // Asegurarse de que el usuario existe
        if (horario.getUsuario() == null || horario.getUsuario().getId() == null) {
            throw new IllegalArgumentException("El usuario es obligatorio");
        }
        
        User usuario = userService.findUserById(horario.getUsuario().getId());
        if (usuario == null) {
            throw new IllegalArgumentException("Usuario no encontrado");
        }
        
        // Validar el rol
        if (rol == null || rol.trim().isEmpty()) {
            throw new IllegalArgumentException("El rol es obligatorio");
        }
        
        // Normalizar el rol
        String normalizedRol = rol.trim().toUpperCase();
        if (!normalizedRol.startsWith("ROLE_")) {
            normalizedRol = "ROLE_" + normalizedRol;
        }
        
        // Verificar que el rol sea uno de los permitidos
        try {
            Role role = Role.valueOf(normalizedRol);
            if (role != Role.ROLE_TCAE && role != Role.ROLE_MEDICO && role != Role.ROLE_ENFERMERO) {
                throw new IllegalArgumentException("Rol no permitido. Los roles permitidos son: ROLE_TCAE, ROLE_MEDICO, ROLE_ENFERMERO");
            }
            horario.setRol(role);
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Rol no válido. Los roles permitidos son: ROLE_TCAE, ROLE_MEDICO, ROLE_ENFERMERO");
        }
        
        // Guardar el horario
        return horarioRepository.save(horario);
    }

    @Transactional
    public Horario actualizarHorario(Horario horario) {
        Horario horarioExistente = obtenerHorarioPorId(horario.getId());
        
        // Actualizar los campos permitidos
        horarioExistente.setFecha(horario.getFecha());
        horarioExistente.setHoraInicio(horario.getHoraInicio());
        horarioExistente.setHoraFin(horario.getHoraFin());
        horarioExistente.setDisponible(horario.isDisponible());
        horarioExistente.setTipoTurno(horario.getTipoTurno());
        horarioExistente.setNotas(horario.getNotas());
        
        return horarioRepository.save(horarioExistente);
    }

    @Transactional
    public void eliminarHorario(Long id) {
        Horario horario = obtenerHorarioPorId(id);
        horarioRepository.delete(horario);
    }
    
    /**
     * Verifica si un usuario es propietario de un horario
     * @param horarioId ID del horario
     * @param usuarioId ID del usuario
     * @return true si el usuario es propietario, false en caso contrario
     */
    public boolean esUsuarioPropietario(Long horarioId, Long usuarioId) {
        Horario horario = obtenerHorarioPorId(horarioId);
        return horario.getUsuario().getId().equals(usuarioId);
    }
    
    /**
     * Asegura que el usuario sea propietario del horario o lanza una excepción
     * @param horarioId ID del horario
     * @param usuarioId ID del usuario
     * @throws AccessDeniedException si el usuario no es propietario
     */
    public void verificarPropietario(Long horarioId, Long usuarioId) {
        if (!esUsuarioPropietario(horarioId, usuarioId)) {
            throw new AccessDeniedException("No tienes permiso para acceder a este horario");
        }
    }

    public Horario obtenerHorarioPorId(Long id) {
        return horarioRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Horario", "id", id));
    }
    
    /**
     * Obtiene todos los horarios de un usuario.
     * 
     * @param usuario Usuario del que se quieren obtener los horarios
     * @return Lista de horarios del usuario
     */
    public List<Horario> findByUsuario(User usuario) {
        return horarioRepository.findByUsuario(usuario);
    }
    
    /**
     * Obtiene los horarios de un usuario en un rango de fechas.
     * 
     * @param usuario Usuario del que se quieren obtener los horarios
     * @param fechaInicio Fecha de inicio del rango
     * @param fechaFin Fecha de fin del rango
     * @return Lista de horarios del usuario en el rango de fechas especificado
     */
    public List<Horario> findByUsuarioAndFechaBetween(User usuario, LocalDate fechaInicio, LocalDate fechaFin) {
        if (fechaInicio == null || fechaFin == null) {
            throw new IllegalArgumentException("Las fechas de inicio y fin son obligatorias");
        }
        if (fechaFin.isBefore(fechaInicio)) {
            throw new IllegalArgumentException("La fecha de fin no puede ser anterior a la fecha de inicio");
        }
        return horarioRepository.findByUsuarioAndFechaBetween(usuario, fechaInicio, fechaFin);
    }
}
