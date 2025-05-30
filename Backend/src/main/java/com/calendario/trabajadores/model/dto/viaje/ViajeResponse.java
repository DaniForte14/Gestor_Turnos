package com.calendario.trabajadores.model.dto.viaje;

import com.calendario.trabajadores.model.common.CamposComunes;
import com.calendario.trabajadores.model.dto.usuario.UsuarioResponse;
import com.calendario.trabajadores.model.dto.usuario.UsuarioVehiculosResponse;
import com.calendario.trabajadores.model.dto.vehiculo.VehiculoDTO;
import jakarta.persistence.Column;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor

public class ViajeResponse extends CamposComunes {

    public Long idViaje;
    public VehiculoDTO vehiculo = new VehiculoDTO();
    public UsuarioResponse conductor = new UsuarioResponse();
    public List<UsuarioResponse> pasajeros = new ArrayList<>();

    public String origen;
    public String destino;
    //fecha de salida
    public Date fecha;
    //hora de salida
    public Date hora;
    //Integer y no int para poder ser null
    public Integer plazas;
    public Boolean activo;



}
