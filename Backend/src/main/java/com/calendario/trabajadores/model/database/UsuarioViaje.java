package com.calendario.trabajadores.model.database;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "usuario_viaje")
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class UsuarioViaje {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    public Long id;
    @ManyToOne
    @JoinColumn(name = "usuario_id")
    public Usuario usuario = new Usuario();
    @ManyToOne
    @JoinColumn(name = "viaje_id")
    public Viaje viaje = new Viaje();

}
