import 'package:flutter/material.dart';
import '../../services/http_service.dart';

class AdminEquiposScreen extends StatefulWidget {
  @override
  _AdminEquiposScreenState createState() => _AdminEquiposScreenState();
}

class _AdminEquiposScreenState extends State<AdminEquiposScreen> {
  List<dynamic>? equipos;
  List<dynamic>? todosEquipos;
  final TextEditingController _buscarCtrl = TextEditingController();
  bool loading = true;

  @override
  void initState() {
    super.initState();
    cargarEquipos();
  }

  Future<void> cargarEquipos() async {
    setState(() => loading = true);
    final data = await HttpService.getTodosEquipos();
    setState(() {
      equipos = data;
      todosEquipos = data;
      loading = false;
    });
  }

  void buscarEquipos() {
    final query = _buscarCtrl.text.toLowerCase();
    setState(() {
      equipos = todosEquipos
          ?.where((e) => e['nombre'].toLowerCase().contains(query))
          .toList();
    });
  }

  void eliminarEquipo(int id) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Eliminar Equipo"),
        content: Text("¿Deseas eliminar este equipo?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancelar")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text("Eliminar")),
        ],
      ),
    );

    if (confirm == true) {
      final ok = await HttpService.eliminarEquipo(id);
      if (ok) cargarEquipos();
    }
  }

  void abrirFormularioEquipo({Map<String, dynamic>? equipoExistente}) {
    final nombreCtrl = TextEditingController(text: equipoExistente?['nombre'] ?? '');
    final descCtrl = TextEditingController(text: equipoExistente?['descripcion'] ?? '');
    final tipo = ValueNotifier(equipoExistente?['tipoEquipo'] ?? 'OTRO');
    final precioCtrl = TextEditingController(text: equipoExistente?['precioPorDia']?.toString() ?? '');
    final cantidadCtrl = TextEditingController(text: equipoExistente?['cantidadDisponible']?.toString() ?? '');
    final imagenCtrl = TextEditingController(text: equipoExistente?['imagenUrl'] ?? '');
    final disponible = ValueNotifier(equipoExistente?['disponibilidad'] ?? true);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(equipoExistente == null ? 'Agregar Equipo' : 'Editar Equipo'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nombreCtrl, decoration: InputDecoration(labelText: 'Nombre')),
              TextField(controller: descCtrl, decoration: InputDecoration(labelText: 'Descripción')),
              DropdownButtonFormField(
                value: tipo.value,
                items: ['PROYECTOR', 'CAMARA', 'MICROFONO', 'COMPUTADORA', 'OTRO']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => tipo.value = val!,
                decoration: InputDecoration(labelText: 'Tipo'),
              ),
              TextField(controller: cantidadCtrl, decoration: InputDecoration(labelText: 'Cantidad disponible')),
              TextField(controller: precioCtrl, decoration: InputDecoration(labelText: 'Precio por Día')),
              TextField(controller: imagenCtrl, decoration: InputDecoration(labelText: 'URL de Imagen')),
              Row(
                children: [
                  Text("Disponible"),
                  ValueListenableBuilder(
                    valueListenable: disponible,
                    builder: (_, val, __) => Switch(value: val, onChanged: (v) => disponible.value = v),
                  ),
                ],
              )
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              final nuevo = {
                'nombre': nombreCtrl.text,
                'descripcion': descCtrl.text,
                'tipoEquipo': tipo.value,
                'cantidadDisponible': int.tryParse(cantidadCtrl.text),
                'precioPorDia': double.tryParse(precioCtrl.text),
                'imagenUrl': imagenCtrl.text,
                'disponibilidad': disponible.value,
              };
              final ok = equipoExistente == null
                  ? await HttpService.crearEquipo(nuevo)
                  : await HttpService.actualizarEquipo(equipoExistente['idEquipo'], nuevo);
              if (ok) cargarEquipos();
              Navigator.pop(context);
            },
            child: Text("Guardar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Equipos'), actions: [
        IconButton(icon: Icon(Icons.refresh), onPressed: cargarEquipos)
      ]),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _buscarCtrl, decoration: InputDecoration(labelText: 'Buscar por nombre'))),
                SizedBox(width: 8),
                ElevatedButton(onPressed: buscarEquipos, child: Text("Buscar")),
                SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  icon: Icon(Icons.add),
                  onPressed: () => abrirFormularioEquipo(),
                  label: Text("Agregar"),
                ),
              ],
            ),
          ),
          Expanded(
            child: loading
                ? Center(child: CircularProgressIndicator())
                : equipos == null
                ? Center(child: Text("Error al cargar."))
                : ListView.builder(
                itemCount: equipos!.length,
                itemBuilder: (context, index) {
                  final e = equipos![index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (e['imagenUrl'] != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                e['imagenUrl'],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey[300],
                                  child: Icon(Icons.image_not_supported),
                                ),
                              ),
                            ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e['nombre'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                if (e['descripcion'] != null) Text(e['descripcion']),
                                Text("Tipo: ${e['tipoEquipo']}"),
                                Text("Cantidad: ${e['cantidadDisponible']}"),
                                Text("Disponible: ${e['disponibilidad'] == true ? 'Sí' : 'No'}"),
                                Text("Precio por día: ${e['precioPorDia']}€"),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => abrirFormularioEquipo(equipoExistente: e),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => eliminarEquipo(e['idEquipo']),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}
