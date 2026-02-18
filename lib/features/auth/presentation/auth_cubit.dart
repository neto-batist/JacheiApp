// lib/features/auth/presentation/auth_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/auth_repository.dart';

abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;
  final SharedPreferences prefs;

  AuthCubit(this.repository, this.prefs) : super(AuthInitial());

  Future<void> cadastrar(String nome, String email, String senha) async {
    // Validação simples
    if (nome.isEmpty || email.isEmpty || senha.isEmpty) {
      emit(AuthError('Preencha todos os campos.'));
      return;
    }

    emit(AuthLoading());

    try {
      // 1. Cadastra no Backend
      final String uid = await repository.cadastrarUsuario(nome, email);

      // 2. Salva o status de "Logado" no celular
      await prefs.setString('user_uid', uid);
      await prefs.setString('user_nome', nome); // Bônus: Salva o nome para usar no Perfil depois

      // 3. Sucesso!
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError('Erro ao criar conta. Tente novamente.'));
    }
  }
}