import 'dart:async';
import 'package:flame/extensions.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Cihazın ivmeölçer sensörünü yöneten ve yerçekimi verisi sağlayan servis sınıfı.
class SensorService {
  static const double _gravityScale = 25.0;

  Stream<Vector2> get gravityStream => accelerometerEventStream().map((event) => Vector2(event.x * -1, event.y) * _gravityScale);
}