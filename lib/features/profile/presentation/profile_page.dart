// lib/features/profile/presentation/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jachei_app/core/di/configure_dependencies.dart';
import 'package:jachei_app/features/auth/presentation/sign_up_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/profile_repository.dart';
import 'profile_cubit.dart';
import 'dart:io';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit(getIt<ProfileRepository>(), getIt<SharedPreferences>())..loadProfile(),
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: BlocConsumer<ProfileCubit, ProfileState>(
        // --- O LISTENER PEGA OS ERROS SEM DESTRUIR A TELA ---
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade800,
                behavior: SnackBarBehavior.floating, // Fica "flutuando" na tela
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          // O ProfileError só aparece centralizado se o Perfil falhar em carregar ao abrir a tela
          else if (state is ProfileError && context.read<ProfileCubit>().state is! ProfileLoaded) {
            return Center(child: Text(state.message));
          }
          else if (state is ProfileLoaded) {
            final user = state.user;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  // --- FOTO DE PERFIL COM BOTÃO DE EDITAR ---
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: primaryColor.withOpacity(0.2),
                        // Usa a foto do Banco, se não houver exibe algo genérico
                        backgroundImage: user.linkFoto.isNotEmpty ? NetworkImage(user.linkFoto) : null,
                        child: user.linkFoto.isEmpty
                            ? Text(user.nome[0], style: TextStyle(fontSize: 40, color: primaryColor))
                            : null,
                      ),
                      GestureDetector(
                        onTap: () => context.read<ProfileCubit>().pickAndUploadPhoto(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2), // Borda branca para destacar o botão
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- NOME E EMAIL ---
                  Text(user.nome, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text(user.email, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 32),

                  // --- MENU DE OPÇÕES ---
                  _buildMenuTile(
                      icon: Icons.person_outline,
                      title: 'Editar Dados',
                      onTap: () { /* Navegar para Form de Edição */ }
                  ),

                  if (state.isPrestador)
                    _buildMenuTile(
                        icon: Icons.work,
                        title: 'Meu Painel de Prestador',
                        iconColor: Colors.green,
                        onTap: () { /* Navegar para Painel */ }
                    )
                  else
                    _buildMenuTile(
                        icon: Icons.storefront,
                        title: 'Torne-se um Prestador de Serviços',
                        iconColor: primaryColor,
                        onTap: () { /* Navegar para Form de Cadastro de Prestador */ }
                    ),

                  _buildMenuTile(
                      icon: Icons.settings,
                      title: 'Configurações',
                      onTap: () { /* Navegar para Configurações */ }
                  ),

                  const Divider(height: 32),

                  _buildMenuTile(
                      icon: Icons.logout,
                      title: 'Sair da Conta',
                      iconColor: Colors.red,
                      textColor: Colors.red,
                      onTap: () {
                        context.read<ProfileCubit>().logout();
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const SignUpPage()));
                      }
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // Widget auxiliar para os botões do menu
  Widget _buildMenuTile({required IconData icon, required String title, required VoidCallback onTap, Color? iconColor, Color? textColor}) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? Colors.grey.shade700),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}