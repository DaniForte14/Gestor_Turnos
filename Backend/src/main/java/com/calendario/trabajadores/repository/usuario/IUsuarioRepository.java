package com.calendario.trabajadores.repository.usuario;

import com.calendario.trabajadores.model.database.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
//UsuarioRepository hereda de JpaRepository que es una interfaz de Spring Data JPA, que proporciona las operaciones CRUD
// para la entidad AdministradorServicio
public interface IUsuarioRepository extends JpaRepository<Usuario, Long>, CustomUsuarioRepository {
    @Query("SELECT u FROM Usuario u WHERE u.activo = :p")
    List<Usuario> findByActivo(@Param("p")boolean activo);
}