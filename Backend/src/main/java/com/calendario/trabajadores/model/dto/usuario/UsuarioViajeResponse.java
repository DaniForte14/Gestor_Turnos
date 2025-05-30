package com.calendario.trabajadores.model.dto.usuario;

import lombok.AllArgsConstructor;
import com.calendario.trabajadores.model.dto.viaje.ViajeDTO;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class UsuarioViajeResponse {

    // Informacion del usuario
    private Long id;
    private String nombre;
    private String apellido1;
    private String apellido2;
    private String email;
    private String telefono;
    private String centroTrabajo;

    // Lista de viajes asociados al usuario
    private List<ViajeDTO> viajes;

    // Atributo opcional de estado si se desea
    private Boolean activo;
}
