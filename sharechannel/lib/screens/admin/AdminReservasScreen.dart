import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/http_service.dart';

class AdminReservasScreen extends StatefulWidget {
  @override
  _AdminReservasScreenState createState() => _AdminReservasScreenState();
}

class _AdminReservasScreenState extends State<AdminReservasScreen> {
  List<dynamic>? reservas;
  bool loading = true;
  String estadoFiltro = "TODOS";
  final TextEditingController _buscarCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    cargarReservas();
  }

  Future<void> cargarReservas() async {
    setState(() => loading = true);
    final data = estadoFiltro == "TODOS"
        ? await HttpService.getTodasReservas()
        : await HttpService.getReservasPorEstado(estadoFiltro);
    setState(() {
      reservas = data;
      loading = false;
    });
  }

  void eliminarReserva(int id) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Eliminar Reserva"),
        content: Text("¿Estás seguro que deseas eliminar esta reserva?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancelar")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text("Eliminar")),
        ],
      ),
    );

    if (confirm == true) {
      final success = await HttpService.eliminarReserva(id);
      if (success) cargarReservas();
    }
  }

  void cambiarEstado(int id, String nuevoEstado) async {
    final estadoValido = ["PENDIENTE", "CONFIRMADA", "CANCELADA", "COMPLETADA"];
    if (!estadoValido.contains(nuevoEstado)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Estado no válido: $nuevoEstado")),
      );
      return;
    }
    final success = await HttpService.actualizarEstadoReserva(id, nuevoEstado);
    if (success) cargarReservas();
  }

  List<dynamic> get reservasFiltradas {
    final query = _buscarCtrl.text.toLowerCase();
    return reservas!.where((r) {
      final nombre = r['usuario']?['nombre']?.toLowerCase() ?? '';
      final correo = r['usuario']?['correo']?.toLowerCase() ?? '';
      return nombre.contains(query) || correo.contains(query);
    }).toList();
  }

  void abrirFormularioCrearReserva() async {
    final usuarios = await HttpService.getAllUsuarios();
    final espacios = await HttpService.getTodosEspacios();
    final equipos = await HttpService.getTodosEquipos();

    dynamic usuarioSeleccionado;
    dynamic espacioSeleccionado;
    dynamic equipoSeleccionado;
    String tipoReserva = 'HORAS';
    DateTime? fechaInicio;
    DateTime? fechaFin;
    String? horaInicio;
    String? horaFin;

    Map<String, List<String>> horasOcupadasPorDia = {};
    Set<DateTime> fechasNoDisponibles = {};

    Future<void> cargarFechasYHoras(int idEspacio) async {
      final data = await HttpService.getFechasYHorasOcupadas(idEspacio);
      if (data != null) {
        horasOcupadasPorDia = data;
        fechasNoDisponibles = data.entries
            .where((entry) => (entry.value.toSet().length >= 13))
            .map((e) => DateTime.parse(e.key))
            .toSet();
      }
    }

    List<String> filtrarHorasDisponibles(DateTime dia, {bool paraFin = false}) {
      final diaKey = DateFormat('yyyy-MM-dd').format(dia);
      final ocupadas = horasOcupadasPorDia[diaKey]?.toSet() ?? {};
      final baseHoras = List.generate(14, (i) => '${(8 + i).toString().padLeft(2, '0')}:00');

      final primeraOcupada = ocupadas
          .map((h) => int.parse(h.split(":")[0]))
          .fold<int?>(null, (prev, h) => prev == null || h < prev ? h : prev);

      var filtradas = baseHoras.where((h) {
        final hora = int.parse(h.split(":")[0]);
        if (!paraFin && hora == 21) return false;
        if (paraFin && hora == 8) return false;
        if (paraFin && hora == 21 && ocupadas.contains("20:00")) return false;

        if (paraFin) {
          return !ocupadas.contains(h) || (primeraOcupada != null && hora == primeraOcupada);
        }
        return !ocupadas.contains(h);
      }).toList();

      if (paraFin && horaInicio != null) {
        final intInicio = int.parse(horaInicio!.split(':')[0]);
        filtradas = filtradas.where((h) => int.parse(h.split(':')[0]) > intInicio).toList();
      }

      return filtradas;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text("Nueva Reserva"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Autocomplete<Map<String, dynamic>>(
                  displayStringForOption: (option) => "${option['nombre']} - ${option['correo']}",
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text == '') {
                      return const Iterable<Map<String, dynamic>>.empty();
                    }
                    return usuarios!.where((u) {
                      final query = textEditingValue.text.toLowerCase();
                      return u['nombre'].toLowerCase().contains(query) || u['correo'].toLowerCase().contains(query);
                    }).cast<Map<String, dynamic>>();
                  },
                  onSelected: (selected) => setState(() => usuarioSeleccionado = selected),
                  fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(labelText: "Seleccionar Usuario"),
                    );
                  },
                ),
                SizedBox(height: 10),
                DropdownButtonFormField(
                  isExpanded: true,
                  value: espacioSeleccionado,
                  hint: Text("Seleccionar Espacio"),
                  items: espacios?.map<DropdownMenuItem>((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e['nombre']),
                  )).toList(),
                  onChanged: (val) async {
                    espacioSeleccionado = val;
                    await cargarFechasYHoras(espacioSeleccionado['idEspacio']);
                    setState(() {});
                  },
                ),
                if (espacioSeleccionado != null)
                  ElevatedButton(
                    onPressed: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 90)),
                        selectableDayPredicate: (day, _, __) => !fechasNoDisponibles.contains(day),
                      );
                      if (picked != null) {
                        setState(() {
                          fechaInicio = picked.start;
                          fechaFin = picked.end;
                          horaInicio = null;
                          horaFin = null;
                        });
                      }
                    },
                    child: Text(fechaInicio == null || fechaFin == null
                        ? "Seleccionar Día Disponible"
                        : 'Del ${DateFormat('dd/MM/yyyy').format(fechaInicio!)} al ${DateFormat('dd/MM/yyyy').format(fechaFin!)}'),
                  ),
                if (fechaInicio != null)
                  Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: horaInicio,
                        hint: Text("Hora Inicio"),
                        items: filtrarHorasDisponibles(fechaInicio!, paraFin: false)
                            .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                            .toList(),
                        onChanged: (val) => setState(() => horaInicio = val),
                      ),
                      DropdownButtonFormField<String>(
                        value: horaFin,
                        hint: Text("Hora Fin"),
                        items: filtrarHorasDisponibles(fechaInicio!, paraFin: true)
                            .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                            .toList(),
                        onChanged: (val) => setState(() => horaFin = val),
                      ),
                    ],
                  ),
                SizedBox(height: 10),
                DropdownButtonFormField(
                  isExpanded: true,
                  value: equipoSeleccionado,
                  hint: Text("Seleccionar Equipo (opcional)"),
                  items: equipos?.map<DropdownMenuItem>((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e['nombre']),
                  )).toList(),
                  onChanged: (val) => setState(() => equipoSeleccionado = val),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancelar")),
            ElevatedButton(
              onPressed: () async {
                if (usuarioSeleccionado == null || espacioSeleccionado == null || fechaInicio == null || fechaFin == null || horaInicio == null || horaFin == null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Completa todos los campos obligatorios.")));
                  return;
                }

                final DateTime inicio = DateTime.parse('${DateFormat('yyyy-MM-dd').format(fechaInicio!)}T$horaInicio:00');
                final DateTime fin = DateTime.parse('${DateFormat('yyyy-MM-dd').format(fechaFin!)}T$horaFin:00');

                if (!inicio.isBefore(fin)) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("La hora de inicio debe ser anterior a la de fin")));
                  return;
                }

                final disponibleEspacio = await HttpService.verificarDisponibilidadEspacio(
                  espacioSeleccionado['idEspacio'],
                  inicio.toIso8601String(),
                  fin.toIso8601String(),
                );
                if (!disponibleEspacio) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ El espacio no está disponible.")));
                  return;
                }

                if (equipoSeleccionado != null) {
                  final disponibleEquipo = await HttpService.verificarDisponibilidadEquipo(
                    equipoSeleccionado['idEquipo'],
                    inicio.toIso8601String(),
                    fin.toIso8601String(),
                  );
                  if (!disponibleEquipo) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ El equipo no está disponible.")));
                    return;
                  }
                }

                final nuevaReserva = {
                  'usuario': { 'idUsuario': usuarioSeleccionado['idUsuario'] },
                  'espacio': { 'idEspacio': espacioSeleccionado['idEspacio'] },
                  'equipo': equipoSeleccionado != null ? { 'idEquipo': equipoSeleccionado['idEquipo'] } : null,
                  'tipoReserva': 'HORAS',
                  'estado': 'PENDIENTE',
                  'fechaInicio': inicio.toIso8601String(),
                  'fechaFin': fin.toIso8601String(),
                };

                final ok = await HttpService.crearReserva(nuevaReserva);
                if (ok) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("✅ Reserva creada exitosamente")));
                  cargarReservas();
                }
              },
              child: Text("Guardar"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estados = ["TODOS", "PENDIENTE", "CONFIRMADA", "CANCELADA", "COMPLETADA"];

    return Scaffold(
      appBar: AppBar(title: Text('Reservas'), actions: [
        IconButton(icon: Icon(Icons.refresh), onPressed: cargarReservas),
      ]),
      body: Column(
        children: [
          // 🔍 Campo de búsqueda
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _buscarCtrl,
              decoration: InputDecoration(labelText: "Buscar por nombre o correo"),
              onChanged: (value) => setState(() {}),
            ),
          ),
          // 🎛️ Filtro + botón Agregar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: estadoFiltro,
                    items: estados.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) {
                      setState(() => estadoFiltro = val!);
                      cargarReservas();
                    },
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: abrirFormularioCrearReserva,
                  icon: Icon(Icons.add),
                  label: Text("Agregar Reserva"),
                ),
              ],
            ),
          ),
          Expanded(
            child: loading
                ? Center(child: CircularProgressIndicator())
                : reservas == null
                ? Center(child: Text("Error al cargar reservas."))
                : reservasFiltradas.isEmpty
                ? Center(child: Text("No hay reservas registradas."))
                : ListView.builder(
              itemCount: reservasFiltradas.length,
              padding: EdgeInsets.symmetric(horizontal: 12),
              itemBuilder: (context, index) {
                final r = reservasFiltradas[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Usuario: ${r['usuario']?['nombre'] ?? 'No disponible'}",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 4),
                        Text("Correo: ${r['usuario']?['correo'] ?? 'No disponible'}"),
                        SizedBox(height: 4),
                        Text("Espacio: ${r['espacio']?['nombre'] ?? 'No disponible'}"),
                        SizedBox(height: 4),
                        Text("Tipo: ${r['tipoReserva']} | Estado: ${r['estado']}"),
                        SizedBox(height: 4),
                        Text("Inicio: ${r['fechaInicio'] ?? '-'}"),
                        Text("Fin: ${r['fechaFin'] ?? '-'}"),
                        if (r['codigoTemporal'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text("Código: ${r['codigoTemporal']}",
                                style: TextStyle(color: Colors.green)),
                          ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            PopupMenuButton<String>(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onSelected: (estado) => cambiarEstado(r['idReserva'], estado),
                              itemBuilder: (ctx) => estados
                                  .where((e) => e != "TODOS")
                                  .map((e) => PopupMenuItem(value: e, child: Text(e)))
                                  .toList(),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => eliminarReserva(r['idReserva']),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
