package com.calendario.trabajadores.model.dto.viaje;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.Date;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor

public class EditarViajeRequest {
    public Long idVehiculo;

    public Long idConductor;

    public String origen;
    public String destino;

    public Date fechaSalida;

    public Date horaSalida;
    //Integer y no int para poder ser null
    public Integer plazas;
    //public Boolean activo;  //**** Inluyo activo? TODO:Pregunta
}
