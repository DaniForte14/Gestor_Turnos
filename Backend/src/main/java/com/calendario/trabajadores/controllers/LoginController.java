package com.calendario.trabajadores.controllers;

import com.calendario.trabajadores.model.dto.usuario.UsuarioResponse;
import com.calendario.trabajadores.model.dto.usuario.UsuarioVehiculosResponse;
import com.calendario.trabajadores.model.errorresponse.GenericResponse;
import com.calendario.trabajadores.services.user.UserService;
import com.calendario.trabajadores.model.errorresponse.ErrorResponse;
import com.calendario.trabajadores.model.login.LoginRequest;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
//ojo: al escoger el model, el de springframework.
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.Optional;

@RestController
@CrossOrigin //Permite peticiones desde cualquier origen
@Tag(name = "Login", description = "Endpoints para el login de los usuarios")
public class LoginController {
    @Autowired
    private UserService userService;

    //Endpoints
    //Login de usuario
    @Operation(summary = "Login de usuario", description = "Endpoint para el login de usuario")
    @PostMapping("/login")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Usuario logueado",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = UsuarioVehiculosResponse.class))),
            @ApiResponse(responseCode = "401", description = "Credenciales inválidas",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = ErrorResponse.class)))
    }
    )
    //RequestParam especifica que son parámetros de la request
    public ResponseEntity<GenericResponse<UsuarioResponse>> login(@RequestBody LoginRequest loginModel) {
        // Llamamos al servicio de login
        GenericResponse<UsuarioResponse> usuarioResponse = userService.login(loginModel.username, loginModel.password);

        // Si el usuario no fue encontrado o las credenciales no son correctas, el GenericResponse tendrá un error
        if (usuarioResponse.getError() != null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(usuarioResponse);
        }

        // Si el login es exitoso, devolvemos la respuesta con el UsuarioVehiculosResponse en GenericResponse
        return ResponseEntity.ok(usuarioResponse);
    }

    // Logout de usuario
    @Operation(summary = "Logout de usuario", description = "Endpoint para el logout de usuario")
    @PostMapping("/logout")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Sesión cerrada con éxito",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = UsuarioResponse.class))),
            @ApiResponse(responseCode = "401", description = "Credenciales inválidas",
                    content = @Content(mediaType = "application/json", schema = @Schema(implementation = ErrorResponse.class)))
    })
    public ResponseEntity<GenericResponse<UsuarioResponse>> logout(@RequestBody LoginRequest loginModel) {
        // Llamamos al servicio de logout
        GenericResponse<UsuarioResponse> logoutResponse = userService.logout(loginModel.username, loginModel.password);

        // Si el usuario no fue encontrado o las credenciales no son correctas, el GenericResponse tendrá un error
        if (logoutResponse.getError() != null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(logoutResponse);
        }

        // Si el logout es exitoso, devolvemos la respuesta con el UsuarioResponse
        return ResponseEntity.ok(logoutResponse);
    }

}
