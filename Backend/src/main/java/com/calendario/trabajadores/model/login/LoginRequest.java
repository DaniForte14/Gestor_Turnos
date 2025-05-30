package com.calendario.trabajadores.model.login;

import lombok.Getter;
import lombok.Setter;

/**
 * Clase que representa la respuesta de la API al intentar iniciar sesión.
 */
@Getter
@Setter
public class LoginRequest {
    public String username;
    public String password; //todo: encriptar CONTRASEÑA

}
