package com.gestorhorarios.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "solicitudes_cambio")
public class SolicitudCambio {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @NotNull
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "solicitante_id", nullable = false)
    private User solicitante;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "receptor_id")
    private User receptor;
    
    @NotNull
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "horario_origen_id", nullable = false)
    private Horario horarioOrigen;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "horario_destino_id")
    private Horario horarioDestino;
    
    @NotNull
    @Enumerated(EnumType.STRING)
    @Column(name = "estado")
    private EstadoSolicitud estado = EstadoSolicitud.PENDIENTE;
    
    @Column(columnDefinition = "TEXT")
    private String mensaje;
    
    @Column(name = "fecha_creacion")
    private LocalDateTime fechaCreacion = LocalDateTime.now();
    
    @Column(name = "fecha_respuesta")
    private LocalDateTime fechaRespuesta;
    
    public enum EstadoSolicitud {
        PENDIENTE,
        ACEPTADA,
        RECHAZADA,
        CANCELADA
    }
}
