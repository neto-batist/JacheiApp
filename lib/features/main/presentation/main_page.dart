// lib/features/main/presentation/main_page.dart
import 'package:flutter/material.dart';
import 'package:jachei_app/features/home/presentation/home_page.dart';
import 'package:jachei_app/features/profile/presentation/profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // --- AS 4 TELAS PRINCIPAIS DO APP ---
  final List<Widget> _pages = [
    const HomePage(),

    // Placeholder para a futura tela de Busca
    const Center(child: Text('Tela de Busca em Construção', style: TextStyle(fontSize: 18))),

    // Placeholder para a futura tela de Favoritos
    const Center(child: Text('Tela de Favoritos em Construção', style: TextStyle(fontSize: 18))),

    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      // Exibe a tela baseada no índice selecionado
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      // O MENU INFERIOR COMPONENTIZADO E DEFINITIVO
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed, // Permite mais de 3 itens sem "pular"
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_outline), activeIcon: Icon(Icons.favorite), label: 'Favoritos'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}