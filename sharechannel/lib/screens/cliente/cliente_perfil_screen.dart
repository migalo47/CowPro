import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import '../../services/http_service.dart';
import '../../theme/theme_provider.dart';
import '../login_screen.dart';

class ClientePerfilScreen extends StatefulWidget {
  const ClientePerfilScreen({Key? key}) : super(key: key);

  @override
  State<ClientePerfilScreen> createState() => _ClientePerfilScreenState();
}

class _ClientePerfilScreenState extends State<ClientePerfilScreen> with TickerProviderStateMixin {
  final storage = FlutterSecureStorage();
  Map<String, dynamic>? usuario;
  bool loading = true;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    cargarPerfil();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
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
      _fadeController.forward();
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
    final nombreCtrl = TextEditingController(text: usuario?['nombre']);
    final correoCtrl = TextEditingController(text: usuario?['correo']);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nombreCtrl, decoration: InputDecoration(labelText: 'Nombre')),
              SizedBox(height: 12),
              TextField(controller: correoCtrl, decoration: InputDecoration(labelText: 'Correo')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                final actualizado = {
                  'nombre': nombreCtrl.text,
                  'correo': correoCtrl.text,
                  'tipoUsuario': usuario?['tipoUsuario'],
                };
                final exito = await HttpService.actualizarUsuario(usuario!['idUsuario'], actualizado);
                if (exito) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Perfil actualizado')));
                  await cargarPerfil();
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

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: loading
          ? Center(child: CircularProgressIndicator())
          : usuario == null
          ? Center(child: Text("No se pudo cargar el perfil", style: TextStyle(color: Colors.grey)))
          : FadeTransition(
        opacity: _fadeController,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.logout, color: isDarkMode ? Colors.white : Colors.black),
                  onPressed: cerrarSesion,
                ),
              ),
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.blue.shade700,
                child: Icon(Icons.person, size: 45, color: Colors.white),
              ),
              SizedBox(height: 20),
              Text(
                "Hola, ${usuario!['nombre']}",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                usuario!['correo'],
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 30),
              _infoCard(Icons.person, "Nombre", usuario!['nombre'], isDarkMode),
              _infoCard(Icons.email, "Correo", usuario!['correo'], isDarkMode),
              _infoCard(Icons.verified_user, "Rol", usuario!['tipoUsuario'], isDarkMode),
              SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: editarPerfil,
                icon: Icon(Icons.edit),
                label: Text('Editar perfil'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => themeProvider.toggleTheme(!isDarkMode),
                icon: Icon(Icons.brightness_6),
                label: Text('Cambiar tema'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode ? Colors.white : Colors.black,
                  foregroundColor: isDarkMode ? Colors.black : Colors.white,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: cerrarSesion,
                icon: Icon(Icons.logout, color: Colors.red),
                label: Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String label, String value, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDarkMode ? Colors.white : Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
