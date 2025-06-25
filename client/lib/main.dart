import 'package:flutter/material.dart';
import 'package:client/core/config/app_theme.dart';
import 'package:client/features/home/screens/home_screen.dart';

// Uygulamanın başlangıç noktası.
void main() => runApp(const R3nzClient());

/// Ana uygulama widget'ı.
/// Tema yönetimi ve başlangıç sayfasını merkezi olarak yöneticek.
class R3nzClient extends StatefulWidget {
  const R3nzClient({super.key});

  @override
  State<R3nzClient> createState() => _R3nzClientState();
}

class _R3nzClientState extends State<R3nzClient> {
  // Mevcut tema modu state'i.
  ThemeMode _currentThemeMode = ThemeMode.dark;

  /// Temayı açık ve koyu mod arasında değiştirir.
  void _toggleThemeMode() {
    setState(() {
      _currentThemeMode = _currentThemeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'R3nz App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _currentThemeMode,
      home: HomeScreen(
        onThemeToggled: _toggleThemeMode,
        currentThemeMode: _currentThemeMode,
      ),
    );
  }
}
