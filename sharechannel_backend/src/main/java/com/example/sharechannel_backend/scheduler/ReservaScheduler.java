package com.example.sharechannel_backend.scheduler;

import com.example.sharechannel_backend.model.Reserva;
import com.example.sharechannel_backend.model.Reserva.EstadoReserva;
import com.example.sharechannel_backend.service.ReservaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.List;

@Component
public class ReservaScheduler {

    @Autowired
    private ReservaService reservaService;

    // Ejecuta cada hora
    @Scheduled(cron = "0 0 * * * *")
    public void actualizarReservasCompletadas() {
        System.out.println("\u23F0 [SCHEDULER] Verificando reservas finalizadas...");

        List<Reserva> reservas = reservaService.listarReservas();
        LocalDateTime ahora = LocalDateTime.now();

        for (Reserva reserva : reservas) {
            if (reserva.getEstado() == EstadoReserva.CONFIRMADA &&
                    reserva.getFechaFin().isBefore(ahora)) {

                reserva.setEstado(EstadoReserva.COMPLETADA);
                reservaService.actualizarReserva(reserva);

                System.out.println("\u2705 Reserva marcada como COMPLETADA: ID " + reserva.getIdReserva());
            }
        }
    }
}
