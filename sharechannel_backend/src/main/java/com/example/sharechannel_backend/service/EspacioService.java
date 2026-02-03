package com.example.sharechannel_backend.service;

import com.example.sharechannel_backend.model.Espacio;
import com.example.sharechannel_backend.repository.EspacioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class EspacioService {

    @Autowired
    private EspacioRepository espacioRepository;

    public List<Espacio> obtenerTodos() {
        return espacioRepository.findAll();
    }

    public Optional<Espacio> obtenerPorId(Integer id) {
        return espacioRepository.findById(id);
    }

    public Espacio crear(Espacio espacio) {
        return espacioRepository.save(espacio);
    }

    public Espacio actualizar(Integer id, Espacio espacioActualizado) {
        return espacioRepository.findById(id).map(espacio -> {
            espacio.setNombre(espacioActualizado.getNombre());
            espacio.setDescripcion(espacioActualizado.getDescripcion());
            espacio.setTipoEspacio(espacioActualizado.getTipoEspacio());
            espacio.setPrecioPorHora(espacioActualizado.getPrecioPorHora());
            espacio.setPrecioPorDia(espacioActualizado.getPrecioPorDia());
            espacio.setPrecioPorMes(espacioActualizado.getPrecioPorMes());
            espacio.setDisponibilidad(espacioActualizado.getDisponibilidad());
            espacio.setDeviceId(espacioActualizado.getDeviceId());
            espacio.setImagenUrl(espacioActualizado.getImagenUrl());
            espacio.setCapacidad(espacioActualizado.getCapacidad());
            return espacioRepository.save(espacio);
        }).orElse(null);
    }

    public boolean eliminar(Integer id) {
        if (espacioRepository.existsById(id)) {
            espacioRepository.deleteById(id);
            return true;
        }
        return false;
    }

    public List<Espacio> obtenerDisponibles() {
        return espacioRepository.findByDisponibilidadTrue();
    }

    public List<Espacio> filtrarPorTipo(Espacio.TipoEspacio tipo) {
        return espacioRepository.findByTipoEspacio(tipo);
    }

}
