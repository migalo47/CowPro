package com.example.sharechannel_backend.service;

import com.example.sharechannel_backend.model.*;
import com.example.sharechannel_backend.repository.PagoRepository;
import com.example.sharechannel_backend.repository.ReservaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class PagoService {

    @Autowired
    private PagoRepository pagoRepository;

    @Autowired
    private FacturaService facturaService;

    @Autowired
    private ReservaRepository reservaRepository;

    @Autowired
    private NotificacionService notificacionService;

    @Autowired
    private HistorialAccesoService historialAccesoService;


    public Pago registrarPago(Pago pago) {
        pago.setFechaPago(java.time.LocalDateTime.now());
        return pagoRepository.save(pago);
    }


    public List<Pago> obtenerPagosPorUsuario(Integer idUsuario) {
        return pagoRepository.findByReservaUsuarioIdUsuario(idUsuario);
    }

    public List<Pago> obtenerPagosPorReserva(Integer idReserva) {
        return pagoRepository.findByReservaIdReserva(idReserva);
    }

    public Optional<Pago> cambiarEstado(Integer idPago, Pago.EstadoPago nuevoEstado) {
        return pagoRepository.findById(idPago).map(pago -> {
            pago.setEstadoPago(nuevoEstado);
            Pago actualizado = pagoRepository.save(pago);

            if (nuevoEstado == Pago.EstadoPago.PAGADO) {
                Reserva reserva = pago.getReserva();

                // ✅ Confirmar la reserva
                reserva.setEstado(Reserva.EstadoReserva.CONFIRMADA);
                reservaRepository.save(reserva);

                // ✅ Crear notificación
                Notificacion notificacion = new Notificacion();
                notificacion.setUsuario(reserva.getUsuario());
                notificacion.setMensaje("Tu reserva del espacio '" + reserva.getEspacio().getNombre() + "' ha sido confirmada.");
                notificacion.setTipoNotificacion(Notificacion.TipoNotificacion.CONFIRMACION);
                notificacion.setEstado(Notificacion.Estado.PENDIENTE);
                notificacion.setFechaNotificacion(java.time.LocalDateTime.now());

                notificacionService.enviar(notificacion);


                // ✅ Registrar en el historial de accesos
                HistorialAcceso historial = new HistorialAcceso();
                historial.setUsuario(reserva.getUsuario());
                historial.setEspacio(reserva.getEspacio());
                historial.setEquipo(reserva.getEquipo()); // Puede ser null si no hay equipo
                historial.setFechaAcceso(LocalDateTime.now());
                historial.setHoraInicio(reserva.getFechaInicio());
                historial.setHoraFin(reserva.getFechaFin());

                historialAccesoService.registrar(historial);

                // ✅ Crear factura si no existe
                boolean yaExisteFactura = facturaService
                        .buscarPorNumero("RES-" + reserva.getIdReserva())
                        .isPresent();

                if (!yaExisteFactura) {
                    Factura factura = new Factura();
                    factura.setReserva(reserva);
                    factura.setUsuario(reserva.getUsuario());
                    factura.setEstado(Factura.EstadoFactura.PAGADA);
                    factura.setFechaEmision(java.time.LocalDateTime.now());
                    factura.setFechaVencimiento(java.time.LocalDateTime.now().plusDays(7));
                    factura.setMetodoPago(Factura.MetodoPago.OTRO);
                    factura.setConcepto("Reserva del espacio " + reserva.getEspacio().getNombre());
                    factura.setNumeroFactura("RES-" + reserva.getIdReserva());

                    BigDecimal total = BigDecimal.ZERO;
                    if (reserva.getEspacio() != null) {
                        switch (reserva.getTipoReserva()) {
                            case HORAS -> total = reserva.getEspacio().getPrecioPorHora();
                            case DIAS -> total = reserva.getEspacio().getPrecioPorDia();
                            case MENSUAL -> total = reserva.getEspacio().getPrecioPorMes();
                        }
                    }
                    if (reserva.getEquipo() != null && reserva.getEquipo().getPrecioPorDia() != null) {
                        total = total.add(reserva.getEquipo().getPrecioPorDia());
                    }

                    factura.setMontoTotal(total);
                    facturaService.guardarFactura(factura);
                }
            }

            // 🔴 Si el pago se rechaza, cancelar la reserva asociada
            if (nuevoEstado == Pago.EstadoPago.RECHAZADO) {
                Reserva reserva = pago.getReserva();

                reserva.setEstado(Reserva.EstadoReserva.CANCELADA);
                reservaRepository.save(reserva);

                // (Opcional) enviar notificación
                Notificacion notificacion = new Notificacion();
                notificacion.setUsuario(reserva.getUsuario());
                notificacion.setMensaje("Tu reserva del espacio '" + reserva.getEspacio().getNombre() + "' ha sido cancelada por rechazo de pago.");
                notificacion.setTipoNotificacion(Notificacion.TipoNotificacion.AVISO);
                notificacion.setEstado(Notificacion.Estado.PENDIENTE);
                notificacion.setFechaNotificacion(LocalDateTime.now());
                notificacionService.enviar(notificacion);
            }


            return actualizado;
        });
    }
    public List<Pago> obtenerTodosPagos() {
        return pagoRepository.findAll();
    }


}
