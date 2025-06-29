import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:client/features/game/game.dart';

/// Oyun ile ilgili UI elemanlarını barındıran ekran.
class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  late final SimulationGame _game;
  final GlobalKey _gameWidgetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _game = SimulationGame();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Yerçekimi Oyunu")),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            GameWidget(key: _gameWidgetKey, game: _game),
            Positioned(
              top: 10,
              right: 10,
              child: ElevatedButton.icon(
                icon: Icon(Icons.clear, color: colorScheme.onPrimary),
                label: Text("Temizle", style: TextStyle(color: colorScheme.onPrimary)),
                onPressed: _game.clearParticles,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
