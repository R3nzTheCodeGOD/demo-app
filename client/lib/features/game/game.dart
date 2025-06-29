import 'dart:async';
import 'dart:math';
import 'package:flame/events.dart';
import 'package:flame/image_composition.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:client/core/services/sensor_service.dart';
import 'package:client/features/game/components/particle.dart';
import 'package:client/features/game/components/wall.dart';

/// Forge2D tabanlı fizik simülasyonu oyun motoru.
class SimulationGame extends Forge2DGame with TapDetector, PanDetector {
  static const double worldWidth = 100.0;
  static const double particleMinRadius = 3;
  static const double particleMaxRadius = 3.5;
  static const Duration minTimeBetweenParticles = Duration(milliseconds: 25);

  late final double _worldHeight;
  final SensorService _sensorService = SensorService();
  late StreamSubscription _gravitySubscription;

  Duration _lastUpdateTime = Duration(milliseconds: 0);

  SimulationGame() : super(world: Forge2DWorld(), zoom: 1) {
    world.gravity = Vector2(0, 9.8 * 20);
  }

  @override
  Color backgroundColor() => const Color(0xFF141414);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final screenAspectRatio = size.x / size.y;
    _worldHeight = worldWidth / screenAspectRatio;
    camera.viewfinder.zoom = size.x / worldWidth + 0.01;
    camera.viewfinder.position = Vector2(worldWidth / 2, _worldHeight / 2);

    final worldBoundaries = Wall.createBoundaries(Vector2(worldWidth, _worldHeight));
    for (final wall in worldBoundaries) {
      world.add(wall);
    }

    _addInitialParticles();
    _setupSensorListener();
  }

  // oyundan çıkınca streami kapat
  @override
  void onRemove() {
    _gravitySubscription.cancel();
    super.onRemove();
  }

  Future<void> _addInitialParticles() async {
    final random = Random();
    for (var i = 0; i < 50; i++) {
      final position = Vector2(random.nextDouble() * worldWidth, random.nextDouble() * _worldHeight);
      final radius = particleMinRadius + random.nextDouble() * (particleMaxRadius - particleMinRadius);
      world.add(MyParticle(initialPosition: position, radius: radius));
    }
  }

  Future<void> _setupSensorListener() async {
    _gravitySubscription = _sensorService.gravityStream.listen((gravity) => world.gravity.setFrom(gravity));
  }

  @override
  void handleTapDown(TapDownDetails details) {
    _addParticleAtLocation(camera.globalToLocal(details.localPosition.toVector2()));
  }

  @override
  void handlePanUpdate(DragUpdateDetails details) {
    final elapsedTime = details.sourceTimeStamp! - _lastUpdateTime;
    if (elapsedTime >= minTimeBetweenParticles) {
      _addParticleAtLocation(camera.globalToLocal(details.localPosition.toVector2()));
      _lastUpdateTime = details.sourceTimeStamp!;
    }
  }

  Future<void> _addParticleAtLocation(Vector2 worldCoordinates) async {
    final radius = particleMinRadius + Random().nextDouble() * (particleMaxRadius - particleMinRadius);
    world.add(MyParticle(initialPosition: worldCoordinates, radius: radius));
  }

  Future<void> clearParticles() async {
    final particles = world.children.whereType<MyParticle>().toList();
    for (final particle in particles) {
      world.remove(particle);
    }
  }
}
