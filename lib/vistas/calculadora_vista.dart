import 'dart:convert';

import '../modelos/ciudad.dart';
import '../modelos/resultado_exposicion.dart';
import '../servicios/open_meteo_api_servicio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CalculadoraCalidadAire extends StatefulWidget {
  const CalculadoraCalidadAire({super.key});

  @override
  State<CalculadoraCalidadAire> createState() => _CalculadoraCalidadAireState();
}

class _CalculadoraCalidadAireState extends State<CalculadoraCalidadAire> {
  final _estadoFormulario = GlobalKey<FormState>();
  Ciudad? _ciudadSeleccionada;
  List<Ciudad> _ciudades = [];
  DateTime _fecha = DateTime.now();
  late final TextEditingController _txtFecha;
  final _txtHoras = TextEditingController();

  String _indiceTexto = "";
  String _nivelTexto = "";
  Color _colorResultado = Colors.black;
  bool _cargando = false;

  final _openMeteoServicio = OpenMeteoApiServicio();

  @override
  void initState() {
    super.initState();
    _txtFecha = TextEditingController(
      text: OpenMeteoApiServicio.formatearFecha(_fecha),
    );
    _cargarCiudades();
  }

  @override
  void dispose() {
    _txtFecha.dispose();
    _txtHoras.dispose();
    super.dispose();
  }

  Future<void> _cargarCiudades() async {
    final datosJson = await rootBundle.loadString(
      "assets/datos/capitales_colombia.json",
    );
    final datos = jsonDecode(datosJson) as List;
    setState(() {
      _ciudades = datos.map((json) => Ciudad.fromJson(json)).toList();
    });
  }

  Future<void> _seleccionarFecha() async {
    final seleccion = await showDatePicker(
      context: context,
      firstDate: DateTime(2013),
      lastDate: DateTime.now().add(const Duration(days: 4)),
      initialDate: _fecha,
    );
    if (seleccion != null) {
      setState(() {
        _fecha = seleccion;
        _txtFecha.text = OpenMeteoApiServicio.formatearFecha(seleccion);
      });
    }
  }

  Color _colorPorNivel(NivelRiesgo nivel) {
    switch (nivel) {
      case NivelRiesgo.bajo:
        return Colors.green;
      case NivelRiesgo.moderado:
        return Colors.orange;
      case NivelRiesgo.alto:
        return Colors.red;
    }
  }

  Future<void> _calcularIndice() async {
    if (!_estadoFormulario.currentState!.validate()) return;

    final horas = double.parse(_txtHoras.text.replaceAll(",", "."));

    setState(() {
      _cargando = true;
      _indiceTexto = "Consultando calidad del aire...";
      _nivelTexto = "";
      _colorResultado = Colors.black;
    });

    try {
      final promedioPm25 = await _openMeteoServicio.getPromedioPm25(
        _ciudadSeleccionada!.latitud,
        _ciudadSeleccionada!.longitud,
        _fecha,
      );

      final resultado = ResultadoExposicion(
        promedioPm25: promedioPm25,
        horasExposicion: horas,
      );

      setState(() {
        _indiceTexto =
            "Índice de exposición: ${resultado.indice.toStringAsFixed(1)}";
        _nivelTexto = "Nivel de riesgo: ${resultado.nivelTexto}";
        _colorResultado = _colorPorNivel(resultado.nivel);
      });
    } catch (e) {
      setState(() {
        _indiceTexto = "No se pudo obtener la calidad del aire. "
            "Verifica tu conexión o intenta con otra fecha.";
        _nivelTexto = "";
        _colorResultado = Colors.red;
      });
    } finally {
      setState(() {
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculadora de Calidad del Aire')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _estadoFormulario,
          child: Column(
            children: [
              DropdownButtonFormField<Ciudad>(
                initialValue: _ciudadSeleccionada,
                decoration: const InputDecoration(
                  labelText: "Ciudad",
                  border: OutlineInputBorder(),
                ),
                items: _ciudades.map((ciudad) {
                  return DropdownMenuItem(
                    value: ciudad,
                    child: Text(ciudad.nombre),
                  );
                }).toList(),
                onChanged: (Ciudad? ciudad) {
                  setState(() {
                    _ciudadSeleccionada = ciudad;
                  });
                },
                validator: (ciudad) =>
                    ciudad == null ? "Debe seleccionar una ciudad" : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _txtFecha,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "Fecha de consulta",
                  border: OutlineInputBorder(),
                ),
                onTap: _seleccionarFecha,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _txtHoras,
                decoration: const InputDecoration(
                  labelText: "Horas de exposición diaria",
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (valor) {
                  if (valor == null || valor.trim().isEmpty) {
                    return "Debe ingresar las horas de exposición";
                  }
                  final horas = double.tryParse(valor.replaceAll(",", "."));
                  if (horas == null) {
                    return "Digite un valor numérico válido";
                  }
                  if (horas < 0 || horas > 24) {
                    return "Las horas deben estar entre 0 y 24";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _calcularIndice,
                  child: const Text("Calcular índice"),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _indiceTexto,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: _colorResultado),
                textAlign: TextAlign.center,
              ),
              Text(
                _nivelTexto,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: _colorResultado),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
