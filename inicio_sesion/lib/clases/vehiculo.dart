class Vehiculo {
  final int id;
  final String tipoVehiculo;
  final String marca;
  final String? modelo; // Puede ser null
  final String color;
  final String placa;
  final int usuarioID;

  Vehiculo({
    required this.id,
    required this.tipoVehiculo,
    required this.marca,
    this.modelo,
    required this.color,
    required this.placa,
    required this.usuarioID,
  });

  factory Vehiculo.fromJson(Map<String, dynamic> json) {
    return Vehiculo(
      id: json['id'],
      tipoVehiculo: json['tipo_vehiculo'],
      marca: json['marca'],
      modelo: json['modelo'],
      color: json['color'],
      placa: json['placa'],
      usuarioID: json['usuarioID'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'placa': placa,
      'modelo': modelo,
      'tipoVehiculo': tipoVehiculo,
      'marca': marca,
      'color': color,
    };
  }
}
