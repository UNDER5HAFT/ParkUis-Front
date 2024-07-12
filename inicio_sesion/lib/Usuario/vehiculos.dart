// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:inicio_sesion/Usuario/Funciones/crear_vehiculo.dart';
import 'package:inicio_sesion/Usuario/Funciones/eliminar_vehiculo.dart';
import 'package:inicio_sesion/clases/user.dart';
import 'package:inicio_sesion/clases/vehiculo.dart';
import 'package:inicio_sesion/Usuario/Funciones/editar_vehiculo.dart';

class VehiculoPage extends StatefulWidget {
  final String result;

  const VehiculoPage({Key? key, required this.result}) : super(key: key);

  @override
  _VehiculoPageState createState() => _VehiculoPageState();
}

class _VehiculoPageState extends State<VehiculoPage> {
  bool isLoading = true;
  List<Vehiculo> result = [];
  bool _hasFetchedVehiculos = false;

  @override
  void initState() {
    super.initState();
    processHeredatedData(widget.result);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasFetchedVehiculos) {
      obtenerVehiculos();
      _hasFetchedVehiculos = true;
    }
  }

  Future<void> processHeredatedData(String result) async {
    Map<String, dynamic> jsonData = jsonDecode(result);
    UserSession().token = jsonData['token']; // Guardar el token en UserSession

    setState(() {
      isLoading = false;
    });
  }

  Future<void> obtenerVehiculos() async {
    print("token: ${UserSession().token}");
    if (UserSession().token == null) {
      print('Error: Token es nulo o está vacío');
      return;
    }
    try {
      final response = await http.get(
        Uri.parse('https://parkuis.onrender.com/users/vehiculo/mis-vehiculos'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Token ${UserSession().token}',
        },
      );
      if (response.body.isEmpty) {
        print("Cuerpo de respuesta vacío o nulo.");
        return;
      }
      print("statuscode: ${response.statusCode}");

      if (response.statusCode == 200) {
        final String responseBody = utf8.decode(response.bodyBytes);
        print("responsebody: $responseBody");
        final List<dynamic> jsonData = jsonDecode(responseBody);
        print("jsondata: $jsonData");
        final List<Vehiculo> vehiculos =
            jsonData.map((item) => Vehiculo.fromJson(item)).toList();
        print("lisitavehiculos: $vehiculos");

        setState(() {
          result = vehiculos;
        });
      } else {
        print('Error al obtener los datos: ${response.statusCode}');
      }
      print("status code vehiculo: ${response.statusCode}");
    } catch (e) {
      print('Error: $e');
    }
  }

  void _navigateToEditarVehiculo(Vehiculo vehiculo) async {
    bool? result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditarVehiculoPage(vehiculo: vehiculo),
      ),
    );
    if (result == true) {
      obtenerVehiculos();
    }
  }

  void _navigateToCrearVehiculo(BuildContext context) async {
    bool? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CrearVehiculoPage()),
    );
    if (result == true) {
      obtenerVehiculos();
    }
  }

  void _showEliminarVehiculoDialog(
      BuildContext context, Vehiculo vehiculo) async {
    bool? result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return EliminarVehiculoPage(vehiculo: vehiculo);
      },
    );
    if (result == true) {
      obtenerVehiculos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Vehículos Asociados:',
                      style: TextStyle(
                          fontSize: 24,
                          color: Color.fromARGB(255, 136, 142, 116)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    result.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : Expanded(
                            child: ListView.builder(
                              itemCount: result.length,
                              itemBuilder: (context, index) {
                                final vehiculo = result[index];
                                return Column(
                                  children: [
                                    GestureDetector(
                                      onLongPress: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text(
                                                'Opciones del vehículo \n ${vehiculo.placa}',
                                                textAlign: TextAlign.center,
                                              ),
                                              content: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                      _navigateToEditarVehiculo(
                                                          vehiculo);
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Color.fromARGB(255,
                                                              103, 165, 62),
                                                    ),
                                                    child: Text('Editar'),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                      _showEliminarVehiculoDialog(
                                                          context, vehiculo);
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Color.fromARGB(255,
                                                              103, 165, 62),
                                                    ),
                                                    child: Text('Eliminar'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color:
                                              Color.fromARGB(255, 45, 49, 51),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        margin:
                                            EdgeInsets.symmetric(vertical: 4.0),
                                        padding: EdgeInsets.all(8.0),
                                        child: ListTile(
                                          title: Text(
                                            vehiculo.placa,
                                            style:
                                                TextStyle(color: Colors.white),
                                            textAlign: TextAlign.center,
                                          ),
                                          subtitle: Text(
                                            'Modelo: ${vehiculo.modelo ?? 'N/A'}\nTipo: ${vehiculo.tipoVehiculo}\nMarca: ${vehiculo.marca}\nColor: ${vehiculo.color}',
                                            textAlign: TextAlign.center,
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                    SizedBox(
                      width: 1000,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {
                          _navigateToCrearVehiculo(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 103, 165, 62),
                        ),
                        child: Text('Crear'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
