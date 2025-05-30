package com.calendario.trabajadores.model.database;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.util.Date;

@Entity
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "vehiculos", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"matricula"}),

})
public class Vehiculo {
    //Es un campo identificador de la tabla y además es identity, es decir, se autoincrementa
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    public Long id;
    public String modeloCoche;
    @Column(name = "matricula", unique = true, nullable = false)
    public String matricula;
    public int plazas;
    @ManyToOne(fetch = FetchType.LAZY)
    //Aseguro la relacion de un vehiculo por usuario, no puede ser nulo y el usuario debe ser unico
    @JoinColumn(name = "usuario_id", nullable = false)
    @JsonBackReference
    //public Usuario usuario = new Usuario();
    public Usuario usuario;
    //vehiculo activo o no
    public Boolean activo;
    @CreationTimestamp
    @Temporal(TemporalType.TIMESTAMP)
    @Column(updatable = false)
    private Date fechaCreacion;

    @UpdateTimestamp
    private Date fechaModificacion;

    private String creadoPor;
    private String modificadoPor;
}
