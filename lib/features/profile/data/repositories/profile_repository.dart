// lib/features/profile/data/repositories/profile_repository.dart
import 'dart:io'; // Necessário para enviar o arquivo da foto
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../models/user_model.dart';
import '../models/prestador_detalhado_model.dart';

@lazySingleton
class ProfileRepository {
  final Dio dio;

  ProfileRepository(this.dio);

  // 1. Busca os dados de Usuário Comum
  Future<UserModel> getUserProfile(String uid) async {
    try {
      final response = await dio.get('/usuarios/me/$uid');
      return UserModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Falha ao carregar perfil do usuário: $e');
    }
  }

  // 2. Tenta buscar o Painel de Prestador (Se existir)
  Future<PrestadorDetalhadoModel?> getPrestadorPanel() async {
    try {
      final response = await dio.get('/prestadores/me');
      return PrestadorDetalhadoModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null; // É apenas um usuário comum
      }
      throw Exception('Falha ao carregar painel do prestador: $e');
    } catch (e) {
      throw Exception('Erro desconhecido ao carregar prestador: $e');
    }
  }

  // 3. O MÉTODO DE VOLTA: Atualizar Foto de Perfil via Multipart
  Future<UserModel> atualizarFotoPerfil(String uid, File foto) async {
    try {
      String fileName = foto.path.split('/').last;

      // Monta o formulário de dados nos padrões que o Spring Boot exige
      FormData formData = FormData.fromMap({
        "foto": await MultipartFile.fromFile(foto.path, filename: fileName),
      });

      final response = await dio.post(
        '/usuarios/me/$uid/foto',
        data: formData,
      );

      // O backend já devolve o DTO do usuário atualizado!
      return UserModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Falha ao atualizar foto de perfil: $e');
    }
  }
}