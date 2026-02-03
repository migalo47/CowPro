package com.example.sharechannel_backend.controller;

import com.example.sharechannel_backend.model.Espacio;
import com.example.sharechannel_backend.service.EspacioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/espacios")
public class EspacioController {

    @Autowired
    private EspacioService espacioService;

    @GetMapping
    public List<Espacio> listarTodos() {
        return espacioService.obtenerTodos();
    }


    @GetMapping("/{id}")
    public Espacio obtenerPorId(@PathVariable Integer id) {
        return espacioService.obtenerPorId(id).orElse(null);
    }

    @PostMapping
    public Espacio crear(@RequestBody Espacio espacio) {
        return espacioService.crear(espacio);
    }

    @PutMapping("/{id}")
    public Espacio actualizar(@PathVariable Integer id, @RequestBody Espacio espacio) {
        return espacioService.actualizar(id, espacio);
    }

    @DeleteMapping("/{id}")
    public String eliminar(@PathVariable Integer id) {
        return espacioService.eliminar(id) ? "Eliminado correctamente" : "No se encontró el espacio";
    }

    @GetMapping("/disponibles")
    public List<Espacio> obtenerDisponibles() {
        return espacioService.obtenerDisponibles();
    }

    @GetMapping("/tipo/{tipo}")
    public List<Espacio> obtenerPorTipo(@PathVariable String tipo) {
        try {
            Espacio.TipoEspacio tipoEspacio = Espacio.TipoEspacio.valueOf(tipo.toUpperCase());
            return espacioService.filtrarPorTipo(tipoEspacio);
        } catch (IllegalArgumentException e) {
            return List.of();
        }
    }

}
