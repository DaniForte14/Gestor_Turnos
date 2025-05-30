package com.calendario.trabajadores.mappings;

import com.calendario.trabajadores.model.database.Usuario;
import com.calendario.trabajadores.model.database.UsuarioViaje;
import com.calendario.trabajadores.model.database.Viaje;
import com.calendario.trabajadores.model.dto.usuario.UsuarioResponse;
import com.calendario.trabajadores.model.dto.viaje.CrearEditarViajeResponse;
import com.calendario.trabajadores.model.dto.viaje.CrearViajeRequest;
import com.calendario.trabajadores.model.dto.viaje.ViajeDTO;
import com.calendario.trabajadores.model.dto.viaje.ViajeResponse;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.Named;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Mapper(componentModel = "spring")
public interface IViajeMapper {

    @Mapping(target = "idVehiculo", source = "vehiculo.id")
    @Mapping(target = "idConductor", source = "conductor.id")
    @Mapping(source = "fecha", target = "fechaSalida")
    @Mapping(source = "hora", target = "horaSalida")
    CrearEditarViajeResponse viajeToCrearEditarViajeResponse(Viaje viajeGuardado);

    @Mapping(source = "idVehiculo", target = "vehiculo.id")
    @Mapping(source = "idConductor", target = "conductor.id")
    @Mapping(source = "fechaSalida", target = "fecha")
    @Mapping(source = "horaSalida", target = "hora")
    @Mapping(target = "usuarioViajes", ignore = true)
    @Mapping(target = "fechaCreacion", ignore = true)
    @Mapping(target = "fechaModificacion", ignore = true)
    @Mapping(target = "creadoPor", ignore = true)
    @Mapping(target = "modificadoPor", ignore = true)
    Viaje crearViajeRequestToViaje(CrearViajeRequest request);

    @Mapping(target = "pasajeros", source = "usuarioViajes", qualifiedByName = "mapPasajeros")
    ViajeResponse viajeToViajeResponse(Viaje viajedb);

    @Named("mapPasajeros")
    default List<UsuarioResponse> mapPasajeros(List<UsuarioViaje> usuarioViajes) {
        if (usuarioViajes == null) return new ArrayList<>();
        return usuarioViajes.stream()
                .map(uv -> usuarioToUsuarioResponse(uv.getUsuario()))
                .collect(Collectors.toList());
    }

    @Mapping(target = "id", source = "id")
    UsuarioResponse usuarioToUsuarioResponse(Usuario usuario);

    @Mapping(target = "id", source = "id")
    @Mapping(target = "fecha", source = "fecha")
    @Mapping(target = "hora", source = "hora")
    @Mapping(target = "vehiculoId", source = "vehiculo.id")
    @Mapping(target = "conductorId", source = "conductor.id")
    ViajeDTO viajeToViajeDTO(Viaje viaje);
}