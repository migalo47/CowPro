package com.example.sharechannel_backend.controller;

import com.example.sharechannel_backend.model.Notificacion;
import com.example.sharechannel_backend.model.Pago;
import com.example.sharechannel_backend.scheduler.NotificacionesScheduler;
import com.example.sharechannel_backend.service.NotificacionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/notificaciones")
public class NotificacionController {

    @Autowired
    private NotificacionService notificacionService;
    @Autowired
    private NotificacionesScheduler scheduler;

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Notificacion enviar(@RequestBody Notificacion notificacion) {
        return notificacionService.enviar(notificacion);
    }

    @GetMapping
        public List<Notificacion> listarTodos() {
        return notificacionService.obtenerTodas();
    }


    @GetMapping("/usuario/{id}")
    public List<Notificacion> obtenerPorUsuario(@PathVariable Integer id) {
        return notificacionService.obtenerPorUsuario(id);
    }

    @PutMapping("/{id}/estado")
    public Notificacion cambiarEstado(@PathVariable Integer id, @RequestParam String estado) {
        Notificacion.Estado nuevoEstado;
        try {
            nuevoEstado = Notificacion.Estado.valueOf(estado.toUpperCase());
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Estado no válido: " + estado);
        }

        return notificacionService.cambiarEstado(id, nuevoEstado)
                .orElseThrow(() -> new IllegalArgumentException("Notificación no encontrada"));
    }

    @PostMapping("/generar-prueba")
    public ResponseEntity<String> generarNotificacionesDePrueba() {
        scheduler.generarNotificacionesProgramadas();
        return ResponseEntity.ok("Notificaciones generadas manualmente.");
    }

    @PostMapping("/todos")
    public ResponseEntity<String> enviarATodos(@RequestBody Notificacion notificacion) {
        notificacionService.enviarATodos(notificacion);
        return ResponseEntity.ok("Notificación enviada a todos los usuarios.");
    }
}
