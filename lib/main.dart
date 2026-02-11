import 'package:flutter/material.dart';
import 'package:jachei_app/core/di/configure_dependencies.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
        // Configuração básica de inputs para ficar bonito
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
      ),
      home: const Scaffold(
        body: Center(child: Text("Jachei - Backend Conectado!")),
      ),
    );
  }
}