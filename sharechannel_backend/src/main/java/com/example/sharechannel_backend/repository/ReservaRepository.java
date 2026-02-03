package com.example.sharechannel_backend.repository;


import com.example.sharechannel_backend.model.Reserva;
import com.example.sharechannel_backend.model.Reserva.EstadoReserva;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface ReservaRepository extends JpaRepository<Reserva, Integer> {

    List<Reserva> findByUsuarioIdUsuario(Integer idUsuario);

    List<Reserva> findByEstado(EstadoReserva estado);

    List<Reserva> findByEspacioIdEspacio(Integer idEspacio);



    @Query("SELECT r FROM Reserva r WHERE r.espacio.idEspacio = :idEspacio " +
            "AND NOT (r.fechaFin <= :fechaInicio OR r.fechaInicio >= :fechaFin)")
    List<Reserva> findReservasSolapadas(
            @Param("idEspacio") Integer idEspacio,
            @Param("fechaInicio") LocalDateTime fechaInicio,
            @Param("fechaFin") LocalDateTime fechaFin
    );

    @Query("SELECT r FROM Reserva r WHERE r.equipo.idEquipo = :idEquipo " +
            "AND NOT (r.fechaFin <= :inicio OR r.fechaInicio >= :fin)")
    List<Reserva> findReservasSolapadasPorEquipo(
            @Param("idEquipo") Integer idEquipo,
            @Param("inicio") LocalDateTime inicio,
            @Param("fin") LocalDateTime fin
    );



}

