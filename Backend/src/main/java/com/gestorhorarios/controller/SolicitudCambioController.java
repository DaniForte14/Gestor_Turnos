package com.gestorhorarios.controller;

import com.gestorhorarios.model.SolicitudCambio;
import com.gestorhorarios.model.User;
import com.gestorhorarios.security.CurrentUser;
import com.gestorhorarios.security.UserPrincipal;
import com.gestorhorarios.service.SolicitudCambioService;
import com.gestorhorarios.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/solicitudes")
@CrossOrigin(origins = "*")
public class SolicitudCambioController {

    @Autowired
    private SolicitudCambioService solicitudCambioService;
    
    @Autowired
    private UserService userService;

    @GetMapping("/enviadas")
    @PreAuthorize("hasRole('MEDICO') or hasRole('ENFERMERO') or hasRole('TCAE')")
    public List<SolicitudCambio> obtenerSolicitudesEnviadas(@CurrentUser UserPrincipal currentUser) {
        return solicitudCambioService.obtenerSolicitudesEnviadasPorUsuarioId(currentUser.getId());
    }

    @GetMapping("/recibidas")
    @PreAuthorize("hasRole('MEDICO') or hasRole('ENFERMERO') or hasRole('TCAE')")
    public List<SolicitudCambio> obtenerSolicitudesRecibidas(@CurrentUser UserPrincipal currentUser) {
        return solicitudCambioService.obtenerSolicitudesRecibidasPorUsuarioId(currentUser.getId());
    }
    
    @GetMapping("/{id}")
    @PreAuthorize("hasRole('MEDICO') or hasRole('ENFERMERO') or hasRole('TCAE')")
    public ResponseEntity<SolicitudCambio> obtenerSolicitudPorId(
            @PathVariable Long id,
            @CurrentUser UserPrincipal currentUser) {
        
        SolicitudCambio solicitud = solicitudCambioService.obtenerSolicitudPorId(id);
        
        // Verificar que el usuario pueda acceder a esta solicitud
        if (!solicitud.getSolicitante().getId().equals(currentUser.getId()) && 
            !solicitud.getReceptor().getId().equals(currentUser.getId())) {
            return ResponseEntity.status(403).build();
        }
        
        return ResponseEntity.ok(solicitud);
    }
    
    @GetMapping("/estado/{estado}")
    @PreAuthorize("hasRole('MEDICO')")
    public List<SolicitudCambio> obtenerSolicitudesPorEstado(
            @PathVariable SolicitudCambio.EstadoSolicitud estado) {
        return solicitudCambioService.obtenerSolicitudesPorEstado(estado);
    }
    
    @GetMapping("/mis-solicitudes/estado/{estado}")
    @PreAuthorize("hasRole('MEDICO') or hasRole('ENFERMERO') or hasRole('TCAE')")
    public List<SolicitudCambio> obtenerMisSolicitudesPorEstado(
            @CurrentUser UserPrincipal currentUser,
            @PathVariable SolicitudCambio.EstadoSolicitud estado) {
        
        User usuario = userService.findUserById(currentUser.getId());
        return solicitudCambioService.obtenerSolicitudesPorUsuarioYEstado(usuario, estado);
    }
    
    @GetMapping("/recientes")
    @PreAuthorize("hasRole('MEDICO') or hasRole('ENFERMERO') or hasRole('TCAE')")
    public List<SolicitudCambio> obtenerSolicitudesRecientes(
            @CurrentUser UserPrincipal currentUser,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime desde) {
        
        User usuario = userService.findUserById(currentUser.getId());
        return solicitudCambioService.findBySolicitanteAndFechaCreacionAfter(usuario, desde);
    }

    @PostMapping
    @PreAuthorize("hasRole('MEDICO') or hasRole('ENFERMERO') or hasRole('TCAE')")
    public ResponseEntity<SolicitudCambio> crearSolicitud(
            @CurrentUser UserPrincipal currentUser,
            @RequestBody SolicitudCambio solicitud) {
        
        User solicitante = userService.findUserById(currentUser.getId());
        solicitud.setSolicitante(solicitante);
        
        return ResponseEntity.ok(solicitudCambioService.crearSolicitud(solicitud));
    }

    @PostMapping("/{id}/responder")
    @PreAuthorize("hasRole('MEDICO') or hasRole('ENFERMERO') or hasRole('TCAE')")
    public ResponseEntity<SolicitudCambio> responderSolicitud(
            @CurrentUser UserPrincipal currentUser,
            @PathVariable Long id,
            @RequestParam boolean aceptada) {
        
        User receptor = userService.findUserById(currentUser.getId());
        return ResponseEntity.ok(solicitudCambioService.responderSolicitud(id, receptor, aceptada));
    }
    
    @PostMapping("/{id}/cancelar")
    @PreAuthorize("hasRole('MEDICO') or hasRole('ENFERMERO') or hasRole('TCAE')")
    public ResponseEntity<?> cancelarSolicitud(
            @CurrentUser UserPrincipal currentUser,
            @PathVariable Long id) {
        
        solicitudCambioService.cancelarSolicitud(id, currentUser.getId());
        return ResponseEntity.ok().build();
    }
}
