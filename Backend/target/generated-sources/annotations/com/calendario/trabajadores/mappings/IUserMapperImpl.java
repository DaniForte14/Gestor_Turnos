package com.calendario.trabajadores.mappings;

import com.calendario.trabajadores.model.database.Usuario;
import com.calendario.trabajadores.model.database.Viaje;
import com.calendario.trabajadores.model.dto.usuario.CrearUsuarioRequest;
import com.calendario.trabajadores.model.dto.usuario.EditarUsuarioRequest;
import com.calendario.trabajadores.model.dto.usuario.UsuarioResponse;
import com.calendario.trabajadores.model.dto.usuario.UsuarioVehiculosResponse;
import com.calendario.trabajadores.model.dto.usuario.UsuarioViajeResponse;
import com.calendario.trabajadores.model.dto.vehiculo.VehiculoDTO;
import com.calendario.trabajadores.model.dto.viaje.ViajeDTO;
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
public class IUserMapperImpl implements IUserMapper {

    @Override
    public UsuarioResponse userToCreateEditResponse(Usuario userDB) {
        if ( userDB == null ) {
            return null;
        }

        UsuarioResponse usuarioResponse = new UsuarioResponse();

        usuarioResponse.setFechaCreacion( userDB.getFechaCreacion() );
        usuarioResponse.setFechaModificacion( userDB.getFechaModificacion() );
        usuarioResponse.setCreadoPor( userDB.getCreadoPor() );
        usuarioResponse.setModificadoPor( userDB.getModificadoPor() );
        usuarioResponse.setId( userDB.getId() );
        usuarioResponse.setNombre( userDB.getNombre() );
        usuarioResponse.setApellido1( userDB.getApellido1() );
        usuarioResponse.setApellido2( userDB.getApellido2() );
        usuarioResponse.setEmail( userDB.getEmail() );
        usuarioResponse.setTelefono( userDB.getTelefono() );
        usuarioResponse.setCentroTrabajo( userDB.getCentroTrabajo() );
        usuarioResponse.setPuesto( userDB.getPuesto() );
        usuarioResponse.setLocalidad( userDB.getLocalidad() );
        usuarioResponse.setPreferenciasHorarias( userDB.getPreferenciasHorarias() );
        usuarioResponse.setDisponibilidadHorasExtras( userDB.getDisponibilidadHorasExtras() );
        usuarioResponse.setRol( userDB.getRol() );
        usuarioResponse.setActivo( userDB.getActivo() );
        usuarioResponse.setViajes( viajeListToViajeDTOList( userDB.getViajes() ) );

        return usuarioResponse;
    }

    @Override
    public Usuario createRequestToUser(CrearUsuarioRequest request) {
        if ( request == null ) {
            return null;
        }

        Usuario usuario = new Usuario();

        usuario.setContraseña( request.getPassword() );
        usuario.setNombre( request.getNombre() );
        usuario.setApellido1( request.getApellido1() );
        usuario.setApellido2( request.getApellido2() );
        usuario.setEmail( request.getEmail() );
        usuario.setTelefono( request.getTelefono() );
        usuario.setCentroTrabajo( request.getCentroTrabajo() );
        usuario.setPuesto( request.getPuesto() );
        usuario.setLocalidad( request.getLocalidad() );
        usuario.setPreferenciasHorarias( request.getPreferenciasHorarias() );
        usuario.setDisponibilidadHorasExtras( request.getDisponibilidadHorasExtras() );
        usuario.setRol( request.getRol() );
        usuario.setActivo( request.getActivo() );

        return usuario;
    }

    @Override
    public Usuario editRequestToUser(EditarUsuarioRequest request) {
        if ( request == null ) {
            return null;
        }

        Usuario usuario = new Usuario();

        usuario.setContraseña( request.getPassword() );
        usuario.setId( request.getId() );
        usuario.setNombre( request.getNombre() );
        usuario.setApellido1( request.getApellido1() );
        usuario.setApellido2( request.getApellido2() );
        usuario.setEmail( request.getEmail() );
        usuario.setTelefono( request.getTelefono() );
        usuario.setCentroTrabajo( request.getCentroTrabajo() );
        usuario.setPuesto( request.getPuesto() );
        usuario.setLocalidad( request.getLocalidad() );
        usuario.setPreferenciasHorarias( request.getPreferenciasHorarias() );
        usuario.setDisponibilidadHorasExtras( request.getDisponibilidadHorasExtras() );
        usuario.setRol( request.getRol() );
        usuario.setActivo( request.getActivo() );

        return usuario;
    }

