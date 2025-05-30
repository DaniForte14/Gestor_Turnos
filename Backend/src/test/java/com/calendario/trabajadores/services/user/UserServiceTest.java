package com.calendario.trabajadores.services.user;

import com.calendario.trabajadores.model.dto.usuario.CrearUsuarioRequest;
import com.calendario.trabajadores.model.dto.usuario.EditarUsuarioRequest;
import jakarta.transaction.Transactional;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

import java.time.LocalDate;
import java.util.Date;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
//(replace = AutoConfigureTestDatabase.Replace.ANY)
//@AutoConfigureTestDatabase
//@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE) // si quisiera usar la bbdd real
@ActiveProfiles("test")
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class UserServiceTest {

    @Autowired
    private UserService userService;

    private Long id;
    private final String email = "paco@gmail.com";
    private final String password = "123";

    @Test
    @DisplayName("1. Crear usuario exitosamente")
    @Order(1)
    void crearUsuario() {
        var userRequest = new CrearUsuarioRequest();
        userRequest.activo = true;
        userRequest.nombre = "Paco";
        userRequest.apellido1 = "Manzanares";
        userRequest.apellido2 = "Corta";
        userRequest.email = email;
        userRequest.localidad = "Leon";
        userRequest.rol = "user";
        userRequest.password = password;

        var response = userService.crearUsuario(userRequest);
        id = response.getData().id;
        assertNotNull(id);
        assertEquals("Paco", response.getData().nombre);
    }

    @Test
    @DisplayName("2. Crear usuario existente (debe fallar)")
    @Order(2)
    void crearUsuarioExistente() {
        var userRequest = new CrearUsuarioRequest();
        userRequest.activo = true;
        userRequest.nombre = "Repetido";
        userRequest.apellido1 = "Apellido";
        userRequest.apellido2 = "Apellido";
        userRequest.email = email; // Mismo email
        userRequest.localidad = "Leon";
        userRequest.rol = "user";
        userRequest.password = "otraClave";

        var response = userService.crearUsuario(userRequest);
        assertNotNull(response.getError());
        assertEquals("El usuario con el email proporcionado ya existe", response.getError().getMessage());
    }

    @Test
    @DisplayName("3. Crear usuario sin contraseña (debe fallar)")
    @Order(3)
    void crearUsuarioSinPassword() {
        var userRequest = new CrearUsuarioRequest();
        userRequest.activo = true;
        userRequest.nombre = "SinClave";
        userRequest.apellido1 = "Error";
        userRequest.apellido2 = "Grave";
        userRequest.email = "error@gmail.com";
        userRequest.localidad = "Leon";
        userRequest.rol = "user";

        var response = userService.crearUsuario(userRequest);
        assertNotNull(response.getError());
    }

    @Test
    @Order(4)
    @Transactional
    @DisplayName("4. Obtener usuario por ID")
    void getUsuarioPorId() {
        var response = userService.getUsuario(id);
        assertEquals("Paco", response.getData().nombre);
    }

    @Test
    @Order(5)
    @Transactional
    @DisplayName("5. Obtener usuario por email")
    void getUsuarioPorEmail() {
        var response = userService.getUsuario(email);
        assertNotNull(response.getData());
        assertEquals("Paco", response.getData().nombre);
    }

    @Test
    @Order(6)
    @DisplayName("6. Editar usuario correctamente")
    void editarUsuario() {
        var editRequest = new EditarUsuarioRequest();
        editRequest.id = id;
        editRequest.nombre = "Paco";
        editRequest.apellido1 = "Actualizado";
        editRequest.apellido2 = "Cambiado";
        editRequest.email = email;
        editRequest.localidad = "Madrid";
        editRequest.rol = "admin";
        editRequest.password = password;
        editRequest.activo = true;

        var response = userService.editUsuario(editRequest);
        assertEquals("Actualizado", response.getData().apellido1);
        assertEquals("admin", response.getData().rol);
    }

    @Test
    @Order(7)
    @Transactional
    @DisplayName("7. Soft delete del usuario")
    void desactivarUsuario() {
        var response = userService.softDelete(id);
        assertFalse(response.getData().activo);
    }

    @Test
    @Order(8)
    @Transactional
    @DisplayName("8. Reactivar usuario")
    void reactivarUsuario() {
        var response = userService.reactivar(id);
        assertTrue(response.getData().activo);
    }

    @Test
    @Order(9)
    @Transactional
    @DisplayName("9. Listar todos los usuarios")
    void listarUsuarios() {
        var lista = userService.listar(Optional.empty());
        assertNotNull(lista.getData());
        assertFalse(lista.getData().isEmpty());
    }

    @Test
    @Order(10)
    @Transactional
    @DisplayName("10. Login exitoso")
    void loginExitoso() {
        var response = userService.login(email, password);
        assertNotNull(response.getData());
        assertEquals(email, response.getData().email);
    }

    @Test
    @Order(11)
    @DisplayName("11. Login con contraseña incorrecta")
    void loginPasswordIncorrecta() {
        var response = userService.login(email, "claveErrónea");
        assertNotNull(response.getError());
        assertEquals("Contraseña incorrecta", response.getError().getMessage());
    }

    @Test
    @Order(12)
    @DisplayName("12. Login con usuario no existente")
    void loginUsuarioNoExiste() {
        var response = userService.login("noexiste@gmail.com", "clave");
        assertNotNull(response.getError());
        assertEquals("Usuario no encontrado", response.getError().getMessage());
    }

    @Test
    @Order(13)
    @Transactional
    @DisplayName("13. Logout exitoso")
    void logoutExitoso() {
        var response = userService.logout(email, password);
        assertNotNull(response.getData());
        assertEquals(email, response.getData().email);
    }

    @Test
    @Order(14)
    @Transactional
    @DisplayName("14. Listar usuarios con vehículos")
    void listarUsuariosConVehiculos() {
        var response = userService.listarUsuariosVehiculos(Optional.empty());
        assertNotNull(response.getData());
    }

    @Test
    @Order(15)
    @Transactional
    @DisplayName("15. Listar usuarios con viajes")
    void listarUsuariosConViajes() {
        var response = userService.listarUsuariosViajes(null);
        assertNotNull(response.getData());
    }

    @Test
    @Order(16)
    @Transactional
    @DisplayName("16. Borrar usuario definitivamente")
    void borrarUsuarioDefinitivamente() {
        var response = userService.borrar(id, email);
        assertNotNull(response.getData());

        var check = userService.getUsuario(id);
        assertNotNull(check.getError());
    }
}