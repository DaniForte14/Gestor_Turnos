package com.calendario.trabajadores.model.dto.turno;

import com.calendario.trabajadores.model.database.EstadoTurno;
import com.calendario.trabajadores.model.database.PeticionTurno;
import lombok.Getter;
import lombok.Setter;
import java.util.Date;

@Getter
@Setter
public class EditarTurnoRequest {
    private Long id;
    private Date horaInicio;
    private Date horaFin;
    private EstadoTurno estadoTurno;
    private PeticionTurno peticionTurno;
    private String notasPeticion;
    private Boolean activo;
}
