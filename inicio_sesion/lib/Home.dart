// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:inicio_sesion/Usuario/BarraInferior.dart';
import 'package:inicio_sesion/clases/user.dart';
import 'package:inicio_sesion/registro.dart';
import 'package:http/http.dart' as http;
import 'package:inicio_sesion/vigilante/BarraInferiorVigilante.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();

  String result = '';
  bool _isObscure = true;

  Future<void> enviarDatosAlServidor() async {
    final String usuario = usuarioController.text.trim();
    final String contrasena = contrasenaController.text.trim();

    // Construir el mapa con los datos del usuario
    final Map<String, String> datosUsuario = {
      'email': usuario,
      'password': contrasena,
    };

    try {
      // Convertir el mapa a JSON
      final datosJson = jsonEncode(datosUsuario);

      // Enviar los datos al servidor
      final http.Response response = await http.post(
        Uri.parse('https://parkuis.onrender.com/users/login'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: datosJson,
      );

      print('respuesta: $response');

      // Actualizar el estado con la respuesta del servidor
      setState(() {
        result = response.body;
      });

      print('result = $result');
      print('statuscode: ${response.statusCode}');
      if (result == '{"detail":"No encontrado."}') {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text('Advertencia'),
              content: Text('Usuario no encontrado'),
            );
          },
        );
      } else if (result == '{"detail":"ContraseÃ±a incorrecta."}') {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text('Advertencia'),
              content: Text('Contraseña incorrecta'),
            );
          },
        );
      } else {
        //En caso de que si pase
        final Map<String, dynamic> jsonData = jsonDecode(result);
        UserSession().token = jsonData['token'];
        final http.Response esVigilante = await http.get(
          Uri.parse('https://parkuis.onrender.com/users/es_vigilante'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Token ${UserSession().token}',
          },
        );
        print("es vigilante ${esVigilante.body}");

        if (esVigilante.body == "false") {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PrincipalUser(
                      result: result,
                    )),
          );
        } else if (esVigilante.body == "true") {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VigilanteUser(
                      result: result,
                    )),
          );
        }
      }
    } catch (e) {
      setState(() {
        result = 'Error al enviar los datos: $e';
      });
      print('no se pudo porque: $e');
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return const AlertDialog(
            title: Text('Advertencia'),
            content: Text('Contraseña incorrecta'),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Image.asset(
                  'images/logoCompleto.png',
                  width: 200, // Ancho de la imagen
                  height: 200, // Alto de la imagen
                ),
              ),
              TextField(
                style: TextStyle(color: Colors.white),
                controller: usuarioController,
                decoration: InputDecoration(
                  labelText: 'Usuario',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onChanged: (_) {
                  setState(() {
                    result = ''; // Limpiar el resultado al cambiar el texto
                  });
                },
              ),
              SizedBox(height: 16),
              TextField(
                style: TextStyle(color: Colors.white),
                controller: contrasenaController,
                obscureText: _isObscure,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility_off : Icons.visibility,
                      color: _isObscure ? Colors.grey : Colors.green,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onChanged: (_) {
                  setState(() {
                    result = ''; // Limpiar el resultado al cambiar el texto
                  });
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed:
                    enviarDatosAlServidor, // Llamar al método para enviar datos
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 103, 165, 62),
                ),
                child: Text('Iniciar Sesión'),
              ),
              SizedBox(height: 32),
              Text(
                '¿No tienes una cuenta?',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegistroScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 103, 165, 62),
                ),
                child: Text('Registrarse'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
