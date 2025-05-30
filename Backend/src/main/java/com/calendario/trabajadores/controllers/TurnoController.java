package com.calendario.trabajadores.controllers;

import com.calendario.trabajadores.model.database.EstadoTurno;
import com.calendario.trabajadores.model.dto.turno.CrearEditarTurnoResponse;
import com.calendario.trabajadores.model.dto.turno.CrearTurnoRequest;
import com.calendario.trabajadores.model.dto.turno.EditarTurnoRequest;
import com.calendario.trabajadores.model.errorresponse.GenericResponse;
import com.calendario.trabajadores.services.turno.TurnoService;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import com.calendario.trabajadores.model.errorresponse.ErrorResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;

import java.util.List;
import java.util.Optional;

@RestController
@Tag(name = "Turno", description = "Endpoints para gestión de turnos")
public class TurnoController {

    @Autowired
    private TurnoService turnoService;

    // Crear un turno
    @Operation(summary = "Creación de turno", description = "Endpoint para crear un turno")
    @PostMapping("/turno/crear")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Turno creado",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = CrearEditarTurnoResponse.class))),
            @ApiResponse(responseCode = "400", description = "Bad Request",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = ErrorResponse.class)))}
    )
    public ResponseEntity<?> crearTurno(@RequestBody CrearTurnoRequest input) {
        GenericResponse<CrearEditarTurnoResponse> respuestaServicio = turnoService.crearTurno(input);

        if (respuestaServicio.getError() != null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(respuestaServicio);
        }
        return ResponseEntity.ok(respuestaServicio);
    }

    // Modificar un turno
    @Operation(summary = "Modificar turno", description = "Endpoint para modificar un turno")
    @PostMapping("/turno/editar")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Turno modificado",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = CrearEditarTurnoResponse.class))),
            @ApiResponse(responseCode = "400", description = "Bad Request",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = ErrorResponse.class)))}
    )
    public ResponseEntity<GenericResponse<CrearEditarTurnoResponse>> editarTurno(@RequestBody EditarTurnoRequest input) {
        GenericResponse<CrearEditarTurnoResponse> respuestaServicio = turnoService.modificarTurno(input);

        if (respuestaServicio.getError() != null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(respuestaServicio);
        }

        return ResponseEntity.ok(respuestaServicio);
    }

    // Activar o desactivar un turno
    @Operation(summary = "Activar/desactivar turno", description = "Endpoint para activar/desactivar un turno")
    @PostMapping("/turno/toggle")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Turno activado/desactivado",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = CrearEditarTurnoResponse.class))),
            @ApiResponse(responseCode = "400", description = "Bad Request",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = ErrorResponse.class)))}
    )
    public ResponseEntity<?> toggleTurno(@RequestBody Long id) {
        GenericResponse<CrearEditarTurnoResponse> respuestaServicio = turnoService.toggleTurno(id);
        if (respuestaServicio.getError() != null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(respuestaServicio);
        }
        return ResponseEntity.ok(respuestaServicio);
    }

    // Listar turnos de un usuario
    @Operation(summary = "Listar turnos de un usuario", description = "Endpoint para listar todos los turnos de un usuario")
    @GetMapping("/turno/list")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Turnos listados",
                    content = @Content(mediaType = "application/json",
                            array = @ArraySchema(schema = @Schema(implementation = CrearEditarTurnoResponse.class)))),

            @ApiResponse(responseCode = "400", description = "Bad Request  - Parámetro inválido o falta de turnos",
                    content = @Content(mediaType = "application/json",
                            schema = @Schema(implementation = ErrorResponse.class)))
    })
    public ResponseEntity<GenericResponse<List<CrearEditarTurnoResponse>>> listarTurnos(
            @RequestParam(value = "usuarioId") Long usuarioId,
            @RequestParam(value = "estado", required = false) Optional<String> estado) {

        // Convertir el estado (String) a un Enum de EstadoTurno
        Optional<EstadoTurno> estadoTurno = estado.map(estadoString -> {
            try {
                return EstadoTurno.valueOf(estadoString);
            } catch (IllegalArgumentException e) {
                // Si no se encuentra el valor, devolvemos null
                return null;
            }
        });

        // Llamar al servicio para obtener los turnos, pasando el estado convertido
        GenericResponse<List<CrearEditarTurnoResponse>> respuestaServicio = turnoService.listarTurnos(usuarioId, estadoTurno);

        // Comprobar si hay errores en la respuesta del servicio
        if (respuestaServicio.getError() != null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(respuestaServicio);
        }

        // Si no hay errores, devolver la respuesta exitosa
        return ResponseEntity.ok(respuestaServicio);
    }


    // Eliminar un turno
    @Operation(summary = "Eliminar turno", description = "Endpoint para eliminar un turno")
    @DeleteMapping("/turno/borrar")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Turno eliminado",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = String.class))),
            @ApiResponse(responseCode = "400", description = "Bad Request - Usuario no autorizado",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = ErrorResponse.class)))}
    )
    public ResponseEntity<?> borrarTurno(@RequestParam Long idTurno, @RequestParam Long idUsuario) {
        GenericResponse<String> respuestaServicio = turnoService.borrarTurno(idTurno, idUsuario);

        if (respuestaServicio.getError() != null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(respuestaServicio);
        }
        return ResponseEntity.ok(respuestaServicio);
    }
}