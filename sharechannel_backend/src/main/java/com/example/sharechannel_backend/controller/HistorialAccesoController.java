package com.example.sharechannel_backend.controller;

import com.example.sharechannel_backend.model.HistorialAcceso;
import com.example.sharechannel_backend.service.HistorialAccesoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/historial")
public class HistorialAccesoController {

    @Autowired
    private HistorialAccesoService historialAccesoService;

    @PostMapping
    public HistorialAcceso registrarAcceso(@RequestBody HistorialAcceso acceso) {
        return historialAccesoService.registrar(acceso);
    }

    @GetMapping("/usuario/{id}")
    public List<HistorialAcceso> historialPorUsuario(@PathVariable Integer id) {
        return historialAccesoService.obtenerPorUsuario(id);
    }

    @GetMapping("/espacio/{id}")
    public List<HistorialAcceso> historialPorEspacio(@PathVariable Integer id) {
        return historialAccesoService.obtenerPorEspacio(id);
    }

    @GetMapping
    public List<HistorialAcceso> historialGeneral() {
        return historialAccesoService.obtenerTodos();
    }
}
