import 'package:flutter/material.dart';

/// Uygulama Tema Sınıfı
class AppTheme {
  // Ana renk en sevdiğim renk
  static const Color _primaryColor = Color(0xffff961f);

  // Ortak AppBar tema ayarları.
  static final AppBarTheme _appBarTheme = AppBarTheme(
    elevation: 4,
    shadowColor: Colors.black.withOpacity(0.7),
    surfaceTintColor: Colors.transparent,
    toolbarHeight: 60,
    titleTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  );

  // Ortak Card tema ayarları.
  static final CardThemeData _cardTheme = CardThemeData(
    elevation: 4,
    shadowColor: Colors.black.withOpacity(0.7),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
  );

  // Açık tema verileri.
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.light,
    ),
    appBarTheme: _appBarTheme.copyWith(
      backgroundColor: _primaryColor,
      foregroundColor: Colors.white,
    ),
    cardTheme: _cardTheme,
  );

  // Koyu tema verileri.
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xff121212),
    cardColor: const Color(0xff212121),
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.dark,
    ),
    appBarTheme: _appBarTheme.copyWith(
      backgroundColor: const Color(0xff212121),
      foregroundColor: Colors.white,
    ),
    cardTheme: _cardTheme.copyWith(
      // color: const Color(0xff212121),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white70),
      bodyMedium: TextStyle(color: Colors.white60),
      headlineMedium: TextStyle(color: Colors.white),
    ),
  );
}
