import 'package:flutter/material.dart';

class AppTheme {
  // 1. Definimos as cores principais como constantes para facilitar o reuso
  static const Color primaryColor = Color(0xFFFF1B00);

  // 2. Criamos o Tema Claro (Light Theme)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      // Gera uma paleta de cores combinando com o seu azul
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
      ),
      primaryColor: primaryColor,

      // Padroniza a AppBar (barra do topo) para todo o app
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white, // Cor do texto e ícones na barra
        centerTitle: true,
        elevation: 0,
      ),

      // A sua configuração de inputs de texto mantida e centralizada
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),

      // Aqui no futuro podemos colocar elevatedButtonTheme, textTheme, etc.
    );
  }
}