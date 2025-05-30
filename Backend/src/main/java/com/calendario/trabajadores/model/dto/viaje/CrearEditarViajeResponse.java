package com.calendario.trabajadores.model.dto.viaje;

import jakarta.persistence.Column;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.util.Date;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class CrearEditarViajeResponse {
    public Long idVehiculo;

    public Long idConductor;

    public String origen;
    public String destino;

    public Date fechaSalida;

    public Date horaSalida;
    //Integer y no int para poder ser null
    public Integer plazas;
    public Boolean activo;  //**** Inluyo activo? TODO:Pregunta
    @CreationTimestamp
    @Column(updatable = false)
    private Date fechaCreacion;

    @UpdateTimestamp
    private Date fechaModificacion;



}
