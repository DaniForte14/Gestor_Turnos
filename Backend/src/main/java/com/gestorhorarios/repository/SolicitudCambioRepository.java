package com.gestorhorarios.repository;

import com.gestorhorarios.model.SolicitudCambio;
import com.gestorhorarios.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface SolicitudCambioRepository extends JpaRepository<SolicitudCambio, Long> {
    // Consultas por usuario
    List<SolicitudCambio> findBySolicitante(User solicitante);
    List<SolicitudCambio> findByReceptor(User receptor);
    
    // Consultas por horario
    List<SolicitudCambio> findByHorarioOrigenId(Long horarioId);
    List<SolicitudCambio> findByHorarioDestinoId(Long horarioId);
    
    // Consultas por estado
    List<SolicitudCambio> findByEstado(SolicitudCambio.EstadoSolicitud estado);
    List<SolicitudCambio> findBySolicitanteAndEstado(User solicitante, SolicitudCambio.EstadoSolicitud estado);
    List<SolicitudCambio> findByReceptorAndEstado(User receptor, SolicitudCambio.EstadoSolicitud estado);
    
    // Consultas por fecha
    List<SolicitudCambio> findByFechaCreacionAfter(LocalDateTime fecha);
    List<SolicitudCambio> findByFechaCreacionBetween(LocalDateTime fechaInicio, LocalDateTime fechaFin);
    
    // Consultas combinadas
    @Query("SELECT s FROM SolicitudCambio s WHERE s.solicitante = ?1 AND s.fechaCreacion >= ?2")
    List<SolicitudCambio> findBySolicitanteAndFechaCreacionAfter(User solicitante, LocalDateTime fecha);
    
    @Query("SELECT s FROM SolicitudCambio s WHERE s.receptor = ?1 AND s.fechaCreacion >= ?2")
    List<SolicitudCambio> findByReceptorAndFechaCreacionAfter(User receptor, LocalDateTime fecha);
}
