import 'package:flutter/material.dart';

class TerminosUsuarioScreen extends StatelessWidget {
  const TerminosUsuarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Términos del Usuario'),
        backgroundColor: isDark ? Colors.grey[900] : Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            'Última actualización: mayo 2025\n\n'
                'Los presentes términos detallan las obligaciones y derechos específicos de los usuarios registrados de CowPro.\n\n'
                '1. Obligaciones del usuario\n'
                '• Proporcionar y mantener información personal verdadera y actualizada.\n'
                '• No transferir ni compartir sus datos de acceso con terceros.\n'
                '• Utilizar los espacios y equipos con responsabilidad y respeto.\n\n'
                '2. Uso adecuado de recursos\n'
                '• El usuario debe respetar los horarios, normas de uso y condiciones de los espacios reservados.\n'
                '• El uso abusivo, negligente o fraudulento puede implicar sanciones o suspensión de cuenta.\n\n'
                '3. Comunicación y soporte\n'
                '• CowPro puede enviar comunicaciones relativas a reservas, actualizaciones del servicio o información administrativa.\n'
                '• Para consultas o incidencias, el usuario puede escribir a info@cowpro.es.\n\n'
                '4. Baja del servicio\n'
                '• El usuario puede solicitar la baja de su cuenta en cualquier momento.\n'
                '• CowPro podrá eliminar cuentas inactivas o que incumplan las normas establecidas.\n\n'
                '5. Modificaciones\n'
                '• Estos términos pueden ser modificados en función de cambios legales o mejoras del servicio.\n'
                '• El usuario será notificado de los cambios relevantes mediante la aplicación o por correo.\n\n'
                'Al registrarse y utilizar la aplicación, el usuario acepta estos términos del usuario.',
            style: TextStyle(fontSize: 15, height: 1.5),
          ),
        ),
      ),
    );
  }
}
