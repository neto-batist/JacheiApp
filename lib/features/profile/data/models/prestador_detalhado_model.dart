// lib/features/profile/data/models/prestador_detalhado_model.dart
import 'foto_portifolio_model.dart';

class PrestadorDetalhadoModel {
  final int id;
  final String nome;
  final String fotoPerfil;
  final String cpf;
  final String descricaoBio;
  final bool atende24H;
  final bool fazDelivery;
  final bool atendeDomiciliar;
  final String servicoPrincipal;
  final double mediaAvaliacoes;
  final int qtdFotosServicos;
  final List<FotoPortifolioModel> portifolio;

  PrestadorDetalhadoModel({
    required this.id,
    required this.nome,
    required this.fotoPerfil,
    required this.cpf,
    required this.descricaoBio,
    required this.atende24H,
    required this.fazDelivery,
    required this.atendeDomiciliar,
    required this.servicoPrincipal,
    required this.mediaAvaliacoes,
    required this.qtdFotosServicos,
    required this.portifolio,
  });

  factory PrestadorDetalhadoModel.fromJson(Map<String, dynamic> json) {
    var list = json['portifolio'] as List? ?? [];
    List<FotoPortifolioModel> portifolioList =
    list.map((i) => FotoPortifolioModel.fromJson(i)).toList();

    return PrestadorDetalhadoModel(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? 'Sem Nome',
      fotoPerfil: json['fotoPerfil'] ?? '',
      cpf: json['cpf'] ?? '',
      descricaoBio: json['descricaoBio'] ?? 'Nenhuma biografia informada.',
      atende24H: json['atende24H'] ?? json['atende24h'] ?? false,
      fazDelivery: json['fazDelivery'] ?? false,
      atendeDomiciliar: json['atendeDomiciliar'] ?? false,
      servicoPrincipal: json['servicoPrincipal'] ?? 'Serviços Gerais',
      mediaAvaliacoes: (json['mediaAvaliacoes'] ?? 0).toDouble(),
      qtdFotosServicos: json['qtdFotosServicos'] ?? 0,
      portifolio: portifolioList,
    );
  }
}