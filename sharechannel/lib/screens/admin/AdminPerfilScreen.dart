import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:sharechannel/screens/login_screen.dart';
import 'package:sharechannel/services/http_service.dart';
import 'package:sharechannel/theme/theme_provider.dart';

class AdminPerfilScrreen extends StatefulWidget {
  @override
  _AdminPerfilScreenState createState() => _AdminPerfilScreenState();
}

class _AdminPerfilScreenState extends State<AdminPerfilScrreen> {
  final storage = FlutterSecureStorage();
  Map<String, dynamic>? usuario;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    cargarPerfil();
  }

  Future<void> cargarPerfil() async {
    final token = await storage.read(key: 'token');
    if (token == null) {
      setState(() => loading = false);
      return;
    }

    try {
      final correo = JwtDecoder.decode(token)['sub'];
      final data = await HttpService.getUsuarioPorCorreo(correo);
      setState(() {
        usuario = data;
        loading = false;
      });
    } catch (e) {
      print('Error al cargar perfil: $e');
      setState(() => loading = false);
    }
  }

  void cerrarSesion() async {
    await storage.deleteAll();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginScreen()),
          (route) => false,
    );
  }

  void editarPerfil() async {
    final nombreCtrl = TextEditingController(text: usuario!['nombre']);
    final correoCtrl = TextEditingController(text: usuario!['correo']);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Perfil'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreCtrl,
                  decoration: InputDecoration(labelText: 'Nombre'),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: correoCtrl,
                  decoration: InputDecoration(labelText: 'Correo'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final actualizado = {
                  'nombre': nombreCtrl.text,
                  'correo': correoCtrl.text,
                  'tipoUsuario': usuario!['tipoUsuario'],
                };

                final exito = await HttpService.actualizarUsuario(usuario!['idUsuario'], actualizado);
                if (exito) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Perfil actualizado')));
                  await cargarPerfil(); // Refresca la info del usuario
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al actualizar')));
                }
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }




  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final themeColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: themeColor,
      appBar: AppBar(
        title: Text('Perfil'),
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: cerrarSesion,
          )
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : usuario == null
          ? Center(child: Text('No se pudo cargar el perfil', style: TextStyle(color: textColor)))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
            Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[850] : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  perfilItem(Icons.person, "Nombre", usuario!['nombre'], textColor),
                  perfilItem(Icons.email, "Correo", usuario!['correo'], textColor),
                  perfilItem(Icons.security, "Rol", usuario!['tipoUsuario'], textColor),
                  perfilItem(Icons.language, "Idioma", "Español", textColor),
                ],
              ),
            ),
            botonAccion(Icons.edit, 'Editar Perfil', editarPerfil, Colors.blueAccent),

            ElevatedButton.icon(
              onPressed: () {
                themeProvider.toggleTheme(!isDarkMode);
              },
              icon: Icon(Icons.brightness_6),
              label: Text('Modo oscuro'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? Colors.white : Colors.black,
                foregroundColor: isDarkMode ? Colors.black : Colors.white,
                minimumSize: Size(double.infinity, 50),
                shape: StadiumBorder(),
              ),
            ),
            SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: cerrarSesion,
              icon: Icon(Icons.logout, color: Colors.red),
              label: Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red),
                minimumSize: Size(double.infinity, 50),
                shape: StadiumBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget perfilItem(IconData icon, String label, String? value, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "$label: ${value ?? ''}",
              style: TextStyle(fontSize: 16, color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget botonAccion(IconData icon, String texto, VoidCallback accion, Color color) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: accion,
          icon: Icon(icon),
          label: Text(texto),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 50),
            shape: StadiumBorder(),
          ),
        ),
        SizedBox(height: 12),
      ],
    );
  }
}
