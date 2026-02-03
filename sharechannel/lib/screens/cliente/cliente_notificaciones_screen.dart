import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/http_service.dart';
import '../../theme/theme_provider.dart';

class ClienteNotificacionesScreen extends StatefulWidget {
  final VoidCallback? onNotificacionesActualizadas;
  const ClienteNotificacionesScreen({Key? key, this.onNotificacionesActualizadas}) : super(key: key);

  @override
  State<ClienteNotificacionesScreen> createState() => _ClienteNotificacionesScreenState();
}

class _ClienteNotificacionesScreenState extends State<ClienteNotificacionesScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> _todas = [];
  List<dynamic> _filtradas = [];
  String _tipoSeleccionado = 'TODOS';
  String _filtroTiempo = 'Todas';
  bool _loading = true;

  final List<String> tipos = [
    'TODOS', 'CONFIRMACION', 'AVISO', 'RECORDATORIO', 'ACCESO', 'PROMOCION'
  ];

  final List<String> filtrosTiempo = ['Todas', 'Hoy', 'Esta semana'];

  @override
  void initState() {
    super.initState();
    _cargarNotificaciones();
  }

  Future<void> _cargarNotificaciones() async {
    final usuario = await HttpService.getUsuarioActual();
    if (usuario != null) {
      final notificaciones = await HttpService.getNotificacionesPorUsuario(usuario['idUsuario']);

      // 🆕 Ordenar desde el principio
      notificaciones?.sort((a, b) =>
          DateTime.parse(b['fechaNotificacion']).compareTo(DateTime.parse(a['fechaNotificacion'])));

      setState(() {
        _todas = notificaciones ?? [];
        _loading = false;
      });

      _filtrar();
    }
  }


  void _filtrar() {
    List<dynamic> lista = [..._todas];

    if (_tipoSeleccionado != 'TODOS') {
      lista = lista.where((n) => n['tipoNotificacion'] == _tipoSeleccionado).toList();
    }

    if (_filtroTiempo == 'Hoy') {
      lista = lista.where((n) {
        final fecha = DateTime.parse(n['fechaNotificacion']);
        return fecha.day == DateTime.now().day &&
            fecha.month == DateTime.now().month &&
            fecha.year == DateTime.now().year;
      }).toList();
    } else if (_filtroTiempo == 'Esta semana') {
      final inicioSemana = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
      lista = lista.where((n) {
        final fecha = DateTime.parse(n['fechaNotificacion']);
        return fecha.isAfter(inicioSemana);
      }).toList();
    }

    lista.sort((a, b) =>
        DateTime.parse(b['fechaNotificacion']).compareTo(DateTime.parse(a['fechaNotificacion'])));

    setState(() {
      _filtradas = lista;
    });

  }

  Future<void> _marcarComoLeidas() async {
    final pendientes = _filtradas.where((n) => n['estado'] == 'PENDIENTE').toList();
    if (pendientes.isEmpty) return;

    for (var notif in pendientes) {
      await HttpService.cambiarEstadoNotificacion(notif['idNotificacion'], 'ENVIADA');
    }

    if (widget.onNotificacionesActualizadas != null) {
      widget.onNotificacionesActualizadas!();
    }

    setState(() {
      for (var notif in pendientes) {
        notif['estado'] = 'ENVIADA';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    final textColor =  Colors.black87;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          _buildFiltros(),
          const Divider(),
          Expanded(
            child: _filtradas.isEmpty
                ? const Center(child: Text("No hay notificaciones"))
                : FutureBuilder(
              future: _marcarComoLeidas(),
              builder: (context, snapshot) {
                return ListView.builder(
                  itemCount: _filtradas.length,
                  itemBuilder: (context, index) {
                    final notif = _filtradas[index];
                    final fecha = DateFormat('dd/MM/yyyy HH:mm').format(
                      DateTime.parse(notif['fechaNotificacion']),
                    );

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: notif['estado'] == 'PENDIENTE' ? Colors.orange[100] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notif['tipoNotificacion'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(notif['mensaje'] ?? '', style: TextStyle(color: textColor)),
                          const SizedBox(height: 6),
                          Text(fecha, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: tipos.map((tipo) {
              final seleccionado = _tipoSeleccionado == tipo;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _tipoSeleccionado = tipo;
                    });
                    _filtrar();
                  },
                  child: Column(
                    children: [
                      Text(
                        tipo,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: seleccionado ? Colors.red : Colors.grey,
                        ),
                      ),
                      if (seleccionado)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          height: 3,
                          width: 20,
                          color: Colors.red,
                        )
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: filtrosTiempo.map((filtro) {
              final activo = _filtroTiempo == filtro;
              return ChoiceChip(
                label: Text(filtro),
                selected: activo,
                onSelected: (_) {
                  setState(() => _filtroTiempo = filtro);
                  _filtrar();
                },
              );
            }).toList(),
          ),
        )
      ],
    );
  }
}