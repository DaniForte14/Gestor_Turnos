package com.gestorhorarios.repository;

import com.gestorhorarios.model.Horario;
import com.gestorhorarios.model.Role;
import com.gestorhorarios.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@Repository
public interface HorarioRepository extends JpaRepository<Horario, Long> {
    List<Horario> findByUsuario(User usuario);
    List<Horario> findByUsuarioAndFechaBetween(User usuario, LocalDate fechaInicio, LocalDate fechaFin);
    List<Horario> findByDisponibleTrueAndUsuarioNot(User usuario);
    List<Horario> findByDisponibleTrueAndUsuarioNotAndFechaBetween(
            User usuario, LocalDate fechaInicio, LocalDate fechaFin);
    List<Horario> findByUsuarioAndDisponibleFalse(User usuario);
    
    // Nuevos métodos para consultas adicionales
    List<Horario> findByFecha(LocalDate fecha);
    List<Horario> findByFechaBetween(LocalDate fechaInicio, LocalDate fechaFin);
    List<Horario> findByUsuarioAndFecha(User usuario, LocalDate fecha);
    
    // Consultas para horarios por tipo de turno
    List<Horario> findByUsuarioAndTipoTurno(User usuario, Horario.TipoTurno tipoTurno);
    List<Horario> findByTipoTurno(Horario.TipoTurno tipoTurno);
    
    // Consulta para horarios que se solapan en una fecha y rango de horas
    @Query("SELECT h FROM Horario h WHERE h.usuario = ?1 AND h.fecha = ?2 AND " +
           "((h.horaInicio <= ?3 AND h.horaFin > ?3) OR (h.horaInicio < ?4 AND h.horaFin >= ?4) OR " +
           "(h.horaInicio >= ?3 AND h.horaFin <= ?4))")
    List<Horario> findOverlappingSchedules(User usuario, LocalDate fecha, LocalTime horaInicio, LocalTime horaFin);
    
    // Consulta para encontrar los horarios disponibles en una fecha específica
    List<Horario> findByFechaAndDisponibleTrue(LocalDate fecha);
    
    // Consulta para encontrar horarios de un usuario a partir de una fecha
    List<Horario> findByUsuarioAndFechaGreaterThanEqual(User usuario, LocalDate fecha);
    
    // Encontrar horarios disponibles por rol y fecha
    @Query("SELECT h FROM Horario h JOIN h.usuario u JOIN u.roles r WHERE h.disponible = true AND (r = :rol OR r = com.gestorhorarios.model.Role.ROLE_USER) AND h.fecha = :fecha")
    List<Horario> findAvailableByRolAndFecha(@Param("rol") Role rol, @Param("fecha") LocalDate fecha);
}
