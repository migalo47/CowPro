package com.example.sharechannel_backend.model;

import jakarta.persistence.*;


import java.math.BigDecimal;

@Entity
@Table(name = "espacios")
public class Espacio {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_espacio")
    private Integer idEspacio;

    private String nombre;
    private String descripcion;

    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_espacio")
    private TipoEspacio tipoEspacio;

    @Column(name = "precio_por_hora")
    private BigDecimal precioPorHora;

    @Column(name = "precio_por_dia")
    private BigDecimal precioPorDia;

    @Column(name = "precio_por_mes")
    private BigDecimal precioPorMes;

    private Boolean disponibilidad;

    @Column(name = "device_id")
    private String deviceId;

    @Column(name="imagen_url")
    private String imagenUrl;

    @Column(name = "capacidad")
    private Integer capacidad;

    public Integer getCapacidad() {
        return capacidad;
    }

    public void setCapacidad(Integer capacidad) {
        this.capacidad = capacidad;
    }



    public String getImagenUrl() {
        return imagenUrl;
    }

    public void setImagenUrl(String imagenUrl) {
        this.imagenUrl = imagenUrl;
    }


    public enum TipoEspacio {
        COWORKING, DESPACHO, SALA_REUNIONES, PLATO_TELEVISION, AULA
    }

    // Getters y Setters


    public Integer getIdEspacio() {
        return idEspacio;
    }

    public void setIdEspacio(Integer idEspacio) {
        this.idEspacio = idEspacio;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public TipoEspacio getTipoEspacio() {
        return tipoEspacio;
    }

    public void setTipoEspacio(TipoEspacio tipoEspacio) {
        this.tipoEspacio = tipoEspacio;
    }

    public BigDecimal getPrecioPorHora() {
        return precioPorHora;
    }

    public void setPrecioPorHora(BigDecimal precioPorHora) {
        this.precioPorHora = precioPorHora;
    }

    public Boolean getDisponibilidad() {
        return disponibilidad;
    }

    public void setDisponibilidad(Boolean disponibilidad) {
        this.disponibilidad = disponibilidad;
    }

    public BigDecimal getPrecioPorMes() {
        return precioPorMes;
    }

    public void setPrecioPorMes(BigDecimal precioPorMes) {
        this.precioPorMes = precioPorMes;
    }

    public BigDecimal getPrecioPorDia() {
        return precioPorDia;
    }

    public void setPrecioPorDia(BigDecimal precioPorDia) {
        this.precioPorDia = precioPorDia;
    }

    public String getDeviceId() {
        return deviceId;
    }

    public void setDeviceId(String deviceId) {
        this.deviceId = deviceId;
    }
}


