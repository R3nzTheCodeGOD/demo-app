import 'dart:io';
import 'package:flutter/material.dart';
import 'package:client/core/config/app_theme.dart';
import 'package:client/features/home/screens/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// backendde sertifika yok
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    // kDebugMode ? true : false
    return super.createHttpClient(context)..badCertificateCallback = ((X509Certificate cert, String host, int port) => true); 
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  dotenv.load(fileName: ".env");
  runApp(const R3nzClient());
}

class R3nzClient extends StatefulWidget {
  const R3nzClient({super.key});

  @override
  State<R3nzClient> createState() => _R3nzClientState();
}

class _R3nzClientState extends State<R3nzClient> {
  ThemeMode _currentThemeMode = ThemeMode.dark;

  void _toggleThemeMode() => setState(() => _currentThemeMode = _currentThemeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "R3nz App",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _currentThemeMode,
      home: HomeScreen(onThemeToggled: _toggleThemeMode, currentThemeMode: _currentThemeMode),
    );
  }
}
