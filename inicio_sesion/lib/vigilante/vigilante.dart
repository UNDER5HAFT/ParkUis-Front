// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:inicio_sesion/clases/vehiculo.dart';
import 'package:qr_bar_code_scanner_dialog/qr_bar_code_scanner_dialog.dart';
import 'package:http/http.dart' as http;

class DatosVigilantePage extends StatefulWidget {
  final String result;

  const DatosVigilantePage({Key? key, required this.result}) : super(key: key);

  @override
  _DatosVigilantePageState createState() => _DatosVigilantePageState();
}

class _DatosVigilantePageState extends State<DatosVigilantePage> {
  late String email;
  late String nombres;
  late String apellidos;
  late int cc;
  late int numCel;
  late String token;
  late int id;
  bool isLoading = true;
  final _qrBarCodeScannerDialogPlugin = QrBarCodeScannerDialog();
  late String code;
  List<Vehiculo> result = [];
  String? qrID;
  String? qrEstado;

  @override
  void initState() {
    super.initState();
    processHeredatedData(widget.result);
  }

  Future<void> processHeredatedData(String result) async {
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

  void seleccionarVehiculo(Vehiculo vehiculo) async {
    print("vehiculo seleccionado ${vehiculo.placa}");
    final urlPase = 'https://parkuis.onrender.com/pase/$code/scan/';
    final responsePase = await http.patch(
      Uri.parse(urlPase),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
      body: jsonEncode({'json_vehiculo': vehiculo.toJson()}),
    );

    print("responsePase ${responsePase.body}");
  }

  Future<void> scanCodeAndSendRequest(String code) async {
    final urlPase = 'https://parkuis.onrender.com/pase/$code/';
    final responsePase = await http.get(
      Uri.parse(urlPase),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
    );
    print(responsePase.body);

    final Map<String, dynamic> responseData = jsonDecode(responsePase.body);
    setState(() {
      qrID = responseData['id'].toString();
      qrEstado = responseData['estado'].toString();
    });

    print('estado del qr: $qrEstado');

    if (qrEstado == "2") {
      final url = 'https://parkuis.onrender.com/pase/$code/scan/';
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );
      print("response $response");
      print("response body ${response.body}");
    }

    if (qrEstado == "0") {
      final url = 'https://parkuis.onrender.com/pase/$code/scan/';
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );

      print(response.body);

      final String responseBody = response.body;
      Map<String, dynamic> jsonData = jsonDecode(responseBody);
      if (jsonData.containsKey('vehiculos') && jsonData['vehiculos'] is List) {
        final List<dynamic> vehiculosData = jsonData['vehiculos'];
        final List<Vehiculo> vehiculos =
            vehiculosData.map((item) => Vehiculo.fromJson(item)).toList();
        setState(() {
          result = vehiculos;
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Éxito'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Por favor, seleccione el vehículo que está entrando'),
                  SizedBox(height: 16),
                  result.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          height:
                              300, // Ajusta el tamaño del ListView según sea necesario
                          child: ListView.builder(
                            itemCount: result.length,
                            itemBuilder: (context, index) {
                              final vehiculo = result[index];
                              return Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      seleccionarVehiculo(vehiculo);
                                      Navigator.of(context).pop();
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Color.fromARGB(255, 45, 49, 51),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      margin:
                                          EdgeInsets.symmetric(vertical: 4.0),
                                      padding: EdgeInsets.all(8.0),
                                      child: ListTile(
                                        title: Text(
                                          vehiculo.placa,
                                          style: TextStyle(color: Colors.white),
                                          textAlign: TextAlign.center,
                                        ),
                                        subtitle: Text(
                                          'Modelo: ${vehiculo.modelo ?? 'N/A'}\nTipo: ${vehiculo.tipoVehiculo}\nMarca: ${vehiculo.marca}\nColor: ${vehiculo.color}',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                ],
              ),
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
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content:
                  Text('Hubo un error al escanear el pase: ${response.body}'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vigilante'),
        backgroundColor: Color.fromARGB(255, 0, 153, 255),
      ),
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
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          Text(
                            'Pulsa el botón para escanear',
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
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Center(
                          child: IconButton(
                            icon: Icon(Icons.qr_code_scanner),
                            iconSize: 50,
                            color: Colors.white,
                            onPressed: () {
                              _qrBarCodeScannerDialogPlugin.getScannedQrBarCode(
                                context: context,
                                onCode: (code) {
                                  setState(() {
                                    this.code = code!;
                                  });
                                  scanCodeAndSendRequest(code!);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
