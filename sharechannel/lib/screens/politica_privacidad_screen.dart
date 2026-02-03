import 'package:flutter/material.dart';

class PoliticaPrivacidadScreen extends StatelessWidget {
  const PoliticaPrivacidadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Política de Privacidad'),
        backgroundColor: isDark ? Colors.grey[900] : Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            'Última actualización: mayo 2025\n\n'
                'En CowPro (Coworking Profesional) nos tomamos muy en serio la privacidad de nuestros usuarios. Esta política de privacidad describe cómo recopilamos, usamos y protegemos su información personal cuando accede y utiliza nuestra aplicación.\n\n'
                '1. Información que recopilamos\n'
                '• Nombre, correo electrónico, número de teléfono y contraseña en el proceso de registro.\n'
                '• Datos relacionados con las reservas realizadas (espacio, fecha, equipo, método de pago).\n'
                '• Dirección IP, tipo de dispositivo, sistema operativo y versión de la app.\n\n'
                '2. Uso de la información\n'
                'Utilizamos la información recopilada para:\n'
                '• Procesar y gestionar reservas de espacios y equipos.\n'
                '• Generar códigos de acceso temporales para las cerraduras inteligentes.\n'
                '• Enviar notificaciones importantes relacionadas con la cuenta y las reservas.\n'
                '• Ofrecer soporte técnico y resolver incidencias.\n'
                '• Mejorar la experiencia del usuario dentro de la aplicación.\n\n'
                '3. Compartición de datos\n'
                'No vendemos, alquilamos ni compartimos su información personal con terceros, excepto cuando es estrictamente necesario para la prestación del servicio, como en el caso de integraciones con sistemas de control de acceso (Tuya).\n\n'
                '4. Seguridad\n'
                'Implementamos medidas técnicas y organizativas adecuadas para proteger sus datos personales, incluyendo cifrado, control de acceso y almacenamiento seguro en servidores protegidos.\n\n'
                '5. Derechos del usuario\n'
                'Usted tiene derecho a acceder, corregir, eliminar o limitar el uso de su información personal. Puede ejercer estos derechos escribiéndonos a info@cowpro.es.\n\n'
                '6. Retención de datos\n'
                'Conservamos su información personal mientras su cuenta esté activa o según lo necesario para cumplir con nuestras obligaciones legales y contractuales.\n\n'
                '7. Cambios en esta política\n'
                'CowPro se reserva el derecho de actualizar esta política de privacidad. Notificaremos cualquier cambio relevante a través de la app o por correo electrónico.\n\n'
                'Al utilizar la aplicación, usted acepta esta política de privacidad en su totalidad.',
            style: TextStyle(fontSize: 15, height: 1.5),
          ),
        ),
      ),
    );
  }
}