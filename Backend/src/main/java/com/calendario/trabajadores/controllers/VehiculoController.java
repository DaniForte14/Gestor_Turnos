package com.calendario.trabajadores.controllers;

import com.calendario.trabajadores.model.dto.usuario.UsuarioResponse;
import com.calendario.trabajadores.model.dto.vehiculo.CrearEditarVehiculoResponse;
import com.calendario.trabajadores.model.dto.vehiculo.CrearVehiculoRequest;
import com.calendario.trabajadores.model.dto.vehiculo.EditarVehiculoRequest;
import com.calendario.trabajadores.model.errorresponse.GenericResponse;
import com.calendario.trabajadores.services.vehiculo.VehiculoService;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import com.calendario.trabajadores.model.errorresponse.ErrorResponse;
import com.calendario.trabajadores.services.user.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;
import java.util.Optional;


@RestController
@Tag(name = "Vehiculo", description = "Endpoints para vehiculo")
public class VehiculoController {
    @Autowired
    private VehiculoService vehiculoService;
    @Autowired
    private UserService userService;

    //No necesito el constructor porque ya tengo la inyeccion de dependencias con @Autowired
    public VehiculoController(VehiculoService vehiculoService, UserService userService) {
        this.vehiculoService = vehiculoService;
        this.userService = userService;
    }

