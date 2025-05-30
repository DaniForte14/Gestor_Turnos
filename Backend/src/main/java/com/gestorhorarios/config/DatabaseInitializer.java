package com.gestorhorarios.config;

import com.gestorhorarios.model.*;
import com.gestorhorarios.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Random;
import java.util.Set;

@Configuration
public class DatabaseInitializer {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private HorarioRepository horarioRepository;

    @Autowired
    private VehiculoRepository vehiculoRepository;

    @Autowired
    private SolicitudCambioRepository solicitudCambioRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    private final Random random = new Random();

    @Bean
    @Transactional
    public CommandLineRunner initDatabase() {
        return args -> {
            // Solo inicializar si la base de datos está vacía
            if (userRepository.count() == 0) {
                System.out.println("Inicializando la base de datos con datos de ejemplo...");
                
                // Crear usuarios
                User admin = createUser("admin", "Admin", "Administrador", "admin@gestor.com", "Centro Principal", "Madrid", Role.ROLE_ADMIN);
                User supervisor = createUser("supervisor", "Supervisor", "Gestor", "supervisor@gestor.com", "Centro Norte", "Barcelona", Role.ROLE_SUPERVISOR);
                User empleado1 = createUser("empleado1", "Juan", "García", "juan@gestor.com", "Centro Este", "Valencia", Role.ROLE_USER);
                User empleado2 = createUser("empleado2", "María", "López", "maria@gestor.com", "Centro Oeste", "Sevilla", Role.ROLE_USER);
                User empleado3 = createUser("empleado3", "Carlos", "Martínez", "carlos@gestor.com", "Centro Sur", "Málaga", Role.ROLE_USER);
                
                System.out.println("Usuarios creados: " + admin.getUsername() + ", " + supervisor.getUsername() + ", " 
                    + empleado1.getUsername() + ", " + empleado2.getUsername() + ", " + empleado3.getUsername());
                
                // Crear vehículos
                createVehiculo("Renault", "Clio", "1234ABC", "Rojo", 5, empleado1);
                createVehiculo("Seat", "Ibiza", "5678DEF", "Azul", 5, empleado2);
                createVehiculo("Toyota", "Corolla", "9012GHI", "Blanco", 5, empleado3);
                createVehiculo("Ford", "Focus", "3456JKL", "Negro", 5, supervisor);
                
                // Crear horarios para el mes actual y el siguiente
                LocalDate hoy = LocalDate.now();
                LocalDate inicioDeMes = hoy.withDayOfMonth(1);
                LocalDate finDelMesSiguiente = hoy.plusMonths(1).withDayOfMonth(hoy.plusMonths(1).lengthOfMonth());
                
                // Crear horarios para cada empleado
                createHorariosEmpleado(empleado1, inicioDeMes, finDelMesSiguiente);
                createHorariosEmpleado(empleado2, inicioDeMes, finDelMesSiguiente);
                createHorariosEmpleado(empleado3, inicioDeMes, finDelMesSiguiente);
                
                // Crear algunas solicitudes de cambio
                createSolicitudCambio(empleado1, empleado2, "¿Podrías cambiarme el turno?");
                createSolicitudCambio(empleado2, empleado3, "Necesito cambiar este turno, ¿te viene bien?");
                createSolicitudCambio(empleado3, empleado1, "¿Me cambias el turno por favor?");
                
                System.out.println("Base de datos inicializada correctamente.");
            } else {
                System.out.println("La base de datos ya tiene datos. Saltando inicialización.");
            }
        };
    }
    
    private User createUser(String username, String nombre, String apellidos, String email, 
                           String centroTrabajo, String localidad, Role... roles) {
        User user = new User();
        user.setUsername(username);
        // No establecemos la contraseña directamente
        user.setNombre(nombre);
        user.setApellidos(apellidos);
        user.setEmail(email);
        user.setCentroTrabajo(centroTrabajo);
        user.setLocalidad(localidad);
        
        Set<Role> roleSet = new HashSet<>(Arrays.asList(roles));
        user.setRoles(roleSet);
        
        // Codificar la contraseña
        user.setPassword(passwordEncoder.encode("password"));
        
        return userRepository.save(user);
    }
    
