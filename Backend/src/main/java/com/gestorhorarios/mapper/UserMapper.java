package com.gestorhorarios.mapper;

import com.gestorhorarios.dto.UserProfile;
import com.gestorhorarios.model.User;
import org.springframework.stereotype.Component;

/**
 * Mapper para convertir entre entidades User y DTOs de perfil de usuario.
 */
@Component
public class UserMapper {
    
    /**
     * Convierte una entidad User a un DTO UserProfile.
     * 
     * @param user La entidad User a convertir
     * @return UserProfile con los datos del usuario
     */
    public UserProfile toUserProfile(User user) {
        if (user == null) {
            return null;
        }
        
        return new UserProfile(
            user.getId(),
            user.getUsername(),
            user.getEmail(),
            user.getNombre(),
            user.getApellidos(),
            user.getCentroTrabajo(),
            user.getLocalidad()
        );
    }
    
    /**
     * Actualiza una entidad User con los datos de un UserProfile.
     * 
     * @param profile El DTO con los datos actualizados
     * @param user La entidad User a actualizar
     */
    public void updateUserFromProfile(UserProfile profile, User user) {
        if (profile == null || user == null) {
            return;
        }
        
        // Actualizar solo los campos permitidos
        if (profile.getNombre() != null) {
            user.setNombre(profile.getNombre());
        }
        if (profile.getApellidos() != null) {
            user.setApellidos(profile.getApellidos());
        }
        if (profile.getEmail() != null) {
            user.setEmail(profile.getEmail());
        }
        if (profile.getCentroTrabajo() != null) {
            user.setCentroTrabajo(profile.getCentroTrabajo());
        }
        if (profile.getLocalidad() != null) {
            user.setLocalidad(profile.getLocalidad());
        }
    }
}
