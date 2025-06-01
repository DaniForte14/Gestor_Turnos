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
import java.util.Random;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Configuration
public class DatabaseInitializer {
    
    private static final Logger logger = LoggerFactory.getLogger(DatabaseInitializer.class);

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private HorarioRepository horarioRepository;

    @Autowired
    private VehicleRepository vehicleRepository;

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
                // Using ROLE_ENFERMERO as a supervisor role since ROLE_SUPERVISOR doesn't exist
                User enfermero = createUser("enfermero1", "Ana", "Martínez", "ana@gestor.com", "Centro Norte", "Barcelona", Role.ROLE_ENFERMERO);
                User medico1 = createUser("medico1", "Juan", "García", "juan@gestor.com", "Centro Este", "Valencia", Role.ROLE_MEDICO);
                User enfermero2 = createUser("enfermero2", "María", "López", "maria@gestor.com", "Centro Oeste", "Sevilla", Role.ROLE_ENFERMERO);
                User auxiliar = createUser("auxiliar1", "Carlos", "Martínez", "carlos@gestor.com", "Centro Sur", "Málaga", Role.ROLE_AUXILIAR);
                
                System.out.println("Usuarios creados: " + admin.getUsername() + ", " + enfermero.getUsername() + ", " 
                    + medico1.getUsername() + ", " + enfermero2.getUsername() + ", " + auxiliar.getUsername());
                
                // Crear vehículos
                Vehicle vehicle1 = createVehicle("Renault", "Clio", "1234ABC", 5, medico1);
                Vehicle vehicle2 = createVehicle("Seat", "Ibiza", "5678DEF", 5, enfermero);
                Vehicle vehicle3 = createVehicle("Toyota", "Corolla", "9012GHI", 5, enfermero2);
                Vehicle vehicle4 = createVehicle("Ford", "Focus", "3456JKL", 5, auxiliar);
                
                // Añadir pasajeros a los vehículos
                addPassenger(vehicle1, enfermero);
                addPassenger(vehicle2, medico1);
                addPassenger(vehicle3, auxiliar);
                addPassenger(vehicle4, enfermero2);
                
                // Crear horarios para el mes actual y el siguiente
                LocalDate hoy = LocalDate.now();
                LocalDate inicioDeMes = hoy.withDayOfMonth(1);
                LocalDate finDelMesSiguiente = hoy.plusMonths(1).withDayOfMonth(hoy.plusMonths(1).lengthOfMonth());
                
                // Crear horarios para cada empleado
                createHorariosEmpleado(medico1, inicioDeMes, finDelMesSiguiente);
                createHorariosEmpleado(enfermero, inicioDeMes, finDelMesSiguiente);
                createHorariosEmpleado(enfermero2, inicioDeMes, finDelMesSiguiente);
                createHorariosEmpleado(auxiliar, inicioDeMes, finDelMesSiguiente);
                
                // Crear algunas solicitudes de cambio
                createSolicitudCambio(medico1, enfermero, "¿Podrías cambiarme el turno?");
                createSolicitudCambio(enfermero, enfermero2, "Necesito cambiar este turno, ¿te viene bien?");
                createSolicitudCambio(enfermero2, auxiliar, "¿Me cambias el turno por favor?");
                
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
        
        // Set the first role (we're only using one role per user now)
        user.setRole(roles.length > 0 ? roles[0] : Role.ROLE_USER);
        
        // Set default password
        user.setPassword(passwordEncoder.encode("password"));
        
        // Set timestamps
        user.setCreatedAt(LocalDateTime.now());
        user.setUpdatedAt(LocalDateTime.now());
        
        return userRepository.save(user);
    }
    
    private Vehicle createVehicle(String brand, String model, String licensePlate, 
                               Integer seats, User owner) {
        Vehicle vehicle = new Vehicle();
        vehicle.setBrand(brand);
        vehicle.setModel(model);
        vehicle.setLicensePlate(licensePlate);
        vehicle.setAvailableSeats(seats);
        vehicle.setOwner(owner);
        vehicle.setActive(true);
        vehicle.setTotalSeats(seats);
        vehicle.setObservations("Vehicle created by database initializer");
        
        return vehicleRepository.save(vehicle);
    }
    
    private void addPassenger(Vehicle vehicle, User user) {
        // Use the helper method to add the passenger
        boolean added = vehicle.añadirPasajero(user);
        
        if (added) {
            // Save both entities to ensure the relationship is persisted
            vehicleRepository.save(vehicle);
            userRepository.save(user);
            
            logger.info("Added user {} as passenger to vehicle {}", user.getId(), vehicle.getId());
        } else {
            logger.warn("Failed to add user {} as passenger to vehicle {}", user.getId(), vehicle.getId());
        }
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
