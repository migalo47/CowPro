import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HttpService {
  static const String baseUrl = 'http://10.0.2.2:8080';
  static final storage = FlutterSecureStorage();

  static Future<String?> login(String correo, String contrasena) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'correo': correo,
          'contrasena': contrasena,
        }),
      );

      print('RESPUESTA LOGIN: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final token = json['token'];
        final correoDevuelto = json['correo'];

        await storage.write(key: 'token', value: token);
        await storage.write(key: 'correo', value: correoDevuelto); // ✅ guardar correo también

        return token;
      }
    } catch (e) {
      print('Error de login: $e');
    }
    return null;
  }


  static Future<List<dynamic>?> getEspaciosDisponibles() async {
    final token = await storage.read(key: 'token');
    if (token == null) {
      print('❌ No se encontró token en el storage');
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/espacios/disponibles'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Error al obtener espacios: ${response.statusCode}');
        print('Cuerpo de error: ${response.body}');
      }
    } catch (e) {
      print('Excepción en getEspaciosDisponibles: $e');
    }
    return null;
  }

  static Future<bool> registerUsuario(Map<String, dynamic> usuarioData) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/usuarios'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(usuarioData),
      );

      return res.statusCode == 200;
    } catch (e) {
      print('Error en registerUsuario: $e');
      return false;
    }
  }

  static Future<List<dynamic>?> getAllUsuarios() async {
    final token = await storage.read(key: 'token');
    if (token == null) return null;

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/usuarios'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      print('Error al obtener usuarios: $e');
    }
    return null;
  }

  static Future<bool> eliminarUsuario(int id) async {
    final token = await storage.read(key: 'token');
    if (token == null) return false;

    try {
      final res = await http.delete(
        Uri.parse('$baseUrl/usuarios/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return res.statusCode == 204;
    } catch (e) {
      print('Error eliminando usuario: $e');
      return false;
    }
  }
  static Future<bool> actualizarUsuario(int id, Map<String, dynamic> usuarioData) async {
    final token = await storage.read(key: 'token');
    if (token == null) return false;

    try {
      final res = await http.put(
        Uri.parse('$baseUrl/usuarios/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(usuarioData),
      );

      return res.statusCode == 200;
    } catch (e) {
      print('Error actualizando usuario: $e');
      return false;
    }
  }
  static Future<List<dynamic>?> getTodasReservas() async {
    final token = await storage.read(key: 'token');
    if (token == null) return null;

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/reservas'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      print('Error al obtener todas las reservas: $e');
    }
    return null;
  }
  static Future<List<dynamic>?> getReservasPorEstado(String estado) async {
    final token = await storage.read(key: 'token');
    if (token == null) return null;

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/reservas/estado/$estado'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      print('Error al obtener reservas por estado: $e');
    }
    return null;
  }

  static Future<bool> eliminarReserva(int id) async {
    final token = await storage.read(key: 'token');
    if (token == null) return false;

    try {
      final res = await http.delete(
        Uri.parse('$baseUrl/reservas/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return res.statusCode == 204;
    } catch (e) {
      print('Error al eliminar reserva: $e');
      return false;
    }
  }

  static Future<List<dynamic>?> getReservasPorUsuario(int idUsuario) async {
    final token = await storage.read(key: 'token');
    if (token == null) return null;

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/reservas/usuario/$idUsuario'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      print('Error al obtener reservas por usuario: $e');
    }
    return null;
  }


  static Future<bool> actualizarEstadoReserva(int id, String nuevoEstado) async {
    final token = await storage.read(key: 'token');
    if (token == null) return false;

    try {
      final res = await http.put(
        Uri.parse('$baseUrl/reservas/$id/estado?estado=$nuevoEstado'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return res.statusCode == 200;
    } catch (e) {
      print('Error al actualizar estado de reserva: $e');
      return false;
    }
  }
  static Future<bool> crearReserva(Map<String, dynamic> reservaData) async {
    final token = await storage.read(key: 'token');
    if (token == null) return false;

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/reservas'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(reservaData),
      );

      return res.statusCode == 200;
    } catch (e) {
      print('Error al crear reserva: $e');
      return false;
    }
  }
  static Future<List<dynamic>?> getTodosEspacios() async {
    final token = await storage.read(key: 'token');
    if (token == null) return null;

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/espacios'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      print('Error al obtener espacios: $e');
    }
    return null;
  }


// CREAR ESPACIO
  static Future<bool> crearEspacio(Map<String, dynamic> espacioData) async {
    final token = await storage.read(key: 'token');
    if (token == null) return false;

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/espacios'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(espacioData),
      );
      return res.statusCode == 200;
    } catch (e) {
      print('Error al crear espacio: $e');
      return false;
    }
  }

