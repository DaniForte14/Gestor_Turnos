package com.calendario.trabajadores.mappings;

import com.calendario.trabajadores.model.database.Usuario;
import com.calendario.trabajadores.model.database.Vehiculo;
import com.calendario.trabajadores.model.dto.usuario.UsuarioVehiculosResponse;
import com.calendario.trabajadores.model.dto.vehiculo.CrearEditarVehiculoResponse;
import com.calendario.trabajadores.model.dto.vehiculo.CrearVehiculoRequest;
import com.calendario.trabajadores.model.dto.vehiculo.EditarVehiculoRequest;
import com.calendario.trabajadores.model.dto.vehiculo.VehiculoDTO;
import java.util.ArrayList;
import java.util.List;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-04-19T17:14:58+0200",
    comments = "version: 1.6.3, compiler: javac, environment: Java 21.0.4 (Oracle Corporation)"
)
@Component
public class IVehiculoMapperImpl implements IVehiculoMapper {

    @Override
    public CrearEditarVehiculoResponse vehiculoToCreateEditResponse(Vehiculo vehiculoDB) {
        if ( vehiculoDB == null ) {
            return null;
        }

        CrearEditarVehiculoResponse crearEditarVehiculoResponse = new CrearEditarVehiculoResponse();

        crearEditarVehiculoResponse.setId( vehiculoDB.getId() );
        crearEditarVehiculoResponse.setModeloCoche( vehiculoDB.getModeloCoche() );
        crearEditarVehiculoResponse.setMatricula( vehiculoDB.getMatricula() );
        crearEditarVehiculoResponse.setPlazas( vehiculoDB.getPlazas() );
        crearEditarVehiculoResponse.setUsuario( usuarioToUsuarioVehiculosResponse( vehiculoDB.getUsuario() ) );
        crearEditarVehiculoResponse.setActivo( vehiculoDB.getActivo() );
        crearEditarVehiculoResponse.setFechaCreacion( vehiculoDB.getFechaCreacion() );
        crearEditarVehiculoResponse.setFechaModificacion( vehiculoDB.getFechaModificacion() );

        return crearEditarVehiculoResponse;
    }

    @Override
    public Vehiculo createRequestToVehiculo(CrearVehiculoRequest request) {
        if ( request == null ) {
            return null;
        }

        Vehiculo vehiculo = new Vehiculo();

        vehiculo.setUsuario( crearVehiculoRequestToUsuario( request ) );
        vehiculo.setModeloCoche( request.getModeloCoche() );
        vehiculo.setMatricula( request.getMatricula() );
        if ( request.getPlazas() != null ) {
            vehiculo.setPlazas( request.getPlazas() );
        }
        vehiculo.setActivo( request.getActivo() );

        return vehiculo;
    }

    @Override
    public Vehiculo editRequestToUser(EditarVehiculoRequest request) {
        if ( request == null ) {
            return null;
        }

        Vehiculo vehiculo = new Vehiculo();

        vehiculo.setUsuario( editarVehiculoRequestToUsuario( request ) );
        vehiculo.setId( request.getId() );
        vehiculo.setModeloCoche( request.getModeloCoche() );
        vehiculo.setMatricula( request.getMatricula() );
        if ( request.getPlazas() != null ) {
            vehiculo.setPlazas( request.getPlazas() );
        }
        vehiculo.setActivo( request.getActivo() );

        return vehiculo;
    }

    protected VehiculoDTO vehiculoToVehiculoDTO(Vehiculo vehiculo) {
        if ( vehiculo == null ) {
            return null;
        }

        VehiculoDTO vehiculoDTO = new VehiculoDTO();

        vehiculoDTO.setFechaCreacion( vehiculo.getFechaCreacion() );
        vehiculoDTO.setFechaModificacion( vehiculo.getFechaModificacion() );
        vehiculoDTO.setCreadoPor( vehiculo.getCreadoPor() );
        vehiculoDTO.setModificadoPor( vehiculo.getModificadoPor() );
        vehiculoDTO.setId( vehiculo.getId() );
        vehiculoDTO.setModeloCoche( vehiculo.getModeloCoche() );
        vehiculoDTO.setMatricula( vehiculo.getMatricula() );
        vehiculoDTO.setPlazas( vehiculo.getPlazas() );
        vehiculoDTO.setActivo( vehiculo.getActivo() );

        return vehiculoDTO;
    }

    protected List<VehiculoDTO> vehiculoListToVehiculoDTOList(List<Vehiculo> list) {
        if ( list == null ) {
            return null;
        }

        List<VehiculoDTO> list1 = new ArrayList<VehiculoDTO>( list.size() );
        for ( Vehiculo vehiculo : list ) {
            list1.add( vehiculoToVehiculoDTO( vehiculo ) );
        }

        return list1;
    }

    protected UsuarioVehiculosResponse usuarioToUsuarioVehiculosResponse(Usuario usuario) {
        if ( usuario == null ) {
            return null;
        }

        UsuarioVehiculosResponse usuarioVehiculosResponse = new UsuarioVehiculosResponse();

        usuarioVehiculosResponse.setId( usuario.getId() );
        usuarioVehiculosResponse.setNombre( usuario.getNombre() );
        usuarioVehiculosResponse.setApellido1( usuario.getApellido1() );
        usuarioVehiculosResponse.setApellido2( usuario.getApellido2() );
        usuarioVehiculosResponse.setEmail( usuario.getEmail() );
        usuarioVehiculosResponse.setVehiculos( vehiculoListToVehiculoDTOList( usuario.getVehiculos() ) );
        usuarioVehiculosResponse.setActivo( usuario.getActivo() );

        return usuarioVehiculosResponse;
    }

    protected Usuario crearVehiculoRequestToUsuario(CrearVehiculoRequest crearVehiculoRequest) {
        if ( crearVehiculoRequest == null ) {
            return null;
        }

        Usuario usuario = new Usuario();

        usuario.setId( crearVehiculoRequest.getIdUsuario() );

        return usuario;
    }

    protected Usuario editarVehiculoRequestToUsuario(EditarVehiculoRequest editarVehiculoRequest) {
        if ( editarVehiculoRequest == null ) {
            return null;
        }

        Usuario usuario = new Usuario();

        usuario.setId( editarVehiculoRequest.getIdUsuario() );

        return usuario;
    }
}
