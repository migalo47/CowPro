import 'package:flutter/material.dart';

class TerminosUsoScreen extends StatelessWidget {
  const TerminosUsoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Términos de Uso'),
        backgroundColor: isDark ? Colors.grey[900] : Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            'Última actualización: mayo 2025\n\n'
                'Estos términos de uso regulan el acceso y uso de la aplicación CowPro por parte de usuarios y administradores. Al registrarse o utilizar la app, el usuario acepta expresamente estas condiciones.\n\n'
                '1. Registro y cuenta\n'
                '• El usuario debe proporcionar datos reales y mantenerlos actualizados.\n'
                '• No se permite el uso de cuentas ajenas ni compartir credenciales.\n\n'
                '2. Uso permitido\n'
                '• La aplicación debe utilizarse exclusivamente para gestionar reservas de espacios y equipos profesionales.\n'
                '• Está prohibido realizar actividades fraudulentas, abusivas o contrarias a la ley.\n\n'
                '3. Reservas\n'
                '• Las reservas están sujetas a disponibilidad y confirmación por parte de CowPro.\n'
                '• El uso indebido o reiterado de reservas falsas podrá suponer la suspensión de la cuenta.\n\n'
                '4. Acceso a espacios\n'
                '• El acceso se realiza mediante credenciales temporales generadas tras la confirmación de la reserva.\n'
                '• Dichos códigos son personales e intransferibles.\n\n'
                '5. Facturación y pagos\n'
                '• Los pagos realizados a través de CowPro se gestionan mediante pasarelas de pago seguras (como Stripe).\n'
                '• En caso de discrepancias o problemas, puede contactarse con info@cowpro.es.\n\n'
                '6. Modificaciones del servicio\n'
                '• CowPro se reserva el derecho de modificar, suspender o cancelar partes del servicio sin previo aviso si se considera necesario.\n\n'
                '7. Terminación de la cuenta\n'
                '• CowPro puede suspender o eliminar una cuenta por uso indebido, fraude, o incumplimiento de estos términos.\n\n'
                'El uso continuado de la aplicación implica la aceptación completa de estos términos de uso.',
            style: TextStyle(fontSize: 15, height: 1.5),
          ),
        ),
      ),
    );
  }
}
