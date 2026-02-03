import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sharechannel/screens/admin/AdminDashboardScreen.dart';
import 'package:sharechannel/screens/cliente/cliente_espacios_screen.dart';
import 'package:sharechannel/screens/politica_privacidad_screen.dart';
import 'package:sharechannel/screens/terminos_uso_screen.dart';
import 'package:sharechannel/screens/terminos_usuario_screen.dart';
import '../services/http_service.dart';
import 'cliente/cliente_home_screen.dart';


class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _storage = FlutterSecureStorage();
  final _pageController = PageController();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _nameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _loading = false;
  String? _error;

  // Check de términos
  bool _termsAcceptedLogin = false;
  bool _termsAcceptedRegister = false;

// ...

  void _login() async {
    if (!_termsAcceptedLogin) {
      setState(() => _error = 'Debes aceptar los términos para continuar.');
      return;
    }

    setState(() => _loading = true);
    final token = await HttpService.login(_emailController.text, _passwordController.text);
    if (token != null) {
      await _storage.write(key: 'token', value: token);

      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      String rol = decodedToken['rol'];

      if (rol == 'CLIENTE') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ClienteHomeScreen()));
      } else if (rol == 'ADMIN') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AdminDashboardScreen()));
      } else {
        setState(() {
          _error = 'Rol desconocido';
          _loading = false;
        });
      }
    } else {
      setState(() {
        _error = 'Credenciales inválidas';
        _loading = false;
      });
    }
  }


  void _register() async {
    if (!_termsAcceptedRegister) {
      setState(() => _error = 'Debes aceptar los términos para continuar.');
      return;
    }

    setState(() => _loading = true);
    final success = await HttpService.registerUsuario({
      'nombre': _nameController.text,
      'correo': _regEmailController.text,
      'telefono': _phoneController.text,
      'contrasena': _regPasswordController.text,
      'tipoUsuario': 'CLIENTE',
    });
    setState(() => _loading = false);

    if (success) {
      _pageController.jumpToPage(1);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registro exitoso 🎉')));
    } else {
      setState(() => _error = 'Ya existe una cuenta asociada con este correo');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/fondo.png', fit: BoxFit.cover),
          PageView(
            controller: _pageController,
            physics: NeverScrollableScrollPhysics(),
            children: [
              _buildWelcomePage(),
              _buildLoginPage(),
              _buildRegisterPage(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/logo1.png', height: 200),
          SizedBox(height: 40),
          _customButton("Iniciar sesión con cuenta existente", Colors.blue, () {
            _pageController.jumpToPage(1);
          }, fontSize: 18, width: 300),
          SizedBox(height: 30),
          _customButton("Crear cuenta nueva", Colors.white, () {
            _pageController.jumpToPage(2);
          }, textColor: Colors.black, fontSize: 18, width: 280),
        ],
      ),
    );
  }

  Widget _buildLoginPage() {
    return _authPage(
      title: "Iniciar Sesión",
      onBack: () => _pageController.jumpToPage(0),
      children: [
        _textField("Introduzca el correo", _emailController),
        _textField("Contraseña", _passwordController, obscure: true),
        _checkboxText(
          value: _termsAcceptedLogin,
          onChanged: (val) => setState(() => _termsAcceptedLogin = val!),
        ),
        _loading
            ? Center(child: CircularProgressIndicator())
            : _customButton("Iniciar sesión", Colors.blue, _login),
        if (_error != null) Text(_error!, style: TextStyle(color: Colors.red)),
      ],
    );
  }

  Widget _buildRegisterPage() {
    return _authPage(
      title: "Crear Cuenta",
      onBack: () => _pageController.jumpToPage(0),
      children: [
        _textField("Nombre", _nameController),
        _textField("Introduzca el correo", _regEmailController),
        _textField("Contraseña", _regPasswordController, obscure: true),
        _textField("Teléfono", _phoneController),
        _checkboxText(
          value: _termsAcceptedRegister,
          onChanged: (val) => setState(() => _termsAcceptedRegister = val!),
        ),
        _loading
            ? Center(child: CircularProgressIndicator())
            : _customButton("Registrarse", Colors.blue, _register),
        if (_error != null) Text(_error!, style: TextStyle(color: Colors.red)),
      ],
    );
  }

  Widget _authPage({required String title, required VoidCallback onBack, required List<Widget> children}) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: ListView(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: onBack,
              color: Colors.black,
            ),
          ),
          Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
          SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _textField(String label, TextEditingController controller, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white70,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _customButton(String text, Color color, VoidCallback onPressed,
      {Color textColor = Colors.white, double fontSize = 16, double width = double.infinity}) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 18), // Centrado vertical
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Center(
          child: Text(text, style: TextStyle(fontSize: fontSize, color: textColor)),
        ),
      ),
    );
  }

  Widget _checkboxText({required bool value, required ValueChanged<bool?> onChanged}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(value: value, onChanged: onChanged),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 12, color: Colors.black),
              children: [
                TextSpan(text: "Estoy de acuerdo con la "),
                TextSpan(
                  text: "política de privacidad",
                  style: TextStyle(color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => PoliticaPrivacidadScreen())); // Cambia a tu pantalla real
                    },
                ),
                TextSpan(text: ", los "),
                TextSpan(
                  text: "términos de uso",
                  style: TextStyle(color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => TerminosUsoScreen()));
                    },
                ),
                TextSpan(text: " y los "),
                TextSpan(
                  text: "términos del usuario.",
                  style: TextStyle(color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => TerminosUsuarioScreen()));
                    },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
