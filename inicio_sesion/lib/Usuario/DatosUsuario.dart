// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'dart:convert';
import 'package:inicio_sesion/clases/user.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:inicio_sesion/clases/vehiculo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatosUsuarioPage extends StatefulWidget {
  final String result;

  const DatosUsuarioPage({Key? key, required this.result}) : super(key: key);

  @override
  _DatosUsuarioPageState createState() => _DatosUsuarioPageState();
}

class _DatosUsuarioPageState extends State<DatosUsuarioPage> {
  late String email;
  late String nombres;
  late String apellidos;
  late int cc;
  late int numCel;
  late String token;
  late int id;
  bool isLoading = true;
  String? qrData;
  int? lastPaseId;

  List<Vehiculo> result = [];

  @override
  void initState() {
    super.initState();
    processHeredatedData(widget.result);
    buscaPase();
  }

  Future<void> crearPase() async {
    final response = await http.post(
      Uri.parse('https://parkuis.onrender.com/pase/'),
      headers: {
        'Authorization': 'Token ${UserSession().token}',
      },
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      setState(() {
        qrData = responseData['id'].toString();
        lastPaseId = responseData['id'];
      });
      await saveLastPaseId(lastPaseId!);
      print("id QR: ${responseData['id']}");
    } else {
      // Manejo de error
      print('Error al crear el pase: ${response.body}');
      print("Error statuscode: ${response.statusCode}");
    }
  }

  Future<void> buscaPase() async {
    final prefs = await SharedPreferences.getInstance();
    lastPaseId = prefs.getInt('lastPaseId');

    if (lastPaseId != null) {
      final response = await http.get(
        Uri.parse('https://parkuis.onrender.com/pase/$lastPaseId'),
        headers: {
          'Authorization': 'Token ${UserSession().token}',
        },
      );

      if (response.statusCode == 200) {
        final paseData = jsonDecode(response.body);
        print(paseData);
        if (paseData['estado'] == 4 || paseData['estado'] == 3) {
          setState(() {
            qrData = null;
          });
        } else {
          setState(() {
            qrData = lastPaseId.toString();
          });
        }
      } else {
        // Manejo de error
        print('Error al buscar el pase: ${response.body}');
        print("Error statuscode: ${response.statusCode}");
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> saveLastPaseId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('lastPaseId', id);
  }

  Future<void> processHeredatedData(String result) async {
    // de ser necesario decodificar esto deberia servir, tomar con pinzas
    //final String decodedResult = utf8.decode(result);
    Map<String, dynamic> jsonData = jsonDecode(result);
    token = jsonData['token'];
    email = jsonData['usuario']['email'];
    nombres = jsonData['usuario']['nombres'];
    apellidos = jsonData['usuario']['apellidos'];
    numCel = jsonData['usuario']['num_cel'];
    cc = jsonData['usuario']['CC'];
    id = jsonData['usuario']['id'];

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(16.0),
                      margin: EdgeInsets.only(bottom: 16.0),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 45, 49, 51),
                        borderRadius:
                            BorderRadius.circular(10.0), // Bordes redondeados
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '$nombres $apellidos',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'CC: $cc',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tel: $numCel',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 60),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 260.0,
                        padding: EdgeInsets.all(16.0),
                        margin: EdgeInsets.only(bottom: 16.0),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 45, 49, 51),
                          borderRadius:
                              BorderRadius.circular(10.0), // Bordes redondeados
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            qrData == null
                                ? ElevatedButton(
                                    onPressed: crearPase,
                                    child: Text("Crear Pase"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Color.fromARGB(255, 103, 165, 62),
                                    ),
                                  )
                                : Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                          width: 210.0,
                                          height: 210.0,
                                          color: Colors.white),
                                      QrImageView(
                                        data: qrData!,
                                        version: QrVersions.auto,
                                        size: 200.0,
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
