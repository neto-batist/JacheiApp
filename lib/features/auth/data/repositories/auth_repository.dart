// lib/features/auth/data/auth_repository.dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

@lazySingleton
class AuthRepository {
  final Dio dio;

  AuthRepository(this.dio);

  // Mapeia exatamente para o seu UsuarioRequest do Java
  Future<String> cadastrarUsuario(String nome, String email) async {
    try {
      final uid = const Uuid().v4(); // Gera um ID único simulando o Firebase

      await dio.post(
        '/usuarios',
        data: {
          "nome": nome,
          "email": email,
          "firebaseUid": uid,
          "linkFoto": "https://ui-avatars.com/api/?name=${nome.replaceAll(' ', '+')}&background=random"
        },
      );

      return uid; // Retorna o ID gerado para salvarmos no celular
    } catch (e) {
      throw Exception('Falha ao cadastrar usuário no backend: $e');
    }
  }

  Future<bool> verificarSeUsuarioExiste(String uid) async {
    try {
      // Faz um GET rápido no backend buscando pelo UID
      final response = await dio.get('/usuarios/me/$uid');
      return response.statusCode == 200;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return false; // O banco de dados confirmou: Usuário foi apagado!
      }
      // Se for outro erro (ex: Servidor offline ou Sem Internet),
      // deixamos entrar como 'true' para o app tentar o Auto-Retry lá na Home Page.
      return true;
    }
  }
}