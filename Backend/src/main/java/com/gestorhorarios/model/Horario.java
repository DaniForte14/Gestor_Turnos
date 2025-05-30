package com.gestorhorarios.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalTime;

@Data
@Entity
@Table(name = "horarios")
public class Horario {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @NotNull
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "usuario_id", nullable = false)
    private User usuario;
    
    @NotNull
    @Column(name = "fecha")
    private LocalDate fecha;
    
    @Column(name = "hora_inicio")
    private LocalTime horaInicio;
    
    @Column(name = "hora_fin")
    private LocalTime horaFin;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_turno")
    private TipoTurno tipoTurno;
    
    @Column(columnDefinition = "boolean default false")
    private boolean disponible = false;
    
    @Column(columnDefinition = "boolean default false")
    private boolean intercambiado = false;
    
    @Column(length = 500)
    private String notas;
    
    public enum TipoTurno {
        MANANA, // Mañana sin Ñ para evitar problemas con MySQL
        TARDE,
        NOCHE,
        COMPLETO,
        OTRO
    }
}