    @Override
    public UsuarioVehiculosResponse usuarioToUsuarioVehiculosResponse(Usuario usuario, List<VehiculoDTO> vehiculos) {
        if ( usuario == null && vehiculos == null ) {
            return null;
        }

        UsuarioVehiculosResponse usuarioVehiculosResponse = new UsuarioVehiculosResponse();

        if ( usuario != null ) {
            usuarioVehiculosResponse.setId( usuario.getId() );
            usuarioVehiculosResponse.setNombre( usuario.getNombre() );
            usuarioVehiculosResponse.setApellido1( usuario.getApellido1() );
            usuarioVehiculosResponse.setApellido2( usuario.getApellido2() );
            usuarioVehiculosResponse.setEmail( usuario.getEmail() );
            usuarioVehiculosResponse.setActivo( usuario.getActivo() );
        }
        List<VehiculoDTO> list = vehiculos;
        if ( list != null ) {
            usuarioVehiculosResponse.setVehiculos( new ArrayList<VehiculoDTO>( list ) );
        }

        setVehiculosNullSafe( usuarioVehiculosResponse );

        return usuarioVehiculosResponse;
    }

    @Override
    public UsuarioResponse usuarioToUsuarioResponse(Usuario usuario) {
        if ( usuario == null ) {
            return null;
        }

        UsuarioResponse usuarioResponse = new UsuarioResponse();

        usuarioResponse.setFechaCreacion( usuario.getFechaCreacion() );
        usuarioResponse.setFechaModificacion( usuario.getFechaModificacion() );
        usuarioResponse.setCreadoPor( usuario.getCreadoPor() );
        usuarioResponse.setModificadoPor( usuario.getModificadoPor() );
        usuarioResponse.setId( usuario.getId() );
        usuarioResponse.setNombre( usuario.getNombre() );
        usuarioResponse.setApellido1( usuario.getApellido1() );
        usuarioResponse.setApellido2( usuario.getApellido2() );
        usuarioResponse.setEmail( usuario.getEmail() );
        usuarioResponse.setTelefono( usuario.getTelefono() );
        usuarioResponse.setCentroTrabajo( usuario.getCentroTrabajo() );
        usuarioResponse.setPuesto( usuario.getPuesto() );
        usuarioResponse.setLocalidad( usuario.getLocalidad() );
        usuarioResponse.setPreferenciasHorarias( usuario.getPreferenciasHorarias() );
        usuarioResponse.setDisponibilidadHorasExtras( usuario.getDisponibilidadHorasExtras() );
        usuarioResponse.setRol( usuario.getRol() );
        usuarioResponse.setActivo( usuario.getActivo() );
        usuarioResponse.setViajes( viajeListToViajeDTOList( usuario.getViajes() ) );

        return usuarioResponse;
    }

    @Override
    public UsuarioViajeResponse userToUsuarioViajeResponse(Usuario usuario) {
        if ( usuario == null ) {
            return null;
        }

        UsuarioViajeResponse usuarioViajeResponse = new UsuarioViajeResponse();

        usuarioViajeResponse.setViajes( viajeListToViajeDTOList( usuario.getViajes() ) );
        usuarioViajeResponse.setId( usuario.getId() );
        usuarioViajeResponse.setNombre( usuario.getNombre() );
        usuarioViajeResponse.setApellido1( usuario.getApellido1() );
        usuarioViajeResponse.setApellido2( usuario.getApellido2() );
        usuarioViajeResponse.setEmail( usuario.getEmail() );
        usuarioViajeResponse.setTelefono( usuario.getTelefono() );
        usuarioViajeResponse.setCentroTrabajo( usuario.getCentroTrabajo() );
        usuarioViajeResponse.setActivo( usuario.getActivo() );

        return usuarioViajeResponse;
    }

    protected ViajeDTO viajeToViajeDTO(Viaje viaje) {
        if ( viaje == null ) {
            return null;
        }

        ViajeDTO viajeDTO = new ViajeDTO();

        viajeDTO.setId( viaje.getId() );
        viajeDTO.setFecha( viaje.getFecha() );
        viajeDTO.setHora( viaje.getHora() );
        viajeDTO.setOrigen( viaje.getOrigen() );
        viajeDTO.setDestino( viaje.getDestino() );
        viajeDTO.setPlazas( viaje.getPlazas() );
        viajeDTO.setEstado( viaje.getEstado() );

        return viajeDTO;
    }

    protected List<ViajeDTO> viajeListToViajeDTOList(List<Viaje> list) {
        if ( list == null ) {
            return null;
        }

        List<ViajeDTO> list1 = new ArrayList<ViajeDTO>( list.size() );
        for ( Viaje viaje : list ) {
            list1.add( viajeToViajeDTO( viaje ) );
        }

        return list1;
    }
}
