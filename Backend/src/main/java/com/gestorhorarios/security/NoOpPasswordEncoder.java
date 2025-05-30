package com.gestorhorarios.security;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

/**
 * Implementación simple de PasswordEncoder que no realiza ninguna encriptación.
 * ADVERTENCIA: Este encoder NO ES SEGURO para entornos de producción.
 * Sólo debe usarse para desarrollo y pruebas.
 */
@Component("noOpPasswordEncoder")
public class NoOpPasswordEncoder implements PasswordEncoder {

    @Override
    public String encode(CharSequence rawPassword) {
        return rawPassword.toString();
    }

    @Override
    public boolean matches(CharSequence rawPassword, String encodedPassword) {
        return rawPassword.toString().equals(encodedPassword);
    }
}
