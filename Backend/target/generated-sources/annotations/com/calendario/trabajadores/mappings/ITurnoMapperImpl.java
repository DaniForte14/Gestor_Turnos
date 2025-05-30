package com.calendario.trabajadores.mappings;

import com.calendario.trabajadores.model.database.EstadoTurno;
import com.calendario.trabajadores.model.database.PeticionTurno;
import com.calendario.trabajadores.model.database.Turno;
import com.calendario.trabajadores.model.database.Usuario;
import com.calendario.trabajadores.model.dto.turno.CrearEditarTurnoResponse;
import com.calendario.trabajadores.model.dto.turno.CrearTurnoRequest;
import com.calendario.trabajadores.model.dto.turno.EditarTurnoRequest;
import com.calendario.trabajadores.model.dto.turno.TurnoDTO;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-04-19T17:14:58+0200",
    comments = "version: 1.6.3, compiler: javac, environment: Java 21.0.4 (Oracle Corporation)"
)
@Component
public class ITurnoMapperImpl implements ITurnoMapper {

    @Override
    public CrearEditarTurnoResponse turnoToCrearEditarTurnoResponse(Turno turno) {
        if ( turno == null ) {
            return null;
        }

        CrearEditarTurnoResponse crearEditarTurnoResponse = new CrearEditarTurnoResponse();

        crearEditarTurnoResponse.setIdUsuario( turnoUsuarioId( turno ) );
        crearEditarTurnoResponse.setId( turno.getId() );
        crearEditarTurnoResponse.setHoraInicio( turno.getHoraInicio() );
        crearEditarTurnoResponse.setHoraFin( turno.getHoraFin() );
        crearEditarTurnoResponse.setEstadoTurno( turno.getEstadoTurno() );
        crearEditarTurnoResponse.setPeticionTurno( turno.getPeticionTurno() );
        crearEditarTurnoResponse.setNotasPeticion( turno.getNotasPeticion() );
        crearEditarTurnoResponse.setActivo( turno.getActivo() );

        return crearEditarTurnoResponse;
    }

    @Override
    public Turno crearTurnoRequestToTurno(CrearTurnoRequest request) {
        if ( request == null ) {
            return null;
        }

        Turno turno = new Turno();

        turno.setUsuario( crearTurnoRequestToUsuario( request ) );
        turno.setHoraInicio( request.getHoraInicio() );
        turno.setHoraFin( request.getHoraFin() );
        turno.setNotasPeticion( request.getNotasPeticion() );

        turno.setEstadoTurno( EstadoTurno.SIN_EMPEZAR );
        turno.setPeticionTurno( PeticionTurno.PENDIENTE );

        return turno;
    }

    @Override
    public Turno editarTurnoRequestToTurno(EditarTurnoRequest request) {
        if ( request == null ) {
            return null;
        }

        Turno turno = new Turno();

        turno.setId( request.getId() );
        turno.setHoraInicio( request.getHoraInicio() );
        turno.setHoraFin( request.getHoraFin() );
        turno.setEstadoTurno( request.getEstadoTurno() );
        turno.setPeticionTurno( request.getPeticionTurno() );
        turno.setNotasPeticion( request.getNotasPeticion() );
        turno.setActivo( request.getActivo() );

        return turno;
    }

    @Override
    public TurnoDTO turnoToTurnoDTO(Turno turno) {
        if ( turno == null ) {
            return null;
        }

        TurnoDTO turnoDTO = new TurnoDTO();

        turnoDTO.setNombreUsuario( turnoUsuarioNombre( turno ) );
        turnoDTO.setEmailUsuario( turnoUsuarioEmail( turno ) );
        turnoDTO.setId( turno.getId() );
        turnoDTO.setHoraInicio( turno.getHoraInicio() );
        turnoDTO.setHoraFin( turno.getHoraFin() );
        turnoDTO.setEstadoTurno( turno.getEstadoTurno() );
        turnoDTO.setPeticionTurno( turno.getPeticionTurno() );
        turnoDTO.setActivo( turno.getActivo() );

        return turnoDTO;
    }

    private Long turnoUsuarioId(Turno turno) {
        Usuario usuario = turno.getUsuario();
        if ( usuario == null ) {
            return null;
        }
        return usuario.getId();
    }

    protected Usuario crearTurnoRequestToUsuario(CrearTurnoRequest crearTurnoRequest) {
        if ( crearTurnoRequest == null ) {
            return null;
        }

        Usuario usuario = new Usuario();

        usuario.setId( crearTurnoRequest.getIdUsuario() );

        return usuario;
    }

    private String turnoUsuarioNombre(Turno turno) {
        Usuario usuario = turno.getUsuario();
        if ( usuario == null ) {
            return null;
        }
        return usuario.getNombre();
    }

    private String turnoUsuarioEmail(Turno turno) {
        Usuario usuario = turno.getUsuario();
        if ( usuario == null ) {
            return null;
        }
        return usuario.getEmail();
    }
}
