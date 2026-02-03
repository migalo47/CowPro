import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/http_service.dart';

import '../../theme/theme_provider.dart';
import 'detalle_espacio_screen.dart';

class ClienteEspaciosScreen extends StatefulWidget {
  const ClienteEspaciosScreen({Key? key}) : super(key: key);

  @override
  State<ClienteEspaciosScreen> createState() => _ClienteEspaciosScreenState();
}

class _ClienteEspaciosScreenState extends State<ClienteEspaciosScreen> {
  List<dynamic> _espacios = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargarEspacios();
  }

  Future<void> _cargarEspacios() async {
    final espacios = await HttpService.getEspaciosDisponibles();
    if (espacios != null) {
      setState(() {
        _espacios = espacios;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  void _mostrarDialogoConfiguracion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Configuración"),
        content: const Text("¿Deseas cambiar el tema de la aplicación?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
              final isCurrentlyDark = Theme.of(context).brightness == Brightness.dark;
              themeProvider.toggleTheme(!isCurrentlyDark);
              Navigator.pop(context);
            },
            child: const Text("Cambiar tema"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/logo1.png',
                    height: 90,
                    fit: BoxFit.contain,
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, size: 28, color: Colors.grey),
                    onPressed: _mostrarDialogoConfiguracion,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'ESPACIOS DISPONIBLES',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Lista de espacios
            Expanded(
              child: _espacios.isEmpty
                  ? const Center(child: Text('No hay espacios disponibles.'))
                  : ListView.builder(
                itemCount: _espacios.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final espacio = _espacios[index];
                  final nombre = espacio['nombre'] ?? '';
                  final imagenUrl = espacio['imagenUrl'] ?? '';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (imagenUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.network(
                              imagenUrl,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 180,
                                color: Colors.grey[300],
                                child: const Center(child: Icon(Icons.image, size: 40)),
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nombre,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DetalleEspacioScreen(espacio: espacio),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                  child: const Text(
                                    'Más información',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
