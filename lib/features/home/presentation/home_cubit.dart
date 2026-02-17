import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

// --- ESTADOS DA TELA ---
abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final String city;
  HomeLoaded(this.city);
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}

// --- LÓGICA (CUBIT) ---
class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  Future<void> getUserLocation() async {
    emit(HomeLoading()); // Avisa a tela para mostrar "Buscando..."

    try {
      // 1. Verifica se o GPS do celular está ligado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return emit(HomeError('Ative o GPS do celular para ver serviços próximos.'));
      }

      // 2. Verifica se o usuário deu permissão para o app usar o GPS
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return emit(HomeError('Permissão de localização negada.'));
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return emit(HomeError('Permissão negada permanentemente nas configurações.'));
      }

      // 3. Pega a coordenada exata (Latitude e Longitude)
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 4. Converte a coordenada no nome da cidade
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        // Tenta pegar a cidade (subAdministrativeArea) ou o bairro/localidade (locality)
        String city = place.subAdministrativeArea ?? place.locality ?? 'Cidade Desconhecida';

        emit(HomeLoaded(city)); // Avisa a tela que deu certo!
      } else {
        emit(HomeError('Não foi possível identificar sua cidade.'));
      }
    } catch (e) {
      emit(HomeError('Erro ao buscar localização. Tente novamente.'));
    }
  }
}