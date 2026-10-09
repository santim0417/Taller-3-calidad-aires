class Ciudad {
  final String nombre;
  final double latitud;
  final double longitud;

  Ciudad({
    required this.nombre,
    required this.latitud,
    required this.longitud,
  });

  factory Ciudad.fromJson(Map<String, dynamic> json) {
    return Ciudad(
      nombre: json['nombre'],
      latitud: (json['latitud'] as num).toDouble(),
      longitud: (json['longitud'] as num).toDouble(),
    );
  }
}
