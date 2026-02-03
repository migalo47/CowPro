import 'package:flutter/material.dart';
import '../../services/http_service.dart';

class AdminEspaciosScreen extends StatefulWidget {
  @override
  _AdminEspaciosScreenState createState() => _AdminEspaciosScreenState();
}

class _AdminEspaciosScreenState extends State<AdminEspaciosScreen> {
  List<dynamic>? espacios;
  List<dynamic>? todosEspacios;
  final TextEditingController _buscarCtrl = TextEditingController();
  bool loading = true;

  @override
  void initState() {
    super.initState();
    cargarEspacios();
  }

  Future<void> cargarEspacios() async {
    setState(() => loading = true);
    final data = await HttpService.getTodosEspacios();
    setState(() {
      espacios = data;
      todosEspacios = data;
      loading = false;
    });
  }

  void buscarEspacios() {
    final query = _buscarCtrl.text.toLowerCase();
    setState(() {
      espacios = todosEspacios
          ?.where((e) => e['nombre'].toLowerCase().contains(query))
          .toList();
    });
  }

  void eliminarEspacio(int id) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Eliminar Espacio"),
        content: Text("¿Deseas eliminar este espacio?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancelar")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text("Eliminar")),
        ],
      ),
    );

    if (confirm == true) {
      final ok = await HttpService.eliminarEspacio(id);
      if (ok) cargarEspacios();
    }
  }

  void abrirFormularioEspacio({Map<String, dynamic>? espacioExistente}) {
    final nombreCtrl = TextEditingController(text: espacioExistente?['nombre'] ?? '');
    final descCtrl = TextEditingController(text: espacioExistente?['descripcion'] ?? '');
    final tipo = ValueNotifier(espacioExistente?['tipoEspacio'] ?? 'COWORKING');
    final precioHoraCtrl = TextEditingController(text: espacioExistente?['precioPorHora']?.toString() ?? '');
    final precioDiaCtrl = TextEditingController(text: espacioExistente?['precioPorDia']?.toString() ?? '');
    final precioMesCtrl = TextEditingController(text: espacioExistente?['precioPorMes']?.toString() ?? '');
    final capacidadCtrl = TextEditingController(text: espacioExistente?['capacidad']?.toString() ?? '');
    final deviceIdCtrl = TextEditingController(text: espacioExistente?['deviceId'] ?? '');
    final imagenCtrl = TextEditingController(text: espacioExistente?['imagenUrl'] ?? '');
    final disponible = ValueNotifier(espacioExistente?['disponibilidad'] ?? true);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(espacioExistente == null ? 'Agregar Espacio' : 'Editar Espacio'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nombreCtrl, decoration: InputDecoration(labelText: 'Nombre')),
              TextField(controller: descCtrl, decoration: InputDecoration(labelText: 'Descripción')),
              DropdownButtonFormField(
                value: tipo.value,
                items: ['COWORKING', 'DESPACHO', 'SALA_REUNIONES', 'PLATO_TELEVISION', 'AULA']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => tipo.value = val!,
                decoration: InputDecoration(labelText: 'Tipo'),
              ),
              TextField(controller: capacidadCtrl, decoration: InputDecoration(labelText: 'Capacidad')),
              TextField(controller: precioHoraCtrl, decoration: InputDecoration(labelText: 'Precio por Hora')),
              TextField(controller: precioDiaCtrl, decoration: InputDecoration(labelText: 'Precio por Día')),
              TextField(controller: precioMesCtrl, decoration: InputDecoration(labelText: 'Precio por Mes')),
              TextField(controller: deviceIdCtrl, decoration: InputDecoration(labelText: 'Device ID')),
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
                'tipoEspacio': tipo.value,
                'capacidad': int.tryParse(capacidadCtrl.text),
                'precioPorHora': double.tryParse(precioHoraCtrl.text),
                'precioPorDia': double.tryParse(precioDiaCtrl.text),
                'precioPorMes': double.tryParse(precioMesCtrl.text),
                'deviceId': deviceIdCtrl.text,
                'imagenUrl': imagenCtrl.text,
                'disponibilidad': disponible.value,
              };
              final ok = espacioExistente == null
                  ? await HttpService.crearEspacio(nuevo)
                  : await HttpService.actualizarEspacio(espacioExistente['idEspacio'], nuevo);
              if (ok) cargarEspacios();
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
      appBar: AppBar(title: Text('Espacios'), actions: [
        IconButton(icon: Icon(Icons.refresh), onPressed: cargarEspacios)
      ]),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _buscarCtrl, decoration: InputDecoration(labelText: 'Buscar por nombre'))),
                SizedBox(width: 8),
                ElevatedButton(onPressed: buscarEspacios, child: Text("Buscar")),
                SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  icon: Icon(Icons.add),
                  onPressed: () => abrirFormularioEspacio(),
                  label: Text("Agregar"),
                ),
              ],
            ),
          ),
          Expanded(
            child: loading
                ? Center(child: CircularProgressIndicator())
                : espacios == null
                ? Center(child: Text("Error al cargar."))
                : ListView.builder(
                itemCount: espacios!.length,
                itemBuilder: (context, index) {
                  final e = espacios![index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (e['imagenUrl'] != null)
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                            child: Image.network(
                              e['imagenUrl'],
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 200,
                                color: Colors.grey[300],
                                child: Center(child: Icon(Icons.broken_image, size: 40)),
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(e['nombre'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    SizedBox(height: 4),
                                    if (e['descripcion'] != null) Text(e['descripcion']),
                                    Text("Tipo: ${e['tipoEspacio']}"),
                                    Text("Capacidad: ${e['capacidad']}"),
                                    Text("Disponible: ${e['disponibilidad'] == true ? 'Sí' : 'No'}"),
                                    Text("Precio: Hora ${e['precioPorHora']}€, Día ${e['precioPorDia']}€, Mes ${e['precioPorMes']}€"),
                                  ],
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => abrirFormularioEspacio(espacioExistente: e),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => eliminarEspacio(e['idEspacio']),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}
