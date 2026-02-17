import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

// Os estados que nossa tela pode ter
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

// A lógica
class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());

  Future<void> getUserLocation() async {
    emit(HomeLoading());

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return emit(HomeError('Ative o GPS do celular.'));
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return emit(HomeError('Permissão de localização negada.'));
        }
      }

      // Pega a coordenada (Latitude e Longitude)
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Transforma a coordenada no nome da cidade
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String cidade = place.subAdministrativeArea ?? place.locality ?? 'Cidade Desconhecida';
        emit(HomeLoaded(cidade));
      } else {
        emit(HomeError('Não foi possível identificar a cidade.'));
      }
    } catch (e) {
      emit(HomeError('Erro ao buscar localização: $e'));
    }
  }
}