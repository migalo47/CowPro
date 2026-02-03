package com.example.sharechannel_backend.model;



import jakarta.persistence.*;
import java.math.BigDecimal;

@Entity
@Table(name = "equipos")
public class Equipo {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_equipo")
    private Integer idEquipo;

    private String nombre;
    private String descripcion;

    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_equipo")
    private TipoEquipo tipoEquipo;

    @Column(name = "precio_por_dia")
    private BigDecimal precioPorDia;

    private Boolean disponibilidad;


    public enum TipoEquipo {
        PROYECTOR, CAMARA, MICROFONO, COMPUTADORA, OTRO
    }

    @Column(name = "imagen_url")
    private String imagenUrl;

    @Column(name = "cantidad_disponible")
    private Integer cantidadDisponible;

    public Integer getCantidadDisponible() {
        return cantidadDisponible;
    }

    public void setCantidadDisponible(Integer cantidadDisponible) {
        this.cantidadDisponible = cantidadDisponible;
    }




    // Getters y Setters
    public Integer getIdEquipo() {
        return idEquipo;
    }

    public void setIdEquipo(Integer idEquipo) {
        this.idEquipo = idEquipo;
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

    public TipoEquipo getTipoEquipo() {
        return tipoEquipo;
    }

    public void setTipoEquipo(TipoEquipo tipoEquipo) {
        this.tipoEquipo = tipoEquipo;
    }

    public BigDecimal getPrecioPorDia() {
        return precioPorDia;
    }

    public void setPrecioPorDia(BigDecimal precioPorDia) {
        this.precioPorDia = precioPorDia;
    }

    public Boolean getDisponibilidad() {
        return disponibilidad;
    }

    public void setDisponibilidad(Boolean disponibilidad) {
        this.disponibilidad = disponibilidad;
    }

    public String getImagenUrl() {
        return imagenUrl;
    }

    public void setImagenUrl(String imagenUrl) {
        this.imagenUrl = imagenUrl;
    }
}

