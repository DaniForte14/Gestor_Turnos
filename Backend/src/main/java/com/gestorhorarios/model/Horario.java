package com.gestorhorarios.model;

import com.fasterxml.jackson.annotation.*;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "horarios")
@JsonIdentityInfo(
    generator = ObjectIdGenerators.PropertyGenerator.class,
    property = "id"
)
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class Horario {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @NotNull
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "usuario_id", nullable = false)
    @JsonIgnoreProperties({"password", "vehiculosComoPasajero"})
    private User usuario;
    
    @NotNull
    @Column(name = "fecha", nullable = false)
    private LocalDate fecha;
    
    @Column(name = "hora_inicio")
    private LocalTime horaInicio;
    
    @Column(name = "hora_fin")
    private LocalTime horaFin;
    
    @CreationTimestamp
    @Column(name = "fecha_creacion", updatable = false, nullable = false)
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    @Column(name = "fecha_actualizacion", nullable = false)
    private LocalDateTime updatedAt;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_turno")
    private TipoTurno tipoTurno;
    
    @Column(columnDefinition = "boolean default false")
    private boolean disponible = false;
    
    @Column(columnDefinition = "boolean default false")
    private boolean intercambiado = false;
    
    @Column(length = 500)
    private String notas;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "rol")
    private Role rol;
    
    @Column(columnDefinition = "TEXT")
    private String observaciones;
    
    public enum TipoTurno {
        MANANA, // Mañana sin Ñ para evitar problemas con MySQL
        TARDE,
        NOCHE,
        COMPLETO,
        OTRO
    }
}
