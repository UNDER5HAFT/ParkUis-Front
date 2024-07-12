// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings, avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:inicio_sesion/clases/user.dart';
import 'package:inicio_sesion/clases/vehiculo.dart';
import 'package:inicio_sesion/color_picker.dart';

class EditarVehiculoPage extends StatefulWidget {
  final Vehiculo vehiculo;

  const EditarVehiculoPage({Key? key, required this.vehiculo})
      : super(key: key);

  @override
  _EditarVehiculoPageState createState() => _EditarVehiculoPageState();
}

class _EditarVehiculoPageState extends State<EditarVehiculoPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _marcaController;
  late TextEditingController _modeloController;
  late TextEditingController _colorController;
  late String _selectedColorName;

  String _tipoVehiculo = '';
  List<bool> _selectedVehiculo = [false, false];

  final TextEditingController _letterController1 = TextEditingController();
  final TextEditingController _letterController2 = TextEditingController();
  final TextEditingController _letterController3 = TextEditingController();
  final TextEditingController _numberController1 = TextEditingController();
  final TextEditingController _numberController2 = TextEditingController();
  final TextEditingController _numberController3 = TextEditingController();

  @override
  void initState() {
    super.initState();
    _marcaController = TextEditingController(text: widget.vehiculo.marca);
    _modeloController = TextEditingController(text: widget.vehiculo.modelo);
    _colorController = TextEditingController(text: widget.vehiculo.color);
    _selectedColorName = widget.vehiculo.color;

    // Configurar el tipo de vehículo inicial
    switch (widget.vehiculo.tipoVehiculo) {
      case 'Auto':
        _selectedVehiculo[0] = true;
        _tipoVehiculo = 'Auto';
        break;
      case 'Moto':
        _selectedVehiculo[1] = true;
        _tipoVehiculo = 'Moto';
        break;

      default:
        _selectedVehiculo[0] = true;
        _tipoVehiculo = 'Auto';
    }

    // Asignar valores a los controladores sin la línea en la placa
    if (widget.vehiculo.placa.isNotEmpty) {
      String placaSinLinea = widget.vehiculo.placa.replaceAll('-', '');
      _letterController1.text = placaSinLinea[0];
      _letterController2.text = placaSinLinea[1];
      _letterController3.text = placaSinLinea[2];
      _numberController1.text = placaSinLinea[3];
      _numberController2.text = placaSinLinea[4];
      _numberController3.text = placaSinLinea[5];
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

  Future<void> _editarVehiculo() async {
    Map<String, dynamic> editedData = {};
    if (_marcaController.text.isNotEmpty &&
        _marcaController.text != widget.vehiculo.marca) {
      editedData['marca'] = _marcaController.text;
    }
    if (_modeloController.text.isNotEmpty &&
        _modeloController.text != widget.vehiculo.modelo) {
      editedData['modelo'] = _modeloController.text;
    }
    if (_selectedColorName.isNotEmpty &&
        _selectedColorName != widget.vehiculo.color) {
      editedData['color'] = _selectedColorName;
    }
    if (_tipoVehiculo.isNotEmpty &&
        _tipoVehiculo != widget.vehiculo.tipoVehiculo) {
      editedData['tipo_vehiculo'] = _tipoVehiculo;
    }
    {
      String placa = _letterController1.text +
          _letterController2.text +
          _letterController3.text +
          '-' +
          _numberController1.text +
          _numberController2.text +
          _numberController3.text;
      if (placa.isNotEmpty && placa != widget.vehiculo.placa) {
        editedData['placa'] = placa;
      }
    }

    if (editedData.isNotEmpty) {
      String? token = UserSession().token;
      if (token == null) {
        print('Token no disponible');
        return;
      }

      String jsonEditedData = jsonEncode(editedData);
      print('edited data: $jsonEditedData');
      print('id vehiculo ${widget.vehiculo.id}');
      print({UserSession().token});
      final response = await http.put(
        Uri.parse(
            'https://parkuis.onrender.com/users/vehiculo/editar/${widget.vehiculo.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token ${UserSession().token}',
        },
        body: jsonEditedData,
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        print(response.statusCode);
        print(response.body);
        print("toekn: $token");
        Navigator.of(context).pop(true); // Indicar que la edición fue exitosa
      } else {
        print('Error al editar el vehículo: ${response.statusCode}');
        print('ha fallado porque ${response.body}');
      }
    } else {
      Navigator.of(context).pop(false); // No hubo cambios
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
    {
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

    if (_formKey.currentState!.validate()) {
      _editarVehiculo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Vehículo'),
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
              Text(
                'Placa',
                style: TextStyle(
                  color: Color.fromARGB(255, 103, 165, 62),
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
