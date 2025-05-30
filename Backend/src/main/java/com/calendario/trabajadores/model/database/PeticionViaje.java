package com.calendario.trabajadores.model.database;

import com.calendario.trabajadores.model.common.CamposComunes;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name = "peticion_viaje")
public class PeticionViaje extends CamposComunes {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    public Long id;
    @ManyToOne
    @JoinColumn(name = "usuario_id")
    public Usuario usuario = new Usuario();
    @ManyToOne
    @JoinColumn(name = "viaje_id")
    public Viaje viaje = new Viaje();
    public EstadoPeticionViaje estado;
}
