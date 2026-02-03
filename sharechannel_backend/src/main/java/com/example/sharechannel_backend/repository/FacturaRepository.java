package com.example.sharechannel_backend.repository;

import com.example.sharechannel_backend.model.Factura;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface FacturaRepository extends JpaRepository<Factura, Integer> {
    List<Factura> findByUsuario_IdUsuario(Integer idUsuario);
    Optional<Factura> findByNumeroFactura(String numeroFactura);
    Optional<Factura> findByReservaIdReserva(Integer idReserva);


}
