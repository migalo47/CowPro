package com.example.sharechannel_backend.dto;

public class LoginResponse {
    private String mensaje;
    private Integer idUsuario;
    private String nombre;
    private String correo; // <-- AÑADIR
    private String token;

    // Constructor
    public LoginResponse(String mensaje, Integer idUsuario, String nombre, String correo, String token) {
        this.mensaje = mensaje;
        this.idUsuario = idUsuario;
        this.nombre = nombre;
        this.correo = correo;
        this.token = token;
    }

    // Getters y Setters
    public String getMensaje() { return mensaje; }
    public void setMensaje(String mensaje) { this.mensaje = mensaje; }

    public Integer getIdUsuario() { return idUsuario; }
    public void setIdUsuario(Integer idUsuario) { this.idUsuario = idUsuario; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }

    public String getCorreo() {
        return correo;
    }

    public void setCorreo(String correo) {
        this.correo = correo;
    }
}
