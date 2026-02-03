import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/http_service.dart';

class AdminNotificacionesScreen extends StatefulWidget {
  @override
  _AdminNotificacionesScreenState createState() => _AdminNotificacionesScreenState();
}

class _AdminNotificacionesScreenState extends State<AdminNotificacionesScreen> {
  List<dynamic>? notificaciones;
  List<dynamic>? todasNotificaciones;
  List<dynamic> todosUsuarios = [];
  final TextEditingController _buscarCtrl = TextEditingController();
  String filtroEstado = 'Todos';
  String filtroTipo = 'Todos';
  DateTime? fechaDesde;
  DateTime? fechaHasta;
  bool loading = true;

  final List<String> tipos = ['Todos', 'CONFIRMACION', 'RECORDATORIO', 'ACCESO', 'PROMOCION', 'AVISO'];
  final List<String> estados = ['Todos', 'PENDIENTE', 'ENVIADA'];

  @override
  void initState() {
    super.initState();
    cargarNotificaciones();
    cargarUsuarios();
  }

  Future<void> cargarUsuarios() async {
    final usuarios = await HttpService.getAllUsuarios();
    if (usuarios != null) {
      setState(() {
        todosUsuarios = usuarios;
      });
      print('✅ Usuarios cargados: ${usuarios.length}');
    } else {
      print('❌ Error al cargar usuarios');
    }
  }

  Future<void> cargarNotificaciones() async {
    setState(() => loading = true);
    final data = await HttpService.getTodasNotificaciones();
    setState(() {
      todasNotificaciones = data;
      notificaciones = data;
      loading = false;
    });
  }

  void aplicarFiltros() {
    final query = _buscarCtrl.text.toLowerCase();
    setState(() {
      notificaciones = todasNotificaciones?.where((n) {
        final mensaje = n['mensaje']?.toLowerCase() ?? '';
        final nombre = n['usuario']?['nombre']?.toLowerCase() ?? '';
        final correo = n['usuario']?['correo']?.toLowerCase() ?? '';
        final estado = n['estado'] ?? '';
        final tipo = n['tipoNotificacion'] ?? '';
        final fechaStr = n['fechaNotificacion'];
        final fecha = fechaStr != null ? DateTime.tryParse(fechaStr) : null;

        final coincideTexto = mensaje.contains(query) || nombre.contains(query) || correo.contains(query);
        final coincideEstado = filtroEstado == 'Todos' || estado == filtroEstado;
        final coincideTipo = filtroTipo == 'Todos' || tipo == filtroTipo;
        final coincideFecha = (fechaDesde == null || (fecha != null && !fecha.isBefore(fechaDesde!))) &&
            (fechaHasta == null || (fecha != null && !fecha.isAfter(fechaHasta!)));

        return coincideTexto && coincideEstado && coincideTipo && coincideFecha;
      }).toList();
    });
  }

