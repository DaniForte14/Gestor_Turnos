package com.calendario.trabajadores.repository.turno;

import com.calendario.trabajadores.model.database.Turno;

import java.util.List;

public interface CustomTurnoRepository {
    List<Turno> buscarTurnosActivos();
}
