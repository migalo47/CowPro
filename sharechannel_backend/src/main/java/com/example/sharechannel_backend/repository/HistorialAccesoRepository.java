package com.example.sharechannel_backend.repository;

import com.example.sharechannel_backend.model.HistorialAcceso;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface HistorialAccesoRepository extends JpaRepository<HistorialAcceso, Integer> {
    List<HistorialAcceso> findByUsuarioIdUsuario(Integer idUsuario);
    List<HistorialAcceso> findByEspacioIdEspacio(Integer idEspacio);
}
