// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, library_private_types_in_public_api

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:email_validator/email_validator.dart';
import 'package:http/http.dart' as http;
import 'package:inicio_sesion/Home.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  _RegistroScreenState createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController cedulaController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();
  final TextEditingController celularController = TextEditingController();
  final TextEditingController sexoController = TextEditingController();

  String result = '';
  bool isValid = false;
  String? selectedSexo;

  Future<void> registrar() async {
    final String email = correoController.text.trim();
    final String contrasena = contrasenaController.text.trim();
    final String nombre = nombreController.text.trim();
    final String apellido = apellidoController.text.trim();
    final String cedula = cedulaController.text.trim();
    final String celular = celularController.text.trim();
    final String sexo = sexoController.text.trim();
    int rol = 1;

    // Construir el mapa con los datos del usuario
    final Map<String, dynamic> datosUsuario = {
      "email": email,
      "password": contrasena,
      "nombres": nombre,
      "apellidos": apellido,
      "rol": rol,
      "CC": int.parse(cedula),
      "num_cel": int.parse(celular),
      "sexo": sexo
    };

    try {
      // Convertir el mapa a JSON
      final datosJson = jsonEncode(datosUsuario);

      // Enviar los datos al servidor
      final http.Response response = await http.post(
        Uri.parse('https://parkuis.onrender.com/users/signup'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: datosJson,
      );

      // Actualizar el estado con la respuesta del servidor
      setState(() {
        result = response.body;
      });
      print('Resultado: $result');
      print("status code: ${response.statusCode}");
      if (response.statusCode == 201) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Cuenta creada exitosamente'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  },
                  child: Text('Volver a inicio'),
                ),
              ],
            );
          },
        );
      } else {
        throw Exception('Error al enviar los datos: ${response.statusCode}');
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('No se pudo crear la cuenta debido a que $result'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void setSelectedSexo(String sexo) {
    setState(() {
      selectedSexo = sexo;
      sexoController.text = sexo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registrarse')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: apellidoController,
                decoration: InputDecoration(
                  labelText: 'Apellido',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: cedulaController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Numero de Cedula',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: correoController,
                decoration: InputDecoration(
                  labelText: 'Correo Electrónico',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: contrasenaController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: celularController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Numero de Celular',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: sexoController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Sexo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                style: TextStyle(fontSize: 16, color: Colors.white),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Selecciona tu sexo'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () {
                                setSelectedSexo('Hombre');
                                Navigator.of(context).pop();
                              },
                              child: Text('Hombre'),
                            ),
                            TextButton(
                              onPressed: () {
                                setSelectedSexo('Mujer');
                                Navigator.of(context).pop();
                              },
                              child: Text('Mujer'),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final bool isValid =
                      EmailValidator.validate(correoController.text);
                  if (isValid == false) {
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Advertencia'),
                          content: Text(
                              'Por favor, asigna un correo electrónico válido'),
                        );
                      },
                    );
                  } else if (isValid == true) {
                    registrar();
                  }
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
