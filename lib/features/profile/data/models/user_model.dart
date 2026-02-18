// lib/features/profile/data/models/user_model.dart
class UserModel {
  final int id;
  final String nome;
  final String email;
  final String linkFoto;
  final String firebaseUid;

  UserModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.linkFoto,
    required this.firebaseUid,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      linkFoto: json['linkFoto'] ?? '',
      firebaseUid: json['firebaseUid'] ?? '',
    );
  }
}