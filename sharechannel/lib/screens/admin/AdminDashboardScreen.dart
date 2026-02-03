import 'package:flutter/material.dart';

import 'AdminEquiposScreen.dart';
import 'AdminEspaciosScreen.dart';
import 'AdminFacturasScreen.dart';
import 'AdminHisorialAccesosScreen.dart';
import 'AdminNotificacionesScreen.dart';
import 'AdminPagosScreen.dart'; // Nuevo import para pagos
import 'AdminReservasScreen.dart';
import 'AdminUsuariosScreen.dart';
import 'AdminPerfilScreen.dart'; // Import de perfil

class AdminDashboardScreen extends StatelessWidget {
  final List<_DashboardItem> items = [
    _DashboardItem("Usuarios", Icons.people, AdminUsuariosScreen()),
    _DashboardItem("Reservas", Icons.event, AdminReservasScreen()),
    _DashboardItem("Espacios", Icons.meeting_room, AdminEspaciosScreen()),
    _DashboardItem("Equipos", Icons.devices, AdminEquiposScreen()),
    _DashboardItem("Facturas", Icons.receipt_long, AdminFacturasScreen()),
    _DashboardItem("Pagos", Icons.payment, AdminPagosScreen()), // 🔥 Añadimos Pagos aquí
    _DashboardItem("Notificaciones", Icons.notifications, AdminNotificacionesScreen()),
    _DashboardItem("Historial Accesos", Icons.history, AdminHistorialAccesosScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Panel de Administración"),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AdminPerfilScrreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => item.screen),
              ),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.icon, size: 40),
                    SizedBox(height: 10),
                    Text(item.title),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DashboardItem {
  final String title;
  final IconData icon;
  final Widget screen;

  _DashboardItem(this.title, this.icon, this.screen);
}
