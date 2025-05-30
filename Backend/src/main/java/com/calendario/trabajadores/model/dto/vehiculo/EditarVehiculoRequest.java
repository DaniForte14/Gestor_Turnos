package com.calendario.trabajadores.model.dto.vehiculo;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
//Anotaciones de Lombok
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class EditarVehiculoRequest {
    //Atributos de EditarVehiculoRequest
    public Long id;
    public String modeloCoche;
    public String matricula;
    public Integer plazas;
    public Long idUsuario;
    public Boolean activo;
}
