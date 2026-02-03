package com.example.sharechannel_backend.dto;

public class CodigoTemporalRequest {
    private String device_id;
    private String desde;
    private String hasta;

    // Getters y setters
    public String getDevice_id() {
        return device_id;
    }

    public void setDevice_id(String device_id) {
        this.device_id = device_id;
    }

    public String getDesde() {
        return desde;
    }

    public void setDesde(String desde) {
        this.desde = desde;
    }

    public String getHasta() {
        return hasta;
    }

    public void setHasta(String hasta) {
        this.hasta = hasta;
    }
}