  void cambiarEstadoNotificacion(int id) async {
    final nuevoEstado = await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text("Cambiar estado"),
        children: estados.where((e) => e != 'Todos').map((e) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, e),
            child: Text(e),
          );
        }).toList(),
      ),
    );

    if (nuevoEstado != null) {
      final success = await HttpService.cambiarEstadoNotificacion(id, nuevoEstado);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Estado actualizado')));
        cargarNotificaciones();
      }
    }
  }

  void crearNotificacionDialog() {
    final TextEditingController mensajeCtrl = TextEditingController();
    final TextEditingController userAutocompleteCtrl = TextEditingController();
    String tipoSeleccionado = 'CONFIRMACION';
    bool enviarATodos = true;
    List<Map<String, dynamic>> usuariosSeleccionados = [];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text("Nueva notificación"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: mensajeCtrl,
                  decoration: InputDecoration(labelText: "Mensaje"),
                ),
                SizedBox(height: 12),
                DropdownButton<String>(
                  value: tipoSeleccionado,
                  isExpanded: true,
                  onChanged: (val) => setState(() => tipoSeleccionado = val!),
                  items: tipos.where((e) => e != 'Todos').map((tipo) {
                    return DropdownMenuItem(value: tipo, child: Text(tipo));
                  }).toList(),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                      value: enviarATodos,
                      onChanged: (v) => setState(() {
                        enviarATodos = v!;
                        if (v) usuariosSeleccionados.clear();
                      }),
                    ),
                    Text("Enviar a todos"),
                  ],
                ),
                if (!enviarATodos)
                  Column(
                    children: [
                      Autocomplete<Map<String, dynamic>>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          final input = textEditingValue.text.toLowerCase();

                          if (input.isEmpty || todosUsuarios.isEmpty) {
                            return const Iterable<Map<String, dynamic>>.empty();
                          }

                          return todosUsuarios.where((usuario) {
                            final correo = (usuario['correo'] ?? '').toLowerCase();
                            final nombre = (usuario['nombre'] ?? '').toLowerCase();
                            return correo.contains(input) || nombre.contains(input);
                          }).cast<Map<String, dynamic>>();
                        },
                        displayStringForOption: (usuario) =>
                        "${usuario['nombre']} - ${usuario['correo']}",
                        fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                          return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              labelText: "Buscar usuario",
                              hintText: "Nombre o correo",
                            ),
                          );
                        },
                        onSelected: (usuario) {
                          if (!usuariosSeleccionados.any((u) => u['idUsuario'] == usuario['idUsuario'])) {
                            setState(() {
                              usuariosSeleccionados.add(usuario);
                            });
                          }
                        },
                      ),
                      SizedBox(height: 12),
                      if (usuariosSeleccionados.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          children: usuariosSeleccionados.map((u) {
                            return Chip(
                              label: Text(u['correo']),
                              onDeleted: () {
                                setState(() {
                                  usuariosSeleccionados.removeWhere(
                                          (x) => x['idUsuario'] == u['idUsuario']);
                                });
                              },
                            );
                          }).toList(),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancelar")),
            ElevatedButton(
              child: Text("Enviar"),
              onPressed: () async {
                Navigator.pop(context);
                final mensaje = mensajeCtrl.text.trim();
                final tipo = tipoSeleccionado;
                if (mensaje.isEmpty) return;

                bool success = true;

                if (enviarATodos) {
                  success = await HttpService.enviarNotificacionATodos({
                    "mensaje": mensaje,
                    "tipoNotificacion": tipo,
                  });

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(success
                        ? "Notificación enviada a todos"
                        : "Error al enviar a todos"),
                  ));
                } else {
                  for (final usuario in usuariosSeleccionados) {
                    final ok = await HttpService.enviarNotificacionAUsuario({
                      "mensaje": mensaje,
                      "tipoNotificacion": tipo,
                      "idUsuario": usuario['idUsuario'],
                    });

                    if (!ok) {
                      success = false;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error al notificar a ${usuario['correo']}")),
                      );
                    }
                  }

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Notificación enviada correctamente")),
                    );
                  }
                }

                await cargarNotificaciones();
              },
            )
          ],
        ),
      ),
    );
  }

  String formatearFecha(String? fechaISO) {
    if (fechaISO == null) return 'N/A';
    final date = DateTime.tryParse(fechaISO);
    if (date == null) return 'N/A';
    return DateFormat('dd/MM/yyyy HH:mm').format(date.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notificaciones'),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: cargarNotificaciones),
          IconButton(icon: Icon(Icons.add_alert), onPressed: crearNotificacionDialog),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _buscarCtrl,
                  decoration: InputDecoration(
                    labelText: 'Buscar por usuario o mensaje',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => aplicarFiltros(),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Text("Estado: "),
                    SizedBox(width: 10),
                    DropdownButton<String>(
                      value: filtroEstado,
                      onChanged: (v) => setState(() {
                        filtroEstado = v!;
                        aplicarFiltros();
                      }),
                      items: estados.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    ),
                    SizedBox(width: 20),
                    Text("Tipo: "),
                    SizedBox(width: 10),
                    DropdownButton<String>(
                      value: filtroTipo,
                      onChanged: (v) => setState(() {
                        filtroTipo = v!;
                        aplicarFiltros();
                      }),
                      items: tipos.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        final desde = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().subtract(Duration(days: 7)),
                          firstDate: DateTime(2023),
                          lastDate: DateTime(2100),
                        );
                        if (desde != null) {
                          setState(() => fechaDesde = desde);
                          aplicarFiltros();
                        }
                      },
                      icon: Icon(Icons.date_range),
                      label: Text(fechaDesde != null
                          ? DateFormat('dd/MM/yyyy').format(fechaDesde!)
                          : "Desde"),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final hasta = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2023),
                          lastDate: DateTime(2100),
                        );
                        if (hasta != null) {
                          setState(() => fechaHasta = hasta);
                          aplicarFiltros();
                        }
                      },
                      icon: Icon(Icons.date_range),
                      label: Text(fechaHasta != null
                          ? DateFormat('dd/MM/yyyy').format(fechaHasta!)
                          : "Hasta"),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: notificaciones == null || notificaciones!.isEmpty
                ? Center(child: Text('No hay notificaciones disponibles'))
                : ListView.builder(
              itemCount: notificaciones!.length,
              itemBuilder: (context, index) {
                final n = notificaciones![index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(n['mensaje'] ?? '',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Usuario: ${n['usuario']?['nombre'] ?? 'Todos'}"),
                        Text("Tipo: ${n['tipoNotificacion']}"),
                        Text("Estado: ${n['estado']}"),
                        Text("Fecha: ${formatearFecha(n['fechaNotificacion'])}"),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => cambiarEstadoNotificacion(n['idNotificacion']),
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
