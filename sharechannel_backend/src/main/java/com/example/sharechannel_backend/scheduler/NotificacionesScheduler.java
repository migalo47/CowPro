package com.example.sharechannel_backend.scheduler;

import com.example.sharechannel_backend.model.Notificacion;
import com.example.sharechannel_backend.model.Reserva;
import com.example.sharechannel_backend.model.Notificacion.TipoNotificacion;
import com.example.sharechannel_backend.service.NotificacionService;
import com.example.sharechannel_backend.service.ReservaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.List;

@Component
public class NotificacionesScheduler {

    @Autowired
    private ReservaService reservaService;

    @Autowired
    private NotificacionService notificacionService;


    @Scheduled(cron = "0 0 * * * *")
    public void generarNotificacionesProgramadas() {
        System.out.println("⏰ [SCHEDULER] Ejecutando verificación de notificaciones programadas...");

        List<Reserva> reservas = reservaService.listarReservas();
        LocalDateTime ahora = LocalDateTime.now();

        for (Reserva reserva : reservas) {
            if (reserva.getEstado() != Reserva.EstadoReserva.CONFIRMADA) continue;

            LocalDateTime inicio = reserva.getFechaInicio();
            LocalDateTime fin = reserva.getFechaFin();
            Integer idUsuario = reserva.getUsuario().getIdUsuario();

            // ----- Recordatorio 24h antes del inicio -----
            if (ahora.isAfter(inicio.minusHours(25)) && ahora.isBefore(inicio.minusHours(23))) {
                String mensaje = "📝 Recuerda que tienes una reserva en el aula " +
                        reserva.getEspacio().getNombre() + " el " + inicio.toLocalDate() +
                        " a las " + inicio.toLocalTime().withSecond(0).withNano(0);
                if (!notificacionService.yaExisteNotificacion(idUsuario, TipoNotificacion.RECORDATORIO.name(), mensaje)) {
                    Notificacion noti = new Notificacion();
                    noti.setUsuario(reserva.getUsuario());
                    noti.setTipoNotificacion(TipoNotificacion.RECORDATORIO);
                    noti.setMensaje(mensaje);
                    notificacionService.enviar(noti);
                }
            }

            // ----- Aviso 1h antes de finalizar -----
            if (ahora.isAfter(fin.minusHours(2)) && ahora.isBefore(fin.minusMinutes(30))) {
                String mensaje = "⚠️ Tu reserva del aula " + reserva.getEspacio().getNombre() +
                        " termina a las " + fin.toLocalTime().withSecond(0).withNano(0);
                if (!notificacionService.yaExisteNotificacion(idUsuario, TipoNotificacion.AVISO.name(), mensaje)) {
                    Notificacion noti = new Notificacion();
                    noti.setUsuario(reserva.getUsuario());
                    noti.setTipoNotificacion(TipoNotificacion.AVISO);
                    noti.setMensaje(mensaje);
                    notificacionService.enviar(noti);
                }
            }
        }
    }
}
