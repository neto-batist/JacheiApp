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
  final String? localPhotoPath; // NOVO: Guarda a foto do celular antes de ir pro banco

  ProfileLoaded(this.user, this.isPrestador, {this.localPhotoPath});
}
class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository repository;
  final SharedPreferences prefs;

  ProfileCubit(this.repository, this.prefs) : super(ProfileLoading());

  Future<void> loadProfile() async {
    try {
      final uid = prefs.getString('user_uid');
      if (uid == null) throw Exception('Usuário não logado');

      final results = await Future.wait([
        repository.getUserProfile(uid),
        repository.isPrestador(uid),
      ]);

      emit(ProfileLoaded(results[0] as UserModel, results[1] as bool));
    } catch (e) {
      emit(ProfileError('Erro ao carregar os dados.'));
    }
  }

  Future<void> pickAndUploadPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    // Se ele escolheu uma foto e a tela já estava carregada
    if (image != null && state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;

      // Emitimos o mesmo estado, mas agora com o caminho da foto nova!
      emit(ProfileLoaded(
        currentState.user,
        currentState.isPrestador,
        localPhotoPath: image.path, // Injeta o arquivo local
      ));

      print("Foto selecionada e atualizada na UI: ${image.path}");
      // Futuramente: Chamar o repository.uploadFoto(image.path) aqui
    }
  }

  Future<void> logout() async {
    await prefs.remove('user_uid');
    await prefs.remove('user_nome');
  }
}