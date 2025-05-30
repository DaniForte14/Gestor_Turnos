package com.calendario.trabajadores.services.viaje;

import com.calendario.trabajadores.mappings.IViajeMapper;
import com.calendario.trabajadores.model.database.EstadoViaje;
import com.calendario.trabajadores.model.database.Usuario;
import com.calendario.trabajadores.model.database.Vehiculo;
import com.calendario.trabajadores.model.database.Viaje;
import com.calendario.trabajadores.model.dto.viaje.CrearEditarViajeResponse;
import com.calendario.trabajadores.model.dto.viaje.CrearViajeRequest;
import com.calendario.trabajadores.model.dto.viaje.EditarViajeRequest;
import com.calendario.trabajadores.model.dto.viaje.ViajeResponse;
import com.calendario.trabajadores.model.errorresponse.GenericResponse;
import com.calendario.trabajadores.model.errorresponse.ErrorResponse;
import com.calendario.trabajadores.repository.usuario.IUsuarioRepository;
import com.calendario.trabajadores.repository.vehiculo.IVehiculoRepository;
import com.calendario.trabajadores.repository.viaje.IViajeRepository;
import org.springframework.stereotype.Service;

import java.util.stream.Collectors;


import java.util.List;
import java.util.Optional;

@Service
public class ViajeService {

    private final IViajeRepository viajeRepository;
    private final IUsuarioRepository usuarioRepository;
    private final IVehiculoRepository vehiculoRepository;
    private final IViajeMapper viajeMapper;

    //Constructor de ViajeService

    public ViajeService(IViajeRepository viajeRepository, IUsuarioRepository usuarioRepository, IVehiculoRepository vehiculoRepository, IViajeMapper viajeMapper) {
        this.viajeRepository = viajeRepository;
        this.usuarioRepository = usuarioRepository;
        this.vehiculoRepository = vehiculoRepository;
        this.viajeMapper = viajeMapper;
    }

    //Crear un viaje *F*
    public GenericResponse<CrearEditarViajeResponse> crearViaje(CrearViajeRequest request) {
        GenericResponse<CrearEditarViajeResponse> responseWrapper = new GenericResponse<>();

        // Buscamos las entidades conductor y vehiculo en la base de datos por sus IDs
        Optional<Usuario> responseUsuario = usuarioRepository.findById(request.getIdConductor());
        Optional<Vehiculo> responseVehiculo = vehiculoRepository.findById(request.getIdVehiculo());

        // Verificamos si el conductor o el vehículo no existen
        if (responseUsuario.isEmpty() || responseVehiculo.isEmpty()) {
            // Si no existen, devolvemos un error
            responseWrapper.setError(new ErrorResponse("Conductor o Vehículo no encontrado"));
            return responseWrapper;
        }

        // Si ambos existen, obtenemos las entidades
        Usuario conductor = responseUsuario.get();
        Vehiculo vehiculo = responseVehiculo.get();

        // Creamos el nuevo viaje con los datos del request y los objetos obtenidos
        var nuevoViaje = viajeMapper.crearViajeRequestToViaje(request);

        // Guardamos el viaje en la base de datos
        Viaje viajeGuardado = viajeRepository.save(nuevoViaje);

        // Mapeamos el viaje guardado a la respuesta
        CrearEditarViajeResponse response = viajeMapper.viajeToCrearEditarViajeResponse(viajeGuardado);

        // Devolvemos la respuesta exitosa con los datos
        responseWrapper.setData(response);
        return responseWrapper;
    }


    /*public Optional<CrearEditarViajeResponse> crearViaje(CrearViajeRequest request) {
        //Buscamos las entidades conductor y vehiculo en la base de datos (getId)
        Optional<Usuario> responseUsuario = usuarioRepository.findById(request.getIdConductor());
        Optional<Vehiculo> responseVehiculo = vehiculoRepository.findById(request.getIdVehiculo());
        // Compruebo que ambos estan vacios, si lo estan retornamos vacío
        if (responseUsuario.isEmpty() || responseVehiculo.isEmpty()) {
            return Optional.empty();
        }
        //Si no están vacíos, obtenemos los objetos
        Usuario conductor = responseUsuario.get();
        Vehiculo vehiculo = responseVehiculo.get();
        // Creamos un nuevo viaje con los datos del request y los objetos conductor y vehiculo
        var nuevoViaje = viajeMapper.crearViajeRequestToViaje(request);
        // Guardamos el viaje
        Viaje viajeGuardado = viajeRepository.save(nuevoViaje);

        // Convertimos el viaje a DTO para la respuesta
        CrearEditarViajeResponse response = viajeMapper.viajeToCrearEditarViajeResponse(viajeGuardado);

        // Retornamos la respuesta como un Optional
        return Optional.of(response);
    }*/

