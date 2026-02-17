// lib/features/home/data/models/prestador_model.dart

class PrestadorModel {
  final int id;
  final String nome;
  final bool atende24H;
  final bool fazDelivery;
  // Fallbacks enquanto não integramos categoria e média de nota vindas do back
  final String categoriaMock;
  final String notaMock;

  PrestadorModel({
    required this.id,
    required this.nome,
    required this.atende24H,
    required this.fazDelivery,
    this.categoriaMock = 'Serviços Gerais',
    this.notaMock = '5.0',
  });

  factory PrestadorModel.fromJson(Map<String, dynamic> json) {
    return PrestadorModel(
      id: json['id'] ?? 0,
      nome: json['usuario']['nome'] ?? 'Sem Nome',
      atende24H: json['atende24h'] ?? false, // Puxando o nome exato do novo JSON
      fazDelivery: json['fazDelivery'] ?? false, // Puxando o nome exato do novo JSON
    );
  }
}