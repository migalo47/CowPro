  // DetalleEspacioScreen.dart actualizado con modo oscuro y corrección final de 21:00

  import 'package:flutter/material.dart';
  import 'package:intl/intl.dart';
  import 'package:provider/provider.dart';
  import '../../services/http_service.dart';
  import '../../theme/theme_provider.dart';

  class DetalleEspacioScreen extends StatefulWidget {
    final Map<String, dynamic> espacio;

    const DetalleEspacioScreen({Key? key, required this.espacio}) : super(key: key);

    @override
    State<DetalleEspacioScreen> createState() => _DetalleEspacioScreenState();
  }

  class _DetalleEspacioScreenState extends State<DetalleEspacioScreen> {
    Set<DateTime> fechasNoDisponibles = {};
    Map<String, List<String>> horasOcupadasPorDia = {};
    DateTime? _fechaInicio;
    DateTime? _fechaFin;
    String? _horaInicio;
    String? _horaFin;
    dynamic _equipoSeleccionado;
    List<dynamic> _equipos = [];
    bool _validando = false;

    final List<String> _horas = List.generate(13, (i) => '${(8 + i).toString().padLeft(2, '0')}:00'); // hasta 20:00

    @override
    void initState() {
      super.initState();
      _cargarFechasYHorasOcupadas();
      _cargarEquiposDisponibles();
    }

    Future<void> _cargarFechasYHorasOcupadas() async {
      final data = await HttpService.getFechasYHorasOcupadas(widget.espacio['idEspacio']);
      if (data != null) {
        setState(() {
          fechasNoDisponibles = data.entries
              .where((entry) => (entry.value.toSet().length >= 13)) // 08:00 a 20:00
              .map((e) => DateTime.parse(e.key))
              .toSet();
          horasOcupadasPorDia = data;
        });
      }
    }

    Future<void> _cargarEquiposDisponibles() async {
      final equipos = await HttpService.getTodosEquipos();
      if (equipos != null) {
        setState(() => _equipos = equipos);
      }
    }

    bool _esDiaHabilitado(DateTime day, DateTime? start, DateTime? end) {
      return !fechasNoDisponibles.contains(day);
    }

    List<String> _filtrarHorasDisponibles(DateTime dia, {bool paraFin = false}) {
      final diaKey = DateFormat('yyyy-MM-dd').format(dia);
      final ocupadas = horasOcupadasPorDia[diaKey]?.toSet() ?? {};
      final List<String> baseHoras = List.generate(14, (i) => '${(8 + i).toString().padLeft(2, '0')}:00');

      final int? primeraOcupada = ocupadas
          .map((h) => int.parse(h.split(":")[0]))
          .fold<int?>(null, (prev, h) => prev == null || h < prev ? h : prev);

      List<String> filtradas = baseHoras.where((h) {
        final hora = int.parse(h.split(":")[0]);
        if (!paraFin && hora == 21) return false;
        if (paraFin && hora == 8) return false;
        if (paraFin && hora == 21 && ocupadas.contains("20:00")) return false;

        if (paraFin) {
          return !ocupadas.contains(h) || (primeraOcupada != null && hora == primeraOcupada);
        }
        return !ocupadas.contains(h);
      }).toList();

      if (paraFin && _horaInicio != null) {
        final intInicio = int.parse(_horaInicio!.split(':')[0]);
        filtradas = filtradas.where((h) => int.parse(h.split(':')[0]) > intInicio).toList();
      }

      return filtradas;
    }

    Future<void> _confirmarReserva() async {
      if (_fechaInicio == null || _fechaFin == null || _horaInicio == null || _horaFin == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Completa todos los campos')));
        return;
      }

      final DateTime inicio = DateTime.parse('${DateFormat('yyyy-MM-dd').format(_fechaInicio!)}T$_horaInicio:00');
      final DateTime fin = DateTime.parse('${DateFormat('yyyy-MM-dd').format(_fechaFin!)}T$_horaFin:00');

      if (inicio.isAfter(fin) || inicio.isAtSameMomentAs(fin)) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('La hora de inicio debe ser menor que la de fin')));
        return;
      }

      setState(() => _validando = true);

      final disponibleEspacio = await HttpService.verificarDisponibilidadEspacio(
        widget.espacio['idEspacio'],
        inicio.toIso8601String(),
        fin.toIso8601String(),
      );

      if (!disponibleEspacio) {
        setState(() => _validando = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ El espacio ya no está disponible')));
        return;
      }

      if (_equipoSeleccionado != null) {
        final disponibleEquipo = await HttpService.verificarDisponibilidadEquipo(
          _equipoSeleccionado['idEquipo'],
          inicio.toIso8601String(),
          fin.toIso8601String(),
        );
        if (!disponibleEquipo) {
          setState(() => _validando = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ El equipo no está disponible')));
          return;
        }
      }

      final usuario = await HttpService.getUsuarioActual();
      if (usuario == null) return;

      final reserva = {
        'usuario': {'idUsuario': usuario['idUsuario']},
        'espacio': {'idEspacio': widget.espacio['idEspacio']},
        'equipo': _equipoSeleccionado != null ? {'idEquipo': _equipoSeleccionado['idEquipo']} : null,
        'tipoReserva': 'HORAS',
        'estado': 'PENDIENTE',
        'fechaInicio': inicio.toIso8601String(),
        'fechaFin': fin.toIso8601String(),
      };

      final ok = await HttpService.crearReserva(reserva);
      setState(() => _validando = false);
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ Reserva realizada')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Error al reservar')));
      }
    }

    @override
    Widget build(BuildContext context) {
      final themeProvider = Provider.of<ThemeProvider>(context);
      final isDark = themeProvider.themeMode == ThemeMode.dark;
      final e = widget.espacio;

      final imagenUrl = e['imagenUrl'] ?? '';
      final nombre = e['nombre'] ?? '';
      final tipo = e['tipoEspacio'] ?? '';
      final disponible = e['disponibilidad'] == true ? 'Sí' : 'No';
      final precioHora = e['precioPorHora']?.toString() ?? '-';
      final precioDia = e['precioPorDia']?.toString() ?? '-';
      final precioMes = e['precioPorMes']?.toString() ?? '-';

      final horasInicio = _fechaInicio != null ? _filtrarHorasDisponibles(_fechaInicio!, paraFin: false) : _horas;
      final horasFin = _fechaInicio != null ? _filtrarHorasDisponibles(_fechaInicio!, paraFin: true) : _horas;

      return Scaffold(
        appBar: AppBar(
          title: Text(nombre, style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: isDark ? Colors.black : Colors.white,
          foregroundColor: isDark ? Colors.white : Colors.black,
          elevation: 0,
        ),
        backgroundColor: isDark ? Colors.black : Colors.grey[100],
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (imagenUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(imagenUrl, height: 200, fit: BoxFit.cover),
              ),
            const SizedBox(height: 16),
            Text(nombre, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
            Text(e['descripcion'] ?? '', style: TextStyle(color: isDark ? Colors.white70 : Colors.grey[700])),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(label: Text(tipo)),
                const SizedBox(width: 12),
                Chip(label: Text('Disponible: $disponible', style: TextStyle(color: isDark ? Colors.black: Colors.black),), backgroundColor: Colors.grey.shade200),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPrecioCard('Precio por horas', precioHora),
                _buildPrecioCard('Precio por días', precioDia),
                _buildPrecioCard('Precio por meses', precioMes),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 90)),
                  selectableDayPredicate: _esDiaHabilitado,
                );
                if (picked != null) {
                  setState(() {
                    _fechaInicio = picked.start;
                    _fechaFin = picked.end;
                    _horaInicio = null;
                    _horaFin = null;
                  });
                }
              },
              icon: Icon(Icons.calendar_month),
              label: Text(
                _fechaInicio == null || _fechaFin == null
                    ? 'Seleccionar fechas disponibles'
                    : 'Del ${DateFormat('dd/MM/yyyy').format(_fechaInicio!)} al ${DateFormat('dd/MM/yyyy').format(_fechaFin!)}',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildHoraDropdown('Hora inicio', _horaInicio, (val) => setState(() => _horaInicio = val), horasInicio)),
                const SizedBox(width: 12),
                Expanded(child: _buildHoraDropdown('Hora fin', _horaFin, (val) => setState(() => _horaFin = val), horasFin)),
              ],
            ),
            const SizedBox(height: 16),
            _buildEquipoDropdown(),
            const SizedBox(height: 24),
            _validando
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _confirmarReserva,
              child: Text('RESERVAR ESPACIO'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildPrecioCard(String label, String precio) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final textColor = isDark ? Colors.white : Colors.black;

      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.blueGrey[800] : Colors.blue[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
          ),
          const SizedBox(height: 4),
          Text('$precio€', style: TextStyle(color: textColor)),
        ],
      );
    }


    Widget _buildHoraDropdown(String label, String? value, void Function(String?) onChanged, List<String> horasDisponibles) {
      final isDark = Theme.of(context).brightness == Brightness.dark;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark ? Colors.grey[800] : Colors.grey.shade200,
        ),
        child: DropdownButtonFormField<String>(
          isExpanded: true,
          dropdownColor: isDark ? Colors.grey[900] : null,
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: label,
            labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black),
          ),
          value: value,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          items: horasDisponibles.map((h) => DropdownMenuItem(value: h, child: Text(h))).toList(),
          onChanged: onChanged,
        ),
      );
    }


    Widget _buildEquipoDropdown() {
      final isDark = Theme.of(context).brightness == Brightness.dark;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark ? Colors.grey[800] : Colors.grey.shade200,
        ),
        child: DropdownButtonFormField(
          isExpanded: true,
          dropdownColor: isDark ? Colors.grey[900] : null,
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: 'Añadir equipo disponible a tu reserva',
            labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black),
          ),
          value: _equipoSeleccionado,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          items: _equipos.map((e) {
            return DropdownMenuItem(
              value: e,
              child: Text(e['nombre']),
            );
          }).toList(),
          onChanged: (val) => setState(() => _equipoSeleccionado = val),
        ),
      );
    }

  }
