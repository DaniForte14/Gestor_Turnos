package com.gestorhorarios.dto;

import com.gestorhorarios.model.Horario;
import jakarta.validation.Constraint;
import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;
import jakarta.validation.Payload;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.lang.annotation.Documented;
import java.lang.annotation.Retention;
import java.lang.annotation.Target;
import java.time.LocalDate;
import java.time.LocalTime;

import static java.lang.annotation.ElementType.*;
import static java.lang.annotation.RetentionPolicy.RUNTIME;

@Data
@ValidHorarioTimeRange
public class HorarioRequest {
    @NotNull(message = "La fecha es obligatoria")
    private LocalDate fecha;
    
    @NotNull(message = "La hora de inicio es obligatoria")
    private LocalTime horaInicio;
    
    @NotNull(message = "La hora de fin es obligatoria")
    private LocalTime horaFin;
    
    private Horario.TipoTurno tipoTurno;
    
    private boolean disponible = false;
    
    private String notas;
    
    private String rol;
}

@Documented
@Constraint(validatedBy = ValidHorarioTimeRange.Validator.class)
@Target({TYPE})
@Retention(RUNTIME)
@interface ValidHorarioTimeRange {
    String message() default "La hora de fin debe ser posterior a la hora de inicio";
    Class<?>[] groups() default {};
    Class<? extends Payload>[] payload() default {};

    class Validator implements ConstraintValidator<ValidHorarioTimeRange, HorarioRequest> {
        @Override
        public boolean isValid(HorarioRequest request, ConstraintValidatorContext context) {
            if (request.getHoraInicio() == null || request.getHoraFin() == null) {
                return true; // Let @NotNull handle null cases
            }
            return request.getHoraFin().isAfter(request.getHoraInicio());
        }
    }
}
