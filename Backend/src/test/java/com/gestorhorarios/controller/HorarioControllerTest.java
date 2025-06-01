package com.gestorhorarios.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.gestorhorarios.dto.HorarioRequest;
import com.gestorhorarios.exception.GlobalExceptionHandler;
import com.gestorhorarios.model.Horario;
import com.gestorhorarios.model.Role;
import com.gestorhorarios.model.User;
import com.gestorhorarios.security.CurrentUser;
import com.gestorhorarios.security.UserPrincipal;
import com.gestorhorarios.service.HorarioService;
import com.gestorhorarios.service.UserService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.springframework.core.MethodParameter;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.bind.support.WebDataBinderFactory;
import org.springframework.web.context.request.NativeWebRequest;
import org.springframework.web.method.support.HandlerMethodArgumentResolver;
import org.springframework.web.method.support.ModelAndViewContainer;
import org.springframework.lang.Nullable;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.Collections;
import java.util.List;
import java.util.Set;
import java.util.HashSet;
import java.util.stream.Collectors;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Pruebas unitarias para el controlador de horarios.
 */
class HorarioControllerTest {

    private MockMvc mockMvc;

    @Mock
    private HorarioService horarioService;

    @Mock
    private UserService userService;

    @InjectMocks
    private HorarioController horarioController;

    private final ObjectMapper objectMapper = new ObjectMapper();
    private User testUser;
    private UserPrincipal testUserPrincipal;
    private Authentication authentication;

    public HorarioControllerTest() {
        objectMapper.registerModule(new JavaTimeModule());
        objectMapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
    }

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        
        // Configurar usuario de prueba
        testUser = new User();
        testUser.setId(1L);
        testUser.setUsername("testuser");
        testUser.setEmail("test@example.com");
        testUser.setPassword("password");
        testUser.setRole(Role.ROLE_MEDICO);
        testUser.setNombre("Test");
        testUser.setApellidos("User");
        
        // Configurar UserPrincipal
        Set<Role> roles = new HashSet<>();
        roles.add(Role.ROLE_MEDICO);
        
        List<GrantedAuthority> authorities = roles.stream()
            .map(role -> new SimpleGrantedAuthority(role.name()))
            .collect(Collectors.toList());
            
        testUserPrincipal = new UserPrincipal(
            testUser.getId(),
            testUser.getUsername(),
            testUser.getEmail(),
            testUser.getPassword(),
            testUser.getNombre(),
            testUser.getApellidos(),
            roles,
            authorities
        );
        
        // Configurar autenticación
        authentication = new UsernamePasswordAuthenticationToken(
            testUserPrincipal,
            null,
            authorities
        );
        
        SecurityContextHolder.getContext().setAuthentication(authentication);
        
        // Configurar argument resolver para @CurrentUser
        HandlerMethodArgumentResolver argumentResolver = new HandlerMethodArgumentResolver() {
            @Override
            public boolean supportsParameter(MethodParameter parameter) {
                return parameter.getParameterAnnotation(CurrentUser.class) != null;
            }

            @Override
            @Nullable
            public Object resolveArgument(MethodParameter parameter, @Nullable ModelAndViewContainer mavContainer,
                                        NativeWebRequest webRequest, @Nullable WebDataBinderFactory binderFactory) throws Exception {
                return testUserPrincipal;
            }
        };
        
        mockMvc = MockMvcBuilders.standaloneSetup(horarioController)
            .setControllerAdvice(new GlobalExceptionHandler())
            .setCustomArgumentResolvers(argumentResolver)
            .build();
        
