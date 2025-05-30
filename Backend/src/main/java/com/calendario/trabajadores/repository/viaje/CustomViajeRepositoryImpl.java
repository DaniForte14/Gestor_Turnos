package com.calendario.trabajadores.repository.viaje;

import com.calendario.trabajadores.model.database.EstadoViaje;
import com.calendario.trabajadores.model.database.Viaje;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class CustomViajeRepositoryImpl implements CustomViajeRepository {

    @PersistenceContext
    private EntityManager entityManager;

    /**
     * @param estado
     * @return
     */
    @Override                //TODO: implementar segun Listar vehiculos
    public List<Viaje> findAllViajesByEstado(EstadoViaje estado) {
        String jpql = "SELECT v FROM Viaje v WHERE v.estado = :estado";
        TypedQuery<Viaje> query = entityManager.createQuery(jpql, Viaje.class);
        query.setParameter("estado", estado);
        return query.getResultList();
    }

    @Override              //TODO: implementar segun Listar vehiculos
    public List<Viaje> findViajesByUsuarioAndEstado(Long usuarioId, EstadoViaje estado) {
        //Creamos la sentencia JPQL
        String jpql = "SELECT v FROM Viaje v WHERE (v.conductor.id = :usuarioId OR v.usuario.id = :usuarioId) AND v.estado = :estado";

        // Creamos la consulta
        TypedQuery<Viaje> query = entityManager.createQuery(jpql, Viaje.class);

        // Establecemos los parámetros
        query.setParameter("usuarioId", usuarioId);
        query.setParameter("estado", estado);

        // Ejecutamos la consulta y devolvemos los resultados
        return query.getResultList();
    }

    /**
     * @param usuarioId
     * @return
     */
    @Override
    public List<Viaje> mostrarViajesConductor(Long usuarioId) {
        return null;
    }

    /**
     * @param usuarioId
     * @return
     */
    @Override
    public List<Viaje> mostrarMisViajes(Long usuarioId) {
        return null;
    }

    /**
     * @param viaje
     * @return
     */
    @Override
    public Viaje actualizarViaje(Viaje viaje) {
        return null;
    }

    /**
     * @param viajeId
     */
    @Override
    public void cancelarViaje(Long viajeId) {

    }

    /**
     * @param viajeId
     * @param usuarioId
     */
    @Override
    public void agregarUsuarioViaje(Long viajeId, Long usuarioId) {

    }

    /**
     * @param viajeId
     * @param usuarioId
     */
    @Override
    public void eliminarUsuarioViaje(Long viajeId, Long usuarioId) {

    }
}
