// lib/features/home/data/models/prestador_model.dart

class PrestadorModel {
  final int id;
  final String nome;
  final String fotoPerfil; // <--- NOVO CAMPO
  final bool atende24H;
  final bool fazDelivery;
  final String categoriaMock;
  final String notaMock;

  PrestadorModel({
    required this.id,
    required this.nome,
    required this.fotoPerfil, // <--- NOVO CAMPO
    required this.atende24H,
    required this.fazDelivery,
    this.categoriaMock = 'Serviços Gerais',
    this.notaMock = '5.0',
  });

  factory PrestadorModel.fromJson(Map<String, dynamic> json) {
    // Puxa o objeto aninhado "usuario" que o Java agora retorna
    final usuarioJson = json['usuario'] ?? {};

    return PrestadorModel(
      id: json['id'] ?? 0,
      nome: usuarioJson['nome'] ?? 'Sem Nome',
      fotoPerfil: usuarioJson['linkFoto'] ?? '', // <--- MAPEANDO A FOTO
      atende24H: json['atende24h'] ?? false,
      fazDelivery: json['fazDelivery'] ?? false,
    );
  }
}