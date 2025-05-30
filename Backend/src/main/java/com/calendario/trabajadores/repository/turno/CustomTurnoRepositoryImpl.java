package com.calendario.trabajadores.repository.turno;

import com.calendario.trabajadores.model.database.Turno;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class CustomTurnoRepositoryImpl implements CustomTurnoRepository {

    @PersistenceContext
    private EntityManager em;

    @Override
    public List<Turno> buscarTurnosActivos() {
        String jpql = "SELECT t FROM Turno t WHERE t.activo = true";
        TypedQuery<Turno> query = em.createQuery(jpql, Turno.class);
        return query.getResultList();
    }
}
