package com.calendario.trabajadores.repository.vehiculo;

import com.calendario.trabajadores.model.database.Vehiculo;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;

import java.util.List;
import java.util.Optional;

public class CustomVehiculoRepositoryImpl implements CustomVehiculoRepository {

    @PersistenceContext
    private EntityManager entityManager;


    //Listar vehiculos por usuario
    @Override
    public List<Vehiculo> listarVehiculosUsuario(Long usuarioId) {
        List<Vehiculo> vehiculos = entityManager.createQuery(
                "SELECT v FROM Vehiculo v JOIN FETCH v.usuario u WHERE u.id = :usuario_id",
                Vehiculo.class
        ).setParameter("usuario_id", usuarioId).getResultList();
        return vehiculos;
    }

    /**
     * @param usuarioId
     * @param activo
     * @return
     */
    @Override  //Listar vehiculos por usuario con filtro
    public List<Vehiculo> listarVehiculosUsuarioConFiltro(Long usuarioId, Optional<Boolean> activo) {
        // Empezamos con una consulta básica para obtener los vehículos de un usuario
        String query = "SELECT v FROM Vehiculo v JOIN v.usuario u WHERE u.id = :usuarioId";

        // Si "activo" no es vacío, añadir la condición para el estado de "activo"
        if (activo.isPresent()) {
            query += " AND v.activo = :activo";
        }

        // Creamos la consulta
        TypedQuery<Vehiculo> typedQuery = entityManager.createQuery(query, Vehiculo.class);
        typedQuery.setParameter("usuarioId", usuarioId);

        // Si "activo" tiene un valor, lo añadimos a la consulta
        activo.ifPresent(activos -> typedQuery.setParameter("activo", activos));

        // Ejecutamos la consulta y devolvemos los resultados
        return typedQuery.getResultList();

    }


}
