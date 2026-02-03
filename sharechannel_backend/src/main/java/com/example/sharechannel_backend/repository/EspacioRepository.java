package com.example.sharechannel_backend.repository;

import com.example.sharechannel_backend.model.Espacio;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface EspacioRepository extends JpaRepository<Espacio, Integer> {
    List<Espacio> findByDisponibilidadTrue();

    List<Espacio> findByTipoEspacio(Espacio.TipoEspacio tipoEspacio);
}
