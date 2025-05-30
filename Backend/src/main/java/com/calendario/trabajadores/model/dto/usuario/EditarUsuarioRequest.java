package com.calendario.trabajadores.model.dto.usuario;

import com.calendario.trabajadores.model.database.Puesto;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class EditarUsuarioRequest {
    //Atributos
    public Long id;
    public String nombre;
    public String apellido1;
    public String apellido2;
    public String email;
    // Password solo en request porque no se devuelve en response
    public String password;
    public String telefono;
    public String centroTrabajo;
    public Puesto puesto;
    public String localidad;
    public String preferenciasHorarias;
    public Boolean disponibilidadHorasExtras;
    public String rol;
    public Boolean activo;
}
