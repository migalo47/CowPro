package com.example.sharechannel_backend.service;


import com.example.sharechannel_backend.dto.CodigoTemporalRequest;
import com.example.sharechannel_backend.dto.CodigoTemporalResponse;
import com.example.sharechannel_backend.model.Equipo;
import com.example.sharechannel_backend.model.Espacio;
import com.example.sharechannel_backend.model.Pago;
import com.example.sharechannel_backend.model.Reserva;
import com.example.sharechannel_backend.model.Reserva.EstadoReserva;
import com.example.sharechannel_backend.repository.ReservaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class ReservaService {

    @Autowired
    private ReservaRepository reservaRepository;

    @Autowired
    private RestTemplate restTemplate; // Inyectamos para llamar APIs externas

    @Autowired
    private EspacioService espacioService; // Para obtener el espacio por ID

    @Autowired
    private EquipoService equipoService; // Para obtener el espacio por ID

    @Autowired
    private PagoService pagoService;

    public Reserva crearReserva(Reserva reserva) {
        String codigoTemporal = generarCodigoTemporal(reserva);
        reserva.setCodigoTemporal(codigoTemporal);
        reserva.setEstado(EstadoReserva.PENDIENTE); // Estado inicial

        Reserva reservaGuardada = reservaRepository.save(reserva);

        // ✅ Recuperar espacio completo
        Espacio espacio = espacioService.obtenerPorId(reserva.getEspacio().getIdEspacio()).orElseThrow();
        reservaGuardada.setEspacio(espacio);

        // Crear pago asociado en estado PENDIENTE
        Pago pago = new Pago();
        pago.setReserva(reservaGuardada);
        pago.setEstadoPago(Pago.EstadoPago.PENDIENTE);
        pago.setMetodoPago(Pago.MetodoPago.EFECTIVO);

        BigDecimal total = BigDecimal.ZERO;
        LocalDateTime inicio = reserva.getFechaInicio();
        LocalDateTime fin = reserva.getFechaFin();

        long horas = java.time.Duration.between(inicio, fin).toHours();
        long dias = java.time.Duration.between(inicio, fin).toDays();
        long meses = dias / 30;

        System.out.println("📅 Fecha inicio: " + inicio);
        System.out.println("📅 Fecha fin: " + fin);
        System.out.println("⏱️ Duración horas: " + horas);
        System.out.println("📆 Duración días: " + dias);
        System.out.println("🗓️ Duración meses: " + meses);

        Reserva.TipoReserva tipoDetectado;
        if (meses >= 1) {
            tipoDetectado = Reserva.TipoReserva.MENSUAL;
        } else if (dias >= 1) {
            tipoDetectado = Reserva.TipoReserva.DIAS;
        } else {
            tipoDetectado = Reserva.TipoReserva.HORAS;
        }
        reservaGuardada.setTipoReserva(tipoDetectado);
        System.out.println("📌 Tipo de reserva determinado: " + tipoDetectado);

        System.out.println("📂 Espacio ID: " + espacio.getIdEspacio());
        System.out.println("💰 Precio hora: " + espacio.getPrecioPorHora());
        System.out.println("💰 Precio día: " + espacio.getPrecioPorDia());
        System.out.println("💰 Precio mes: " + espacio.getPrecioPorMes());

        switch (tipoDetectado) {
            case HORAS -> {
                long h = Math.max(horas, 1);
                if (espacio.getPrecioPorHora() != null) {
                    total = espacio.getPrecioPorHora().multiply(BigDecimal.valueOf(h));
                    System.out.println("🧮 Total por horas (" + h + "): " + total);
                } else {
                    System.out.println("⚠️ Precio por hora es null");
                }
            }
            case DIAS -> {
                long d = Math.max(dias, 1);
                if (espacio.getPrecioPorDia() != null) {
                    total = espacio.getPrecioPorDia().multiply(BigDecimal.valueOf(d));
                    System.out.println("🧮 Total por días (" + d + "): " + total);
                } else {
                    System.out.println("⚠️ Precio por día es null");
                }
            }
            case MENSUAL -> {
                long m = Math.max(meses, 1);
                if (espacio.getPrecioPorMes() != null) {
                    total = espacio.getPrecioPorMes().multiply(BigDecimal.valueOf(m));
                    System.out.println("🧮 Total por meses (" + m + "): " + total);
                } else {
                    System.out.println("⚠️ Precio por mes es null");
                }
            }
        }

        if (reserva.getEquipo() != null && reserva.getEquipo().getPrecioPorDia() != null) {
            total = total.add(reserva.getEquipo().getPrecioPorDia());
        }

        System.out.println("💸 Total final del pago: " + total);

        pago.setMonto(total);
        pagoService.registrarPago(pago);

        return reservaGuardada;
    }



    public List<Reserva> listarReservas() {
        return reservaRepository.findAll();
    }

    public Optional<Reserva> obtenerReservaPorId(Integer id) {
        return reservaRepository.findById(id);
    }

    public List<Reserva> obtenerReservasPorUsuario(Integer idUsuario) {
        return reservaRepository.findByUsuarioIdUsuario(idUsuario);
    }

    public List<Reserva> obtenerReservasPorEstado(EstadoReserva estado) {
        return reservaRepository.findByEstado(estado);
    }

    public Reserva actualizarReserva(Reserva reserva) {
        return reservaRepository.save(reserva);
    }

    public void eliminarReserva(Integer id) {
        reservaRepository.deleteById(id);
    }


    public boolean verificarDisponibilidad(Integer idEspacio, LocalDateTime inicio, LocalDateTime fin) {
        List<Reserva> solapadas = reservaRepository.findReservasSolapadas(idEspacio, inicio, fin)
                .stream()
                .filter(r -> r.getEstado() == EstadoReserva.PENDIENTE || r.getEstado() == EstadoReserva.CONFIRMADA)
                .toList();

        Optional<Espacio> espacioOpt = espacioService.obtenerPorId(idEspacio);
        if (espacioOpt.isEmpty()) return false;

        Espacio espacio = espacioOpt.get();
        int capacidad = espacio.getCapacidad() != null ? espacio.getCapacidad() : 1;

        return solapadas.size() < capacidad;
    }


    public boolean verificarDisponibilidadEquipo(Integer idEquipo, LocalDateTime inicio, LocalDateTime fin) {
        if (idEquipo == null) return true; // Si no se seleccionó equipo, se considera válido

        List<Reserva> solapadas = reservaRepository.findReservasSolapadasPorEquipo(idEquipo, inicio, fin);
        Optional<Equipo> equipoOpt = equipoService.obtenerPorId(idEquipo);

        if (equipoOpt.isEmpty()) return false;

        Equipo equipo = equipoOpt.get();
        int cantidad = equipo.getCantidadDisponible() != null ? equipo.getCantidadDisponible() : 1;

        return solapadas.size() < cantidad;
    }


    private String generarCodigoTemporal(Reserva reserva) {
        System.out.println("🟡 Iniciando generación de código temporal...");

        try {
            Espacio espacio = espacioService.obtenerPorId(reserva.getEspacio().getIdEspacio())
                    .orElseThrow(() -> new IllegalArgumentException("❌ Espacio no encontrado"));

            String url = "http://cowpro-fastapi:8000/generar-password"; // Cámbiala si no estás en local

            System.out.println("🌐 URL de la API: " + url);
            System.out.println("📦 Device ID: " + espacio.getDeviceId());
            System.out.println("📅 Desde: " + reserva.getFechaInicio());
            System.out.println("📅 Hasta: " + reserva.getFechaFin());

            CodigoTemporalRequest request = new CodigoTemporalRequest();
            request.setDevice_id(espacio.getDeviceId());
            request.setDesde(reserva.getFechaInicio().toString());
            request.setHasta(reserva.getFechaFin().toString());

            HttpEntity<CodigoTemporalRequest> entity = new HttpEntity<>(request);

            ResponseEntity<CodigoTemporalResponse> response = restTemplate.postForEntity(
                    url, entity, CodigoTemporalResponse.class
            );

            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                String codigo = response.getBody().getCodigo();
                System.out.println("✅ Código temporal recibido: " + codigo);
                return codigo;
            } else {
                System.out.println("⚠️ La API respondió sin código o con error: " + response.getStatusCode());
            }

        } catch (Exception e) {
            System.out.println("❌ Error generando código temporal: " + e.getMessage());
            e.printStackTrace();
        }

        return "ERROR-CODIGO";
    }


    public List<LocalDate> obtenerFechasSinCapacidadDisponible(Integer idEspacio) {
        Optional<Espacio> espacioOpt = espacioService.obtenerPorId(idEspacio);
        if (espacioOpt.isEmpty()) return List.of();

        Espacio espacio = espacioOpt.get();
        int capacidad = espacio.getCapacidad() != null ? espacio.getCapacidad() : 1;

        List<Reserva> reservas = reservaRepository.findByEspacioIdEspacio(idEspacio);
        Map<LocalDate, Long> conteoPorDia = new HashMap<>();

        for (Reserva r : reservas) {
            // 🔒 Ignorar reservas canceladas o completadas
            if (r.getEstado() == EstadoReserva.CANCELADA || r.getEstado() == EstadoReserva.COMPLETADA) {
                continue;
            }

            LocalDate inicio = r.getFechaInicio().toLocalDate();
            LocalDate fin = r.getFechaFin().toLocalDate();

            for (LocalDate date = inicio; !date.isAfter(fin); date = date.plusDays(1)) {
                conteoPorDia.put(date, conteoPorDia.getOrDefault(date, 0L) + 1);
            }
        }

        return conteoPorDia.entrySet().stream()
                .filter(e -> e.getValue() >= capacidad)
                .map(Map.Entry::getKey)
                .toList();
    }


    public Map<String, List<String>> obtenerHorasOcupadasPorFecha(Integer idEspacio) {
        List<Reserva> reservas = reservaRepository.findByEspacioIdEspacio(idEspacio);

        Map<String, List<String>> ocupadasPorFecha = new HashMap<>();

        for (Reserva r : reservas) {
            // 🔒 Ignorar reservas canceladas o completadas
            if (r.getEstado() == EstadoReserva.CANCELADA || r.getEstado() == EstadoReserva.COMPLETADA) {
                continue;
            }

            LocalDate fechaInicio = r.getFechaInicio().toLocalDate();
            LocalDate fechaFin = r.getFechaFin().toLocalDate();
            LocalDate fecha = fechaInicio;

            while (!fecha.isAfter(fechaFin)) {
                String fechaStr = fecha.toString();

                LocalDateTime inicio = r.getFechaInicio();
                LocalDateTime fin = r.getFechaFin();

                int horaInicio = (fecha.equals(fechaInicio)) ? inicio.getHour() : 8;
                int horaFin = (fecha.equals(fechaFin)) ? fin.getHour() : 21;

                List<String> horas = ocupadasPorFecha.getOrDefault(fechaStr, new ArrayList<>());
                for (int h = horaInicio; h < horaFin; h++) {
                    horas.add(String.format("%02d:00", h));
                }

                ocupadasPorFecha.put(fechaStr, horas);
                fecha = fecha.plusDays(1);
            }
        }

        return ocupadasPorFecha;
    }


    public Map<String, List<String>> obtenerHorasOcupadasPorDia(Integer idEspacio) {
        List<Reserva> reservas = reservaRepository.findByEspacioIdEspacio(idEspacio);

        Map<String, List<String>> mapa = new HashMap<>();

        for (Reserva reserva : reservas) {
            // 🔒 Ignorar reservas canceladas o completadas
            if (reserva.getEstado() == EstadoReserva.CANCELADA || reserva.getEstado() == EstadoReserva.COMPLETADA) {
                continue;
            }

            LocalDate fecha = reserva.getFechaInicio().toLocalDate();
            LocalDate fechaFin = reserva.getFechaFin().toLocalDate();
            LocalTime horaInicio = reserva.getFechaInicio().toLocalTime();
            LocalTime horaFin = reserva.getFechaFin().toLocalTime();

            for (LocalDate dia = fecha; !dia.isAfter(fechaFin); dia = dia.plusDays(1)) {
                String clave = dia.toString();
                List<String> ocupadas = mapa.getOrDefault(clave, new ArrayList<>());

                int inicio = (dia.equals(fecha)) ? horaInicio.getHour() : 8;
                int fin = (dia.equals(fechaFin)) ? horaFin.getHour() : 21;

                for (int h = inicio; h < fin; h++) {
                    if (h >= 8 && h < 21) {
                        ocupadas.add(String.format("%02d:00", h));
                    }
                }

                mapa.put(clave, ocupadas);
            }
        }

        return mapa;
    }



}
