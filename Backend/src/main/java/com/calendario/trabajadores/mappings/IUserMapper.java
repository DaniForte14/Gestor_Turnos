package com.calendario.trabajadores.mappings;

import com.calendario.trabajadores.model.database.Usuario;
import com.calendario.trabajadores.model.dto.usuario.*;
import com.calendario.trabajadores.model.dto.vehiculo.VehiculoDTO;
import org.mapstruct.AfterMapping;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.AfterMapping;
import org.mapstruct.MappingTarget;

import java.util.ArrayList;
import java.util.List;

@Mapper(componentModel = "spring")
public interface IUserMapper {
    //Mapeo de los atributos de la clase Usuario a los atributos de la clase UsuarioVehiculosResponse
    UsuarioResponse userToCreateEditResponse(Usuario userDB);

    //Mapeo de los atributos de la clase CrearUsuarioRequest a los atributos de la clase Usuario
    @Mapping(source = "password", target = "contraseña")
    Usuario createRequestToUser(CrearUsuarioRequest request);

    //Mapeo de los atributos de la clase EditarUsuarioRequest a los atributos de la clase Usuario
    @Mapping(source = "password", target = "contraseña")
    Usuario editRequestToUser(EditarUsuarioRequest request);
    /*F*/
    @Mapping(target = "vehiculos", source = "vehiculos")
    UsuarioVehiculosResponse usuarioToUsuarioVehiculosResponse(Usuario usuario, List<VehiculoDTO> vehiculos);

    //Para manejar que los usuarios puedan no tener vehiculos, es decir, sea null
    @AfterMapping
    default void setVehiculosNullSafe(@MappingTarget UsuarioVehiculosResponse response) {
        if (response.getVehiculos() == null) {
            response.setVehiculos(new ArrayList<>());
        }
    }

    UsuarioResponse usuarioToUsuarioResponse(Usuario usuario);
    // Mapea la lista de viajes a la propiedad 'viajes'
    @Mapping(source = "usuario.viajes", target = "viajes")
    UsuarioViajeResponse userToUsuarioViajeResponse(Usuario usuario);
}