    //Crear un vehículo
    @Operation(summary = "Creación de vehiculo", description = "Endpoint para crear un vehiculo")
    @PostMapping("/vehiculo/crear")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Vehiculo creado",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = CrearEditarVehiculoResponse.class))),
            @ApiResponse(responseCode = "400", description = "Bad Request",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = ErrorResponse.class)))}
    )
    public ResponseEntity<?> CrearVehiculo(@RequestBody CrearVehiculoRequest input) {
        //Dejo de trabajar con optional y empiezo a trabajar con GenericResponse
        GenericResponse<CrearEditarVehiculoResponse> respuestaServicio = vehiculoService.crearVehiculo(input);
        //Cambio isEmpty por getError() != null para dar ahora la traza del error
        if (respuestaServicio.getError() != null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(respuestaServicio);
        }
        return ResponseEntity.ok(respuestaServicio);
    }

    //Editar los datos de un vehiculo
    @Operation(summary = "Editar vehiculo", description = "Endpoint para editar un vehiculo")
    @PostMapping("/vehiculo/editar")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Vehiculo editado",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = CrearEditarVehiculoResponse.class))),
            @ApiResponse(responseCode = "400", description = "Bad Request",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = ErrorResponse.class)))}
    )
    public ResponseEntity<GenericResponse<CrearEditarVehiculoResponse>> editarVehiculo(@RequestBody EditarVehiculoRequest input) {
        GenericResponse<CrearEditarVehiculoResponse> respuestaServicio = vehiculoService.modificarVehiculo(input);

        if (respuestaServicio.getError() != null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(respuestaServicio);
        }

        return ResponseEntity.ok(respuestaServicio);
    }

    //Toggle Vehiculo (Activar o Desactivar un vehiculo)
    @Operation(summary = "Activar/desactivar vehiculo", description = "Endpoint para activar/desactivar un vehiculo")
    @PostMapping("/vehiculo/toggle")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "vehiculo activado/desactivado",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = CrearEditarVehiculoResponse.class))),
            @ApiResponse(responseCode = "400", description = "Bad Request",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = ErrorResponse.class)))}
    )
    public ResponseEntity<?> toggleVehiculo(@RequestBody Long id) {
        GenericResponse<CrearEditarVehiculoResponse> respuestaServicio = vehiculoService.toggleVehiculo(id);
        if (respuestaServicio.getError() != null) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(respuestaServicio);
        }
        return ResponseEntity.ok(respuestaServicio);
    }

    //TODO:Listar todos los vehiculos de un usuario (Las tres opciones)
    @Operation(summary = "listar todos los vehiculos de un usuario", description = "Endpoint para listar todos vehiculos" +
            " de un usuario")
    @GetMapping("/vehiculo/list")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Vehiculos listados",
                    content = @Content(mediaType = "application/json",
                            array = @ArraySchema(schema = @Schema(implementation = CrearEditarVehiculoResponse.class)))),
            @ApiResponse(responseCode = "400", description = "Bad Request  - Parámetro inválido o falta de vehículos",
                    content = @Content(mediaType = "application/json",
                            schema = @Schema(implementation = ErrorResponse.class)))
    }
    )
    //Metodo para obtener un usuario por su id
    public ResponseEntity<GenericResponse<UsuarioResponse>> getUsuario(Long id) {
        // Llamar al servicio para obtener el usuario
        GenericResponse<UsuarioResponse> usuarioResponse = userService.getUsuario(id);

        // Si no se encontro el usuario, devolver un error con el estado NOT_FOUND
        if (!usuarioResponse.isSuccess()) {
            // Crear un nuevo GenericResponse para envolver el ErrorResponse
            GenericResponse<UsuarioResponse> errorResponseWrapper = new GenericResponse<>();
            errorResponseWrapper.setError(usuarioResponse.getError());

            // Devolver el error con el codigo de estado HTTP NOT_FOUND
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(errorResponseWrapper);
        }

        // Si el usuario existe, devolver los datos en un GenericResponse exitoso
        return ResponseEntity.status(HttpStatus.OK).body(usuarioResponse);
    }

    /*Version anterior de listAll
    public ResponseEntity<GenericResponse<List<CrearEditarVehiculoResponse>>> listAll(
            @RequestParam(value = "usuarioId") Long usuarioId,
            @RequestParam(value = "activo", required = false) Optional<Boolean> activo) {

        GenericResponse<List<CrearEditarVehiculoResponse>> respuestaServicio = vehiculoService.listarVehiculos(usuarioId, activo);

        if (respuestaServicio.getError() != null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(respuestaServicio);
        }

        return ResponseEntity.ok(respuestaServicio);
    }*/

    // Endpoint para obtener un vehículo por su ID *F*
    @Operation(summary = "Obtener vehículo por ID", description = "Endpoint para obtener un vehículo por su ID único")
    @GetMapping("/{id}")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Vehículo encontrado",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = CrearEditarVehiculoResponse.class))),
            @ApiResponse(responseCode = "404", description = "Vehículo no encontrado",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = ErrorResponse.class)))
    })
    public ResponseEntity<GenericResponse<CrearEditarVehiculoResponse>> obtenerVehiculoPorId(@PathVariable Long id) {
        GenericResponse<CrearEditarVehiculoResponse> response = vehiculoService.obtenerVehiculoPorId(id);
        if (response.isSuccess()) {
            return ResponseEntity.ok(response);
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        }
    }


    // Endpoint para obtener un vehículo por su matrícula *F
    @Operation(summary = "Obtener vehículo por matrícula", description = "Endpoint para obtener un vehículo por su matrícula única")
    @GetMapping("/matricula/{matricula}")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Vehículo encontrado",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = CrearEditarVehiculoResponse.class))),
            @ApiResponse(responseCode = "404", description = "Vehículo no encontrado",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = ErrorResponse.class)))
    })
    public ResponseEntity<GenericResponse<CrearEditarVehiculoResponse>> obtenerVehiculoPorMatricula(@PathVariable String matricula) {
        GenericResponse<CrearEditarVehiculoResponse> response = vehiculoService.obtenerVehiculoPorMatricula(matricula);
        if (response.isSuccess()) {
            return ResponseEntity.ok(response);
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        }
    }


    // Endpoint para eliminar un vehículo por ID *F
    // esto lo elimina de la base de datos y no deberia poderlo hacer un usuario
    //un usuario deberia poder activar/desactivar el vehiculo, pero no borrarlo de la bbdd
    @Operation(summary = "Eliminación de vehículo", description = "Endpoint para eliminar un vehículo de forma definitiva por su ID")
    @DeleteMapping("/vehiculo/{id}")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Vehículo eliminado con éxito",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = GenericResponse.class))),
            @ApiResponse(responseCode = "404", description = "Vehículo no encontrado",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = ErrorResponse.class))),
            @ApiResponse(responseCode = "403", description = "No autorizado para eliminar el vehículo",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = ErrorResponse.class)))
    })
    public ResponseEntity<GenericResponse<String>> borrarVehiculo(@PathVariable Long id) {
        // Llamamos al servicio para eliminar el vehículo
        GenericResponse<String> response = vehiculoService.eliminarVehiculo(id);

        // Si el vehículo no existe, respondemos con un error 404
        if (response.getError() != null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        }

        // Si el vehículo fue eliminado exitosamente, respondemos con un 200
        return ResponseEntity.status(HttpStatus.OK).body(response);
    }
}
