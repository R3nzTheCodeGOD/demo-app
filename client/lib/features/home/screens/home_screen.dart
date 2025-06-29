import 'package:flutter/material.dart';
import 'package:client/features/map/screens/map_screen.dart';
import 'package:client/features/game/screens/game_screen.dart';
import 'package:client/features/home/widgets/info_card.dart';

/// Ana sayfa
class HomeScreen extends StatelessWidget {
  final VoidCallback onThemeToggled;
  final ThemeMode currentThemeMode;

  const HomeScreen({
    super.key,
    required this.onThemeToggled,
    required this.currentThemeMode,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("R3nz App"),
        actions: <Widget>[
          IconButton(
            icon: Icon(currentThemeMode == ThemeMode.light ? Icons.wb_sunny : Icons.mode_night),
            tooltip: currentThemeMode == ThemeMode.light ? "Koyu Tema" : "Açık Tema",
            onPressed: onThemeToggled,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // Ekran genişliğinin %5'i kadar yatay boşluk
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("Hoş Geldiniz!", style: textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
              const SizedBox(height: 20),
              InfoCard(
                icon: Icons.pin_drop_outlined,
                title: "Harita",
                subtitle: "Google Maps API ile yakındaki yada seçilmiş konumdaki yerleri getiren ve gösteren modül.",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const MapScreen())),
              ),
              const SizedBox(height: 20),
              InfoCard(
                icon: Icons.gamepad_outlined,
                title: "Yerçekimi Oyunu",
                subtitle: "Telefondaki sensörleri kullanarak parçakları hareket ettirdiğimiz basit bir oyun.",
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const SimulationScreen())),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
