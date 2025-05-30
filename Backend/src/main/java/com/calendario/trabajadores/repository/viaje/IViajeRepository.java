package com.calendario.trabajadores.repository.viaje;

import com.calendario.trabajadores.model.database.Viaje;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface IViajeRepository extends JpaRepository<Viaje, Long>, CustomViajeRepository {


    Object findViajeByConductorId(Long idConductor);
}
