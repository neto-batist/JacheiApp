// lib/features/home/data/home_repository.dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'models/prestador_model.dart';
import 'models/categoria_model.dart';

@lazySingleton
class HomeRepository {
  final Dio dio;

  HomeRepository(this.dio);

  // Agora recebe Latitude e Longitude!
  Future<List<PrestadorModel>> getPrestadoresProximos(double lat, double lng) async {
    try {
      // Passando as coordenadas via Query Parameters (raio padrão de 50km para testes)
      final response = await dio.get('/prestadores/proximos', queryParameters: {
        'lat': lat,
        'lng': lng,
        'raioKm': 50,
      });

      final List dados = response.data;
      return dados.map((json) => PrestadorModel.fromJson(json)).toList();

    } catch (e) {
      throw Exception('Falha ao conectar no backend Java.');
    }
  }

  Future<List<CategoriaModel>> getCategorias() async {
    try {
      final response = await dio.get('/catalogo/categorias');
      final List dados = response.data;
      return dados.map((json) => CategoriaModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Falha ao buscar categorias.');
    }
  }
}