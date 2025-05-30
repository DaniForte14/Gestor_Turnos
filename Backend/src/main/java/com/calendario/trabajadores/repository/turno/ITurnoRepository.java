package com.calendario.trabajadores.repository.turno;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import com.calendario.trabajadores.model.database.Turno;
import com.calendario.trabajadores.model.database.EstadoTurno;
import java.util.List;

@Repository
public interface ITurnoRepository extends JpaRepository<Turno, Long>, CustomTurnoRepository {

    // Metodo para obtener turnos por id de usuario y estado
    List<Turno> findByUsuarioIdAndEstadoTurno(Long usuarioId, EstadoTurno estadoTurno);

    // Metodo para obtener turnos por id de usuario
    List<Turno> findByUsuarioId(Long usuarioId);
}
