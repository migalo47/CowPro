package com.example.sharechannel_backend.service;

import com.example.sharechannel_backend.model.Equipo;
import com.example.sharechannel_backend.repository.EquipoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class EquipoService {

    @Autowired
    private EquipoRepository equipoRepository;

    public List<Equipo> obtenerTodos() {
        return equipoRepository.findAll();
    }

    public Optional<Equipo> obtenerPorId(Integer id) {
        return equipoRepository.findById(id);
    }

    public Equipo crear(Equipo equipo) {
        return equipoRepository.save(equipo);
    }

    public Equipo actualizar(Integer id, Equipo datosActualizados) {
        return equipoRepository.findById(id).map(equipo -> {
            equipo.setNombre(datosActualizados.getNombre());
            equipo.setDescripcion(datosActualizados.getDescripcion());
            equipo.setTipoEquipo(datosActualizados.getTipoEquipo());
            equipo.setPrecioPorDia(datosActualizados.getPrecioPorDia());
            equipo.setDisponibilidad(datosActualizados.getDisponibilidad());
            equipo.setImagenUrl(datosActualizados.getImagenUrl());
            equipo.setCantidadDisponible(datosActualizados.getCantidadDisponible());
            return equipoRepository.save(equipo);
        }).orElse(null);
    }

    public boolean eliminar(Integer id) {
        if (equipoRepository.existsById(id)) {
            equipoRepository.deleteById(id);
            return true;
        }
        return false;
    }

    public List<Equipo> obtenerDisponibles() {
        return equipoRepository.findByDisponibilidadTrue();
    }

    public List<Equipo> filtrarPorTipo(Equipo.TipoEquipo tipo) {
        return equipoRepository.findByTipoEquipo(tipo);
    }
}

