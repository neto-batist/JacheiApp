// lib/features/home/presentation/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jachei_app/core/di/configure_dependencies.dart';
import 'package:jachei_app/core/widgets/prestador_card.dart'; // Nosso componente
import 'package:jachei_app/features/profile/presentation/profile_page.dart';

import '../data/home_repository.dart';
import 'home_cubit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Fundo levemente cinza para destacar os Cards
      body: _selectedIndex == 0
      // ===================================================================
      // INJEÇÃO DO CUBIT DA HOME COM REPOSITÓRIO E PREFS
      // ===================================================================
          ? BlocProvider(
        create: (context) => HomeCubit(
          getIt<HomeRepository>(),
          getIt<SharedPreferences>(),
        )..getUserLocationAndData(),
        child: const HomeView(),
      )
          : const ProfilePage(), // Quando criar a tela de perfil, ela já entra aqui!

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: primaryColor,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {

        // ---------------------------------------------------------------------
        // ESTADO DE CARREGAMENTO
        // ---------------------------------------------------------------------
        if (state is HomeInitial || state is HomeLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // ---------------------------------------------------------------------
        // ESTADO DE ERRO (Com o Retry de 10 segundos automático)
        // ---------------------------------------------------------------------
        if (state is HomeError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(),
                ],
              ),
            ),
          );
        }

        // ---------------------------------------------------------------------
        // ESTADO DE SUCESSO (Dados carregados da API)
        // ---------------------------------------------------------------------
        if (state is HomeLoaded) {
          return CustomScrollView(
            slivers: [
              // --- APP BAR FLUTUANTE ---
              SliverAppBar(
                backgroundColor: primaryColor,
                floating: true,
                pinned: true,
                elevation: 2,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sua localização', style: TextStyle(fontSize: 12, color: Colors.white70)),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                            state.city,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                        ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: Colors.white),
                    onPressed: () {
                      // TODO: Tela de Notificações
                    },
                  ),
                ],
                // A Barra de Pesquisa acoplada à AppBar
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(70),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12)
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'O que você está procurando?',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          prefixIcon: Icon(Icons.search, color: primaryColor),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // --- CONTEÚDO DA PÁGINA (SliverToBoxAdapter para Widgets Normais) ---
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título das Categorias
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
                      child: Text('Categorias', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),

                    // Lista Horizontal de Categorias
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: state.categorias.length,
                        itemBuilder: (context, index) {
                          final categoria = state.categorias[index];
                          return _buildCategoryItem(categoria.nome, primaryColor);
                        },
                      ),
                    ),

                    // Título dos Prestadores
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
                      child: Text('Profissionais Próximos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

              // --- LISTA DE PRESTADORES (Usando o SliverList para performance infinita) ---
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final prestador = state.prestadores[index];

                      // INVOCANDO NOSSO NOVO COMPONENTE
                      return PrestadorCard(
                        prestador: prestador,
                        onTap: () {
                          // TODO: Abrir tela de detalhes do prestador
                        },
                        // A AÇÃO DE FAVORITAR CHAMA O MÉTODO NOVO DO CUBIT
                        onFavoriteTap: () {
                          context.read<HomeCubit>().toggleFavorito(prestador);
                        },
                      );
                    },
                    childCount: state.prestadores.length,
                  ),
                ),
              ),

              // Espaço extra no final da lista
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        }

        return const SizedBox.shrink(); // Fallback de segurança
      },
    );
  }

  // Método auxiliar para desenhar o ícone de categoria (Pode ser componentizado depois)
  Widget _buildCategoryItem(String nome, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: primaryColor.withOpacity(0.1),
            child: Icon(Icons.build, color: primaryColor, size: 24), // Ícone genérico por enquanto
          ),
          const SizedBox(height: 8),
          Text(
            nome.length > 12 ? '${nome.substring(0, 10)}...' : nome,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}