import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Injeta o Cubit na árvore de widgets e já manda buscar a localização
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jachei'),
      ),
      body: Column(
        children: [
          // CABEÇALHO DA LOCALIZAÇÃO
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Row(
              children: [
                Icon(Icons.location_on, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                // O BlocBuilder "escuta" o Cubit e refaz apenas este pedaço da tela
                BlocBuilder<HomeCubit, HomeState>(
                  builder: (context, state) {
                    if (state is HomeLoading || state is HomeInitial) {
                      return const Text('Buscando sua localização...');
                    } else if (state is HomeLoaded) {
                      return Text(
                        'Você está em: ${state.city}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      );
                    } else if (state is HomeError) {
                      return Text(state.message, style: const TextStyle(color: Colors.red));
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),

          // RESTANTE DA TELA (Barra de pesquisa, Categorias, etc)
          const Expanded(
            child: Center(
              child: Text('Aqui vão as recomendações próximas!'),
            ),
          ),
        ],
      ),
    );
  }
}