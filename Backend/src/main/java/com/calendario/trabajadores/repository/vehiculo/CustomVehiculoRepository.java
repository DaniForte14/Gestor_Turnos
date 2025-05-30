package com.calendario.trabajadores.repository.vehiculo;

import com.calendario.trabajadores.model.database.Vehiculo;

import java.util.List;
import java.util.Optional;

public interface CustomVehiculoRepository{

    //Listar vehiculos por usuario
    List<Vehiculo> listarVehiculosUsuario(Long usuarioId);


    List<Vehiculo> listarVehiculosUsuarioConFiltro(Long usuarioId, Optional<Boolean> activo);
}

