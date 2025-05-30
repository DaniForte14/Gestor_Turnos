package com.gestorhorarios.dto;

import lombok.Getter;
import lombok.Setter;

/**
 * DTO que representa el perfil de un usuario.
 * Contiene información básica del usuario para su visualización y edición.
 */
@Getter
@Setter
public class UserProfile {
    private Long id;
    private String username;
    private String email;
    private String nombre;
    private String apellidos;
    private String centroTrabajo;
    private String localidad;

    /**
     * Constructor sin argumentos para la deserialización JSON.
     */
    public UserProfile() {}

    /**
     * Constructor con todos los campos.
     * 
     * @param id ID del usuario
     * @param username Nombre de usuario
     * @param email Correo electrónico
     * @param nombre Nombre real del usuario
     * @param apellidos Apellidos del usuario
     * @param centroTrabajo Centro de trabajo del usuario
     * @param localidad Localidad del usuario
     */
    public UserProfile(Long id, String username, String email, String nombre, 
                      String apellidos, String centroTrabajo, String localidad) {
        this.id = id;
        this.username = username;
        this.email = email;
        this.nombre = nombre;
        this.apellidos = apellidos;
        this.centroTrabajo = centroTrabajo;
        this.localidad = localidad;
    }
}
