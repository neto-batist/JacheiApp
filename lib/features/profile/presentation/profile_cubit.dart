// lib/features/profile/presentation/profile_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/user_model.dart';
import '../data/repositories/profile_repository.dart';

abstract class ProfileState {}
class ProfileLoading extends ProfileState {}
class ProfileLoaded extends ProfileState {
  final UserModel user;
  final bool isPrestador;
  ProfileLoaded(this.user, this.isPrestador);
}
class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository repository;
  final SharedPreferences prefs;

  // --- O Pulo do Gato (Cache) ---
  // Guardamos os dados em memória para a tela não sumir se um upload der erro
  UserModel? _cachedUser;
  bool _cachedIsPrestador = false;

  ProfileCubit(this.repository, this.prefs) : super(ProfileLoading());

  Future<void> loadProfile() async {
    try {
      final uid = prefs.getString('user_uid');
      if (uid == null) throw Exception('Usuário não logado');

      final results = await Future.wait([
        repository.getUserProfile(uid),
        repository.isPrestador(uid),
      ]);

      // Salva no cache antes de emitir para a tela
      _cachedUser = results[0] as UserModel;
      _cachedIsPrestador = results[1] as bool;

      emit(ProfileLoaded(_cachedUser!, _cachedIsPrestador));
    } catch (e) {
      emit(ProfileError('Erro ao carregar os dados do perfil.'));
    }
  }

  Future<void> pickAndUploadPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // 1. VALIDAÇÃO DE FORMATO (Lista Branca)
      final nomeArquivo = image.name.toLowerCase();
      if (!nomeArquivo.endsWith('.jpg') &&
          !nomeArquivo.endsWith('.jpeg') &&
          !nomeArquivo.endsWith('.png')) {

        emit(ProfileError('Formato de foto indesejado. Selecione apenas imagens JPG ou PNG.'));
        _restoreState(); // Volta a mostrar a tela de perfil normalmente
        return;
      }

      // 2. VALIDAÇÃO DE TAMANHO (Max 10MB)
      final tamanhoBytes = await image.length();
      final tamanhoMB = tamanhoBytes / (1024 * 1024);
      if (tamanhoMB > 10) {
        emit(ProfileError('A foto é muito grande (${tamanhoMB.toStringAsFixed(1)}MB). O limite é 10MB.'));
        _restoreState();
        return;
      }

      // 3. UPLOAD REAL
      try {
        final uid = prefs.getString('user_uid');
        if (uid == null) return;

        emit(ProfileLoading()); // Mostra o loading apenas enquanto envia

        await repository.uploadFotoPerfil(uid, image.path);

        // Sucesso! Busca o perfil novamente para pegar o link novo do Spring Boot
        await loadProfile();

      } catch (e) {
        emit(ProfileError('Erro de conexão ao enviar a foto. Tente novamente.'));
        _restoreState();
      }
    }
  }

  // Função auxiliar que redesenha a tela com os dados em cache após um erro
  void _restoreState() {
    if (_cachedUser != null) {
      emit(ProfileLoaded(_cachedUser!, _cachedIsPrestador));
    }
  }

  Future<void> logout() async {
    await prefs.remove('user_uid');
    await prefs.remove('user_nome');
  }
}