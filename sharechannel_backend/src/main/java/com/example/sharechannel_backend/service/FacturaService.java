package com.example.sharechannel_backend.service;

import com.example.sharechannel_backend.model.Factura;
import com.example.sharechannel_backend.repository.FacturaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class FacturaService {

    @Autowired
    private FacturaRepository facturaRepository;

    public Factura guardarFactura(Factura factura) {
        return facturaRepository.save(factura);
    }

    public List<Factura> obtenerTodas() {
        return facturaRepository.findAll();
    }

    public Optional<Factura> obtenerPorId(Integer id) {
        return facturaRepository.findById(id);
    }

    public List<Factura> obtenerPorUsuario(Integer idUsuario) {
        return facturaRepository.findByUsuario_IdUsuario(idUsuario);
    }

    public Optional<Factura> cambiarEstado(Integer id, Factura.EstadoFactura estado) {
        return facturaRepository.findById(id).map(factura -> {
            factura.setEstado(estado);
            return facturaRepository.save(factura);
        });
    }

    public Optional<Factura> buscarPorNumero(String numeroFactura) {
        return facturaRepository.findByNumeroFactura(numeroFactura);
    }

    public Optional<Factura> obtenerPorReserva(Integer idReserva) {
        return facturaRepository.findByReservaIdReserva(idReserva);
    }



}
