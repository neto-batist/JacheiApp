import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // O BlocProvider "injeta" o Cubit nesta tela e já chama a função de buscar o GPS logo que a tela abre (..)
    return BlocProvider(
      create: (context) => HomeCubit()..getUserLocation(),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Puxa o seu Laranja configurado no AppTheme
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jachei', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // --- BARRA DE LOCALIZAÇÃO ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.08), // Um fundo laranja bem clarinho
              border: Border(
                bottom: BorderSide(color: primaryColor.withOpacity(0.2)),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, color: primaryColor), // Ícone Laranja
                const SizedBox(width: 8),

                // O BlocBuilder escuta o Cubit e atualiza SÓ este pedaço da tela
                Expanded(
                  child: BlocBuilder<HomeCubit, HomeState>(
                    builder: (context, state) {
                      if (state is HomeLoading || state is HomeInitial) {
                        return Text(
                          'Buscando sua localização...',
                          style: TextStyle(color: primaryColor, fontStyle: FontStyle.italic),
                        );
                      } else if (state is HomeLoaded) {
                        return Text(
                          state.city, // Mostra o nome da cidade
                          style: TextStyle(
                            color: primaryColor, // Texto Laranja
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis, // Se o nome for gigante, coloca "..."
                        );
                      } else if (state is HomeError) {
                        return Text(
                          state.message,
                          style: const TextStyle(color: Colors.red, fontSize: 13),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),

          // --- RESTANTE DA TELA ---
          const Expanded(
            child: Center(
              child: Text(
                'Aqui vão as categorias e recomendações!',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}