import 'package:flutter/material.dart';

class ColorPickerDialog extends StatefulWidget {
  final String initialColorName;
  final Function(String) onColorSelected;

  ColorPickerDialog({
    required this.initialColorName,
    required this.onColorSelected,
  });

  @override
  _ColorPickerDialogState createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late String _selectedColorName;

  final Map<String, Color> _colorMap = {
    'Negro': Colors.black,
    'Blanco': Colors.white,
    'Rojo': Colors.red,
    'Verde': Colors.green,
    'Azul': Colors.blue,
    'Amarillo': Colors.yellow,
    'Gris': Colors.grey,
  };

  @override
  void initState() {
    super.initState();
    _selectedColorName = widget.initialColorName;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Seleccionar Color'),
      content: SingleChildScrollView(
        child: Column(
          children: _colorMap.keys.map((String colorName) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: _colorMap[colorName],
              ),
              title: Text(colorName),
              onTap: () {
                widget.onColorSelected(colorName);
                Navigator.of(context).pop();
              },
              selected: _selectedColorName == colorName,
            );
          }).toList(),
        ),
      ),
    );
  }
}
