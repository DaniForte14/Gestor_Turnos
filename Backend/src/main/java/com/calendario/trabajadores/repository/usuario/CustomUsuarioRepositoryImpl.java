package com.calendario.trabajadores.repository.usuario;

import com.calendario.trabajadores.mappings.IUserMapper;
import com.calendario.trabajadores.model.database.Usuario;
import com.calendario.trabajadores.model.database.Vehiculo;
import com.calendario.trabajadores.model.dto.usuario.UsuarioVehiculosResponse;
import com.calendario.trabajadores.model.dto.vehiculo.VehiculoDTO;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Repository
public class CustomUsuarioRepositoryImpl implements CustomUsuarioRepository {
    @PersistenceContext
    private EntityManager entityManager;
    @Autowired
    private IUserMapper userMapper;
    //Método para buscar un AdministradorServicio por su correo electrónico
    @Override
    public Optional<Usuario> findUsuarioByEmail(String email) {
        return entityManager.createQuery("SELECT u FROM Usuario u WHERE u.email = :email", Usuario.class)
                .setParameter("email", email)
                .getResultList()
                .stream()
                .findFirst();
    }
    @Override
    public List<UsuarioVehiculosResponse> findAllUsuariosVehiculos() {
        // Usamos LEFT JOIN para asegurarnos de que no se pierdan usuarios sin vehículos
        List<Object[]> result = entityManager.createQuery(
                        "SELECT u, v FROM Usuario u " +
                                // Los vehículos pueden ser null si no los tienen
                                "LEFT JOIN u.vehiculos v", Object[].class)
                .getResultList();

        // Ahora mapeamos los resultados usando el mapper
        return result.stream()
                .map(row -> {
                    Usuario usuario = (Usuario) row[0];
                    // Los vehículos pueden ser null si no existen
                    List<VehiculoDTO> vehiculos = (List<VehiculoDTO>) row[1];

                    //  usamos el mapper para convertir el Usuario a UsuarioVehiculosResponse
                    return userMapper.usuarioToUsuarioVehiculosResponse(usuario, vehiculos);
                })
                .collect(Collectors.toList());
    }
    @Override
    public List<UsuarioVehiculosResponse> findAllUsuariosVehiculosFiltrados(boolean activo) {
        // Consulta con LEFT JOIN para obtener los usuarios y sus vehículos filtrados por el estado 'activo'
        List<Object[]> result = entityManager.createQuery(
                        "SELECT u, v FROM Usuario u " +
                                "LEFT JOIN u.vehiculos v WHERE v.activo = :activo", Object[].class)
                .setParameter("activo", activo)
                .getResultList();

        // Mapear los resultados usando el mapper
        return result.stream()
                .map(row -> {
                    Usuario usuario = (Usuario) row[0];
                    List<VehiculoDTO> vehiculos = (List<VehiculoDTO>) row[1];  // Los vehículos pueden ser null si no existen

                    // Usamos el mapper para convertir el Usuario a UsuarioVehiculosResponse
                    return userMapper.usuarioToUsuarioVehiculosResponse(usuario, vehiculos);
                })
                .collect(Collectors.toList());
    }

    //Antiguos metodos de UsuarioVehiculo
    /*//Listar usuarios con sus vehiculos
    @Override
    public List<UsuarioVehiculosResponse> findAllUsuariosVehiculos() {
        var resp = entityManager.createQuery("SELECT com.calendario.trabajadores.model.dto.usuario.UsuarioVehiculosResponse" +
                        "(u.id, u.nombre, u.apellido1, u.apellido2, u.email,  " +
                        "(SELECT new com.calendario.trabajadores.model.dto.vehiculo.VehiculoDTO(v.id, v.marca, v.modelo) " +
                        "FROM Vehiculo v WHERE v.usuario.id = u.id))  u.activo) FROM Usuario u", UsuarioVehiculosResponse.class)
                .getResultList();
        return resp;
    }

    @Override
    public List<UsuarioVehiculosResponse> findAllUsuariosVehiculosFiltrados(boolean param) {
        var resp = entityManager.createQuery(
                        "SELECT new com.calendario.trabajadores.model.dto.usuario.UsuarioVehiculosResponse(" +
                                "   u.id, u.nombre, u.apellido1, u.apellido2, u.email, " +
                                "   (SELECT COALESCE(" +
                                "       CAST(COUNT(v) AS integer), 0) FROM Vehiculo v " +
                                "    WHERE v.usuario.id = u.id AND v.activo = :activo)) " +
                                "FROM Usuario u", UsuarioVehiculosResponse.class)
                .setParameter("activo", param)
                .getResultList();
        return resp;
    }*/

}
