package com.example.sharechannel_backend.controller;



import com.example.sharechannel_backend.model.Reserva;
import com.example.sharechannel_backend.model.Reserva.EstadoReserva;
import com.example.sharechannel_backend.service.ReservaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/reservas")
public class ReservaController {

    @Autowired
    private ReservaService reservaService;

    // Crear reserva
    @PostMapping
    public ResponseEntity<Reserva> crearReserva(@RequestBody Reserva reserva) {
        Reserva nueva = reservaService.crearReserva(reserva);
        return ResponseEntity.ok(nueva);
    }

    // Listar todas
    @GetMapping
    public ResponseEntity<List<Reserva>> listar() {
        return ResponseEntity.ok(reservaService.listarReservas());
    }

    // Obtener por ID
    @GetMapping("/{id}")
    public ResponseEntity<Reserva> obtenerPorId(@PathVariable Integer id) {
        Optional<Reserva> reserva = reservaService.obtenerReservaPorId(id);
        return reserva.map(ResponseEntity::ok).orElseGet(() -> ResponseEntity.notFound().build());
    }

    // Obtener por usuario
    @GetMapping("/usuario/{idUsuario}")
    public ResponseEntity<List<Reserva>> obtenerPorUsuario(@PathVariable Integer idUsuario) {
        return ResponseEntity.ok(reservaService.obtenerReservasPorUsuario(idUsuario));
    }

    // Obtener por estado
    @GetMapping("/estado/{estado}")
    public ResponseEntity<List<Reserva>> obtenerPorEstado(@PathVariable String estado) {
        EstadoReserva estadoReserva = EstadoReserva.valueOf(estado);
        return ResponseEntity.ok(reservaService.obtenerReservasPorEstado(estadoReserva));
    }


    // Actualizar
    @PutMapping("/{id}")
    public ResponseEntity<Reserva> actualizar(@PathVariable Integer id, @RequestBody Reserva reserva) {
        reserva.setIdReserva(id);
        return ResponseEntity.ok(reservaService.actualizarReserva(reserva));
    }

    // Eliminar
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Integer id) {
        reservaService.eliminarReserva(id);
        return ResponseEntity.noContent().build();
    }

    // ReservaController.java
    @GetMapping("/disponibilidad")
    public ResponseEntity<Boolean> verificarDisponibilidad(
            @RequestParam Integer id_espacio,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime fecha_inicio,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime fecha_fin
    ) {
        boolean disponible = reservaService.verificarDisponibilidad(id_espacio, fecha_inicio, fecha_fin);
        return ResponseEntity.ok(disponible);
    }
    @GetMapping("/disponibilidadEquipo")
    public ResponseEntity<Boolean> verificarDisponibilidadEquipo(
            @RequestParam Integer id_equipo,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime inicio,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime fin
    ){
        boolean disponible = reservaService.verificarDisponibilidadEquipo(id_equipo, inicio, fin);
        return ResponseEntity.ok(disponible);
    }
    @PutMapping("/{id}/estado")
    public ResponseEntity<Reserva> actualizarEstado(
            @PathVariable Integer id,
            @RequestParam String estado
    ) {
        Reserva reserva = reservaService.obtenerReservaPorId(id)
                .orElseThrow(() -> new RuntimeException("Reserva no encontrada"));

        reserva.setEstado(EstadoReserva.valueOf(estado.toUpperCase()));
        Reserva actualizada = reservaService.actualizarReserva(reserva);
        return ResponseEntity.ok(actualizada);
    }
    @GetMapping("/fechasNoDisponibles")
    public ResponseEntity<List<LocalDate>> obtenerFechasNoDisponibles(@RequestParam Integer idEspacio) {
        List<LocalDate> fechas = reservaService.obtenerFechasSinCapacidadDisponible(idEspacio);
        return ResponseEntity.ok(fechas);
    }

    @GetMapping("/horasOcupadas")
    public ResponseEntity<Map<String, List<String>>> obtenerHorasOcupadas(
            @RequestParam Integer idEspacio) {
        Map<String, List<String>> resultado = reservaService.obtenerHorasOcupadasPorFecha(idEspacio);
        return ResponseEntity.ok(resultado);
    }

    @GetMapping("/fechasYHorasOcupadas")
    public ResponseEntity<Map<String, List<String>>> obtenerFechasYHorasOcupadas(
            @RequestParam Integer idEspacio) {
        Map<String, List<String>> resultado = reservaService.obtenerHorasOcupadasPorDia(idEspacio);
        return ResponseEntity.ok(resultado);
    }


}

