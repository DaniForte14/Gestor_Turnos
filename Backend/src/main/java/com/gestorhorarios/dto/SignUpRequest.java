package com.gestorhorarios.dto;

import com.gestorhorarios.model.Role;
import jakarta.validation.constraints.*;
import lombok.Data;

import java.util.HashSet;
import java.util.Set;

@Data
public class SignUpRequest {
    @NotBlank
    @Size(min = 3, max = 20)
    private String username;

    @NotBlank
    @Size(max = 50)
    @Email
    private String email;

    @NotBlank
    @Size(min = 6, max = 40)
    private String password;

    @NotBlank
    private String nombre;

    @NotBlank
    private String apellidos;

    @NotBlank
    private String centroTrabajo;

    @NotBlank
    private String localidad;

    @NotBlank
    private String telefono;

    @NotNull
    private Set<String> roleNames;
    
    // Método auxiliar para convertir de String a Role
    public Set<Role> getRoles() {
        Set<Role> convertedRoles = new HashSet<>();
        
        if (roleNames == null || roleNames.isEmpty()) {
            // Si no hay roles, asignar ROLE_USER por defecto
            convertedRoles.add(Role.ROLE_USER);
            return convertedRoles;
        }
        
        for (String roleName : roleNames) {
            try {
                // Asegurarse de que el nombre del rol esté en mayúsculas
                String normalizedRoleName = roleName.trim().toUpperCase();
                
                // Si el rol no empieza con ROLE_, añadirlo
                if (!normalizedRoleName.startsWith("ROLE_")) {
                    normalizedRoleName = "ROLE_" + normalizedRoleName;
                }
                
                // Convertir a enum
                convertedRoles.add(Role.valueOf(normalizedRoleName));
                System.out.println("Rol asignado correctamente: " + normalizedRoleName);
            } catch (IllegalArgumentException e) {
                System.err.println("Rol inválido: " + roleName + ". Error: " + e.getMessage());
            }
        }
        
        // Si después de procesar todos los roles no hay ninguno válido, asignar ROLE_USER
        if (convertedRoles.isEmpty()) {
            System.out.println("No se encontraron roles válidos. Asignando ROLE_USER por defecto");
            convertedRoles.add(Role.ROLE_USER);
        }
        
        return convertedRoles;
    }
}