// ACTUALIZAR ESPACIO
  static Future<bool> actualizarEspacio(int id, Map<String, dynamic> espacioData) async {
    final token = await storage.read(key: 'token');
    if (token == null) return false;

    try {
      final res = await http.put(
        Uri.parse('$baseUrl/espacios/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(espacioData),
      );
      return res.statusCode == 200;
    } catch (e) {
      print('Error al actualizar espacio: $e');
      return false;
    }
  }

  static Future<bool> verificarDisponibilidadEspacio(int idEspacio, String inicio, String fin) async {
    final token = await storage.read(key: 'token');
    final res = await http.get(
      Uri.parse('$baseUrl/reservas/disponibilidad?id_espacio=$idEspacio&fecha_inicio=$inicio&fecha_fin=$fin'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return res.statusCode == 200 && jsonDecode(res.body) == true;
  }

  static Future<bool> verificarDisponibilidadEquipo(int idEquipo, String inicio, String fin) async {
    final token = await storage.read(key: 'token');
    final res = await http.get(
      Uri.parse('$baseUrl/reservas/disponibilidadEquipo?id_equipo=$idEquipo&inicio=$inicio&fin=$fin'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return res.statusCode == 200 && jsonDecode(res.body) == true;
  }

  static Future<List<String>?> getFechasNoDisponibles(int idEspacio) async {
    final token = await storage.read(key: 'token');
    final res = await http.get(
      Uri.parse('$baseUrl/reservas/fechasNoDisponibles?idEspacio=$idEspacio'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final List<dynamic> body = jsonDecode(res.body);
      return body.cast<String>();
    }
    return null;
  }



// ELIMINAR ESPACIO
  static Future<bool> eliminarEspacio(int id) async {
    final token = await storage.read(key: 'token');
    if (token == null) return false;

    try {
      final res = await http.delete(
        Uri.parse('$baseUrl/espacios/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return res.statusCode == 200;
    } catch (e) {
      print('Error al eliminar espacio: $e');
      return false;
    }
  }

// OBTENER ESPACIO POR ID (opcional)
  static Future<Map<String, dynamic>?> getEspacioPorId(int id) async {
    final token = await storage.read(key: 'token');
    if (token == null) return null;

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/espacios/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      print('Error al obtener espacio por ID: $e');
    }
    return null;
  }

// FILTRAR POR TIPO
  static Future<List<dynamic>?> getEspaciosPorTipo(String tipo) async {
    final token = await storage.read(key: 'token');
    if (token == null) return null;

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/espacios/tipo/$tipo'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      print('Error al filtrar espacios por tipo: $e');
    }
    return null;
  }
  static Future<List<dynamic>?> getTodosEquipos() async {
    final token = await storage.read(key: 'token');
    if (token == null) return null;

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/equipos'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      print('Error al obtener equipos: $e');
    }
    return null;
  }



// Crear equipo
  static Future<bool> crearEquipo(Map<String, dynamic> equipoData) async {
    final token = await storage.read(key: 'token');
    if (token == null) return false;

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/equipos'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(equipoData),
      );
      return res.statusCode == 200;
    } catch (e) {
      print('Error al crear equipo: $e');
      return false;
    }
  }

// Actualizar equipo
  static Future<bool> actualizarEquipo(int id, Map<String, dynamic> equipoData) async {
    final token = await storage.read(key: 'token');
    if (token == null) return false;

    try {
      final res = await http.put(
        Uri.parse('$baseUrl/equipos/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(equipoData),
      );
      return res.statusCode == 200;
    } catch (e) {
      print('Error al actualizar equipo: $e');
      return false;
    }
  }

// Eliminar equipo
  static Future<bool> eliminarEquipo(int id) async {
    final token = await storage.read(key: 'token');
    if (token == null) return false;

    try {
      final res = await http.delete(
        Uri.parse('$baseUrl/equipos/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return res.statusCode == 200 || res.statusCode == 204;
    } catch (e) {
      print('Error al eliminar equipo: $e');
      return false;
    }
  }

  static Future<List<dynamic>?> getTodasFacturas() async {
    final token = await storage.read(key: 'token');
    if (token == null) return null;

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/facturas'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      print('Error al obtener todas las facturas: $e');
    }
    return null;
  }


  static Future<dynamic> getFacturaPorReserva(int idReserva) async {
    final token = await storage.read(key: 'token');
    if (token == null) return null;

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/facturas/reserva/$idReserva'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        print('Error al obtener factura por reserva: ${res.statusCode}');
      }
    } catch (e) {
      print('Excepción al obtener factura por reserva: $e');
    }

    return null;
  }

  static Future<bool> cambiarEstadoFactura(int idFactura, String nuevoEstado) async {
    final token = await storage.read(key: 'token');
    if (token == null) return false;

    try {
      final res = await http.put(
        Uri.parse('$baseUrl/facturas/$idFactura/estado?estado=$nuevoEstado'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return res.statusCode == 200;
    } catch (e) {
      print('Error al cambiar estado factura: $e');
      return false;
    }
  }

  static Future<List<dynamic>?> getTodosPagos() async {
    final token = await storage.read(key: 'token');
    if (token == null) return null;

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/pagos'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      print('Error al obtener pagos: $e');
    }
    return null;
  }

  static Future<bool> cambiarEstadoPago(int idPago, String nuevoEstado) async {
    final token = await storage.read(key: 'token');
    if (token == null) return false;

    try {
      final res = await http.put(
        Uri.parse('$baseUrl/pagos/$idPago/$nuevoEstado'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      return res.statusCode == 200;
    } catch (e) {
      print('Error al cambiar estado de pago: $e');
      return false;
    }
  }
  static Future<List<dynamic>?> getTodasNotificaciones() async {
    final token = await storage.read(key: 'token');
    if (token == null) return null;

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/notificaciones'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      print('Error al obtener notificaciones: $e');
    }
    return null;
  }


  static Future<bool> cambiarEstadoNotificacion(int id, String estado) async {
    final token = await storage.read(key: 'token');
    if (token == null) return false;

    try {
      final res = await http.put(
        Uri.parse('$baseUrl/notificaciones/$id/estado?estado=$estado'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return res.statusCode == 200;
    } catch (e) {
      print('Error al cambiar estado de notificación: $e');
      return false;
    }
  }
  static Future<List<dynamic>?> getHistorialAccesos() async {
    final token = await storage.read(key: 'token');
    if (token == null) return null;

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/historial'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      print('Error al obtener historial de accesos: $e');
    }
    return null;
  }


// 🔥 Obtener historial por ID de usuario
  static Future<List<dynamic>?> getHistorialAccesosPorUsuario(int idUsuario) async {
    final token = await storage.read(key: 'token');
    if (token == null) return null;

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/historial/usuario/$idUsuario'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      print('Error historial usuario: $e');
    }
    return null;
  }

// 🔥 Obtener historial por ID de espacio
  static Future<List<dynamic>?> getHistorialAccesosPorEspacio(int idEspacio) async {
    final token = await storage.read(key: 'token');
    if (token == null) return null;

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/historial/espacio/$idEspacio'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      print('Error historial espacio: $e');
    }
    return null;
  }

  static Future<void> logout() async {
    await storage.deleteAll(); // Limpia token, correo y todo
  }

  static Future<Map<String, dynamic>?> getUsuarioActual() async {
    final token = await storage.read(key: 'token');
    final correo = await storage.read(key: 'correo');
    if (token == null || correo == null) return null;

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/usuarios/correo/$correo'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (e) {
      print('Error al obtener usuario actual: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getUsuarioPorCorreo(String correo) async {
    final token = await storage.read(key: 'token');
    if (token == null) return null;

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/usuarios/correo/$correo'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      print('Error al obtener usuario por correo: $e');
    }
    return null;
  }

  static Future<List<dynamic>?> getNotificacionesPorUsuario(int idUsuario) async {
    final token = await storage.read(key: 'token');
    if (token == null) return null;

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/notificaciones/usuario/$idUsuario'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        print('Error al obtener notificaciones por usuario: ${res.statusCode}');
      }
    } catch (e) {
      print('Excepción al obtener notificaciones: $e');
    }
    return null;
  }

  static Future<Map<String, List<String>>?> getFechasYHorasOcupadas(int idEspacio) async {
    final token = await storage.read(key: 'token');
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/reservas/fechasYHorasOcupadas?idEspacio=$idEspacio'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        return Map<String, List<String>>.from(json.decode(res.body).map(
              (key, value) => MapEntry(key, List<String>.from(value)),
        ));
      }
    } catch (e) {
      print('Error al obtener horas ocupadas: $e');
    }
    return null;
  }

  static Future<bool> enviarNotificacionAUsuario(Map<String, dynamic> data) async {
    final token = await storage.read(key: 'token');
    if (token == null) return false;

    final idUsuario = data['idUsuario'];
    final body = {
      "mensaje": data['mensaje'],
      "tipoNotificacion": data['tipoNotificacion'],
      "usuario": {"idUsuario": idUsuario}
    };

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/notificaciones'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      return res.statusCode == 201;
    } catch (e) {
      print('Error al enviar notificación a usuario: $e');
      return false;
    }
  }

  static Future<bool> enviarNotificacionATodos(Map<String, dynamic> data) async {
    final token = await storage.read(key: 'token');
    if (token == null) return false;

    final body = {
      "mensaje": data['mensaje'],
      "tipoNotificacion": data['tipoNotificacion'],
    };

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/notificaciones/todos'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      return res.statusCode == 200;
    } catch (e) {
      print('Error al enviar notificación a todos: $e');
      return false;
    }
  }




}
