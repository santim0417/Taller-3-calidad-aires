enum NivelRiesgo { bajo, moderado, alto }

class ResultadoExposicion {
  final double promedioPm25;
  final double horasExposicion;

  ResultadoExposicion({
    required this.promedioPm25,
    required this.horasExposicion,
  });

  /// índice_exposición = promedio_PM2_5 × horas_exposición
  double get indice => promedioPm25 * horasExposicion;

  /// < 100 Bajo | 100–200 Moderado | > 200 Alto
  NivelRiesgo get nivel {
    if (indice < 100) return NivelRiesgo.bajo;
    if (indice <= 200) return NivelRiesgo.moderado;
    return NivelRiesgo.alto;
  }

  String get nivelTexto {
    switch (nivel) {
      case NivelRiesgo.bajo:
        return "Bajo";
      case NivelRiesgo.moderado:
        return "Moderado";
      case NivelRiesgo.alto:
        return "Alto";
    }
  }
}
