package com.gestorhorarios.security;

import com.gestorhorarios.model.User;
import com.gestorhorarios.repository.UserRepository;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class CustomUserDetailsService implements UserDetailsService {

    private final UserRepository userRepository;

    public CustomUserDetailsService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Override
    @Transactional
    public UserDetails loadUserByUsername(String usernameOrEmail) throws UsernameNotFoundException {
        try {
            System.out.println("Buscando usuario por username o email: " + usernameOrEmail);
            
            // Buscar usuario por nombre de usuario o email
            User user = userRepository.findByUsernameOrEmail(usernameOrEmail, usernameOrEmail)
                    .orElseThrow(() -> {
                        String errorMsg = "Usuario no encontrado con el nombre de usuario o email: " + usernameOrEmail;
                        System.err.println("ERROR: " + errorMsg);
                        return new UsernameNotFoundException(errorMsg);
                    });
            
            System.out.println("Usuario encontrado: " + user.getUsername());
            System.out.println("Contraseña almacenada: " + user.getPassword());
            
            return UserPrincipal.create(user);
            
        } catch (UsernameNotFoundException e) {
            throw e; // Relanzar excepciones específicas
        } catch (Exception e) {
            System.err.println("Error inesperado cargando usuario: " + e.getMessage());
            e.printStackTrace();
            throw new UsernameNotFoundException("Error al cargar el usuario", e);
        }
    }

    @Transactional(readOnly = true)
    public UserDetails loadUserById(Long id) {
        User user = userRepository.findById(id)
            .orElseThrow(() -> new UsernameNotFoundException("Usuario no encontrado con el id: " + id));
            
        return UserPrincipal.create(user);
    }
}
