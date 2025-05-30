package com.calendario.trabajadores.model.dto.vehiculo;

import com.calendario.trabajadores.model.dto.usuario.UsuarioVehiculosResponse;
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
public class CrearEditarVehiculoResponse {
    //Atributos de CrearEditarVehiculoResponse
    public Long id;
    public String modeloCoche;
    public String matricula;
    //Integer y no int para que pueda ser null
    public Integer plazas;
    public UsuarioVehiculosResponse usuario;
    //Boolean y no boolean para que pueda ser null
    public Boolean activo;
    @CreationTimestamp
    @Column(updatable = false)
    private Date fechaCreacion;

    @UpdateTimestamp
    private Date fechaModificacion;
}
