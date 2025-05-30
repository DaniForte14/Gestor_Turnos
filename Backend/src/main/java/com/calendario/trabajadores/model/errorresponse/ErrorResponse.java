package com.calendario.trabajadores.model.errorresponse;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Schema(description = "Error response model") //TODO: crear javadoc de todo (mejor al final) y revisar
public class ErrorResponse {
    //Atributos
    //Estado de la respuesta ("ok" o "error")
    @Schema(description = "Status of the response", example = "error")
    private String status;
    //Mensaje de error
    @Schema(description = "Error message", example = "Invalid credentials")
    private String message;
    //Tipo de excepción
    @Schema(description = "Type of the exception", example = "java.lang.IllegalArgumentException")
    private String exceptionType;

    //Constructores
    //Constructor por defecto
    public ErrorResponse() {
        this.status = "ok";
        this.message = "";
        this.exceptionType = "";
    }

    //Constructor con parámetros, recibe una excepción y extrae su información
    public ErrorResponse(Exception ex) {
        //Estado de la respuesta es "error
        this.status = "error";
        //Obtenemos el mensaje de la excepción
        this.message = ex.getMessage();
        //Obtenemos el tipo de excepción como string
        this.exceptionType = ex.getClass().getName();
    }

    //Constructor con parámetros, recibe solo un mensaje de error
    public ErrorResponse(String message) {
        //Estado de la respuesta es "error"
        this.status = "error";
        //Asignamos el mensaje que nos proporcionan
        this.message = message;
        //No se especifica el tipo de excepción
        this.exceptionType = "";
    }

}

