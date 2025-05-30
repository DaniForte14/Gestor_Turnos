package com.calendario.trabajadores.services.user;

import com.calendario.trabajadores.mappings.IUserMapper;
import com.calendario.trabajadores.mappings.IViajeMapper;
import com.calendario.trabajadores.model.database.Usuario;
import com.calendario.trabajadores.model.dto.usuario.*;
import com.calendario.trabajadores.model.dto.viaje.ViajeDTO;
import com.calendario.trabajadores.model.errorresponse.ErrorResponse;
import com.calendario.trabajadores.model.errorresponse.GenericResponse;
import com.calendario.trabajadores.repository.usuario.IUsuarioRepository;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class UserService {
    // Inyección de dependencias
    private final IUsuarioRepository userRepository;
    private final IUserMapper userMapper;
    private final IViajeMapper viajeMapper; // Inyectamos el IViajeMapper

    // Constructor de UserService
    public UserService(IUsuarioRepository userRepository, IUserMapper userMapper, IViajeMapper viajeMapper) {
        this.userRepository = userRepository;
        this.userMapper = userMapper;
        this.viajeMapper = viajeMapper; // Asignamos el IViajeMapper
    }

    //Metodo para hacer login
    public GenericResponse<UsuarioResponse> login(String username, String password) {
        var wrapperResponse = new GenericResponse<UsuarioResponse>();

        // Buscar el usuario por el email (username)
        Optional<Usuario> usuario = userRepository.findUsuarioByEmail(username);
        if (usuario.isEmpty()) {
            // Si no existe el usuario, devolvemos un error
            wrapperResponse.setError(new ErrorResponse("Usuario no encontrado"));
            return wrapperResponse;
        }

        // Verificar si la contraseña es correcta
        if (!usuario.get().getContraseña().equals(password)) {
            wrapperResponse.setError(new ErrorResponse("Contraseña incorrecta"));
            return wrapperResponse;
        }

        // Si el login es correcto, mapeamos los datos
        UsuarioResponse tempDTO = userMapper.usuarioToUsuarioResponse(usuario.get());

        // Devolvemos el DTO envuelto en GenericResponse
        wrapperResponse.setData(tempDTO);
        return wrapperResponse;
    }

    // Método para hacer logout
    public GenericResponse<UsuarioResponse> logout(String username, String password) {
        var wrapperResponse = new GenericResponse<UsuarioResponse>();

        // Buscar el usuario por el email (username)
        Optional<Usuario> usuario = userRepository.findUsuarioByEmail(username);
        if (usuario.isEmpty()) {
            // Si no existe el usuario, devolvemos un error
            wrapperResponse.setError(new ErrorResponse("Usuario no encontrado"));
            return wrapperResponse;
        }

        // Si el usuario existe, mapeamos los datos a UsuarioResponse (sin vehículos)
        UsuarioResponse tempDTO = userMapper.usuarioToUsuarioResponse(usuario.get());

        // Devolvemos el DTO con el mensaje de éxito en GenericResponse
        wrapperResponse.setData(tempDTO);
        return wrapperResponse;
    }

    //Metodo para crear un usuario
    public GenericResponse<UsuarioResponse> crearUsuario(CrearUsuarioRequest request) {

        //Buscar por email si el usuario ya existe
        var usuarioExists = userRepository.findUsuarioByEmail(request.getEmail());
        var wrapperResponse = new GenericResponse<UsuarioResponse>();
        if (usuarioExists.isPresent()) {
            wrapperResponse.setError(new ErrorResponse("El usuario con el email proporcionado ya existe"));
            return wrapperResponse;
        }
        // Validamos que el nombre no sea nulo
        if (request.getNombre() == null || request.getNombre().isEmpty()) {
            wrapperResponse.setError(new ErrorResponse("El campo 'nombre' es obligatorio"));
            return wrapperResponse;  // Retorna con un error si el nombre es nulo o vacío
        }
        //Si no existe, creamos un nuevo usuario
        var usuario = userMapper.createRequestToUser(request);
        //Activamos el usuario por defecto
        usuario.setActivo(true);
       try { //Guardamos el usuario en la base de datos
           var usuarioSaved = userRepository.save(usuario);
           // Mapeamos el usuario guardado a un DTO
           var response = userMapper.userToCreateEditResponse(usuarioSaved);

           // Envolvemos la respuesta en GenericResponse y la devolvemos
           wrapperResponse.setData(response);
           return wrapperResponse;
       } catch (DataIntegrityViolationException Ex){
           wrapperResponse.setError(new ErrorResponse(Ex.getMessage()));
           return wrapperResponse;
       }
    }


    //Metodo para editar un usuario
    public GenericResponse<UsuarioResponse> editUsuario(EditarUsuarioRequest request) {
        var usuario = userRepository.findById(request.getId());
        if (usuario.isEmpty()) {
            var error = new GenericResponse<UsuarioResponse>();
            error.setError(new ErrorResponse("Usuario no encontrado"));
            return error;
        }

        var Usuario = userMapper.editRequestToUser(request);
        var usuarioSaved = userRepository.save(Usuario);
        var response = userMapper.userToCreateEditResponse(usuarioSaved);
        var wrapperResponse = new GenericResponse<UsuarioResponse>();
        wrapperResponse.setData(response);
        return wrapperResponse;
    }

    //Metodo para desactivar un usuario
    public GenericResponse<UsuarioResponse> softDelete(Long id) {
        //Buscamos al usuario por su id
        var usuario = userRepository.findById(id);
        //Si no existe devolvemos un Optional vacio
        if (usuario.isEmpty()) {
            var error = new GenericResponse<UsuarioResponse>();
            error.setError(new ErrorResponse("Usuario no encontrado"));
            return error;
        }
        //Obtenemos el usuario
        Usuario temp = usuario.get();
        // Desactivamos al usuario
        temp.setActivo(false);
        //Guardamos el usuario en la base de datos
        Usuario usuarioSaved = userRepository.save(temp);
        //Mapeamos el usuario a un DTO
        var response = userMapper.userToCreateEditResponse(usuarioSaved);
        // Envolvemos el DTO en un GenericResponse y lo devolvemos
        var wrapperResponse = new GenericResponse<UsuarioResponse>();
        wrapperResponse.setData(response);
        return wrapperResponse;
    }

    //Metodo para reactivar a un usuario
    public GenericResponse<UsuarioResponse> reactivar(Long id) {
        //Buscamos al usuario por su id
        var usuario = userRepository.findById(id);
        //Si no existe devolvemos un Optional vacio
        if (usuario.isEmpty()) {
            var error = new GenericResponse<UsuarioResponse>();
            error.setError(new ErrorResponse("Usuario no encontrado"));
            return error;
        }
        //Obtenemos el usuario
        Usuario temp = usuario.get();
        //Activamos al usuario
        temp.setActivo(true);
        //Guardamos el usuario en la base de datos
        Usuario usuarioSaved = userRepository.save(temp);
        //Mapeamos el usuario a un DTO
        var response = userMapper.userToCreateEditResponse(usuarioSaved);
        // Envolvemos el DTO en un GenericResponse y lo devolvemos
        var wrapperResponse = new GenericResponse<UsuarioResponse>();
        wrapperResponse.setData(response);
        return wrapperResponse;
    }

    //Metodo para obtener un usuario por su email
    public GenericResponse<UsuarioResponse> getUsuario(String email) {
        var usuario = userRepository.findUsuarioByEmail(email);
        if (usuario.isEmpty()) {
            var error = new GenericResponse<UsuarioResponse>();
            error.setError(new ErrorResponse("Usuario no encontrado"));
            return error;
        }
        // Mapear usuario a DTO
        var response = userMapper.userToCreateEditResponse(usuario.get());

        // Envolver en GenericResponse y devolver
        var wrapperResponse = new GenericResponse<UsuarioResponse>();
        wrapperResponse.setData(response);
        return wrapperResponse;
    }

    //Metodo para obtener un usuario por su id
    public GenericResponse<UsuarioResponse> getUsuario(Long id) {
        var usuario = userRepository.findById(id);
        if (usuario.isEmpty()) {
            var error = new GenericResponse<UsuarioResponse>();
            error.setError(new ErrorResponse("Usuario no encontrado"));
            return error;
        }
        // Mapear usuario a DTO
        var response = userMapper.userToCreateEditResponse(usuario.get());

        // Envolver en GenericResponse y devolver
        var wrapperResponse = new GenericResponse<UsuarioResponse>();
        wrapperResponse.setData(response);
        return wrapperResponse;
    }

    public GenericResponse<List<UsuarioResponse>> listar(Optional<Boolean> activo) {
        List<Usuario> lista;
        List<UsuarioResponse> listaResponse;

        // Si no se pasa el parámetro activo, devolvemos todos los usuarios
        if (activo.isEmpty()) {
            lista = userRepository.findAll();
        } else {
            // Si se pasa el parámetro activo, devolvemos los usuarios activos o inactivos
            lista = userRepository.findByActivo(activo.get());
        }

        var wrapperResponse = new GenericResponse<List<UsuarioResponse>>();

        if (lista.isEmpty()) {
            wrapperResponse.setError(new ErrorResponse("No se encontraron usuarios"));
        } else {
            // Mapeamos los usuarios a UsuarioResponse
            listaResponse = lista.stream()
                    .map(usuario -> {
                        // Mapeo del usuario
                        UsuarioResponse usuarioResponse = userMapper.userToCreateEditResponse(usuario);

                        // Mapeo de los viajes del usuario a ViajeDTO
                        List<ViajeDTO> viajesDTO = usuario.getViajes().stream()
                                .map(viaje -> viajeMapper.viajeToViajeDTO(viaje)) // Aquí usamos el mapeo correcto
                                .collect(Collectors.toList());

                        // Asignamos los viajes al usuario
                        usuarioResponse.setViajes(viajesDTO);

                        return usuarioResponse;
                    })
                    .collect(Collectors.toList());

            wrapperResponse.setData(listaResponse);
        }

        return wrapperResponse;
    }



//Antiguo metodo listar *J*
//En lugar de tener varios metodos para encontrar según los parametros que tenga, creamos un método que
//sea capaz de devolvernos una lista de usuarios según los parametros que le pasemos
    /*public GenericResponse<List<UsuarioResponse>> listar(Optional<Boolean> activo) {
        List<Usuario> lista;
        List<UsuarioResponse> listaResponse;
        if (activo.isEmpty()) {
            //si no se pasa el parametro activo, devolvemos todos los usuarios
            lista = userRepository.findAll();
        } else {
            //si se pasa el parametro activo y es true o false, devolvemos los usuarios activos o inactivos respectivamente
            lista = userRepository.findByActivo(activo.get());
            //var lista = userRepository.findByActivo(true);
            //var lista = userRepository.findByActivo(false);
        }
        var wrapperResponse = new GenericResponse<List<UsuarioResponse>>();
        if (lista.isEmpty()) {
            wrapperResponse.setError(new ErrorResponse("No se encontraron usuarios"));
        } else {
            listaResponse = lista.stream().map(usuario -> userMapper.userToCreateEditResponse(usuario)).toList();
            wrapperResponse.setData(listaResponse);

        }
        return wrapperResponse;
    }*/


    //Metodo para listar usuarios con vehiculos
    public GenericResponse<List<UsuarioVehiculosResponse>> listarUsuariosVehiculos(Optional<Boolean> activo) {
        List<UsuarioVehiculosResponse> lista;
        //primero compruebo si es null
        if (activo.isEmpty()) {
            //Evitar una dependencia circular (findAll)
            lista = userRepository.findAllUsuariosVehiculos();

        } else {
            //sabemos que no esta vacío
            lista = userRepository.findAllUsuariosVehiculosFiltrados(activo.get());
        }
        var wrapperResponse = new GenericResponse<List<UsuarioVehiculosResponse>>();
        if (lista.isEmpty()) {
            wrapperResponse.setError(new ErrorResponse("No se encontraron usuarios"));
        } else {
            wrapperResponse.setData(lista);
        }
        return wrapperResponse;
    }

    //listar los viajes de un usuario: *F*
    public GenericResponse<List<UsuarioViajeResponse>> listarUsuariosViajes(Boolean activo) {
        List<UsuarioViajeResponse> lista = new ArrayList<>();

        // Recuperamos los usuarios con viajes (según si están activos o no)
        List<Usuario> usuarios;
        if (activo == null) {
            // Si no se pasa el parámetro activo, obtenemos todos los usuarios
            usuarios = userRepository.findAll();
        } else {
            // Si se pasa el parámetro activo, filtramos según el estado
            usuarios = userRepository.findByActivo(activo);
        }

        // Recorremos cada usuario y mapeamos los datos a DTO
        for (Usuario usuario : usuarios) {
            // Usamos el mapeador para convertir el usuario a UsuarioViajeResponse
            UsuarioViajeResponse usuarioViajeResponse = userMapper.userToUsuarioViajeResponse(usuario);

            // Mapeamos los viajes del usuario a ViajeDTO
            List<ViajeDTO> viajesDTO = usuario.getViajes().stream()
                    .map(viaje -> viajeMapper.viajeToViajeDTO(viaje))  // Mapeamos cada viaje a ViajeDTO
                    .collect(Collectors.toList());

            // Asignamos la lista de viajes al UsuarioViajeResponse
            usuarioViajeResponse.setViajes(viajesDTO);

            // Añadimos el usuarioViajeResponse a la lista final
            lista.add(usuarioViajeResponse);
        }

        // Creamos la respuesta genérica con los datos mapeados
        var wrapperResponse = new GenericResponse<List<UsuarioViajeResponse>>();
        if (lista.isEmpty()) {
            // Si no encontramos usuarios con viajes, devolvemos un error
            wrapperResponse.setError(new ErrorResponse("No se encontraron usuarios con viajes"));
        } else {
            // Si encontramos, devolvemos los datos
            wrapperResponse.setData(lista);
        }

        return wrapperResponse;
    }

    //Metodo para borrar un usuario (IMPORTANTE: los usuarios no deben usar este. Riesgo de borrado de la base de datos)
    public GenericResponse<UsuarioResponse> borrar(Long id, String email) {
        var usuario = userRepository.findById(id);
        if (usuario.isEmpty()) {
            var error = new GenericResponse<UsuarioResponse>();
            error.setError(new ErrorResponse("Usuario no encontrado"));
            return error;
        }
        if (!usuario.get().getEmail().equals(email)) {
            var error = new GenericResponse<UsuarioResponse>();
            error.setError(new ErrorResponse("El email no coincide con el del usuario"));
            return error;
        }
        //Borrado total del usuario de la bbdd
        userRepository.delete(usuario.get());
        // Mapeamos la respuesta y la envolvemos en GenericResponse
        var response = userMapper.userToCreateEditResponse(usuario.get());
        var wrapperResponse = new GenericResponse<UsuarioResponse>();
        wrapperResponse.setData(response);

        return wrapperResponse;
    }




}
