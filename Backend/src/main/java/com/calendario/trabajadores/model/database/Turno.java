package com.calendario.trabajadores.model.database;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.Date;

@Getter
@Setter
@Entity
@Table(name = "turnos")
public class Turno {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    //Identificador de la tabla
    private Long id;
    @ManyToOne
    @JoinColumn(name = "usuario_id", nullable = false) //Revisar lo de usuario id**
    public Usuario usuario = new Usuario();

    @Column(nullable = false)
    private Date horaInicio;

    @Column(nullable = false)
    private Date horaFin;

    //Estado del turno
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    public EstadoTurno estadoTurno;
    //Estado de la petición de cambio de turno
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    public PeticionTurno peticionTurno;
    //Puede ir una nota asociada a la petición de cambio de turno
    public String notasPeticion;
    // Constructor para asignar zona horaria por defecto
    public Boolean activo;
    @Column(updatable = false)
    private Date fechaCreacion;

    @UpdateTimestamp
    private Date fechaModificacion;

    private String creadoPor;
    private String modificadoPor;
    //Constructor vacio
    public Turno() {
        this.horaInicio = new Date();
        this.horaFin = new Date();
    }
}

