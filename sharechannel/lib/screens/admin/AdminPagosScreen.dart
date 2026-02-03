import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/http_service.dart';

class AdminPagosScreen extends StatefulWidget {
  @override
  _AdminPagosScreenState createState() => _AdminPagosScreenState();
}

class _AdminPagosScreenState extends State<AdminPagosScreen> {
  List<dynamic>? pagos;
  List<dynamic>? todosPagos;
  final TextEditingController _buscarCtrl = TextEditingController();
  String _filtroEstado = 'Todos';
  String _filtroMetodo = 'Todos';
  DateTime? fechaDesde;
  DateTime? fechaHasta;
  bool loading = true;

  final List<String> estados = ['Todos', 'PENDIENTE', 'PAGADO', 'RECHAZADO'];
  final List<String> metodos = ['Todos', 'TARJETA', 'TRANSFERENCIA', 'EFECTIVO', 'OTRO'];

  @override
  void initState() {
    super.initState();
    cargarPagos();
  }

  Future<void> cargarPagos() async {
    setState(() => loading = true);
    final data = await HttpService.getTodosPagos();
    setState(() {
      pagos = data;
      todosPagos = data;
      loading = false;
    });
  }

  void aplicarFiltros() {
    final query = _buscarCtrl.text.toLowerCase();
    setState(() {
      pagos = todosPagos?.where((p) {
        final estado = p['estadoPago'] ?? '';
        final metodo = p['metodoPago'] ?? '';
        final nombreUsuario = p['reserva']?['usuario']?['nombre']?.toLowerCase() ?? '';
        final fechaStr = p['fechaPago'];
        final fechaPago = fechaStr != null ? DateTime.tryParse(fechaStr) : null;

        final coincideTexto = nombreUsuario.contains(query);
        final coincideEstado = _filtroEstado == 'Todos' || estado == _filtroEstado;
        final coincideMetodo = _filtroMetodo == 'Todos' || metodo == _filtroMetodo;
        final coincideFecha = (fechaDesde == null || (fechaPago != null && !fechaPago.isBefore(fechaDesde!))) &&
            (fechaHasta == null || (fechaPago != null && !fechaPago.isAfter(fechaHasta!)));

        return coincideTexto && coincideEstado && coincideMetodo && coincideFecha;
      }).toList();
    });
  }

  void cambiarEstadoPago(int idPago) async {
    final nuevoEstado = await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text("Cambiar estado del pago"),
        children: ['PENDIENTE', 'PAGADO', 'RECHAZADO'].map((estado) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, estado),
            child: Text(estado),
          );
        }).toList(),
      ),
    );

    if (nuevoEstado != null) {
      final success = await HttpService.cambiarEstadoPago(idPago, nuevoEstado);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Estado actualizado")));
        cargarPagos();
      }
    }
  }

  Widget buildFiltroChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: estados.map((estado) {
          final isSelected = _filtroEstado == estado;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(estado),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _filtroEstado = estado;
                  aplicarFiltros();
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildDropdownMetodo() {
    return DropdownButton<String>(
      value: _filtroMetodo,
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _filtroMetodo = value;
            aplicarFiltros();
          });
        }
      },
      items: metodos.map((m) {
        return DropdownMenuItem(
          value: m,
          child: Text(m),
        );
      }).toList(),
    );
  }

  Color colorEstado(String estado) {
    switch (estado) {
      case 'PENDIENTE':
        return Colors.orange;
      case 'PAGADO':
        return Colors.green;
      case 'RECHAZADO':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String formatearFecha(String? fechaISO) {
    if (fechaISO == null) return 'N/A';
    final date = DateTime.tryParse(fechaISO);
    if (date == null) return 'N/A';
    return DateFormat('dd/MM/yyyy HH:mm').format(date.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Pagos'),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: cargarPagos),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _buscarCtrl,
                  decoration: InputDecoration(
                    labelText: 'Buscar por usuario',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => aplicarFiltros(),
                ),
                SizedBox(height: 12),
                buildFiltroChips(),
                SizedBox(height: 12),
                Row(
                  children: [
                    Text("Método: "),
                    SizedBox(width: 10),
                    buildDropdownMetodo(),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        final desde = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().subtract(Duration(days: 7)),
                          firstDate: DateTime(2023),
                          lastDate: DateTime(2100),
                        );
                        if (desde != null) {
                          setState(() => fechaDesde = desde);
                          aplicarFiltros();
                        }
                      },
                      icon: Icon(Icons.date_range),
                      label: Text(fechaDesde != null
                          ? DateFormat('dd/MM/yyyy').format(fechaDesde!)
                          : "Desde"),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final hasta = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2023),
                          lastDate: DateTime(2100),
                        );
                        if (hasta != null) {
                          setState(() => fechaHasta = hasta);
                          aplicarFiltros();
                        }
                      },
                      icon: Icon(Icons.date_range),
                      label: Text(fechaHasta != null
                          ? DateFormat('dd/MM/yyyy').format(fechaHasta!)
                          : "Hasta"),
                    ),
                  ],
                ),

              ],
            ),
          ),
          Expanded(
            child: pagos!.isEmpty
                ? Center(child: Text("No hay pagos registrados"))
                : ListView.builder(
              itemCount: pagos!.length,
              itemBuilder: (context, index) {
                final p = pagos![index];
                final estado = p['estadoPago'];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text("Pago #${p['idPago']}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Usuario: ${p['reserva']?['usuario']?['nombre'] ?? 'N/A'}"),
                        Text("Monto: ${p['monto'] != null ? '${p['monto']} €' : 'null €'}"),
                        Text("Método: ${p['metodoPago'] ?? 'N/A'}"),
                        Text("Fecha: ${formatearFecha(p['fechaPago'])}"),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, color: colorEstado(estado), size: 14),
                        SizedBox(width: 6),
                        Text(
                          estado,
                          style: TextStyle(fontSize: 12),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, size: 18),
                          onPressed: () => cambiarEstadoPago(p['idPago']),
                          tooltip: 'Cambiar estado',
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
