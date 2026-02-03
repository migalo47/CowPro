package com.example.sharechannel_backend.service;

import com.example.sharechannel_backend.model.HistorialAcceso;
import com.example.sharechannel_backend.repository.HistorialAccesoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class HistorialAccesoService {

    @Autowired
    private HistorialAccesoRepository historialAccesoRepository;

    public HistorialAcceso registrar(HistorialAcceso acceso) {
        return historialAccesoRepository.save(acceso);
    }

    public List<HistorialAcceso> obtenerPorUsuario(Integer idUsuario) {
        return historialAccesoRepository.findByUsuarioIdUsuario(idUsuario);
    }

    public List<HistorialAcceso> obtenerPorEspacio(Integer idEspacio) {
        return historialAccesoRepository.findByEspacioIdEspacio(idEspacio);
    }

    public List<HistorialAcceso> obtenerTodos() {
        return historialAccesoRepository.findAll();
    }

    public Optional<HistorialAcceso> obtenerPorId(Integer id) {
        return historialAccesoRepository.findById(id);
    }
}
