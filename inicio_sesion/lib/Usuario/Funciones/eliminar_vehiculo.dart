// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:inicio_sesion/clases/user.dart';
import 'package:inicio_sesion/clases/vehiculo.dart';

class EliminarVehiculoPage extends StatefulWidget {
  final Vehiculo vehiculo;

  const EliminarVehiculoPage({Key? key, required this.vehiculo})
      : super(key: key);

  @override
  _EliminarVehiculoPageState createState() => _EliminarVehiculoPageState();
}

class _EliminarVehiculoPageState extends State<EliminarVehiculoPage> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _eliminarVehiculo() async {
    String? token = UserSession().token;
    if (token == null) {
      print('Token no disponible');
      return;
    }

    final response = await http.delete(
      Uri.parse(
          'https://parkuis.onrender.com/users/vehiculo/eliminar/${widget.vehiculo.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
    );

    print(response.statusCode);
    if (response.statusCode == 200) {
      Navigator.of(context).pop(true); // Indica que la operación fue exitosa
      _showResultDialog('Vehículo eliminado correctamente');
    } else {
      print('Error al eliminar el vehículo: ${response.statusCode}');
      print('ha fallado porque ${response.body}');
      Navigator.of(context).pop(false); // Indica que la operación falló
      _showResultDialog('Error al eliminar el vehículo');
    }
  }

  void _showResultDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Resultado'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('¿Deseas eliminar el vehículo?'),
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                _eliminarVehiculo();
              },
              child: Text('Eliminar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 103, 165, 62),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Image.asset('images/Stella.png'),
          ),
        ],
      ),
    );
  }
}
