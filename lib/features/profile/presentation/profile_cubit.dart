// lib/features/profile/presentation/profile_cubit.dart
import 'dart:io'; // Necessário para a manipulação do arquivo da foto
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/repositories/profile_repository.dart';
import '../data/models/user_model.dart';
import '../data/models/prestador_detalhado_model.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserModel user;
  final PrestadorDetalhadoModel? prestador; // Nulo se for apenas usuário comum!

  ProfileLoaded({
    required this.user,
    this.prestador,
  });
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository repository;
  final SharedPreferences prefs;

  ProfileCubit(this.repository, this.prefs) : super(ProfileInitial());

  // ===========================================================================
  // CARREGAR DADOS (Busca Usuário e Painel Simultaneamente)
  // ===========================================================================
  Future<void> loadProfile({bool isRefresh = false}) async {
    if (!isRefresh && state is! ProfileError) emit(ProfileLoading());

    try {
      final uid = prefs.getString('user_uid');
      if (uid == null) throw Exception('Sessão expirada. Faça login novamente.');

      // O Segredo da Performance: Disparamos as duas requisições ao mesmo tempo!
      // A segunda requisição vai voltar nula graciosamente se ele não for prestador.
      final results = await Future.wait([
        repository.getUserProfile(uid),
        repository.getPrestadorPanel(),
      ]);

      final user = results[0] as UserModel;
      final prestador = results[1] as PrestadorDetalhadoModel?;

      emit(ProfileLoaded(user: user, prestador: prestador));
    } catch (e) {
      emit(ProfileError('Erro ao carregar os dados do perfil. Verifique sua conexão.'));
    }
  }

  // ===========================================================================
  // ATUALIZAR FOTO DE PERFIL
  // ===========================================================================
  Future<void> atualizarFoto(File foto) async {
    // Só podemos atualizar se a tela já estiver carregada com os dados base
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;

      // Emitimos o Loading para a UI mostrar que a foto está subindo para o servidor
      emit(ProfileLoading());

      try {
        final uid = prefs.getString('user_uid');
        if (uid == null) throw Exception('Sessão expirada.');

        // Faz o upload real
        final userAtualizado = await repository.atualizarFotoPerfil(uid, foto);

        // Devolvemos a tela reconstruída com a nova foto, mantendo os dados do prestador intactos
        emit(ProfileLoaded(user: userAtualizado, prestador: currentState.prestador));
      } catch (e) {
        // Se a foto falhar (ex: arquivo muito grande), avisa e volta o estado de antes
        emit(ProfileError('Erro ao enviar a foto. Tente novamente.'));
        await Future.delayed(const Duration(seconds: 3));
        emit(ProfileLoaded(user: currentState.user, prestador: currentState.prestador));
      }
    }
  }

  // ===========================================================================
  // SAIR DA CONTA
  // ===========================================================================
  Future<void> logout() async {
    await prefs.remove('auth_token');
    await prefs.remove('user_uid');
  }
}