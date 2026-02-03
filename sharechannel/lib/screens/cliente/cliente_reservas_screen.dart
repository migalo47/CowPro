import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../services/http_service.dart';
import '../../theme/theme_provider.dart';

class ClienteReservasScreen extends StatefulWidget {
  final VoidCallback? onReservasActualizadas;
  const ClienteReservasScreen({Key? key, this.onReservasActualizadas}) : super(key: key);

  @override
  State<ClienteReservasScreen> createState() => _ClienteReservasScreenState();
}

class _ClienteReservasScreenState extends State<ClienteReservasScreen> {
  List<dynamic> _todas = [];
  List<dynamic> _filtradas = [];
  String _estadoSeleccionado = 'CONFIRMADA';
  String _filtroTiempo = 'Esta semana';
  bool _loading = true;
  int _contador = 0;

  final List<String> estados = ['CONFIRMADA', 'PENDIENTE', 'CANCELADA', 'COMPLETADA'];
  final List<String> filtrosTiempo = ['Esta semana', 'Este mes', 'Todas'];

  @override
  void initState() {
    super.initState();
    _cargarReservas();
  }

  bool _reservasVistas = false; // NUEVA bandera local

  Future<void> _marcarReservasComoVistas() async {
    if (_reservasVistas) return; // Ya se hizo
    final ahora = DateTime.now();

    final vistas = _filtradas.where((r) =>
    r['estado'] == 'PENDIENTE' &&
        DateTime.parse(r['fechaInicio']).isAfter(ahora)
    ).toList();

    if (vistas.isNotEmpty) {
      setState(() {
        _contador = 0;
        _reservasVistas = true;
      });
      if (widget.onReservasActualizadas != null) {
        widget.onReservasActualizadas!(); // Se notifica para ocultar badge
      }
    }
  }

  Future<void> _cargarReservas() async {
    final usuario = await HttpService.getUsuarioActual();
    if (usuario != null) {
      final reservas = await HttpService.getReservasPorUsuario(usuario['idUsuario']);
      setState(() {
        _todas = reservas ?? [];
        _loading = false;
      });
      _filtrar();
      _actualizarContador();
    }
  }

  void _filtrar() {
    List<dynamic> lista = _todas.where((r) => r['estado'] == _estadoSeleccionado).toList();
    final ahora = DateTime.now();

    if (_filtroTiempo == 'Esta semana') {
      final inicioSemana = DateTime(ahora.year, ahora.month, ahora.day - (ahora.weekday - 1)); // lunes
      final finSemana = inicioSemana.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59)); // domingo

