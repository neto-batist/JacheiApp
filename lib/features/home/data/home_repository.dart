import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'models/prestador_model.dart';
import 'models/categoria_model.dart';

@lazySingleton
class HomeRepository {
  final Dio dio;

  HomeRepository(this.dio);

  Future<List<PrestadorModel>> buscarPrestadoresProximos(double lat, double lng) async {
    try {
      // 1. Usando a nova rota unificada com os filtros dinâmicos via QueryParams
      final response = await dio.get(
        '/prestadores',
        queryParameters: {
          'latitudeUsuario': lat,
          'longitudeUsuario': lng,
          'raioKm': 15.0, // Busca num raio de 15km
          'size': 20,     // Traz 20 prestadores de uma vez para popular a Home
        },
      );

      // 2. Extrai a lista de dentro da propriedade 'content' da página do Spring
      final List dados = response.data['content'] ?? [];

      return dados.map((json) => PrestadorModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Falha ao carregar prestadores: $e');
    }
  }

  // O buscarCategorias permanece igual por enquanto!
  Future<List<CategoriaModel>> buscarCategorias() async {
    try {
      final response = await dio.get('/catalogo/categorias');
      final List dados = response.data;
      return dados.map((json) => CategoriaModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Falha ao carregar categorias: $e');
    }
  }

  Future<void> alternarFavoritoBackend(String uidUsuario, int idPrestador) async {
    try {
      // Bate na nossa rota cravada no Java (A mesma que usamos no script Python!)
      await dio.post('/usuarios/me/$uidUsuario/favoritos/$idPrestador');
    } catch (e) {
      throw Exception('Falha ao favoritar: $e');
    }
  }
}