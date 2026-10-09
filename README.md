# Calculadora de Calidad del Aire

Evaluación 3 – Programación de Dispositivos Móviles (IUPB).

App Flutter que consulta de forma asíncrona la API Air Quality de Open-Meteo,
obtiene el promedio diario de PM2.5 de una ciudad de Colombia y calcula:

    indice_exposicion = promedio_PM2_5 × horas_exposicion

| Índice  | Riesgo   |
|---------|----------|
| < 100   | Bajo     |
| 100–200 | Moderado |
| > 200   | Alto     |

## Estructura
- `lib/modelos/` – `Ciudad`, `ResultadoExposicion` (fórmula y clasificación)
- `lib/servicios/` – `OpenMeteoApiServicio` (consumo HTTP)
- `lib/vistas/` – `CalculadoraCalidadAire` (interfaz)
- `assets/datos/capitales_colombia.json` – ciudades con coordenadas

## Ejecutar
    flutter pub get
    flutter run
# Taller-3-calidad-aires
