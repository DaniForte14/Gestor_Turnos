package com.calendario.trabajadores.controllers;

import com.calendario.trabajadores.model.dto.usuario.CrearUsuarioRequest;
import com.calendario.trabajadores.model.dto.usuario.UsuarioResponse;
import com.calendario.trabajadores.model.dto.usuario.EditarUsuarioRequest;
import com.calendario.trabajadores.model.dto.usuario.UsuarioVehiculosResponse;
import com.calendario.trabajadores.model.errorresponse.ErrorResponse;
import com.calendario.trabajadores.model.errorresponse.GenericResponse;
import com.calendario.trabajadores.services.user.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@Tag(name = "User", description = "Endpoints para modificación y creación de usuarios")
public class UserController {
    @Autowired
    private UserService userService;

    //Endpoints
    //Crear usuario
    @Operation(summary = "Creación de usuario", description = "Endpoint para crear un usuario")
    @PostMapping("/user/create")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Usuario creado",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = UsuarioResponse.class))),
            @ApiResponse(responseCode = "400", description = "Bad Request",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = ErrorResponse.class)))
    }
    )
    public ResponseEntity<?> create(@RequestBody CrearUsuarioRequest request) {
        // Forzamos que el usuario registrado sea un usuario normal (capa extra de seguridad)
        request.rol = "user";

        // Llamamos al servicio para crear el usuario
        var usuario = userService.crearUsuario(request);

        // Si no se pudo crear el usuario (error), devolvemos el error con el mensaje adecuado
        if (!usuario.isSuccess()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of(usuario.getError().getStatus(),
                    usuario.getError().getMessage()));
        }

        // Si el usuario se creó correctamente, devolvemos la respuesta con los datos del usuario creado
        return ResponseEntity.ok(usuario);
    }

    //Crear usuario admin
    @Operation(summary = "Creación de admin", description = "Endpoint para crear un admin")
    @PostMapping("/user/adminCreate")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Admin creado",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = UsuarioResponse.class))),
            @ApiResponse(responseCode = "400", description = "Bad Request",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = ErrorResponse.class)))
    }
    )
    //ResponseEntity<GenericResponse<UsuarioResponse>>
    public ResponseEntity<?> createAdmin(@RequestBody CrearUsuarioRequest request) {
        //Forzamos que el usuario registrado sea un usuario normal (capa extra de seguridad)
        request.rol = "admin";
        // Llamamos al servicio para crear el usuario
        GenericResponse<UsuarioResponse> usuario = userService.crearUsuario(request);
        if (!usuario.isSuccess()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of(usuario.getError().getStatus(), usuario.getError().getMessage()));
        }
        return ResponseEntity.ok(usuario.getData());
    }

    //Editar datos de un usuario
    @Operation(summary = "Editar datos de un usuario", description = "Endpoint para editar datos de un usuario")
    @PostMapping("/user/edit")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "user modificado",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = UsuarioResponse.class))),
            @ApiResponse(responseCode = "400", description = "Bad Request",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = ErrorResponse.class)))
    }
    )

    public ResponseEntity<?> editarUsuario(@RequestBody EditarUsuarioRequest request) {
        var usuario = userService.editUsuario(request);
        if (!usuario.isSuccess()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of(usuario.getError().getStatus(), usuario.getError().getMessage()));
        }
        return ResponseEntity.ok(usuario.getData());
    }

    //Dar de baja usuario (desactivar)
    @Operation(summary = "dar de baja usuario", description = "Endpoint para dar de baja usuario")
    @PostMapping("/user/deactivate")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "usuario desactivado",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = UsuarioResponse.class))),
            @ApiResponse(responseCode = "400", description = "Bad Request",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = ErrorResponse.class)))
    }
    )
    public ResponseEntity<?> bajaUsuario(@RequestParam Long id) {
        // Llamamos al servicio para realizar la baja del usuario
        var usuario = userService.softDelete(id);
        // Si la baja falla (usuario no encontrado o error), devolvemos el error
        if (!usuario.isSuccess()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of(usuario.getError()
                    .getStatus(), usuario.getError().getMessage()));
        }

        // Si la baja es exitosa, devolvemos la respuesta con los datos del usuario
        return ResponseEntity.ok(usuario.getData());
    }

    //Reactivar usuario
    @Operation(summary = "reactivar usuario", description = "Endpoint para reactivar usuario")
    @PostMapping("/user/reactivate")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "usuario reactivado",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = UsuarioResponse.class))),
            @ApiResponse(responseCode = "400", description = "Bad Request",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = ErrorResponse.class)))
    }
    )
    public ResponseEntity<?> reactivar(@RequestParam Long id) {
        var usuario = userService.reactivar(id);
        if (!usuario.isSuccess()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of(usuario.getError()
                    .getStatus(), usuario.getError().getMessage()));
        }
        return ResponseEntity.ok(usuario.getData());
    }

    //Listar información de un usuario (obtener el usuario con el id)
    @Operation(summary = "Listar información de un usuario", description = "Endpoint para listar información de un usuario")
    @GetMapping("/user/getById")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Usuario encontrado",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = UsuarioResponse.class))),
            @ApiResponse(responseCode = "400", description = "Bad Request",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = ErrorResponse.class)))
    }
    )
    public ResponseEntity<?> getUsuario(@RequestParam Long id) {
        var usuario = userService.getUsuario(id);
        if (!usuario.isSuccess()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of(usuario.getError().getStatus(), usuario.getError().getMessage()));
        }
        return ResponseEntity.ok(usuario.getData());
    }

    //Listar información de un usuario (obtener el usuario con el email)
    @Operation(summary = "Listar información de un usuario", description = "Endpoint para listar información de un usuario")
    @GetMapping("/user/getByEmail")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Usuario encontrado",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = UsuarioResponse.class))),
            @ApiResponse(responseCode = "400", description = "Bad Request",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = ErrorResponse.class)))
    }
    )
    public ResponseEntity<?> getUsuario(@RequestParam String email) {
        var usuario = userService.getUsuario(email);
        if (!usuario.isSuccess()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of(usuario.getError().getStatus(), usuario.getError().getMessage()));
        }
        return ResponseEntity.ok(usuario.getData());
    }

    //Listar usuarios
    @Operation(summary = "listar usuarios", description = "Endpoint para listar todos los usuarios")
    @GetMapping("/user/list")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "user reactivated",
                    content = @Content(mediaType = "application/json", array = @ArraySchema(schema = @Schema(implementation = UsuarioResponse.class)))),
            @ApiResponse(responseCode = "400", description = "Bad Request",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = ErrorResponse.class)))
    }
    )
    public ResponseEntity<?> listAll(@RequestParam(value = "activo") Optional<Boolean> activo) {
        var usuario = userService.listar(activo);
        if (!usuario.isSuccess()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of(usuario.getError().getStatus(), usuario.getError().getMessage()));
        }
        return ResponseEntity.ok(usuario.getData());
    }


    //Listar usuarios con vehiculos
    @Operation(summary = "Listar usuarios con vehiculos", description = "Endpoint para listar usuarios con vehiculos")
    @GetMapping("/user/vehiculos")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Lista creada",
                    content = @Content(mediaType = "application/json", array = @ArraySchema(schema = @Schema(implementation = UsuarioVehiculosResponse.class)))),
            @ApiResponse(responseCode = "400", description = "Bad Request",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = ErrorResponse.class)))
    }
    )
    public ResponseEntity<?> listarUsuariosVehiculos(@RequestParam(value = "activo") Optional<Boolean> activo) {
        return ResponseEntity.ok(userService.listarUsuariosVehiculos(activo));
    }

    //Borrado total usuario (Uso solo para admin! Para usuarios normales usar bajaUsuario (SoftDelete)
    @Operation(summary = "borrar usuario", description = "Endpoint para borrar usuario")
    @DeleteMapping("/user/delete")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "borrar usuario",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = UsuarioResponse.class))),
            @ApiResponse(responseCode = "400", description = "Bad Request",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = ErrorResponse.class)))
    }
    )
    public ResponseEntity<?> borrarUsuario(@RequestParam Long id, String email) {
        GenericResponse<UsuarioResponse> usuario = userService.borrar(id, email);
        if (!usuario.isSuccess()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of(usuario.getError().getStatus(), usuario.getError().getMessage()));
        }
        return ResponseEntity.ok(usuario.getData());
    }

    //Listar usuarios con viajes asociados   /*F*
    @Operation(summary = "Listar usuarios con viajes", description = "Endpoint para listar usuarios con viajes asociados")
    @GetMapping("/user/viajes")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Lista creada",
                    content = @Content(mediaType = "application/json", array = @ArraySchema(schema = @Schema(implementation = UsuarioResponse.class)))) , // Cambié UsuarioViajesResponse por UsuarioResponse
            @ApiResponse(responseCode = "400", description = "Bad Request",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = ErrorResponse.class)))
    })
    public ResponseEntity<?> listarUsuariosViajes(@RequestParam(value = "activo") Optional<Boolean> activo) {
        // Asumiendo que el servicio devuelve un GenericResponse<List<UsuarioResponse>> como se definió antes
        GenericResponse<List<UsuarioResponse>> response = userService.listar(activo);  // Cambié listarUsuariosViajes por listar
        return ResponseEntity.ok(response);
    }



}