    // Cambiar el estado de un viaje con validaciones //TODO: REVISAR TOGGLE CAMBIO DE ESTADO
    //public Optional<ViajeResponse> cambiarEstadoViaje(Long idViaje, EstadoViaje nuevoEstado)
    public Optional<CrearEditarViajeResponse> cambiarEstadoViaje(Long idViaje, String action) {
        // Buscar el viaje por ID
        Optional<Viaje> viajeOptional = viajeRepository.findById(idViaje);

        // Si no existe, retornamos vacío
        if (viajeOptional.isEmpty()) {
            return Optional.empty();
        }

        Viaje viajeModel = viajeOptional.get();
        EstadoViaje estadoActual = viajeModel.getEstado();
        // Estado por defecto
        EstadoViaje siguienteEstado = estadoActual;

        // Validación: no se puede editar un viaje FINALIZADO
        if (estadoActual == EstadoViaje.FINALIZADO) {
            return Optional.empty(); // No se puede cambiar un viaje finalizado
        }

        // Determinar el nuevo estado en función de la acción
        if ("confirmar".equalsIgnoreCase(action) && estadoActual == EstadoViaje.DISPONIBLE) {
            siguienteEstado = EstadoViaje.EN_CURSO;
        } else if ("finalizar".equalsIgnoreCase(action) && estadoActual == EstadoViaje.EN_CURSO) {
            siguienteEstado = EstadoViaje.FINALIZADO;
        } else {
            return Optional.empty();  // Acción no válida o cambio no permitido
        }

        // Si el estado actual es el mismo que el siguiente, no hacemos nada
        if (estadoActual == siguienteEstado) {
            return Optional.empty();  // El estado ya es el mismo, no se hace nada
        }

        // Actualizamos el estado del viaje
        viajeModel.setEstado(siguienteEstado);

        // Guardamos los cambios
        Viaje viajeActualizado = viajeRepository.save(viajeModel);

        // Mapeamos el viaje actualizado a un DTO de respuesta usando el mapper
        CrearEditarViajeResponse viajeResponse = viajeMapper.viajeToCrearEditarViajeResponse(viajeActualizado);

        return Optional.of(viajeResponse);
    }

    //Editar datos de un viaje
    // TODO EDITAR DATOS DE UN VIAJE : añadir validacion de no se puede editar un viaje en curso o finalizado.
    //No se incluye estado porque no debe ser editado por el usuarioL
    public Optional<CrearEditarViajeResponse> editarViaje(Long id, EditarViajeRequest param) {
        // Buscar el viaje en la base de datos
        Optional<Viaje> viajeOptional = viajeRepository.findById(id);

        // Si no existe, retornamos un Optional vacío
        if (viajeOptional.isEmpty()) {
            return Optional.empty();  // Viaje no encontrado
        }

        // Obtener el viaje actual
        Viaje viaje = viajeOptional.get();

        // Validación: no se puede editar un viaje que está en curso o finalizado
        if (viaje.getEstado() != EstadoViaje.DISPONIBLE) {
            return Optional.empty();  // No se puede editar el viaje
        }

        // Actualizar solo los campos que no son nulos en el DTO
        if (param.getIdConductor() != null) {
            viaje.getConductor().setId(param.getIdConductor());
        }
        if (param.getOrigen() != null) {
            viaje.setOrigen(param.getOrigen());
        }
        if (param.getDestino() != null) {
            viaje.setDestino(param.getDestino());
        }
        if (param.getFechaSalida() != null) {
            viaje.setFecha(param.getFechaSalida());
        }
        if (param.getHoraSalida() != null) {
            viaje.setHora(param.getHoraSalida());
        }
        if (param.getIdVehiculo() != null) {
            viaje.getVehiculo().setId(param.getIdVehiculo());
        }
        if (param.getPlazas() != null) {
            viaje.setPlazas(param.getPlazas());
        }

        // Guardamos los cambios en la base de datos
        Viaje viajeActualizado = viajeRepository.save(viaje);

        // Usamos el Mapper para convertir el viaje actualizado a un DTO de respuesta
        CrearEditarViajeResponse respuesta = viajeMapper.viajeToCrearEditarViajeResponse(viajeActualizado);

        return Optional.of(respuesta);  // Retornamos el DTO con los datos actualizados
    }


