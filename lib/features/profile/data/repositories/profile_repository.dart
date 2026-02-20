// lib/features/profile/data/profile_repository.dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../models/user_model.dart';

@lazySingleton
class ProfileRepository {
  final Dio dio;

  ProfileRepository(this.dio);

  // 1. Busca os dados do usuário atual
  Future<UserModel> getUserProfile(String uid) async {
    try {
      final response = await dio.get('/usuarios/me/$uid');
      return UserModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Falha ao carregar perfil.');
    }
  }

  // 2. Verifica se ele JÁ É um prestador de serviços
  Future<bool> isPrestador(String uid) async {
    try {
      final response = await dio.get('/prestadores/me/$uid');
      return response.statusCode == 200;
    } catch (e) {
      return false; // Se der 404, ele não é prestador ainda
    }
  }

  Future<void> uploadFotoPerfil(String uid, String imagePath) async {
    try {
      // Cria o form-data do Dio para empacotar o arquivo
      final formData = FormData.fromMap({
        'foto': await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        ),
      });

      // Dispara para a rota do Spring Boot
      await dio.post(
        '/usuarios/me/$uid/foto',
        data: formData,
      );
    } catch (e) {
      throw Exception('Falha ao enviar foto para o servidor: $e');
    }
  }
}