    private Vehiculo createVehiculo(String marca, String modelo, String matricula, String color, 
                                  Integer plazas, User propietario) {
        Vehiculo vehiculo = new Vehiculo();
        vehiculo.setMarca(marca);
        vehiculo.setModelo(modelo);
        vehiculo.setMatricula(matricula);
        vehiculo.setColor(color);
        vehiculo.setAsientosDisponibles(plazas);
        vehiculo.setPropietario(propietario);
        vehiculo.setActivo(true);
        
        return vehiculoRepository.save(vehiculo);
    }
    
    private void createHorariosEmpleado(User empleado, LocalDate fechaInicio, LocalDate fechaFin) {
        LocalDate fecha = fechaInicio;
        while (!fecha.isAfter(fechaFin)) {
            // No crear horarios para sábados y domingos
            if (fecha.getDayOfWeek().getValue() < 6) {
                Horario horario = new Horario();
                horario.setUsuario(empleado);
                horario.setFecha(fecha);
                
                // Alternar entre turnos de mañana, tarde y noche
                int dayValue = fecha.getDayOfMonth() % 3;
                if (dayValue == 0) {
                    // Turno de mañana (8:00 - 16:00)
                    horario.setTipoTurno(Horario.TipoTurno.MANANA);
                    horario.setHoraInicio(LocalTime.of(8, 0));
                    horario.setHoraFin(LocalTime.of(16, 0));
                } else if (dayValue == 1) {
                    // Turno de tarde (16:00 - 0:00)
                    horario.setTipoTurno(Horario.TipoTurno.TARDE);
                    horario.setHoraInicio(LocalTime.of(16, 0));
                    horario.setHoraFin(LocalTime.of(0, 0));
                } else {
                    // Turno de noche (0:00 - 8:00)
                    horario.setTipoTurno(Horario.TipoTurno.NOCHE);
                    horario.setHoraInicio(LocalTime.of(0, 0));
                    horario.setHoraFin(LocalTime.of(8, 0));
                }
                
                // Aleatoriamente marcar algunos como disponibles para intercambio
                horario.setDisponible(random.nextInt(10) < 3); // 30% de probabilidad
                
                horarioRepository.save(horario);
            }
            fecha = fecha.plusDays(1);
        }
    }
    
    private void createSolicitudCambio(User solicitante, User receptor, String mensaje) {
        try {
            // Encontrar un horario futuro del solicitante
            LocalDate hoy = LocalDate.now();
            Horario horarioOrigen = horarioRepository.findByUsuarioAndFechaGreaterThanEqual(solicitante, hoy)
                    .stream()
                    .filter(h -> !h.isDisponible())
                    .findFirst()
                    .orElse(null);
                    
            // Encontrar un horario futuro del receptor
            Horario horarioDestino = horarioRepository.findByUsuarioAndFechaGreaterThanEqual(receptor, hoy)
                    .stream()
                    .filter(h -> !h.isDisponible())
                    .findFirst()
                    .orElse(null);
                    
            if (horarioOrigen != null && horarioDestino != null) {
                SolicitudCambio solicitud = new SolicitudCambio();
                solicitud.setSolicitante(solicitante);
                solicitud.setReceptor(receptor);
                solicitud.setHorarioOrigen(horarioOrigen);
                solicitud.setHorarioDestino(horarioDestino);
                solicitud.setMensaje(mensaje);
                solicitud.setEstado(SolicitudCambio.EstadoSolicitud.PENDIENTE);
                solicitud.setFechaCreacion(LocalDateTime.now());
                
                solicitudCambioRepository.save(solicitud);
                System.out.println("Solicitud de cambio creada entre " + solicitante.getUsername() + " y " + receptor.getUsername());
            } else {
                System.out.println("No se pudo crear la solicitud de cambio: horarios no encontrados");
            }
        } catch (Exception e) {
            System.err.println("Error al crear solicitud de cambio: " + e.getMessage());
        }
    }
}
