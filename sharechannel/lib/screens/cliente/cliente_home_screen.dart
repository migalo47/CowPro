import 'package:flutter/material.dart';
import 'cliente_espacios_screen.dart';
import 'cliente_reservas_screen.dart';
import 'cliente_notificaciones_screen.dart';
import 'cliente_perfil_screen.dart';
import '../../services/http_service.dart';

class ClienteHomeScreen extends StatefulWidget {
  const ClienteHomeScreen({Key? key}) : super(key: key);

  @override
  State<ClienteHomeScreen> createState() => _ClienteHomeScreenState();
}

class _ClienteHomeScreenState extends State<ClienteHomeScreen> {
  int _selectedIndex = 0;
  int _notificacionesPendientes = 0;
  int _reservasPendientes = 0;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _contarNotificacionesPendientes();
    _contarReservasPendientes();
    _screens.addAll([
      const ClienteEspaciosScreen(),
      ClienteReservasScreen(
        onReservasActualizadas: _contarReservasPendientes,
      ),
      ClienteNotificacionesScreen(
        onNotificacionesActualizadas: _contarNotificacionesPendientes,
      ),
      const ClientePerfilScreen(),
    ]);
  }

  Future<void> _contarNotificacionesPendientes() async {
    final usuario = await HttpService.getUsuarioActual();
    if (usuario != null) {
      final notifs = await HttpService.getNotificacionesPorUsuario(usuario['idUsuario']);
      if (notifs != null) {
        final pendientes = notifs.where((n) => n['estado'] == 'PENDIENTE').length;
        setState(() {
          _notificacionesPendientes = pendientes;
        });
      }
    }
  }

  Future<void> _contarReservasPendientes() async {
    final usuario = await HttpService.getUsuarioActual();
    if (usuario != null) {
      final reservas = await HttpService.getReservasPorUsuario(usuario['idUsuario']);
      if (reservas != null) {
        final ahora = DateTime.now();
        final pendientes = reservas.where((r) =>
        r['estado'] == 'PENDIENTE' && DateTime.parse(r['fechaInicio']).isAfter(ahora)
        ).length;
        setState(() {
          _reservasPendientes = pendientes;
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 2) {
      Future.delayed(const Duration(milliseconds: 500), _contarNotificacionesPendientes);
    } else if (index == 1) {
      Future.delayed(const Duration(milliseconds: 500), _contarReservasPendientes);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
        backgroundColor: Colors.blue,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Espacios'),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.book_online),
                if (_reservasPendientes > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '$_reservasPendientes',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Reservas',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.notifications),
                if (_notificacionesPendientes > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '$_notificacionesPendientes',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Notificaciones',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
