package com.example.sharechannel_backend.model;

import jakarta.persistence.*;


import java.time.LocalDateTime;

@Entity
@Table(name = "historial_accesos")
public class HistorialAcceso {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_historial")
    private Integer idHistorial;

    @ManyToOne
    @JoinColumn(name = "id_usuario")
    private Usuario usuario;

    @ManyToOne
    @JoinColumn(name = "id_espacio")
    private Espacio espacio;

    @ManyToOne
    @JoinColumn(name = "id_equipo")
    private Equipo equipo;

    @Column(name = "fecha_acceso")
    private LocalDateTime fechaAcceso;

    @Column(name = "hora_inicio")
    private LocalDateTime horaInicio;

    @Column(name = "hora_fin")
    private LocalDateTime horaFin;

    // Getters y Setters

    public Integer getIdHistorial() {
        return idHistorial;
    }

    public void setIdHistorial(Integer idHistorial) {
        this.idHistorial = idHistorial;
    }

    public Usuario getUsuario() {
        return usuario;
    }

    public void setUsuario(Usuario usuario) {
        this.usuario = usuario;
    }

    public Espacio getEspacio() {
        return espacio;
    }

    public void setEspacio(Espacio espacio) {
        this.espacio = espacio;
    }

    public Equipo getEquipo() {
        return equipo;
    }

    public void setEquipo(Equipo equipo) {
        this.equipo = equipo;
    }

    public LocalDateTime getFechaAcceso() {
        return fechaAcceso;
    }

    public void setFechaAcceso(LocalDateTime fechaAcceso) {
        this.fechaAcceso = fechaAcceso;
    }

    public LocalDateTime getHoraInicio() {
        return horaInicio;
    }

    public void setHoraInicio(LocalDateTime horaInicio) {
        this.horaInicio = horaInicio;
    }

    public LocalDateTime getHoraFin() {
        return horaFin;
    }

    public void setHoraFin(LocalDateTime horaFin) {
        this.horaFin = horaFin;
    }
}

