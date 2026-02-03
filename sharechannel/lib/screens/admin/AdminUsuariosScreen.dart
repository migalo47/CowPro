import 'package:flutter/material.dart';
import '../../services/http_service.dart';

class AdminUsuariosScreen extends StatefulWidget {
  @override
  _AdminUsuariosScreenState createState() => _AdminUsuariosScreenState();
}

class _AdminUsuariosScreenState extends State<AdminUsuariosScreen> {
  List<dynamic>? usuarios;
  bool loading = true;
  final TextEditingController _buscarCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    cargarUsuarios();
  }

  Future<void> cargarUsuarios() async {
    setState(() => loading = true);
    final res = await HttpService.getAllUsuarios();
    setState(() {
      usuarios = res;
      loading = false;
    });
  }

  List<dynamic> get usuariosFiltrados {
    final query = _buscarCtrl.text.toLowerCase();
    return usuarios?.where((u) {
      final nombre = u['nombre']?.toLowerCase() ?? '';
      final correo = u['correo']?.toLowerCase() ?? '';
      return nombre.contains(query) || correo.contains(query);
    }).toList() ?? [];
  }

  void eliminarUsuario(int id) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Eliminar Usuario"),
        content: Text("¿Estás seguro que deseas eliminar este usuario?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancelar")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text("Eliminar")),
        ],
      ),
    );

    if (confirm == true) {
      final success = await HttpService.eliminarUsuario(id);
      if (success) cargarUsuarios();
    }
  }

  void abrirFormularioUsuario({Map<String, dynamic>? usuarioExistente}) {
    final nombreCtrl = TextEditingController(text: usuarioExistente?['nombre'] ?? "");
    final correoCtrl = TextEditingController(text: usuarioExistente?['correo'] ?? "");
    final telefonoCtrl = TextEditingController(text: usuarioExistente?['telefono'] ?? "");
    final contrasenaCtrl = TextEditingController();
    final tipoUsuario = ValueNotifier(usuarioExistente?['tipoUsuario'] ?? 'CLIENTE');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(usuarioExistente == null ? 'Agregar Usuario' : 'Editar Usuario'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nombreCtrl, decoration: InputDecoration(labelText: 'Nombre')),
              TextField(controller: correoCtrl, decoration: InputDecoration(labelText: 'Correo')),
              TextField(controller: telefonoCtrl, decoration: InputDecoration(labelText: 'Teléfono')),
              if (usuarioExistente == null)
                TextField(controller: contrasenaCtrl, decoration: InputDecoration(labelText: 'Contraseña'), obscureText: true),
              ValueListenableBuilder(
                valueListenable: tipoUsuario,
                builder: (_, value, __) => DropdownButton<String>(
                  value: value,
                  isExpanded: true,
                  items: ['CLIENTE', 'EMPLEADO', 'ADMIN']
                      .map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)))
                      .toList(),
                  onChanged: (val) => tipoUsuario.value = val!,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancelar")),
          ElevatedButton(
            child: Text("Guardar"),
            onPressed: () async {
              final nuevo = {
                'nombre': nombreCtrl.text,
                'correo': correoCtrl.text,
                'telefono': telefonoCtrl.text,
                'tipoUsuario': tipoUsuario.value,
                if (usuarioExistente == null) 'contrasena': contrasenaCtrl.text,
              };
              final ok = usuarioExistente == null
                  ? await HttpService.registerUsuario(nuevo)
                  : await HttpService.actualizarUsuario(usuarioExistente['idUsuario'], nuevo);
              if (ok) cargarUsuarios();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Usuarios'),
        actions: [IconButton(onPressed: cargarUsuarios, icon: Icon(Icons.refresh))],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              controller: _buscarCtrl,
              decoration: InputDecoration(
                labelText: "Buscar por nombre o correo",
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (val) => setState(() {}),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () => abrirFormularioUsuario(),
                icon: Icon(Icons.add),
                label: Text("Agregar Usuario"),
              ),
            ),
          ),
          Expanded(
            child: loading
                ? Center(child: CircularProgressIndicator())
                : usuariosFiltrados.isEmpty
                ? Center(child: Text("No hay usuarios registrados."))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: usuariosFiltrados.length,
              itemBuilder: (context, index) {
                final u = usuariosFiltrados[index];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  margin: EdgeInsets.symmetric(vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(Icons.person, size: 36),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(u['nombre'] ?? 'Sin nombre',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              SizedBox(height: 2),
                              Text(u['correo'] ?? 'Sin correo'),
                              Text("Tel: ${u['telefono'] ?? 'N/A'}"),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(u['tipoUsuario'] ?? '', style: TextStyle(fontSize: 12)),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => abrirFormularioUsuario(usuarioExistente: u),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => eliminarUsuario(u['idUsuario']),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
