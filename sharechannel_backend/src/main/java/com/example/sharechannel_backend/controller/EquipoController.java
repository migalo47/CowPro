package com.example.sharechannel_backend.controller;

import com.example.sharechannel_backend.model.Equipo;
import com.example.sharechannel_backend.service.EquipoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/equipos")
public class EquipoController {

    @Autowired
    private EquipoService equipoService;

    @GetMapping
    public List<Equipo> listarTodos() {
        return equipoService.obtenerTodos();
    }

    @GetMapping("/{id}")
    public Equipo obtenerPorId(@PathVariable Integer id) {
        return equipoService.obtenerPorId(id).orElse(null);
    }

    @PostMapping
    public Equipo crear(@RequestBody Equipo equipo) {
        return equipoService.crear(equipo);
    }

    @PutMapping("/{id}")
    public Equipo actualizar(@PathVariable Integer id, @RequestBody Equipo equipo) {
        return equipoService.actualizar(id, equipo);
    }

    @DeleteMapping("/{id}")
    public String eliminar(@PathVariable Integer id) {
        return equipoService.eliminar(id) ? "Equipo eliminado correctamente" : "Equipo no encontrado";
    }

    @GetMapping("/disponibles")
    public List<Equipo> obtenerDisponibles() {
        return equipoService.obtenerDisponibles();
    }

    @GetMapping("/tipo/{tipo}")
    public List<Equipo> obtenerPorTipo(@PathVariable String tipo) {
        try {
            Equipo.TipoEquipo tipoEquipo = Equipo.TipoEquipo.valueOf(tipo.toUpperCase());
            return equipoService.filtrarPorTipo(tipoEquipo);
        } catch (IllegalArgumentException e) {
            return List.of(); // Devuelve lista vacía si el tipo no existe
        }
    }
}
