package com.example.sharechannel_backend.repository;

import com.example.sharechannel_backend.model.Notificacion;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface NotificacionRepository extends JpaRepository<Notificacion, Integer> {
    List<Notificacion> findByUsuarioIdUsuario(Integer idUsuario);
}
