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
    if (nome.isEmpty || email.isEmpty || senha.isEmpty) {
      emit(AuthError('Preencha todos os campos.'));
      return;
    }

    emit(AuthLoading());

    try {
      // 1. Cadastra no Banco
      await repository.cadastrarUsuario(nome, email, senha);

      // 2. Faz o Login Automático para pegar o JWT
      final loginData = await repository.login(email, senha);

      // 3. Salva no celular: O Token agora é a Chave Mestra!
      await prefs.setString('jwt_token', loginData['token']);
      await prefs.setString('user_uid', loginData['firebaseUid']);
      await prefs.setString('user_nome', loginData['nome']);

      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError('Erro ao processar autenticação. Tente novamente.'));
    }
  }

  // Já deixo o método de Login pronto para quando você for criar a Tela de Login!
  Future<void> login(String email, String senha) async {
    if (email.isEmpty || senha.isEmpty) {
      emit(AuthError('Preencha e-mail e senha.'));
      return;
    }
    emit(AuthLoading());
    try {
      final loginData = await repository.login(email, senha);
      await prefs.setString('jwt_token', loginData['token']);
      await prefs.setString('user_uid', loginData['firebaseUid']);
      await prefs.setString('user_nome', loginData['nome']);
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError('Credenciais incorretas.'));
    }
  }
}