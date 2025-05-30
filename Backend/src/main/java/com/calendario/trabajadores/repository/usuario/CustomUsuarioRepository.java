package com.calendario.trabajadores.repository.usuario;

import com.calendario.trabajadores.model.database.Usuario;
import com.calendario.trabajadores.model.dto.usuario.UsuarioVehiculosResponse;
import com.calendario.trabajadores.model.dto.vehiculo.VehiculoDTO;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface CustomUsuarioRepository {
    //Métodos de consulta

    //Método para buscar un AdministradorServicio por su correo electrónico
    Optional<Usuario> findUsuarioByEmail(String email);

   //Listar usuarios con sus vehiculos
    List<UsuarioVehiculosResponse> findAllUsuariosVehiculos();
    //
    List<UsuarioVehiculosResponse> findAllUsuariosVehiculosFiltrados(boolean param);
}
