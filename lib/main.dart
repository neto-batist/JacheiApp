import 'package:flutter/material.dart';
import 'package:jachei_app/core/di/configure_dependencies.dart';
import 'package:jachei_app/core/theme/app_theme.dart'; // Importe o seu tema aqui
import 'package:jachei_app/features/splash/presentation/splash_page.dart';

void main() async {
  // Garante que a engine do Flutter está pronta antes de rodar código async
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa nossa Injeção de Dependência (Dio, Prefs, etc.)
  await configureDependencies();

  runApp(const JacheiApp());
}

class JacheiApp extends StatelessWidget {
  const JacheiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jachei',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // << APONTA PARA O SEU NOVO ARQUIVO DE TEMA
      home: const SplashPage(),
    );
  }
}