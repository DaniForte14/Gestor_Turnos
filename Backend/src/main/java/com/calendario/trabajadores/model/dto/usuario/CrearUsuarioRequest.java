package com.calendario.trabajadores.model.dto.usuario;

import com.calendario.trabajadores.model.database.Puesto;
import jakarta.persistence.Column;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class CrearUsuarioRequest {
    //Atributos
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
    public Boolean activo;  //**** TODO:Revisar

}

