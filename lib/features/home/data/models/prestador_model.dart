class PrestadorModel {
  final int id;
  final String nome;
  final String fotoPerfil;
  final bool atende24H;
  final bool fazDelivery;

  // --- NOVOS DADOS REAIS DO BACKEND ---
  final String servicoPrincipal;
  final double mediaAvaliacoes;
  bool isFavorito;

  PrestadorModel({
    required this.id,
    required this.nome,
    required this.fotoPerfil,
    required this.atende24H,
    required this.fazDelivery,
    required this.servicoPrincipal,
    required this.mediaAvaliacoes,
    this.isFavorito = false,
  });

  factory PrestadorModel.fromJson(Map<String, dynamic> json) {
    return PrestadorModel(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? 'Sem Nome',
      fotoPerfil: json['fotoPerfil'] ?? '',
      // Tratamento de segurança para conversão do Jackson (Spring)
      atende24H: json['atende24H'] ?? json['atende24h'] ?? false,
      fazDelivery: json['fazDelivery'] ?? false,
      servicoPrincipal: json['servicoPrincipal'] ?? 'Serviços Gerais',
      mediaAvaliacoes: (json['mediaAvaliacoes'] ?? 0).toDouble(),
      isFavorito: json['favorito'] ?? json['isFavorito'] ?? false,
    );
  }
}