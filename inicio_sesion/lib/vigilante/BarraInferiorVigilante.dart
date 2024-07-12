// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:inicio_sesion/vigilante/crearPaseTemporal.dart';
import 'package:inicio_sesion/vigilante/vigilante.dart';

class VigilanteUser extends StatefulWidget {
  final String result;

  const VigilanteUser({Key? key, required this.result}) : super(key: key);
  @override
  _VigilanteUserState createState() => _VigilanteUserState();
}

class _VigilanteUserState extends State<VigilanteUser> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      DatosVigilantePage(result: widget.result),
      PaseTemporalPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Escaneo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note_add),
            label: 'Pase Temporal',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Color.fromARGB(
            255, 0, 153, 255), // Color de fondo del BottomNavigationBar
        fixedColor: Colors.white, // Color del cuadrado seleccionado
      ),
    );
  }
}
