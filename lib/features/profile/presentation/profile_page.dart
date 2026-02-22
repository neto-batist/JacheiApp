// lib/features/profile/presentation/profile_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jachei_app/core/di/configure_dependencies.dart';
import 'package:jachei_app/features/auth/presentation/login_page.dart';
import '../data/repositories/profile_repository.dart';
import 'profile_cubit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit(
        getIt<ProfileRepository>(),
        getIt<SharedPreferences>(),
      )..loadProfile(),
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  // Função isolada para abrir a galeria e chamar o Cubit
  Future<void> _selecionarEEnviarFoto(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (image != null && context.mounted) {
      context.read<ProfileCubit>().atualizarFoto(File(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {

          if (state is ProfileInitial || state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileError && context.read<ProfileCubit>().state is! ProfileLoaded) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  ElevatedButton(
                    onPressed: () => context.read<ProfileCubit>().loadProfile(),
                    child: const Text('Tentar Novamente'),
                  )
                ],
              ),
            );
          }

          if (state is ProfileLoaded) {
            final user = state.user;
            final prestador = state.prestador; // Pode ser null!

            return RefreshIndicator(
              color: primaryColor,
              onRefresh: () async {
                await context.read<ProfileCubit>().loadProfile(isRefresh: true);
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                children: [

                  // ===========================================================
                  // SEÇÃO 1: DADOS BASE DO USUÁRIO (Sempre visível)
                  // ===========================================================
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: primaryColor.withOpacity(0.1),
                          backgroundImage: user.linkFoto.isNotEmpty ? NetworkImage(user.linkFoto) : null,
                          child: user.linkFoto.isEmpty
                              ? Icon(Icons.person, size: 50, color: primaryColor)
                              : null,
                        ),
                        GestureDetector(
                          onTap: () => _selecionarEEnviarFoto(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(child: Text(user.nome, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
                  Center(child: Text(user.email, style: TextStyle(color: Colors.grey.shade600, fontSize: 16))),

                  const SizedBox(height: 32),

                  // ===========================================================
                  // SEÇÃO 2: A DIVISÃO INTELIGENTE (Usuário VS Prestador)
                  // ===========================================================

                  if (prestador != null) ...[
                    // --- LAYOUT EXCLUSIVO DO PRESTADOR ---
                    const Text('Meu Painel Profissional', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    // Card de Status
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(prestador.servicoPrincipal, style: TextStyle(fontSize: 16, color: primaryColor, fontWeight: FontWeight.bold)),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 20),
                                    const SizedBox(width: 4),
                                    Text(prestador.mediaAvaliacoes.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Text(prestador.descricaoBio, style: TextStyle(color: Colors.grey.shade700)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Galeria do Portfólio
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Meu Portfólio (${prestador.qtdFotosServicos}/15)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        TextButton.icon(
                            onPressed: () { /* TODO: Tela de Upload de Trabalho */ },
                            icon: const Icon(Icons.add),
                            label: const Text('Adicionar Foto')
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (prestador.portifolio.isEmpty)
                      const Center(child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('Nenhuma foto de trabalho adicionada.'),
                      ))
                    else
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: prestador.portifolio.length,
                          itemBuilder: (context, index) {
                            final foto = prestador.portifolio[index];
                            return Container(
                              width: 100,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage(foto.urlFoto),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 32),
                  ] else ...[
                    // --- LAYOUT DO USUÁRIO COMUM ---
                    Card(
                      elevation: 0,
                      color: primaryColor.withOpacity(0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Icon(Icons.storefront, color: primaryColor, size: 32),
                        title: const Text('Trabalha por conta própria?', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Torne-se um prestador e receba clientes.'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // TODO: Abrir tela de "Upgrade" para Prestador
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // ===========================================================
                  // SEÇÃO 3: MENU COMUM PARA TODOS
                  // ===========================================================
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        ListTile(leading: const Icon(Icons.person_outline), title: const Text('Editar Meus Dados'), trailing: const Icon(Icons.chevron_right), onTap: () {}),
                        const Divider(height: 1),
                        ListTile(leading: const Icon(Icons.location_on_outlined), title: const Text('Meus Endereços'), trailing: const Icon(Icons.chevron_right), onTap: () {}),
                        const Divider(height: 1),
                        ListTile(leading: const Icon(Icons.help_outline), title: const Text('Ajuda e Suporte'), trailing: const Icon(Icons.chevron_right), onTap: () {}),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.logout, color: Colors.red),
                          title: const Text('Sair', style: TextStyle(color: Colors.red)),
                          onTap: () {
                            context.read<ProfileCubit>().logout().then((_) {
                              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}