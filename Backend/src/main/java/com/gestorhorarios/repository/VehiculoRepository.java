package com.gestorhorarios.repository;

import com.gestorhorarios.model.User;
import com.gestorhorarios.model.Vehiculo;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface VehiculoRepository extends JpaRepository<Vehiculo, Long> {
    List<Vehiculo> findByPropietario(User propietario);
    List<Vehiculo> findByActivoTrue();
    boolean existsByMatricula(String matricula);
    Optional<Vehiculo> findByMatricula(String matricula);
}
