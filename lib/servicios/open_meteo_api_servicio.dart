import "dart:convert";

import "package:http/http.dart" as http;

class OpenMeteoApiServicio {
  static const baseUrl = "https://air-quality-api.open-meteo.com/v1/air-quality";

  /// Consulta de forma asíncrona los valores horarios de PM2.5 para [fecha]
  /// y devuelve el promedio diario. Lanza una [Exception] si no hay datos.
  Future<double> getPromedioPm25(
    double latitud,
    double longitud,
    DateTime fecha,
  ) async {
    final fechaFormateada = formatearFecha(fecha);

    final endpoint = Uri.parse(
      "$baseUrl?latitude=$latitud&longitude=$longitud&hourly=pm2_5"
      "&start_date=$fechaFormateada&end_date=$fechaFormateada&timezone=auto",
    );

    final respuesta = await http.get(endpoint);

    if (respuesta.statusCode != 200) {
      throw Exception("Error ${respuesta.statusCode} al consultar la API");
    }

    final datosJSON = jsonDecode(respuesta.body);
    final List valores = datosJSON["hourly"]["pm2_5"] ?? [];

    // Algunas horas pueden venir en null: se ignoran en el promedio.
    final validos = valores.whereType<num>().map((v) => v.toDouble()).toList();

    if (validos.isEmpty) {
      throw Exception("Sin datos de PM2.5 para la fecha seleccionada");
    }

    final suma = validos.reduce((a, b) => a + b);
    return suma / validos.length;
  }

  static String formatearFecha(DateTime fecha) {
    final mes = fecha.month.toString().padLeft(2, "0");
    final dia = fecha.day.toString().padLeft(2, "0");
    return "${fecha.year}-$mes-$dia";
  }
}
