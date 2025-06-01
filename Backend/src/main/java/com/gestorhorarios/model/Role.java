package com.gestorhorarios.model;

/**
 * Enumeración de roles de usuario en el sistema.
 * Los valores deben coincidir con los definidos en la base de datos.
 */
public enum Role {
    ROLE_ADMIN,       // Administrador del sistema con acceso completo
    ROLE_MEDICO,      // Personal médico
    ROLE_ENFERMERO,   // Personal de enfermería
    ROLE_TCAE,        // Técnico en Cuidados Auxiliares de Enfermería
    ROLE_AUXILIAR,    // Auxiliar de enfermería (alias para compatibilidad)
    ROLE_USER;        // Usuario básico (por defecto)

    /**
     * Convierte un String a un valor del enum Role.
     * @param role String que representa el rol
     * @return El valor del enum correspondiente o null si no se encuentra
     */
    public static Role fromString(String role) {
        if (role != null) {
            for (Role r : Role.values()) {
                if (role.equalsIgnoreCase(r.name())) {
                    return r;
                }
            }
        }
        return ROLE_USER; // Valor por defecto
    }
}
