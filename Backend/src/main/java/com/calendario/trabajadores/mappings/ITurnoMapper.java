package com.calendario.trabajadores.mappings;

import com.calendario.trabajadores.model.database.Turno;
import com.calendario.trabajadores.model.dto.turno.CrearTurnoRequest;
import com.calendario.trabajadores.model.dto.turno.EditarTurnoRequest;
import com.calendario.trabajadores.model.dto.turno.CrearEditarTurnoResponse;
import com.calendario.trabajadores.model.dto.turno.TurnoDTO;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface ITurnoMapper {

    // Mapea Turno a CrearEditarTurnoResponse (al crear y editar y devolver al frontend)
    @Mapping(source = "usuario.id", target = "idUsuario")
    CrearEditarTurnoResponse turnoToCrearEditarTurnoResponse(Turno turno);

    // Mapea CrearTurnoRequest a Turno (para guardar en la DB)
    @Mapping(source = "idUsuario", target = "usuario.id")
    @Mapping(target = "estadoTurno", constant = "SIN_EMPEZAR")
    @Mapping(target = "peticionTurno", constant = "PENDIENTE")
    Turno crearTurnoRequestToTurno(CrearTurnoRequest request);

    // Mapea EditarTurnoRequest a Turno (para actualizar)
    // no se cambia el usuario al editar
    @Mapping(target = "usuario", ignore = true)
    Turno editarTurnoRequestToTurno(EditarTurnoRequest request);

    // Mapea Turno a TurnoDTO para listar o mostrar en vistas
    @Mapping(source = "usuario.nombre", target = "nombreUsuario")
    @Mapping(source = "usuario.email", target = "emailUsuario")
    TurnoDTO turnoToTurnoDTO(Turno turno);
}
