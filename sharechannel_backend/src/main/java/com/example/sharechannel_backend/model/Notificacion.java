package com.example.sharechannel_backend.model;

import jakarta.persistence.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "notificaciones")

public class Notificacion {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_notificacion")
    private Integer idNotificacion;

    @ManyToOne
    @JoinColumn(name = "id_usuario")
    private Usuario usuario;

    private String mensaje;

    @Enumerated(EnumType.STRING)
    private TipoNotificacion tipoNotificacion;

    @Enumerated(EnumType.STRING)
    private Estado estado;

    @Column(name = "fecha_notificacion")
    private LocalDateTime fechaNotificacion;

    public enum TipoNotificacion{
        CONFIRMACION, RECORDATORIO, ACCESO, PROMOCION, AVISO;
    }
    public enum Estado{
        PENDIENTE, ENVIADA
    }

    //Getter and setters
    public Integer getIdNotificacion() {
        return idNotificacion;
    }

    public void setIdNotificacion(Integer idNotificacion) {
        this.idNotificacion = idNotificacion;
    }

    public Usuario getUsuario() {
        return usuario;
    }

    public void setUsuario(Usuario usuario) {
        this.usuario = usuario;
    }

    public String getMensaje() {
        return mensaje;
    }

    public void setMensaje(String mensaje) {
        this.mensaje = mensaje;
    }

    public TipoNotificacion getTipoNotificacion() {
        return tipoNotificacion;
    }

    public void setTipoNotificacion(TipoNotificacion tipoNotificacion) {
        this.tipoNotificacion = tipoNotificacion;
    }

    public Estado getEstado() {
        return estado;
    }

    public void setEstado(Estado estado) {
        this.estado = estado;
    }

    public LocalDateTime getFechaNotificacion() {
        return fechaNotificacion;
    }

    public void setFechaNotificacion(LocalDateTime fechaNotificacion) {
        this.fechaNotificacion = fechaNotificacion;
    }
}
