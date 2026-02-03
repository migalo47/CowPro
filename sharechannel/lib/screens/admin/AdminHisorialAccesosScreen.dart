import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/http_service.dart';

class AdminHistorialAccesosScreen extends StatefulWidget {
  @override
  _AdminHistorialAccesosScreenState createState() => _AdminHistorialAccesosScreenState();
}

class _AdminHistorialAccesosScreenState extends State<AdminHistorialAccesosScreen> {
  List<dynamic>? accesos;
  List<dynamic>? todosAccesos;
  List<dynamic> usuarios = [];
  List<dynamic> espacios = [];

  bool loading = true;
  dynamic selectedEspacio;
  final TextEditingController _usuarioSearchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    setState(() => loading = true);
    final hist = await HttpService.getHistorialAccesos();
    final usrs = await HttpService.getAllUsuarios();
    final esp = await HttpService.getTodosEspacios();

    setState(() {
      accesos = hist;
      todosAccesos = hist;
      usuarios = usrs ?? [];
      espacios = esp ?? [];
      loading = false;
    });
  }

  String formatearFecha(String? iso) {
    if (iso == null) return 'N/A';
    final date = DateTime.tryParse(iso);
    return date != null ? DateFormat('dd/MM/yyyy HH:mm').format(date) : 'N/A';
  }

  Future<void> filtrarPorUsuario(Map<String, dynamic> usuario) async {
    setState(() => loading = true);
    final data = await HttpService.getHistorialAccesosPorUsuario(usuario['idUsuario']);
    setState(() {
      accesos = data;
      loading = false;
    });
  }

  Future<void> filtrarPorEspacio(dynamic espacio) async {
    if (espacio == null) return;
    setState(() => loading = true);
    final data = await HttpService.getHistorialAccesosPorEspacio(espacio['idEspacio']);
    setState(() {
      accesos = data;
      selectedEspacio = espacio;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Accesos'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: cargarDatos,
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(minWidth: 250, maxWidth: 400),
                      child: Autocomplete<Map<String, dynamic>>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          final input = textEditingValue.text.toLowerCase();
                          return usuarios.where((u) =>
                          (u['nombre'] ?? '').toLowerCase().contains(input) ||
                              (u['correo'] ?? '').toLowerCase().contains(input)
                          ).cast<Map<String, dynamic>>();
                        },
                        displayStringForOption: (usuario) => usuario['nombre'] ?? '',
                        fieldViewBuilder: (context, controller, focusNode, _) {
                          return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              labelText: 'Filtrar por usuario',
                              prefixIcon: Icon(Icons.person_outline),
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: theme.colorScheme.surfaceVariant,
                            ),
                          );
                        },
                        onSelected: (usuario) => filtrarPorUsuario(usuario),
                      ),
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(minWidth: 250, maxWidth: 400),
                      child: DropdownButtonFormField<Map<String, dynamic>>(
                        value: selectedEspacio,
                        items: espacios.map<DropdownMenuItem<Map<String, dynamic>>>((esp) {
                          return DropdownMenuItem(
                            value: esp,
                            child: Text(esp['nombre']),
                          );
                        }).toList(),
                        onChanged: (espacio) => filtrarPorEspacio(espacio),
                        decoration: InputDecoration(
                          labelText: 'Filtrar por espacio',
                          prefixIcon: Icon(Icons.location_on_outlined),
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: loading
                ? Center(child: CircularProgressIndicator())
                : accesos == null || accesos!.isEmpty
                ? Center(child: Text('No hay accesos registrados'))
                : ListView.builder(
              itemCount: accesos!.length,
              itemBuilder: (context, i) {
                final h = accesos![i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(20),
                    color: theme.cardColor,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.person, size: 20, color: theme.colorScheme.primary),
                                  SizedBox(width: 6),
                                  Text(
                                    h['usuario']?['nombre'] ?? 'Sin usuario',
                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Text(
                                formatearFecha(h['fechaAcceso']),
                                style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text("Espacio: ${h['espacio']?['nombre'] ?? ''}"),
                          if (h['equipo'] != null)
                            Text("Equipo: ${h['equipo']?['nombre'] ?? ''}"),
                          Text("Inicio: ${formatearFecha(h['horaInicio'])}"),
                          Text("Fin: ${formatearFecha(h['horaFin'])}"),
                        ],
                      ),
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