package com.gestorhorarios.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Data;

@Data
@Entity
@Table(name = "vehiculos")
public class Vehiculo {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @NotBlank
    @Column(nullable = false)
    private String marca;
    
    @NotBlank
    @Column(nullable = false)
    private String modelo;
    
    @NotBlank
    @Column(name = "matricula", unique = true, nullable = false)
    private String matricula;
    
    @NotBlank
    @Column(name = "color")
    private String color;
    
    @NotNull
    @Positive
    @Column(name = "asientos_disponibles")
    private Integer asientosDisponibles;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "usuario_id", nullable = false)
    private User propietario;
    
    @Column(columnDefinition = "boolean default true")
    private boolean activo = true;
    
    @Column(length = 500)
    private String observaciones;
}
