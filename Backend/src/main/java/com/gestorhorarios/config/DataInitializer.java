package com.gestorhorarios.config;

import com.gestorhorarios.model.Role;
import com.gestorhorarios.model.User;
import com.gestorhorarios.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

@Component
public class DataInitializer implements CommandLineRunner {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        // Crear usuarios de prueba si no existen
        if (userRepository.count() == 0) {
            // Admin user
            User admin = new User();
            admin.setUsername("admin");
            admin.setPassword(passwordEncoder.encode("admin123"));
            admin.setNombre("Administrador");
            admin.setApellidos("Sistema");
            admin.setEmail("admin@hospital.com");
            admin.setCentroTrabajo("Hospital Central");
            admin.setLocalidad("Ciudad Principal");
            admin.setTelefono("123456789");
            admin.setRole(Role.ROLE_ADMIN);
            admin.setCreatedAt(LocalDateTime.now());
            admin.setUpdatedAt(LocalDateTime.now());
            userRepository.save(admin);

            // Médico de prueba
            User medico = new User();
            medico.setUsername("medico1");
            medico.setPassword(passwordEncoder.encode("medico123"));
            medico.setNombre("Carlos");
            medico.setApellidos("García López");
            medico.setEmail("carlos.garcia@hospital.com");
            medico.setCentroTrabajo("Hospital Central");
            medico.setLocalidad("Ciudad Principal");
            medico.setTelefono("987654321");
            medico.setRole(Role.ROLE_MEDICO);
            medico.setCreatedAt(LocalDateTime.now());
            medico.setUpdatedAt(LocalDateTime.now());
            userRepository.save(medico);

            // Enfermero de prueba
            User enfermero = new User();
            enfermero.setUsername("enfermero1");
            enfermero.setPassword(passwordEncoder.encode("enfermero123"));
            enfermero.setNombre("Ana");
            enfermero.setApellidos("Martínez Ruiz");
            enfermero.setEmail("ana.martinez@hospital.com");
            enfermero.setCentroTrabajo("Hospital Central");
            enfermero.setLocalidad("Ciudad Principal");
            enfermero.setTelefono("654321987");
            enfermero.setRole(Role.ROLE_ENFERMERO);
            enfermero.setCreatedAt(LocalDateTime.now());
            enfermero.setUpdatedAt(LocalDateTime.now());
            userRepository.save(enfermero);

            // Auxiliar de enfermería de prueba
            User auxiliar = new User();
            auxiliar.setUsername("auxiliar1");
            auxiliar.setPassword(passwordEncoder.encode("auxiliar123"));
            auxiliar.setNombre("Laura");
            auxiliar.setApellidos("Sánchez Pérez");
            auxiliar.setEmail("laura.sanchez@hospital.com");
            auxiliar.setCentroTrabajo("Hospital Central");
            auxiliar.setLocalidad("Ciudad Principal");
            auxiliar.setTelefono("321654987");
            auxiliar.setRole(Role.ROLE_AUXILIAR);
            auxiliar.setCreatedAt(LocalDateTime.now());
            auxiliar.setUpdatedAt(LocalDateTime.now());
            userRepository.save(auxiliar);
        }
    }
}
