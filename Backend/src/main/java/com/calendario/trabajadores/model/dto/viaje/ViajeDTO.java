package com.calendario.trabajadores.model.dto.viaje;
import com.calendario.trabajadores.model.database.EstadoViaje;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.Date;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ViajeDTO {
    private Long id;
    private Date fecha;
    private Date hora;
    private String origen;
    private String destino;
    private int plazas;
    private EstadoViaje estado;
    // Solo el ID del conductor para no cargar toda la entidad
    private Long conductorId;
    // Solo el ID del vehiculo para no cargar toda la entidad
    private Long vehiculoId;
}
