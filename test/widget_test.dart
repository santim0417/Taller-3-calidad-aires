import 'package:calculadora_calidad_aire/modelos/resultado_exposicion.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Clasificación del índice de exposición', () {
    expect(
      ResultadoExposicion(promedioPm25: 8.1, horasExposicion: 5).nivel,
      NivelRiesgo.bajo,
    );
    expect(
      ResultadoExposicion(promedioPm25: 12, horasExposicion: 10).nivel,
      NivelRiesgo.moderado,
    );
    expect(
      ResultadoExposicion(promedioPm25: 30, horasExposicion: 10).nivel,
      NivelRiesgo.alto,
    );
  });
}
