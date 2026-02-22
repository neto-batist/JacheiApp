// lib/features/profile/data/models/foto_portifolio_model.dart
class FotoPortifolioModel {
  final int id;
  final String urlFoto;

  FotoPortifolioModel({
    required this.id,
    required this.urlFoto,
  });

  factory FotoPortifolioModel.fromJson(Map<String, dynamic> json) {
    return FotoPortifolioModel(
      id: json['id'] ?? 0,
      urlFoto: json['urlFoto'] ?? '',
    );
  }
}