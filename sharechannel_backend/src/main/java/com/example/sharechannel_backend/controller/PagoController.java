package com.example.sharechannel_backend.controller;

import com.example.sharechannel_backend.model.Pago;
import com.example.sharechannel_backend.model.Usuario;
import com.example.sharechannel_backend.service.PagoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/pagos")
public class PagoController {

    @Autowired
    private PagoService pagoService;

    @PostMapping
    public Pago registrarPago(@RequestBody Pago pago) {
        return pagoService.registrarPago(pago);
    }


    @GetMapping("/usuario/{idUsuario}")
    public List<Pago> pagosPorUsuario(@PathVariable Integer idUsuario) {
        return pagoService.obtenerPagosPorUsuario(idUsuario);
    }

    @GetMapping("/reserva/{idReserva}")
    public List<Pago> pagosPorReserva(@PathVariable Integer idReserva) {
        return pagoService.obtenerPagosPorReserva(idReserva);
    }

    @PutMapping("/{id}/{estado}")
    public Pago cambiarEstado(@PathVariable Integer id, @PathVariable String estado) {
        Pago.EstadoPago nuevoEstado;
        try {
            nuevoEstado = Pago.EstadoPago.valueOf(estado.toUpperCase());
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("Estado no válido: " + estado);
        }

        return pagoService.cambiarEstado(id, nuevoEstado)
                .orElseThrow(() -> new IllegalArgumentException("Pago no encontrado"));
    }
    @GetMapping
    public List<Pago> listarTodos() {
        return pagoService.obtenerTodosPagos();
    }

}

