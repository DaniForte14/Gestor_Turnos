package com.gestorhorarios.security;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.gestorhorarios.model.Role;
import com.gestorhorarios.model.User;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.Collections;
import java.util.Objects;
import java.util.Set;

/**
 * Clase que implementa UserDetails para la autenticación de Spring Security.
 * Contiene la información del usuario autenticado y sus permisos.
 */
public class UserPrincipal implements UserDetails {
    private final Long id;
    private final String username;
    private final String email;
    private final String nombre;
    private final String apellidos;
    private final Set<Role> roles;

    @JsonIgnore
    private final String password;

    private final Collection<? extends GrantedAuthority> authorities;

    public UserPrincipal(Long id, String username, String email, String password,
                        String nombre, String apellidos, Set<Role> roles,
                        Collection<? extends GrantedAuthority> authorities) {
        this.id = id;
        this.username = username;
        this.email = email;
        this.password = password;
        this.nombre = nombre;
        this.apellidos = apellidos;
        this.roles = roles != null ? roles : Collections.emptySet();
        this.authorities = authorities;
    }

    /**
     * Crea una instancia de UserPrincipal a partir de un objeto User.
     * @param user El usuario del que se obtendrán los datos
     * @return Una nueva instancia de UserPrincipal
     */
    public static UserPrincipal create(User user) {
        if (user == null) {
            throw new IllegalArgumentException("El usuario no puede ser nulo");
        }
        
        // Obtener los roles del usuario
        Set<Role> roles = user.getRoles() != null ? user.getRoles() : Collections.emptySet();
        
        // Crear las autoridades a partir de los roles
        Collection<GrantedAuthority> authorities = roles.stream()
            .map(role -> new SimpleGrantedAuthority(role.name()))
            .collect(java.util.stream.Collectors.toList());
            
        return new UserPrincipal(
            user.getId(),
            user.getUsername(),
            user.getEmail(),
            user.getPassword(),
            user.getNombre(),
            user.getApellidos(),
            roles,
            authorities
        );
    }

    public Long getId() {
        return id;
    }

    public String getEmail() {
        return email;
    }
    
    public String getNombre() {
        return nombre;
    }
    
    public String getApellidos() {
        return apellidos;
    }
    
    /**
     * Obtiene los roles del usuario.
     * @return Los roles del usuario
     */
    public Set<Role> getRoles() {
        return roles;
    }
    
    /**
     * Obtiene el rol principal del usuario (para compatibilidad con código existente).
     * @return El primer rol del conjunto o ROLE_USER si no hay roles
     */
    @Deprecated
    public Role getRole() {
        return roles.isEmpty() ? Role.ROLE_USER : roles.iterator().next();
    }

    @Override
    public String getUsername() {
        return username;
    }

    @Override
    public String getPassword() {
        return password;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return true;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        UserPrincipal that = (UserPrincipal) o;
        return Objects.equals(id, that.id) &&
               Objects.equals(username, that.username) &&
               Objects.equals(email, that.email) &&
               Objects.equals(nombre, that.nombre) &&
               Objects.equals(apellidos, that.apellidos) &&
               Objects.equals(roles, that.roles) &&
               Objects.equals(password, that.password);
    }
    
    @Override
    public int hashCode() {
        return Objects.hash(id, username, email, password, nombre, apellidos, roles, authorities);
    }
}
