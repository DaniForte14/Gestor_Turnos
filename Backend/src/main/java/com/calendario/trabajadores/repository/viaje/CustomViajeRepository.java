package com.calendario.trabajadores.repository.viaje;

import com.calendario.trabajadores.model.database.EstadoViaje;
import com.calendario.trabajadores.model.database.Viaje;

import java.util.Date;
import java.util.List;
import java.util.Optional;

public interface CustomViajeRepository {

    //Metodo para mostrar los viajes de un conductor
    List<Viaje> mostrarViajesConductor(Long usuarioId);

    //Mostrar mis viajes (pasajero)
    List<Viaje> mostrarMisViajes(Long usuarioId);

    //Actualizar viaje
    Viaje actualizarViaje(Viaje viaje);

    //Cancelar viaje
    void cancelarViaje(Long viajeId);

    //Agregar usuario a viaje
    void agregarUsuarioViaje(Long viajeId, Long usuarioId);

    //Eliminar usuario de viaje
    void eliminarUsuarioViaje(Long viajeId, Long usuarioId);


    List<Viaje> findAllViajesByEstado(EstadoViaje estado);

    List<Viaje> findViajesByUsuarioAndEstado(Long usuarioId, EstadoViaje estado);
}
