import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

@lazySingleton
class AuthRepository {
  final Dio dio;

  AuthRepository(this.dio);

  // 1. O novo método de Login Real
  Future<Map<String, dynamic>> login(String email, String senha) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {
          "email": email,
          "senha": senha,
        },
      );
      // Retorna o JSON (token, firebaseUid, nome, linkFoto)
      return response.data;
    } catch (e) {
      throw Exception('Falha ao realizar login. Verifique suas credenciais.');
    }
  }

  // 2. O Cadastro com a Senha Inclusa
  Future<String> cadastrarUsuario(String nome, String email, String senha) async {
    try {
      final uid = const Uuid().v4();

      await dio.post(
        '/usuarios',
        data: {
          "nome": nome,
          "email": email,
          "firebaseUid": uid,
          "linkFoto": "https://ui-avatars.com/api/?name=${nome.replaceAll(' ', '+')}&background=random",
          "senha": senha // <--- AGORA O BACKEND EXIGE SENHA
        },
      );
      return uid;
    } catch (e) {
      throw Exception('Falha ao cadastrar usuário no backend: $e');
    }
  }

  // 3. Verifica o status do Usuário/Token na Splash Screen
  Future<bool> verificarSeUsuarioExiste(String uid) async {
    try {
      final response = await dio.get('/usuarios/me/$uid');
      return response.statusCode == 200;
    } on DioException catch (e) {
      // Adicionamos o 403 (Proibido/Sem Token) na lista de bloqueios
      if (e.response?.statusCode == 404 ||
          e.response?.statusCode == 401 ||
          e.response?.statusCode == 403) {
        return false;
      }
      return true; // Mantém true apenas para Timeout, Erro 500 ou Falta de Internet real
    }
  }
}