package com.calendario.trabajadores.services.turno;

import com.calendario.trabajadores.mappings.ITurnoMapper;
import com.calendario.trabajadores.model.database.EstadoTurno;
import com.calendario.trabajadores.model.database.Turno;
import com.calendario.trabajadores.model.database.Usuario;
import com.calendario.trabajadores.model.dto.turno.CrearEditarTurnoResponse;
import com.calendario.trabajadores.model.dto.turno.CrearTurnoRequest;
import com.calendario.trabajadores.model.dto.turno.EditarTurnoRequest;
import com.calendario.trabajadores.model.errorresponse.ErrorResponse;
import com.calendario.trabajadores.model.errorresponse.GenericResponse;
import com.calendario.trabajadores.repository.turno.ITurnoRepository;
import com.calendario.trabajadores.repository.usuario.IUsuarioRepository;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class TurnoService {

    private final ITurnoRepository turnoRepository;
    private final ITurnoMapper turnoMapper;
    private final IUsuarioRepository usuarioRepository;

    // Constructor del servicio
    public TurnoService(ITurnoRepository turnoRepository, ITurnoMapper turnoMapper, IUsuarioRepository usuarioRepository) {
        this.turnoRepository = turnoRepository;
        this.turnoMapper = turnoMapper;
        this.usuarioRepository = usuarioRepository;
    }

    // Crear un turno (solo deberia hacerlo un admin)
    public GenericResponse<CrearEditarTurnoResponse> crearTurno(CrearTurnoRequest request) {
        GenericResponse<CrearEditarTurnoResponse> responseWrapper = new GenericResponse<>();

        // Añadir validaciones

        // Crear el objeto turno desde el request
        Turno turno = turnoMapper.crearTurnoRequestToTurno(request);

        // Guardamos el turno en la base de datos
        Turno turnoGuardado = turnoRepository.save(turno);

        // Mapeamos la respuesta
        CrearEditarTurnoResponse response = turnoMapper.turnoToCrearEditarTurnoResponse(turnoGuardado);

        // Devolvemos la respuesta
        responseWrapper.setData(response);
        return responseWrapper;
    }

    // Modificar un turno
    public GenericResponse<CrearEditarTurnoResponse> modificarTurno(EditarTurnoRequest request) {
        GenericResponse<CrearEditarTurnoResponse> responseWrapper = new GenericResponse<>();

        // Buscar el turno por ID
        Optional<Turno> turnoOptional = turnoRepository.findById(request.getId());

        if (turnoOptional.isEmpty()) {
            responseWrapper.setError(new ErrorResponse("El turno no existe"));
            return responseWrapper;
        }

        Turno turno = turnoOptional.get();

        // Actualizar solo los campos enviados en la peticion de modificar
        if (request.getHoraInicio() != null) {
            turno.setHoraInicio(request.getHoraInicio());
        }
        if (request.getHoraFin() != null) {
            turno.setHoraFin(request.getHoraFin());
        }
        if (request.getEstadoTurno() != null) {
            turno.setEstadoTurno(request.getEstadoTurno());
        }
        if (request.getNotasPeticion() != null) {
            turno.setNotasPeticion(request.getNotasPeticion());
        }
        if (request.getActivo() != null) {
            turno.setActivo(request.getActivo());
        }

        // Guardamos los cambios en la base de datos
        Turno turnoActualizado = turnoRepository.save(turno);

        // Mapeamos la respuesta y la devolvemos
        responseWrapper.setData(turnoMapper.turnoToCrearEditarTurnoResponse(turnoActualizado));
        return responseWrapper;
    }

    // Desactivar un turno (cambiar el estado a "inactivo")
    public GenericResponse<CrearEditarTurnoResponse> toggleTurno(Long id) {
        GenericResponse<CrearEditarTurnoResponse> responseWrapper = new GenericResponse<>();

        // Buscar el turno por ID
        Optional<Turno> turnoOpt = turnoRepository.findById(id);

        if (turnoOpt.isEmpty()) {
            responseWrapper.setError(new ErrorResponse("El turno no existe"));
            return responseWrapper;
        }

        // Cambiar el estado del turno
        Turno turno = turnoOpt.get();
        turno.setActivo(!turno.getActivo());

        // Guardar los cambios
        Turno turnoActualizado = turnoRepository.save(turno);

        // Mapeamos y devolvemos la respuesta
        responseWrapper.setData(turnoMapper.turnoToCrearEditarTurnoResponse(turnoActualizado));
        return responseWrapper;
    }

    public GenericResponse<List<CrearEditarTurnoResponse>> listarTurnos(Long usuarioId, Optional<EstadoTurno> estado) {
        // Validar si el usuario existe con el repositorio de usuarios
        var usuario = usuarioRepository.findById(usuarioId);
        if (usuario.isEmpty()) {
            var errorResponse = new GenericResponse<List<CrearEditarTurnoResponse>>();
            errorResponse.setError(new ErrorResponse("Usuario no encontrado"));
            return errorResponse;
        }

        // Obtener lista de turnos, filtrados por el usuario y estado (si nos lo dan)
        List<Turno> turnos = new ArrayList<>();

        if (estado.isPresent()) {
            turnos = turnoRepository.findByUsuarioIdAndEstadoTurno(usuarioId, estado.get());
        } else {
            turnos = turnoRepository.findByUsuarioId(usuarioId);
        }

        // Mapear turnos a respuestas DTO
        List<CrearEditarTurnoResponse> turnoResponses = turnos.stream()
                .map(turno -> turnoMapper.turnoToCrearEditarTurnoResponse(turno))
                .collect(Collectors.toList());

        // Envolver en GenericResponse y devolver
        var wrapperResponse = new GenericResponse<List<CrearEditarTurnoResponse>>();
        wrapperResponse.setData(turnoResponses);
        return wrapperResponse;
    }

    // Borrar un turno (solo lo puede hacer un usuario admin)
    public GenericResponse<String> borrarTurno(Long idTurno, Long idUsuario) {
        GenericResponse<String> responseWrapper = new GenericResponse<>();

        // Verificar si el usuario es admin
        Optional<Usuario> usuarioOpt = usuarioRepository.findById(idUsuario);
        if (usuarioOpt.isEmpty() || !usuarioOpt.get().getRol().equals("ADMIN")) {
            responseWrapper.setError(new ErrorResponse("No tienes permiso para realizar esta acción"));
            return responseWrapper;
        }

        // Buscar el turno por ID
        Optional<Turno> turnoOpt = turnoRepository.findById(idTurno);
        if (turnoOpt.isEmpty()) {
            responseWrapper.setError(new ErrorResponse("El turno no existe"));
            return responseWrapper;
        }

        // Eliminar el turno de la base de datos
        turnoRepository.delete(turnoOpt.get());

        // Devolver respuesta exitosa
        responseWrapper.setData("Turno eliminado");
        return responseWrapper;
    }
}
