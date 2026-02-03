package com.example.sharechannel_backend.service;

import com.example.sharechannel_backend.model.Notificacion;
import com.example.sharechannel_backend.model.Usuario;
import com.example.sharechannel_backend.repository.NotificacionRepository;
import com.example.sharechannel_backend.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class NotificacionService {

    @Autowired
    private NotificacionRepository notificacionRepository;

    @Autowired
    private UsuarioRepository usuarioRepository;

    public Notificacion enviar(Notificacion notificacion) {
        notificacion.setEstado(Notificacion.Estado.PENDIENTE);
        notificacion.setFechaNotificacion(LocalDateTime.now());
        return notificacionRepository.save(notificacion);
    }

    public List<Notificacion> obtenerPorUsuario(Integer idUsuario) {
        return notificacionRepository.findByUsuarioIdUsuario(idUsuario);
    }


    public void enviarATodos(Notificacion notificacion) {
        List<Usuario> usuarios = usuarioRepository.findAll();
        for (Usuario usuario : usuarios) {
            Notificacion copia = new Notificacion();
            copia.setUsuario(usuario);
            copia.setMensaje(notificacion.getMensaje());
            copia.setTipoNotificacion(notificacion.getTipoNotificacion());
            copia.setEstado(Notificacion.Estado.PENDIENTE);
            copia.setFechaNotificacion(LocalDateTime.now());
            notificacionRepository.save(copia);
        }
    }


    public Optional<Notificacion> cambiarEstado(Integer id, Notificacion.Estado nuevoEstado) {
        return notificacionRepository.findById(id).map(notificacion -> {
            notificacion.setEstado(nuevoEstado);
            return notificacionRepository.save(notificacion);
        });
    }

    public List<Notificacion> obtenerTodas() {
        return notificacionRepository.findAll();
    }

    public boolean yaExisteNotificacion(Integer idUsuario, String tipo, String contenidoExacto) {
        List<Notificacion> existentes = notificacionRepository.findByUsuarioIdUsuario(idUsuario);
        return existentes.stream().anyMatch(n ->
                n.getTipoNotificacion().name().equalsIgnoreCase(tipo) &&
                        n.getMensaje() != null &&
                        n.getMensaje().equals(contenidoExacto)
        );
    }
}
