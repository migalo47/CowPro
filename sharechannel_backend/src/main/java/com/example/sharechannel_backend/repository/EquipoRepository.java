package com.example.sharechannel_backend.repository;

import com.example.sharechannel_backend.model.Equipo;
import org.springframework.data.jpa.repository.JpaRepository;

import org.springframework.stereotype.Repository;

import java.util.List;


@Repository
public interface EquipoRepository extends JpaRepository<Equipo, Integer> {
    List<Equipo> findByDisponibilidadTrue();
    List<Equipo> findByTipoEquipo(Equipo.TipoEquipo tipoEquipo);
}
