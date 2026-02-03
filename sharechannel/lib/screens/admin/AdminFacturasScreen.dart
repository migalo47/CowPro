import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../services/http_service.dart';

class AdminFacturasScreen extends StatefulWidget {
  @override
  _AdminFacturasScreenState createState() => _AdminFacturasScreenState();
}

class _AdminFacturasScreenState extends State<AdminFacturasScreen> {
  List<dynamic>? facturas;
  List<dynamic>? todasFacturas;
  final TextEditingController _buscarCtrl = TextEditingController();
  bool loading = true;

  @override
  void initState() {
    super.initState();
    cargarFacturas();
  }

  Future<void> cargarFacturas() async {
    setState(() => loading = true);
    final data = await HttpService.getTodasFacturas();
    setState(() {
      facturas = data;
      todasFacturas = data;
      loading = false;
    });
  }

  void buscarFacturas() {
    final query = _buscarCtrl.text.toLowerCase();
    setState(() {
      facturas = todasFacturas?.where((f) {
        final numero = f['numeroFactura']?.toLowerCase() ?? '';
        final concepto = f['concepto']?.toLowerCase() ?? '';
        final nombreUsuario = f['usuario']?['nombre']?.toLowerCase() ?? '';
        final correoUsuario = f['usuario']?['correo']?.toLowerCase() ?? '';
        return numero.contains(query) || concepto.contains(query) || nombreUsuario.contains(query) || correoUsuario.contains(query);
      }).toList();
    });
  }

  void cambiarEstadoFactura(int idFactura) async {
    final nuevoEstado = await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text("Cambiar estado"),
        children: ['PENDIENTE', 'PAGADA', 'CANCELADA'].map((estado) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, estado),
            child: Text(estado),
          );
        }).toList(),
      ),
    );

    if (nuevoEstado != null) {
      final success = await HttpService.cambiarEstadoFactura(idFactura, nuevoEstado);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Estado actualizado")));
        cargarFacturas();
      }
    }
  }

  void generarPdfFactura(dynamic factura) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // LOGO
              pw.Text(
                'COW PRO',
                style: pw.TextStyle(
                  fontSize: 32,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.purple,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Factura de reserva',
                style: pw.TextStyle(fontSize: 18),
              ),
              pw.Divider(thickness: 1.5),
              pw.SizedBox(height: 16),

              // DATOS FACTURA
              pw.Container(
                padding: pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _infoFactura("Número de factura", factura['numeroFactura']),
                    _infoFactura("Usuario", "${factura['usuario']?['nombre']} (${factura['usuario']?['correo']})"),
                    _infoFactura("Concepto", factura['concepto']),
                    _infoFactura("Monto total", "${factura['montoTotal']} "),
                    _infoFactura("Fecha de emisión", factura['fechaEmision'] ?? ''),
                    _infoFactura("Fecha de vencimiento", factura['fechaVencimiento'] ?? ''),
                    _infoFactura("Estado", factura['estado']),
                    _infoFactura("Método de pago", factura['metodoPago']),
                  ],
                ),
              ),

              pw.Spacer(),
              pw.Divider(),
              pw.Center(
                child: pw.Text(
                  'Gracias por confiar en ShareChannel.',
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
                ),
              ),
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
          pw.Expanded(
            flex: 2,
            child: pw.Text("$label:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),
          pw.Expanded(
            flex: 3,
            child: pw.Text(value ?? '', style: pw.TextStyle(color: PdfColors.black)),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Facturas'),
        actions: [IconButton(icon: Icon(Icons.refresh), onPressed: cargarFacturas)],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _buscarCtrl,
                    decoration: InputDecoration(labelText: 'Buscar por número, concepto o usuario'),
                    onChanged: (v) => buscarFacturas(),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: buscarFacturas,
                  icon: Icon(Icons.search),
                  label: Text("Buscar"),
                ),
              ],
            ),
          ),
          Expanded(
            child: loading
                ? Center(child: CircularProgressIndicator())
                : facturas == null
                ? Center(child: Text('Error cargando facturas'))
                : facturas!.isEmpty
                ? Center(child: Text('No hay facturas disponibles'))
                : ListView.builder(
              itemCount: facturas!.length,
              itemBuilder: (context, index) {
                final f = facturas![index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Factura: ${f['numeroFactura']}', style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text('Usuario: ${f['usuario']?['nombre'] ?? ''}'),
                              Text('Concepto: ${f['concepto']}'),
                              Text('Monto: ${f['montoTotal']} €'),
                              Text('Estado: ${f['estado']}'),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.picture_as_pdf, color: Colors.blue),
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                              onPressed: () => generarPdfFactura(f),
                            ),
                            SizedBox(height: 4),
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.orange),
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                              onPressed: () => cambiarEstadoFactura(f['idFactura']),
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