      lista = lista.where((r) {
        final inicio = DateTime.parse(r['fechaInicio']);
        final fin = DateTime.parse(r['fechaFin']);

        // ✅ Hay solapamiento si la reserva empieza antes de que termine la semana
        // y termina después de que empieza la semana.
        return inicio.isBefore(finSemana) && fin.isAfter(inicioSemana);
      }).toList();
    } else if (_filtroTiempo == 'Este mes') {
      final inicioMes = DateTime(ahora.year, ahora.month, 1);
      final finMes = DateTime(ahora.year, ahora.month + 1, 1).subtract(const Duration(seconds: 1));

      lista = lista.where((r) {
        final inicio = DateTime.parse(r['fechaInicio']);
        final fin = DateTime.parse(r['fechaFin']);

        return inicio.isBefore(finMes) && fin.isAfter(inicioMes);
      }).toList();
    }

    lista.sort((a, b) => DateTime.parse(b['fechaInicio']).compareTo(DateTime.parse(a['fechaInicio'])));

    setState(() {
      _filtradas = lista;
    });
  }


  void _actualizarContador() {
    final ahora = DateTime.now();
    final nuevas = _todas.where((r) {
      final fecha = DateTime.parse(r['fechaInicio']);
      return r['estado'] == 'PENDIENTE' && fecha.isAfter(ahora);
    }).length;

    setState(() => _contador = nuevas);
    if (widget.onReservasActualizadas != null) {
      widget.onReservasActualizadas!();
    }
  }

  void _descargarFactura(dynamic reserva) async {
    final factura = await HttpService.getFacturaPorReserva(reserva['idReserva']);
    if (factura == null) return;

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('COWPRO', style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold, color: PdfColors.purple)),
              pw.SizedBox(height: 8),
              pw.Text('Factura de reserva', style: pw.TextStyle(fontSize: 18)),
              pw.Divider(thickness: 1.5),
              pw.SizedBox(height: 16),
              pw.Container(
                padding: pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(color: PdfColors.grey200, borderRadius: pw.BorderRadius.circular(6)),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _infoFactura("Número de factura", factura['numeroFactura']),
                    _infoFactura("Usuario", "${factura['usuario']?['nombre']} (${factura['usuario']?['correo']})"),
                    _infoFactura("Concepto", factura['concepto']),
                    _infoFactura("Monto total", "${factura['montoTotal']} "),
                    _infoFactura("Fecha de emisión", factura['fechaEmision']),
                    _infoFactura("Fecha de vencimiento", factura['fechaVencimiento']),
                    _infoFactura("Estado", factura['estado']),
                    _infoFactura("Método de pago", factura['metodoPago']),
                  ],
                ),
              ),
              pw.Spacer(),
              pw.Divider(),
              pw.Center(child: pw.Text('Gracias por confiar en ShareChannel.', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600))),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  pw.Widget _infoFactura(String label, String? value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(flex: 2, child: pw.Text("$label:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          pw.Expanded(flex: 3, child: pw.Text(value ?? '', style: pw.TextStyle(color: PdfColors.black))),
        ],
      ),
    );
  }

  void _mostrarDetalleReserva(Map<String, dynamic> reserva) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    final espacio = reserva['espacio'];
    final fechaInicio = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(reserva['fechaInicio']));
    final fechaFin = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(reserva['fechaFin']));

    String mensaje;
    Icon icono;

    if (reserva['estado'] == 'PENDIENTE') {
      mensaje = '⏳ Tu reserva está pendiente de pago. Accede cuando se confirme.';
      icono = const Icon(Icons.hourglass_empty, color: Colors.orange, size: 48);
    } else if (reserva['estado'] == 'CANCELADA') {
      mensaje = '❌ Esta reserva ha sido cancelada. Esperamos verte pronto.';
      icono = const Icon(Icons.cancel, color: Colors.red, size: 48);
    } else if (reserva['estado'] == 'COMPLETADA') {
      mensaje = '✅ Reserva finalizada. ¡Gracias por confiar en nosotros!';
      icono = const Icon(Icons.check_circle, color: Colors.green, size: 48);
    } else {
      mensaje = '🔐 Código de acceso: ${reserva['codigoTemporal'] ?? 'N/A'}';
      icono = const Icon(Icons.lock_open, color: Colors.blueAccent, size: 48);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            icono,
            const SizedBox(height: 12),
            Text(espacio['nombre'] ?? 'Nombre no disponible', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87), textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text('Inicio: $fechaInicio', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
            Text('Fin: $fechaFin', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
            const SizedBox(height: 8),
            Chip(
              label: Text(reserva['estado'], style: const TextStyle(color: Colors.white)),
              backgroundColor: reserva['estado'] == 'CONFIRMADA' ? Colors.green : reserva['estado'] == 'PENDIENTE' ? Colors.orange : Colors.red,
            ),
            const Divider(height: 30),
            Text(mensaje, style: TextStyle(fontSize: 16, color: isDark ? Colors.white : Colors.black), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            if (reserva['estado'] == 'COMPLETADA' || reserva['estado'] == 'CONFIRMADA')
              ElevatedButton.icon(
                onPressed: () => _descargarFactura(reserva),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Descargar factura'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Cerrar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

@override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;
    final textColor =  Colors.black87;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Mis Reservas'),
            if (_contador > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('$_contador nuevas', style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
          ],
        ),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          _buildFiltroEstados(),
          _buildFiltroTiempo(),
          const Divider(),
          Expanded(
            child: _filtradas.isEmpty
                ? const Center(child: Text("No hay reservas en este estado"))
                : FutureBuilder(
              future: _marcarReservasComoVistas(),
              builder: (context, snapshot) {
                return ListView.builder(
                  itemCount: _filtradas.length,
                  itemBuilder: (context, index) {
                    final reserva = _filtradas[index];
                    final espacio = reserva['espacio'];
                    final imagen = espacio['imagenUrl'] ?? '';
                    final fechaInicio = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(reserva['fechaInicio']));
                    final fechaFin = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(reserva['fechaFin']));

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      color: _getColorPorEstado(reserva['estado']),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (imagen.isNotEmpty)
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: Image.network(
                                imagen,
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 160,
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
                                  espacio['nombre'] ?? '',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                                const SizedBox(height: 8),
                                Text("Del $fechaInicio al $fechaFin", style: TextStyle(color: Colors.black87)),
                                const SizedBox(height: 6),
                                Text("Estado: ${reserva['estado']}", style: TextStyle(color: Colors.black87)),
                                const SizedBox(height: 12),
                                Center(
                                  child: ElevatedButton(
                                    onPressed: () => _mostrarDetalleReserva(reserva),
                                    child: const Text('Más información', style: TextStyle(color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
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

  Widget _buildFiltroEstados() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: estados.map((estado) {
          final activo = _estadoSeleccionado == estado;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _estadoSeleccionado = estado;
                });
                _filtrar();
              },
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        estado,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: activo ? Colors.red : Colors.grey,
                        ),
                      ),
                      if (_contador > 0 && estado == 'PENDIENTE')
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('$_contador', style: const TextStyle(color: Colors.white, fontSize: 10)),
                        )
                    ],
                  ),
                  if (activo)
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
    );
  }

  Widget _buildFiltroTiempo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
    );
  }

  Color _getColorPorEstado(String estado) {
    switch (estado) {
      case 'CONFIRMADA':
        return Colors.green[100]!;
      case 'PENDIENTE':
        return Colors.orange[100]!;
      case 'CANCELADA':
        return Colors.red[100]!;
      case 'COMPLETADA':
        return Colors.grey[300]!;
      default:
        return Colors.white;
    }
  }
}