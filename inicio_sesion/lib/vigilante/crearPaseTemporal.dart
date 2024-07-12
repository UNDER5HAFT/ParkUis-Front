// PaseTemporalPage.dart

// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings, avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:inicio_sesion/clases/user.dart';
import '../color_picker.dart';

class PaseTemporalPage extends StatefulWidget {
  const PaseTemporalPage({Key? key}) : super(key: key);

  @override
  _PaseTemporalPageState createState() => _PaseTemporalPageState();
}

class _PaseTemporalPageState extends State<PaseTemporalPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _marcaController;
  late TextEditingController _modeloController;
  late TextEditingController _colorController;
  late String _selectedColorName;
  late String? code = "0";

  String _tipoVehiculo = '';
  List<bool> _selectedVehiculo = [false, false, false];

  final TextEditingController _letterController1 = TextEditingController();
  final TextEditingController _letterController2 = TextEditingController();
  final TextEditingController _letterController3 = TextEditingController();
  final TextEditingController _numberController1 = TextEditingController();
  final TextEditingController _numberController2 = TextEditingController();
  final TextEditingController _numberController3 = TextEditingController();

  @override
  void initState() {
    super.initState();
    _marcaController = TextEditingController();
    _modeloController = TextEditingController();
    _colorController = TextEditingController();
    _selectedColorName = '';

    // Configurar el tipo de vehículo inicial
    _selectedVehiculo[0] = true;
    _tipoVehiculo = 'Auto';
  }

  void _onVehiculoTypeSelected(int index) {
    setState(() {
      for (int i = 0; i < _selectedVehiculo.length; i++) {
        _selectedVehiculo[i] = i == index;
      }
      switch (index) {
        case 0:
          _tipoVehiculo = 'Auto';
          break;
        case 1:
          _tipoVehiculo = 'Moto';
          break;
        case 2:
          _tipoVehiculo = 'Sin Placa';
          break;
      }
    });
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
        code = responseData['id'].toString();
      });
      print("id QR: ${responseData['id']}");
    } else {
      // Manejo de error
      print('Error al crear el pase: ${response.body}');
      print("Error statuscode: ${response.statusCode}");
    }
  }

  void _onGuardarCambios() {
    if (_tipoVehiculo != 'bicicleta') {
      String placa = _letterController1.text +
          _letterController2.text +
          _letterController3.text +
          ' - ' +
          _numberController1.text +
          _numberController2.text +
          _numberController3.text;
      String? placaError = _validatePlaca(placa);
      if (placaError != null) {
        _showErrorDialog(placaError);
        return;
      }
    }

    _crearVehiculo();
  }

  String? _validatePlaca(String? value) {
    if (value == null || value.isEmpty) {
      return 'El campo no puede estar vacío';
    }
    if (_tipoVehiculo == 'Auto') {
      if (!RegExp(r'^[A-Za-z]{3}\s-\s\d{3}$').hasMatch(value)) {
        return 'La placa debe consistir de 3 letras y 3 números';
      }
    } else if (_tipoVehiculo == 'Moto') {
      if (!RegExp(r'^[A-Za-z]{3}\s-\s\d{2}[A-Za-z]$').hasMatch(value)) {
        return 'La placa debe consistir de 3 letras, 2 números y 1 letra';
      }
    }
    return null;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
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

  Future<void> _crearVehiculo() async {
    Map<String, dynamic> newData = {
      'tipo_vehiculo': _tipoVehiculo,
    };

    // Solo asignar marca, modelo y color si el tipo de vehículo es bicicleta
    if (_tipoVehiculo == 'Bicicleta') {
      newData['marca'] = _marcaController.text;
      newData['modelo'] = _modeloController.text;
      newData['color'] = _selectedColorName;
    }

    // Asignar placa si el tipo de vehículo no es bicicleta
    if (_tipoVehiculo != 'Bicicleta') {
      String placa = _letterController1.text +
          _letterController2.text +
          _letterController3.text +
          '-' +
          _numberController1.text +
          _numberController2.text +
          _numberController3.text;
      newData['placa'] = placa;
    }
    crearPase();
    String jsonNewData = jsonEncode(newData);
    print('new data: $jsonNewData');

    final response = await http.patch(
      Uri.parse('https://parkuis.onrender.com/pase/$code/scan'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token ${UserSession().token}',
      },
      body: jsonEncode({'json_vehiculo': newData}),
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 201) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Registro Exitoso'),
            content: Text('El vehículo ha sido registrado exitosamente.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Volver a la pantalla anterior
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Ocurrió un error al registrar el vehículo.'),
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

  @override
  void dispose() {
    _marcaController.dispose();
    _modeloController.dispose();
    _colorController.dispose();
    _letterController1.dispose();
    _letterController2.dispose();
    _letterController3.dispose();
    _numberController1.dispose();
    _numberController2.dispose();
    _numberController3.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required String labelText,
    required TextEditingController controller,
    required String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.grey),
      ),
      validator: validator,
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) {
        return ColorPickerDialog(
          initialColorName: _selectedColorName,
          onColorSelected: (String colorName) {
            setState(() {
              _selectedColorName = colorName;
              _colorController.text = colorName;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Pase Temporal'),
        backgroundColor: Color.fromARGB(255, 0, 153, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: ToggleButtons(
                  isSelected: _selectedVehiculo,
                  onPressed: _onVehiculoTypeSelected,
                  borderColor: Color.fromARGB(255, 0, 153, 255),
                  color: Colors.white,
                  selectedColor: Colors.white,
                  fillColor: Color.fromARGB(255, 0, 153, 255),
                  borderWidth: 2,
                  selectedBorderColor: Color.fromARGB(255, 0, 153, 255),
                  borderRadius: BorderRadius.circular(10),
                  constraints: BoxConstraints(
                    minHeight: 80.0,
                    minWidth: 100.0,
                  ),
                  children: const [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_car),
                        Text('Auto'),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.two_wheeler),
                        Text('Moto'),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.pedal_bike),
                        Text('Bicicleta'),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              if (_tipoVehiculo == 'Sin Placa') ...[
                TextFormField(
                  controller: _marcaController,
                  decoration: InputDecoration(
                    labelText: 'Marca',
                    labelStyle: TextStyle(
                      color: Color.fromARGB(255, 0, 153, 255),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 0, 153, 255),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 0, 153, 255),
                      ),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _modeloController,
                  decoration: InputDecoration(
                    labelText: 'Modelo',
                    labelStyle: TextStyle(
                      color: Color.fromARGB(255, 0, 153, 255),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 0, 153, 255),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 0, 153, 255),
                      ),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _colorController,
                  readOnly: true,
                  onTap: _showColorPicker,
                  decoration: InputDecoration(
                    labelText: 'Color',
                    labelStyle: TextStyle(
                      color: Color.fromARGB(255, 0, 153, 255),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 0, 153, 255),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 0, 153, 255),
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 0, 153, 255),
                      ),
                    ),
                    suffixIcon: Icon(
                      Icons.color_lens,
                      color: Colors.grey,
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
              ],
              if (_tipoVehiculo != 'Sin Placa') ...[
                Text(
                  'Placa',
                  style: TextStyle(
                    color: Color.fromARGB(255, 0, 153, 255),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PlateInput(
                  tipoVehiculo: _tipoVehiculo,
                  letterController1: _letterController1,
                  letterController2: _letterController2,
                  letterController3: _letterController3,
                  numberController1: _numberController1,
                  numberController2: _numberController2,
                  numberController3: _numberController3,
                ),
              ],
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _onGuardarCambios,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 0, 153, 255),
                ),
                child: Text('Crear Pase Temporal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlateInput extends StatelessWidget {
  final String tipoVehiculo;
  final TextEditingController letterController1;
  final TextEditingController letterController2;
  final TextEditingController letterController3;
  final TextEditingController numberController1;
  final TextEditingController numberController2;
  final TextEditingController numberController3;

  const PlateInput({
    Key? key,
    required this.tipoVehiculo,
    required this.letterController1,
    required this.letterController2,
    required this.letterController3,
    required this.numberController1,
    required this.numberController2,
    required this.numberController3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTextField(letterController1, 'A-Z', context),
        _buildTextField(letterController2, 'A-Z', context),
        _buildTextField(letterController3, 'A-Z', context),
        Text(
          '   -   ',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        _buildTextField(numberController1, '0-9', context),
        _buildTextField(numberController2, '0-9', context),
        _buildTextField(
            numberController3, tipoVehiculo == 'Moto' ? 'A-Z' : '0-9', context),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String allowedChars,
      BuildContext context) {
    return Container(
      width: 40,
      margin: EdgeInsets.all(4.0),
      child: TextField(
        controller: controller,
        style: TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
        maxLength: 1,
        decoration: InputDecoration(
          counterText: '', // Hide the counter
          labelStyle: TextStyle(
              color: Color.fromARGB(255, 0, 153, 255)), // Color de la etiqueta
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Color.fromARGB(255, 0, 153,
                    255)), // Color del borde cuando no está enfocado
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Color.fromARGB(
                    255, 0, 153, 255)), // Color del borde cuando está enfocado
          ),
          border: OutlineInputBorder(),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(
            RegExp(allowedChars == 'A-Z' ? r'[A-Za-z]' : r'[0-9]'),
          ),
          UpperCaseTextFormatter(),
        ],
        keyboardType:
            allowedChars == 'A-Z' ? TextInputType.text : TextInputType.number,
        onChanged: (value) {
          if (value.isNotEmpty) {
            FocusScope.of(context).nextFocus();
          }
        },
        onTap: () {
          controller.clear();
        },
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