    //Editar viaje pero sin usar tantos if: ************
/*
    public Optional<CrearEditarViajeResponse> editarViaje(Long id, EditarViajeRequest param) {
    // Buscar el viaje en la base de datos
    Optional<Viaje> viajeOptional = viajeRepository.findById(id);

    // Si no existe, retornamos un Optional vacío
    if (viajeOptional.isEmpty()) {
        return Optional.empty();  // Viaje no encontrado
    }

    // Obtener el viaje actual
    Viaje viaje = viajeOptional.get();

    // Validación: no se puede editar un viaje que está en curso o finalizado
    if (viaje.getEstado() != EstadoViaje.DISPONIBLE) {
        return Optional.empty();  // No se puede editar el viaje
    }

    // Mapeo dinámico: Actualizamos solo los campos no nulos usando reflexión TODO: usar una mapper para esto
    actualizarCampo(viaje::setConductor, param.getIdConductor());
    actualizarCampo(viaje::setOrigen, param.getOrigen());
    actualizarCampo(viaje::setDestino, param.getDestino());
    actualizarCampo(viaje::setFecha, param.getFechaSalida());
    actualizarCampo(viaje::setHora, param.getHoraSalida());
    actualizarCampo(viaje::setVehiculo, param.getIdVehiculo());
    actualizarCampo(viaje::setPlazas, param.getPlazas());

    // Guardamos los cambios en la base de datos
    Viaje viajeActualizado = viajeRepository.save(viaje);

    // Usamos el Mapper para convertir el viaje actualizado a un DTO de respuesta
    CrearEditarViajeResponse respuesta = viajeMapper.viajeToCrearEditarViajeResponse(viajeActualizado);

    return Optional.of(respuesta);  // Retornamos el DTO con los datos actualizados
}

// Método auxiliar para actualizar campos solo si el valor no es nulo
private <T> void actualizarCampo(Consumer<T> setter, T value) {
    if (value != null) {
        setter.accept(value);
    }
}
*/


    //Listar todos los viajes (uso para admin) TODO: REVISAR / USAR COOKIES DE SESION
    //Lista todos los viajes y hace filtrado por rol (admin) y por estado del viaje
    public List<CrearEditarViajeResponse> listarViajes(Long usuarioId, String rol, EstadoViaje estado) {
        List<Viaje> viajes;

        // Si el usuario es admin, puede ver todos los viajes con el filtro de estado
        if ("ADMIN".equalsIgnoreCase(rol)) {
            viajes = viajeRepository.findAllViajesByEstado(estado);  // Admin puede ver todos los viajes
        } else {
            // Si es un usuario normal, solo puede ver los viajes de su usuario y filtrados por estado
            viajes = viajeRepository.findViajesByUsuarioAndEstado(usuarioId, estado);
        }

        // Convertimos la lista de Viaje a CrearEditarViajeResponse usando el Mapper
        List<CrearEditarViajeResponse> viajesResponse = viajes.stream()
                .map(viaje -> viajeMapper.viajeToCrearEditarViajeResponse(viaje))  // Usamos el Mapper para convertir a CrearEditarViajeResponse
                .collect(Collectors.toList());

        return viajesResponse;
    }

    //Listar datos viaje
    public Optional<ViajeResponse> listarDatosViaje(Long idViaje) {
        var viajeExists = viajeRepository.findById(idViaje);
        if (viajeExists.isEmpty()) {
            return Optional.empty();
        }
        var viajeTemp = viajeExists.get();
        var respuesta = viajeMapper.viajeToViajeResponse(viajeTemp);
        return Optional.of(respuesta);
    }
}
