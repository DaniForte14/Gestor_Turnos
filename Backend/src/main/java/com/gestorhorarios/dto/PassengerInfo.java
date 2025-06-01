package com.gestorhorarios.dto;

import com.gestorhorarios.model.User;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO for passenger information in vehicle responses
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PassengerInfo {
    private Long id;
    private String username;
    private String nombreCompleto;
    private String email;
    
    /**
     * Creates a PassengerInfo from a User entity
     * @param user The User entity
     * @return A new PassengerInfo instance
     */
    public static PassengerInfo fromUser(User user) {
        if (user == null) {
            return null;
        }
        
        return PassengerInfo.builder()
                .id(user.getId())
                .username(user.getUsername())
                .nombreCompleto(user.getNombre() + " " + user.getApellidos())
                .email(user.getEmail())
                .build();
    }
}
