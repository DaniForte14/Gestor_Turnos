package com.gestorhorarios.service;

import com.gestorhorarios.exception.ResourceNotFoundException;
import com.gestorhorarios.model.Horario;
import com.gestorhorarios.model.Role;
import com.gestorhorarios.model.User;
import com.gestorhorarios.repository.HorarioRepository;
import com.gestorhorarios.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.time.LocalTime;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class HorarioServiceTest {

    @Mock
    private HorarioRepository horarioRepository;

    @Mock
    private UserRepository userRepository;
    
    @Mock
    private UserService userService;

    @InjectMocks
    private HorarioService horarioService;

    private User testUser;
    private Horario testHorario;

    @BeforeEach
    void setUp() {
        // Configurar usuario de prueba
        testUser = new User();
        testUser.setId(1L);
        testUser.setUsername("testuser");
        testUser.setRole(Role.ROLE_MEDICO);

        // Configurar horario de prueba
        testHorario = new Horario();
        testHorario.setId(1L);
        testHorario.setFecha(LocalDate.now().plusDays(1));
        testHorario.setHoraInicio(LocalTime.of(9, 0));
        testHorario.setHoraFin(LocalTime.of(17, 0));
        testHorario.setTipoTurno(Horario.TipoTurno.MANANA);
        testHorario.setDisponible(true);
        testHorario.setUsuario(testUser);
        testHorario.setRol(Role.ROLE_MEDICO);
    }

    @Test
    void crearHorario_WithValidData_ShouldSaveHorario() {
        // Configurar el mock del repositorio
        when(horarioRepository.save(any(Horario.class))).thenReturn(testHorario);
        when(userService.findUserById(anyLong())).thenReturn(testUser);

        // Crear un nuevo horario para guardar
        Horario nuevoHorario = new Horario();
        nuevoHorario.setFecha(testHorario.getFecha());
        nuevoHorario.setHoraInicio(testHorario.getHoraInicio());
        nuevoHorario.setHoraFin(testHorario.getHoraFin());
        nuevoHorario.setTipoTurno(testHorario.getTipoTurno());
        nuevoHorario.setUsuario(testUser);

        // Llamar al método a probar
        Horario resultado = horarioService.crearHorario(nuevoHorario, "ROLE_MEDICO");

        // Verificar el resultado
        assertNotNull(resultado);
        assertEquals(testHorario.getId(), resultado.getId());
        assertEquals(testHorario.getFecha(), resultado.getFecha());
        assertEquals(testHorario.getHoraInicio(), resultado.getHoraInicio());
        assertEquals(testHorario.getHoraFin(), resultado.getHoraFin());
        assertEquals(testHorario.getTipoTurno(), resultado.getTipoTurno());
        assertTrue(resultado.isDisponible());
        assertNotNull(resultado.getRol());
        assertEquals(Role.ROLE_MEDICO, resultado.getRol());

        // Verificar que se llamó al método save del repositorio
        verify(horarioRepository, times(1)).save(any(Horario.class));
    }

    @Test
    void crearHorario_WithEndTimeBeforeStartTime_ShouldThrowException() {
        // Configurar un horario con hora de fin antes que la de inicio
        Horario horarioInvalido = new Horario();
        horarioInvalido.setFecha(LocalDate.now().plusDays(1));
        horarioInvalido.setHoraInicio(LocalTime.of(17, 0));
        horarioInvalido.setHoraFin(LocalTime.of(9, 0));
        horarioInvalido.setUsuario(testUser);

        // Verificar que se lanza la excepción esperada
        IllegalArgumentException exception = assertThrows(
            IllegalArgumentException.class,
            () -> horarioService.crearHorario(horarioInvalido, "ROLE_MEDICO")
        );

        assertEquals("La hora de fin no puede ser anterior a la hora de inicio", exception.getMessage());
    }

    @Test
    void crearHorario_WithNonExistentUser_ShouldThrowException() {
        // Configurar el mock para simular que el usuario no existe
        when(userService.findUserById(anyLong())).thenThrow(new ResourceNotFoundException("Usuario no encontrado"));

        // Crear un horario con un usuario que no existe
        Horario horario = new Horario();
        horario.setFecha(LocalDate.now().plusDays(1));
        horario.setHoraInicio(LocalTime.of(9, 0));
        horario.setHoraFin(LocalTime.of(17, 0));
        
        User user = new User();
        user.setId(999L); // ID de usuario que no existe
        horario.setUsuario(user);

        // Verificar que se lanza la excepción esperada
        assertThrows(ResourceNotFoundException.class, 
            () -> horarioService.crearHorario(horario, "ROLE_MEDICO"));
    }

    @Test
    void crearHorario_WithSpecificRoles_ShouldSaveWithThoseRoles() {
        // Configurar el mock del repositorio
        when(horarioRepository.save(any(Horario.class))).thenAnswer(invocation -> {
            Horario saved = invocation.getArgument(0);
            saved.setId(1L);
            return saved;
        });
        when(userService.findUserById(anyLong())).thenReturn(testUser);

        // Crear un horario con un rol específico
        Horario horarioConRol = new Horario();
        horarioConRol.setFecha(testHorario.getFecha());
        horarioConRol.setHoraInicio(testHorario.getHoraInicio());
        horarioConRol.setHoraFin(testHorario.getHoraFin());
        horarioConRol.setTipoTurno(testHorario.getTipoTurno());
        horarioConRol.setUsuario(testUser);
        horarioConRol.setRol(Role.ROLE_MEDICO);

        // Llamar al método a probar
        Horario resultado = horarioService.crearHorario(horarioConRol, "ROLE_MEDICO");

        // Verificar que se guardó con el rol específico
        assertNotNull(resultado);
        assertNotNull(resultado.getId());
        assertEquals(Role.ROLE_MEDICO, resultado.getRol());
    }
}

