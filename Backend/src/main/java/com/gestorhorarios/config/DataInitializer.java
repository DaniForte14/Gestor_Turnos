package com.gestorhorarios.config;

import com.gestorhorarios.model.Role;
import com.gestorhorarios.model.User;
import com.gestorhorarios.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.Collections;
import java.util.HashSet;

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
            admin.setRoles(new HashSet<>(Collections.singletonList(Role.ROLE_MEDICO)));
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
            medico.setRoles(new HashSet<>(Collections.singletonList(Role.ROLE_MEDICO)));
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
            enfermero.setRoles(new HashSet<>(Collections.singletonList(Role.ROLE_ENFERMERO)));
            userRepository.save(enfermero);

            // TCAE de prueba
            User tcae = new User();
            tcae.setUsername("tcae1");
            tcae.setPassword(passwordEncoder.encode("tcae123"));
            tcae.setNombre("Laura");
            tcae.setApellidos("Sánchez Pérez");
            tcae.setEmail("laura.sanchez@hospital.com");
            tcae.setCentroTrabajo("Hospital Central");
            tcae.setLocalidad("Ciudad Principal");
            tcae.setRoles(new HashSet<>(Collections.singletonList(Role.ROLE_TCAE)));
            userRepository.save(tcae);
        }
    }
}
