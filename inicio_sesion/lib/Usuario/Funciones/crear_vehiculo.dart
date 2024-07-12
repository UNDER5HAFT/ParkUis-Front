// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings, avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:inicio_sesion/clases/user.dart';
import 'package:inicio_sesion/color_picker.dart';

class CrearVehiculoPage extends StatefulWidget {
  const CrearVehiculoPage({Key? key}) : super(key: key);

  @override
  _CrearVehiculoPageState createState() => _CrearVehiculoPageState();
}

class _CrearVehiculoPageState extends State<CrearVehiculoPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _marcaController;
  late TextEditingController _modeloController;
  late TextEditingController _colorController;
  late String _selectedColorName;

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

  Future<void> _crearVehiculo() async {
    Map<String, dynamic> newData = {
      'tipo_vehiculo': _tipoVehiculo,
      'marca': _marcaController.text,
      'modelo': _modeloController.text,
      'color': _selectedColorName,
    };

    if (_tipoVehiculo != 'bicicleta') {
      String placa = _letterController1.text +
          _letterController2.text +
          _letterController3.text +
          '-' +
          _numberController1.text +
          _numberController2.text +
          _numberController3.text;
      newData['placa'] = placa;
    }

    String? token = UserSession().token;
    if (token == null) {
      print('Token no disponible');
      return;
    }

    String jsonNewData = jsonEncode(newData);
    print('new data: $jsonNewData');
    final response = await http.post(
      Uri.parse('https://parkuis.onrender.com/users/vehiculo/crear'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
      body: jsonNewData,
    );

    print("responde: ${response.body}");
    print("codigo: ${response.statusCode}");
    if (response.statusCode == 201) {
      // Asegúrate de usar el context correcto
      if (!mounted) return;

      // Mostrar el diálogo de éxito
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Vehículo Creado'),
            content: Text('Vehículo creado exitosamente.'),
          );
        },
      );

      Future.delayed(Duration(seconds: 1), () {
        if (!mounted) return;
        Navigator.of(context).pop();
        Navigator.of(context).pop(true);
      });
    } else {
      print('Error al crear el vehículo: ${response.statusCode}');
      print('ha fallado porque $response');
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Vehículo'),
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
                  borderColor: Color.fromARGB(255, 103, 165, 62),
                  color: Colors.white,
                  selectedColor: Colors.white,
                  fillColor: Color.fromARGB(255, 103, 165, 62),
                  borderWidth: 2,
                  selectedBorderColor: Color.fromARGB(255, 103, 165, 62),
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
              TextFormField(
                controller: _marcaController,
                decoration: InputDecoration(
                  labelText: 'Marca',
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _modeloController,
                decoration: InputDecoration(
                  labelText: 'Modelo',
                  border: OutlineInputBorder(),
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
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(
                    Icons.color_lens,
                    color: Colors.grey,
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 16.0),
              if (_tipoVehiculo != 'Sin Placa')
                Text(
                  'Placa',
                  style: TextStyle(
                    color: Color.fromARGB(255, 103, 165, 62),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (_tipoVehiculo != 'Sin Placa')
                PlateInput(
                  tipoVehiculo: _tipoVehiculo,
                  letterController1: _letterController1,
                  letterController2: _letterController2,
                  letterController3: _letterController3,
                  numberController1: _numberController1,
                  numberController2: _numberController2,
                  numberController3: _numberController3,
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _onGuardarCambios,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 103, 165, 62),
                ),
                child: Text('Guardar Cambios'),
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
          style: TextStyle(color: Colors.white),
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
