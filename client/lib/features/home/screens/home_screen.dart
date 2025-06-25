import 'package:flutter/material.dart';
import 'package:client/features/home/widgets/info_card.dart';

/// Uygulamanın ana sayfası.
/// Farklı modüllere geçişi sağlayacak.
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('R3nz App'),
        actions: [
          IconButton(
            icon: Icon(
              currentThemeMode == ThemeMode.light
                  ? Icons.wb_sunny
                  : Icons.mode_night,
            ),
            onPressed: onThemeToggled,
            tooltip: currentThemeMode == ThemeMode.light
                ? 'Koyu Tema'
                : 'Açık Tema',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          // Ekran genişliğinin %5'i kadar yatay boşluk
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.05,
            vertical: 20.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Hoş Geldiniz!',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              InfoCard(
                icon: Icons.pin_drop_outlined,
                title: "NarPOS Haritalar",
                subtitle:
                    "Google Maps API ile yakındaki yada seçilmiş konumdaki işletmeleri getiren ve gösteren modül.",
                onTap: () {
                  // modüle yönlendirme yapılacak.
                },
              ),
              const SizedBox(height: 20),
              InfoCard(
                icon: Icons.gamepad_outlined,
                title: "Test 1",
                subtitle: "xyz, xyz, xyz, xyz, xyz, xyz, xyz",
                onTap: () {
                  // yönlendirme.
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
