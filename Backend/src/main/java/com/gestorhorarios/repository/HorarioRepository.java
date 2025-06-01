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
import java.util.Optional;

@Repository
public interface HorarioRepository extends JpaRepository<Horario, Long> {
    // Basic CRUD operations
    @Override
    Optional<Horario> findById(Long id);
    
    // User-specific queries
    List<Horario> findByUsuario(User usuario);
    List<Horario> findByUsuarioAndFechaBetween(User usuario, LocalDate fechaInicio, LocalDate fechaFin);
    List<Horario> findByUsuarioAndDisponibleFalse(User usuario);
    List<Horario> findByUsuarioAndFecha(User usuario, LocalDate fecha);
    List<Horario> findByUsuarioAndFechaGreaterThanEqual(User usuario, LocalDate fecha);
    
    // Availability queries
    List<Horario> findByDisponibleTrue();
    List<Horario> findByDisponibleTrueAndUsuarioNot(User usuario);
    List<Horario> findByDisponibleTrueAndUsuarioNotAndFechaBetween(
            User usuario, LocalDate fechaInicio, LocalDate fechaFin);
    List<Horario> findByFechaAndDisponibleTrue(LocalDate fecha);
    
    // Date-based queries
    List<Horario> findByFecha(LocalDate fecha);
    List<Horario> findByFechaBetween(LocalDate fechaInicio, LocalDate fechaFin);
    List<Horario> findByFechaBetweenAndDisponibleTrue(LocalDate fechaInicio, LocalDate fechaFin);
    
    // Shift type queries
    List<Horario> findByUsuarioAndTipoTurno(User usuario, Horario.TipoTurno tipoTurno);
    List<Horario> findByTipoTurno(Horario.TipoTurno tipoTurno);
    List<Horario> findByTipoTurnoAndFechaBetween(Horario.TipoTurno tipoTurno, LocalDate fechaInicio, LocalDate fechaFin);
    
    // Role-based queries
    @Query("SELECT h FROM Horario h JOIN h.usuario u WHERE h.disponible = true AND " +
           "(:rol MEMBER OF u.roles OR com.gestorhorarios.model.Role.ROLE_USER MEMBER OF u.roles) AND " +
           "h.fecha = :fecha")
    List<Horario> findAvailableByRolAndFecha(@Param("rol") Role rol, @Param("fecha") LocalDate fecha);
    
    @Query("SELECT h FROM Horario h JOIN h.usuario u WHERE h.disponible = true AND " +
           "(:rol MEMBER OF u.roles OR com.gestorhorarios.model.Role.ROLE_USER MEMBER OF u.roles) AND " +
           "h.fecha BETWEEN :startDate AND :endDate")
    List<Horario> findAvailableByRolAndFechaBetween(
            @Param("rol") Role rol, 
            @Param("startDate") LocalDate startDate, 
            @Param("endDate") LocalDate endDate);
    
    // Schedule conflict detection
    @Query("SELECT h FROM Horario h WHERE h.usuario = :usuario AND h.fecha = :fecha AND " +
           "((h.horaInicio <= :horaInicio AND h.horaFin > :horaInicio) OR " +
           "(h.horaInicio < :horaFin AND h.horaFin >= :horaFin) OR " +
           "(h.horaInicio >= :horaInicio AND h.horaFin <= :horaFin))")
    List<Horario> findConflictingSchedules(
            @Param("usuario") User usuario,
            @Param("fecha") LocalDate fecha,
            @Param("horaInicio") LocalTime horaInicio,
            @Param("horaFin") LocalTime horaFin);
    
    // Find by user, date range and role
    @Query("SELECT h FROM Horario h JOIN h.usuario u WHERE h.usuario = :usuario AND " +
           "h.fecha BETWEEN :startDate AND :endDate AND " +
           ":rol MEMBER OF u.roles")
    List<Horario> findByUsuarioAndFechaBetweenAndRol(
            @Param("usuario") User usuario,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate,
            @Param("rol") Role rol);
    
    // Find count of schedules by user and date range
    @Query("SELECT COUNT(h) FROM Horario h WHERE h.usuario = :usuario AND h.fecha BETWEEN :startDate AND :endDate")
    Long countByUsuarioAndFechaBetween(
            @Param("usuario") User usuario,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate);
}
