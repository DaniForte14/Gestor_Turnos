package com.calendario.trabajadores.model.common;

import lombok.Getter;
import lombok.Setter;

import java.util.Date;
@Getter
@Setter
public class CamposComunes {   //TODO:Revisar

    private Date fechaCreacion;


    private Date fechaModificacion;

    private String creadoPor;
    private String modificadoPor;
}
