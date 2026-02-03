package com.example.sharechannel_backend.repository;

import com.example.sharechannel_backend.model.Pago;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PagoRepository extends JpaRepository<Pago, Integer> {
    List<Pago> findByReservaUsuarioIdUsuario(Integer idUsuario);
    List<Pago> findByReservaIdReserva(Integer idReserva);


}
