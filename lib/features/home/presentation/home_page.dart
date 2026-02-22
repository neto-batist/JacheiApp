// lib/features/home/presentation/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jachei_app/core/di/configure_dependencies.dart';
import 'package:jachei_app/core/widgets/prestador_card.dart';
import 'package:jachei_app/core/widgets/category_item.dart'; // <--- NOSSO NOVO COMPONENTE

import '../data/home_repository.dart';
import 'home_cubit.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Como a MainPage segura o Scaffold principal, a HomePage agora só injeta o Cubit e chama a View!
    return BlocProvider(
      create: (context) => HomeCubit(
        getIt<HomeRepository>(),
        getIt<SharedPreferences>(),
      )..getUserLocationAndData(),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {

          if (state is HomeInitial || state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HomeError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(state.message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            );
          }

          if (state is HomeLoaded) {
            return RefreshIndicator(
                color: primaryColor,
                onRefresh: () async {
                  // 2. CHAMA O MÉTODO PASSANDO A FLAG TRUE!
                  await context.read<HomeCubit>().getUserLocationAndData(isRefresh: true);
                },
                child: CustomScrollView(
                    slivers: [
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
                                Text(state.city, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                              ],
                            ),
                          ],
                        ),
                        actions: [
                          IconButton(icon: const Icon(Icons.notifications_none, color: Colors.white), onPressed: () {}),
                        ],
                        bottom: PreferredSize(
                          preferredSize: const Size.fromHeight(70),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Container(
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'O que você está procurando?',
                                  prefixIcon: Icon(Icons.search, color: primaryColor),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
                              child: Text('Categorias', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                            SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                itemCount: state.categorias.length,
                                itemBuilder: (context, index) {
                                  final categoria = state.categorias[index];
                                  // --- USANDO O COMPONENTE INTELIGENTE AQUI ---
                                  return CategoryItem(
                                    categoria: categoria,
                                    onTap: () {
                                      print("Filtrar por: ${categoria.nome}");
                                    },
                                  );
                                },
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
                              child: Text('Profissionais Próximos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),

                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                                (context, index) {
                              final prestador = state.prestadores[index];
                              return PrestadorCard(
                                prestador: prestador,
                                onTap: () {},
                                onFavoriteTap: () {
                                  context.read<HomeCubit>().toggleFavorito(prestador);
                                },
                              );
                            },
                            childCount: state.prestadores.length,
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    ],
                )
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}