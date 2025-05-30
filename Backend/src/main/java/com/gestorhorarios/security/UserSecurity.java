package com.gestorhorarios.security;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

@Component("userSecurity")
public class UserSecurity {
    
    public boolean isCurrentUserOrAdmin(UserPrincipal currentUser, Long userId) {
        // Allow if the current user is an admin or the owner of the account
        return currentUser != null && 
               (currentUser.getAuthorities().stream()
                   .anyMatch(grantedAuthority -> grantedAuthority.getAuthority().equals("ROLE_MEDICO")) ||
                currentUser.getId().equals(userId));
    }
    
    public boolean isAdmin() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        return authentication != null && 
               authentication.getAuthorities().stream()
                   .anyMatch(grantedAuthority -> grantedAuthority.getAuthority().equals("ROLE_MEDICO"));
    }
}
