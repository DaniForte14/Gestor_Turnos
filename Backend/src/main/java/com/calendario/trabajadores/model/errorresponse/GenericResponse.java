package com.calendario.trabajadores.model.errorresponse;


import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter

/*
 * Clase genérica para manejar las respuestas de la API.
 * Permite devolver datos en caso de éxito o error.
 *
 * @param <T> El tipo de dato de la respuesta será cualquier clase
 */
@Schema(description = "Generic response model")
public class GenericResponse<T> {

    /**
     * Datos de la respuesta si la operación es exitosa.
     */
    @Schema(description = "Data returned in response")
    private T data;

    /**
     * Información del error si la operación falla.
     */
    @Schema(description = "Error details, if any")
    private ErrorResponse error;

    /**
     * Constructor vacío.
     */
    public GenericResponse() {
    }


    /**
     * Verifica si la respuesta es exitosa (sin errores).
     *
     * @return {@code true} si no hay error, {@code false} si hay un error.
     */
    public boolean isSuccess() {
        return error == null;
    }

}
