package com.example.sharechannel_backend.controller;

import com.example.sharechannel_backend.model.Factura;
import com.example.sharechannel_backend.service.FacturaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@RestController
@RequestMapping("/facturas")
public class FacturaController {

    @Autowired
    private FacturaService facturaService;

    @PostMapping
    public Factura crearFactura(@RequestBody Factura factura) {
        return facturaService.guardarFactura(factura);
    }

    @GetMapping
    public List<Factura> listarTodas() {
        return facturaService.obtenerTodas();
    }

    @GetMapping("/{id}")
    public Factura obtenerPorId(@PathVariable Integer id) {
        return facturaService.obtenerPorId(id)
                .orElseThrow(() -> new RuntimeException("Factura no encontrada"));
    }

    @GetMapping("/usuario/{id}")
    public List<Factura> obtenerPorUsuario(@PathVariable Integer id) {
        return facturaService.obtenerPorUsuario(id);
    }

    @PutMapping("/{id}/estado")
    public Factura cambiarEstado(@PathVariable Integer id, @RequestParam String estado) {
        Factura.EstadoFactura nuevoEstado;
        try {
            nuevoEstado = Factura.EstadoFactura.valueOf(estado.toUpperCase());
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Estado no válido: " + estado);
        }

        return facturaService.cambiarEstado(id, nuevoEstado)
                .orElseThrow(() -> new RuntimeException("Factura no encontrada"));
    }

    @GetMapping("/buscar/{numero}")
    public Factura buscarPorNumero(@PathVariable String numero) {
        String numeroLimpio = numero.trim();

        return facturaService.buscarPorNumero(numeroLimpio)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Factura no encontrada"));
    }

    // ✅ Nuevo endpoint: buscar factura por ID de reserva
    @GetMapping("/reserva/{idReserva}")
    public Factura obtenerPorIdReserva(@PathVariable Integer idReserva) {
        return facturaService.obtenerPorReserva(idReserva)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Factura no encontrada para la reserva"));
    }

}
