package com.calendario.trabajadores.model.dto.usuario;

import com.calendario.trabajadores.model.dto.vehiculo.VehiculoDTO;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class UsuarioVehiculosResponse{

    public Long id;
    public String nombre;
    public String apellido1;
    public String apellido2;
    public String email;
    public List<VehiculoDTO> vehiculos;
    public Boolean activo;


}