        // Configurar mocks
        when(userService.findUserById(anyLong())).thenReturn(testUser);
        when(horarioService.crearHorario(any(Horario.class), eq("ROL_INVALIDO")))
            .thenThrow(new RuntimeException("Rol no válido"));
        when(horarioService.crearHorario(any(Horario.class), anyString())).thenAnswer(invocation -> {
            Horario horario = invocation.getArgument(0);
            String rol = invocation.getArgument(1);
            if (horario.getUsuario() == null) {
                throw new RuntimeException("El usuario no puede ser nulo");
            }
            horario.setId(1L);
            if (rol != null && !rol.trim().isEmpty()) {
                try {
                    horario.setRol(Role.valueOf(rol.trim().toUpperCase()));
                } catch (IllegalArgumentException e) {
                    throw new RuntimeException("Rol no válido");
                }
            } else if (horario.getRol() == null) {
                horario.setRol(horario.getUsuario().getRole());
            }
            return horario;
        });
    }

    @Test
    @WithMockUser(username = "testuser", roles = {"MEDICO"})
    void crearHorario_WithValidData_ShouldReturnCreatedHorario() throws Exception {
        // Preparar la solicitud
        HorarioRequest request = new HorarioRequest();
        LocalDate tomorrow = LocalDate.now().plusDays(1);
        request.setFecha(tomorrow);
        request.setHoraInicio(LocalTime.of(9, 0));
        request.setHoraFin(LocalTime.of(17, 0));
        request.setTipoTurno(Horario.TipoTurno.MANANA);
        
        // Configurar el horario esperado
        Horario horario = new Horario();
        horario.setId(1L);
        horario.setFecha(tomorrow);
        horario.setHoraInicio(LocalTime.of(9, 0));
        horario.setHoraFin(LocalTime.of(17, 0));
        horario.setTipoTurno(Horario.TipoTurno.MANANA);
        horario.setDisponible(true);
        horario.setRol(Role.ROLE_MEDICO);
        horario.setUsuario(testUser);
        
        // Configurar el mock del servicio
        when(horarioService.crearHorario(any(Horario.class), anyString())).thenReturn(horario);
        
        // Ejecutar la prueba
        mockMvc.perform(post("/api/horarios")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andDo(print())
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.fecha").exists())
                .andExpect(jsonPath("$.horaInicio[0]").value(9))
                .andExpect(jsonPath("$.horaInicio[1]").value(0))
                .andExpect(jsonPath("$.horaFin[0]").value(17))
                .andExpect(jsonPath("$.horaFin[1]").value(0))
                .andExpect(jsonPath("$.tipoTurno").value("MANANA"))
                .andExpect(jsonPath("$.disponible").value(true))
                .andExpect(jsonPath("$.rol").value("ROLE_MEDICO"));
    }
    
    @Test
    @WithMockUser(username = "admin", roles = {"ADMIN"})
    void crearHorario_WithInvalidRole_ShouldReturnBadRequest() throws Exception {
        // Configurar el usuario como administrador
        testUser.setRole(Role.ROLE_ADMIN);
        when(userService.findUserById(anyLong())).thenReturn(testUser);
        
        // Preparar la solicitud con rol inválido
        HorarioRequest request = new HorarioRequest();
        request.setFecha(LocalDate.now().plusDays(1));
        request.setHoraInicio(LocalTime.of(9, 0));
        request.setHoraFin(LocalTime.of(17, 0));
        request.setTipoTurno(Horario.TipoTurno.MANANA);
        request.setRol("ROL_INVALIDO");
        
        // Ejecutar la prueba
        mockMvc.perform(post("/api/horarios")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andDo(print())
                .andExpect(status().isBadRequest());
    }
    
    @Test
    @WithMockUser(username = "testuser", roles = {"MEDICO"})
    void crearHorario_WithEndTimeBeforeStartTime_ShouldReturnBadRequest() throws Exception {
        // Preparar la solicitud con hora de fin anterior a la de inicio
        HorarioRequest request = new HorarioRequest();
        request.setFecha(LocalDate.now().plusDays(1));
        request.setHoraInicio(LocalTime.of(17, 0));
        request.setHoraFin(LocalTime.of(9, 0)); // Hora de fin anterior a la de inicio
        request.setTipoTurno(Horario.TipoTurno.MANANA);
        
        // Ejecutar la prueba
        mockMvc.perform(post("/api/horarios")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andDo(print())
                .andExpect(status().isBadRequest());
    }
    
    @Test
    @WithMockUser(username = "admin", roles = {"ADMIN"})
    void crearHorario_AdminCanSetRole_ShouldReturnCreatedHorario() throws Exception {
        // Configurar el usuario como administrador
        testUser.setRole(Role.ROLE_ADMIN);
        when(userService.findUserById(anyLong())).thenReturn(testUser);
        
        // Preparar la solicitud con rol específico
        HorarioRequest request = new HorarioRequest();
        LocalDate tomorrow = LocalDate.now().plusDays(1);
        request.setFecha(tomorrow);
        request.setHoraInicio(LocalTime.of(9, 0));
        request.setHoraFin(LocalTime.of(17, 0));
        request.setTipoTurno(Horario.TipoTurno.MANANA);
        request.setRol("ROLE_ENFERMERO");
        
        // Configurar el horario esperado
        Horario horario = new Horario();
        horario.setId(1L);
        horario.setFecha(tomorrow);
        horario.setHoraInicio(LocalTime.of(9, 0));
        horario.setHoraFin(LocalTime.of(17, 0));
        horario.setTipoTurno(Horario.TipoTurno.MANANA);
        horario.setDisponible(true);
        horario.setRol(Role.ROLE_ENFERMERO);
        horario.setUsuario(testUser);
        
        // Configurar el mock del servicio
        when(horarioService.crearHorario(any(Horario.class), eq("ROLE_ENFERMERO"))).thenReturn(horario);
        
        // Ejecutar la prueba
        mockMvc.perform(post("/api/horarios")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andDo(print())
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.rol").value("ROLE_ENFERMERO"));
    }
    
    @Test
    @WithMockUser(username = "testuser", roles = {"MEDICO"})
    void crearHorario_WithoutRole_ShouldUseUserRole() throws Exception {
        // Configurar el usuario
        testUser.setRole(Role.ROLE_MEDICO);
        when(userService.findUserById(anyLong())).thenReturn(testUser);
        
        // Preparar la solicitud sin rol
        HorarioRequest request = new HorarioRequest();
        LocalDate tomorrow = LocalDate.now().plusDays(1);
        request.setFecha(tomorrow);
        request.setHoraInicio(LocalTime.of(9, 0));
        request.setHoraFin(LocalTime.of(17, 0));
        request.setTipoTurno(Horario.TipoTurno.MANANA);
        
        // Configurar el horario esperado
        Horario horario = new Horario();
        horario.setId(1L);
        horario.setFecha(tomorrow);
        horario.setHoraInicio(LocalTime.of(9, 0));
        horario.setHoraFin(LocalTime.of(17, 0));
        horario.setTipoTurno(Horario.TipoTurno.MANANA);
        horario.setDisponible(true);
        horario.setRol(Role.ROLE_MEDICO); // Debería usar el rol del usuario
        horario.setUsuario(testUser);
        
        // Configurar el mock del servicio
        when(horarioService.crearHorario(any(Horario.class), anyString())).thenReturn(horario);
        
        // Ejecutar la prueba
        mockMvc.perform(post("/api/horarios")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
                .andDo(print())
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.rol").value("ROLE_MEDICO"));
    }
}
