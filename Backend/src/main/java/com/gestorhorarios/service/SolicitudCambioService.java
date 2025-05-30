package com.gestorhorarios.service;

import com.gestorhorarios.exception.ResourceNotFoundException;
import com.gestorhorarios.model.*;
import com.gestorhorarios.repository.HorarioRepository;
import com.gestorhorarios.repository.SolicitudCambioRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class SolicitudCambioService {

    @Autowired
    private SolicitudCambioRepository solicitudCambioRepository;

    @Autowired
    private HorarioRepository horarioRepository;

    @Autowired
    private HorarioService horarioService;
    
    @Autowired
    private UserService userService;

    public List<SolicitudCambio> obtenerSolicitudesEnviadas(User usuario) {
        return solicitudCambioRepository.findBySolicitante(usuario);
    }
    
    public List<SolicitudCambio> obtenerSolicitudesEnviadasPorUsuarioId(Long usuarioId) {
        User usuario = userService.findUserById(usuarioId);
        return solicitudCambioRepository.findBySolicitante(usuario);
    }

    public List<SolicitudCambio> obtenerSolicitudesRecibidas(User usuario) {
        return solicitudCambioRepository.findByReceptor(usuario);
    }
    
    public List<SolicitudCambio> obtenerSolicitudesRecibidasPorUsuarioId(Long usuarioId) {
        User usuario = userService.findUserById(usuarioId);
        return solicitudCambioRepository.findByReceptor(usuario);
    }
    
    public List<SolicitudCambio> obtenerSolicitudesPorEstado(SolicitudCambio.EstadoSolicitud estado) {
        return solicitudCambioRepository.findByEstado(estado);
    }
    
    public List<SolicitudCambio> obtenerSolicitudesPorUsuarioYEstado(User usuario, SolicitudCambio.EstadoSolicitud estado) {
        return solicitudCambioRepository.findBySolicitanteAndEstado(usuario, estado);
    }
    
    public List<SolicitudCambio> findBySolicitanteAndFechaCreacionAfter(User solicitante, LocalDateTime fecha) {
        return solicitudCambioRepository.findBySolicitanteAndFechaCreacionAfter(solicitante, fecha);
    }
    
    public SolicitudCambio obtenerSolicitudPorId(Long id) {
        return solicitudCambioRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Solicitud de cambio", "id", id));
    }

    @Transactional
    public SolicitudCambio crearSolicitud(SolicitudCambio solicitud) {
        // Verificar que el horario origen existe y pertenece al solicitante
        Horario horarioOrigen = horarioService.obtenerHorarioPorId(solicitud.getHorarioOrigen().getId());
        if (!horarioOrigen.getUsuario().getId().equals(solicitud.getSolicitante().getId())) {
            throw new AccessDeniedException("El horario de origen no pertenece al solicitante");
        }

        // Si hay un horario de destino, verificar que existe y está disponible
        if (solicitud.getHorarioDestino() != null) {
            Horario horarioDestino = horarioService.obtenerHorarioPorId(solicitud.getHorarioDestino().getId());
            if (!horarioDestino.isDisponible()) {
                throw new IllegalArgumentException("El horario de destino no está disponible");
            }
            
            // Establecer el receptor como el propietario del horario de destino
            solicitud.setReceptor(horarioDestino.getUsuario());
        }
        
        // Establecer valores iniciales para la solicitud
        solicitud.setFechaCreacion(LocalDateTime.now());
        solicitud.setEstado(SolicitudCambio.EstadoSolicitud.PENDIENTE);
        solicitud.setFechaRespuesta(null);

        return solicitudCambioRepository.save(solicitud);
    }

    @Transactional
    public SolicitudCambio responderSolicitud(Long solicitudId, User receptor, boolean aceptada) {
        SolicitudCambio solicitud = obtenerSolicitudPorId(solicitudId);

        if (!solicitud.getReceptor().getId().equals(receptor.getId())) {
            throw new AccessDeniedException("No tienes permiso para responder a esta solicitud");
        }

        if (solicitud.getEstado() != SolicitudCambio.EstadoSolicitud.PENDIENTE) {
            throw new IllegalStateException("La solicitud ya ha sido procesada");
        }

        if (aceptada) {
            // Verificar que los horarios aún existen
            Horario horarioOrigen = horarioService.obtenerHorarioPorId(solicitud.getHorarioOrigen().getId());
            Horario horarioDestino = horarioService.obtenerHorarioPorId(solicitud.getHorarioDestino().getId());
            
            // Verificar que los horarios aún pertenecen a los mismos usuarios
            if (!horarioOrigen.getUsuario().getId().equals(solicitud.getSolicitante().getId())) {
                throw new IllegalStateException("El horario de origen ya no pertenece al solicitante");
            }
            
            if (!horarioDestino.getUsuario().getId().equals(solicitud.getReceptor().getId())) {
                throw new IllegalStateException("El horario de destino ya no pertenece al receptor");
            }

            // Intercambiar los usuarios de los horarios
            User solicitante = horarioOrigen.getUsuario();
            horarioOrigen.setUsuario(horarioDestino.getUsuario());
            horarioDestino.setUsuario(solicitante);

            // Actualizar los horarios
            horarioRepository.save(horarioOrigen);
            horarioRepository.save(horarioDestino);

            solicitud.setEstado(SolicitudCambio.EstadoSolicitud.ACEPTADA);
        } else {
            solicitud.setEstado(SolicitudCambio.EstadoSolicitud.RECHAZADA);
        }

        solicitud.setFechaRespuesta(LocalDateTime.now());
        return solicitudCambioRepository.save(solicitud);
    }
    
    @Transactional
    public void cancelarSolicitud(Long solicitudId, Long usuarioId) {
        SolicitudCambio solicitud = obtenerSolicitudPorId(solicitudId);
        
        // Verificar que la solicitud pertenece al usuario
        if (!solicitud.getSolicitante().getId().equals(usuarioId)) {
            throw new AccessDeniedException("No tienes permiso para cancelar esta solicitud");
        }
        
        // Verificar que la solicitud está pendiente
        if (solicitud.getEstado() != SolicitudCambio.EstadoSolicitud.PENDIENTE) {
            throw new IllegalStateException("No se puede cancelar una solicitud que ya ha sido procesada");
        }
        
        solicitud.setEstado(SolicitudCambio.EstadoSolicitud.CANCELADA);
        solicitud.setFechaRespuesta(LocalDateTime.now());
        solicitudCambioRepository.save(solicitud);
    }
}
