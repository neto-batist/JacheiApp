// lib/features/home/presentation/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jachei_app/core/di/configure_dependencies.dart';
import 'package:jachei_app/features/profile/presentation/profile_page.dart'; // <-- Import da tela de perfil
import '../data/home_repository.dart';
import '../data/models/prestador_model.dart';
import 'home_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(getIt<HomeRepository>())..getUserLocationAndData(),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;

  // --- MÁGICA DA NAVEGAÇÃO: Lista de Telas que a BottomBar controla ---
  final List<Widget> _pages = [
    const HomeContent(), // Aba 0: O conteúdo real da Home (Extraído para a classe abaixo)
    const Center(child: Text('Busca - Em Breve')), // Aba 1
    const Center(child: Text('Favoritos - Em Breve')), // Aba 2
    const ProfilePage(), // Aba 3: A tela de Perfil conectada!
  ];

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Jachei', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      // IndexedStack mantém o estado da tela ao trocar de aba (não recarrega a internet de novo)
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed, // Impede a barra de pular ao clicar
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Busca'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoritos'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

// ============================================================================
// CONTEÚDO DA HOME (Tudo que antes ficava direto no body veio para cá)
// ============================================================================
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  // --- Função que mapeia os nomes do banco para ícones do app ---
  IconData _getIconForCategory(String name) {
    switch (name.toLowerCase()) {
      case 'elétrica': return Icons.electrical_services;
      case 'hidráulica': return Icons.plumbing;
      case 'limpeza': return Icons.cleaning_services;
      case 'transporte': return Icons.local_shipping;
      case 'beleza': return Icons.face;
      case 'ti': return Icons.computer;
      default: return Icons.category; // Ícone genérico se o nome for novo
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Column(
      children: [
        // --- CABEÇALHO DO GPS ---
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.08),
            border: Border(bottom: BorderSide(color: primaryColor.withOpacity(0.2))),
          ),
          child: Row(
            children: [
              Icon(Icons.location_on, color: primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: BlocBuilder<HomeCubit, HomeState>(
                  builder: (context, state) {
                    if (state is HomeLoading || state is HomeInitial) {
                      return Text('Buscando localização...', style: TextStyle(color: primaryColor, fontStyle: FontStyle.italic));
                    } else if (state is HomeLoaded) {
                      return Text(state.city, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16));
                    } else if (state is HomeError) {
                      return Text('Aguardando conexão...', style: TextStyle(color: Colors.orange.shade700, fontStyle: FontStyle.italic));
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),

        // --- CORPO DA TELA (LOADING, ERRO COM RETRY OU DADOS REAIS) ---
        Expanded(
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading || state is HomeInitial) {
                return const Center(child: CircularProgressIndicator());
              }

              else if (state is HomeError) {
                // TELA DE AUTO-RETRY
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        const CircularProgressIndicator(),
                      ],
                    ),
                  ),
                );
              }

              else if (state is HomeLoaded) {
                // O APP COMPLETO COM DADOS REAIS DO BANCO
                return RefreshIndicator(
                  onRefresh: () async => context.read<HomeCubit>().getUserLocationAndData(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. BARRA DE PESQUISA
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'O que você está procurando?',
                            prefixIcon: Icon(Icons.search, color: primaryColor),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 2. CARROSSEL DE CATEGORIAS (Vindo do Spring Boot)
                        const Text('Categorias', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),

                        if (state.categorias.isEmpty)
                          const Text('Nenhuma categoria cadastrada ainda.', style: TextStyle(color: Colors.grey))
                        else
                          SizedBox(
                            height: 100, // Altura fixa para o carrossel horizontal
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemCount: state.categorias.length,
                              itemBuilder: (context, index) {
                                final cat = state.categorias[index];
                                return _buildCategoryItem(
                                    context,
                                    cat.nome,
                                    _getIconForCategory(cat.nome),
                                    primaryColor
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 24),

                        // 3. LISTA DE PRESTADORES DO SPRING BOOT
                        const Text('Recomendados na sua região', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),

                        if (state.prestadores.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Text('Nenhum prestador encontrado perto de você.'),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.prestadores.length,
                            itemBuilder: (context, index) {
                              final prestador = state.prestadores[index];
                              return _buildProviderCard(context, prestador, primaryColor);
                            },
                          ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  // --- WIDGETS AUXILIARES PARA LIMPAR O CÓDIGO ---

  Widget _buildCategoryItem(BuildContext context, String title, IconData icon, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: primaryColor, size: 30),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildProviderCard(BuildContext context, PrestadorModel prestador, Color primaryColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: primaryColor.withOpacity(0.2),
          child: Text(
              prestador.nome.isNotEmpty ? prestador.nome[0] : '?',
              style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 20)
          ),
        ),
        title: Text(prestador.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(prestador.categoriaMock),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(prestador.notaMock, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (prestador.atende24H)
              const Icon(Icons.access_time_filled, color: Colors.orange, size: 20),
            if (prestador.fazDelivery)
              const Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Icon(Icons.two_wheeler, color: Colors.teal, size: 20),
              ),
          ],
        ),
        onTap: () {
          // Futuramente: Ir para a tela de detalhes do prestador
        },
      ),
    );
  }
}