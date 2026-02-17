// lib/features/home/presentation/home_cubit.dart
import 'dart:async'; // Necessário para o Timer
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../data/home_repository.dart';
import '../data/models/prestador_model.dart';

abstract class HomeState {}
class HomeInitial extends HomeState {}
class HomeLoading extends HomeState {}
class HomeLoaded extends HomeState {
  final String city;
  final List<PrestadorModel> prestadores;
  HomeLoaded(this.city, this.prestadores);
}
class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository repository;

  HomeCubit(this.repository) : super(HomeInitial());

  Future<void> getUserLocationAndData() async {
    // Se o estado já é erro (está no meio do retry), não zera a tela para Loading,
    // apenas tenta silenciosamente por trás.
    if (state is! HomeError) emit(HomeLoading());

    try {
      // 1. Permissões e GPS
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Ative o GPS');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw Exception('Permissão negada');
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      // Apenas para mostrar o nome na UI
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      String city = 'Cidade Desconhecida';
      if (placemarks.isNotEmpty) {
        city = placemarks.first.subAdministrativeArea ?? placemarks.first.locality ?? 'Cidade Desconhecida';
      }

      // 2. BUSCA GEOGRÁFICA NO BACKEND (LAT E LNG)
      final prestadores = await repository.getPrestadoresProximos(
          position.latitude,
          position.longitude
      );

      // 3. Sucesso! Mostra os dados na tela
      emit(HomeLoaded(city, prestadores));

    } catch (e) {
      // 4. RETRY AUTOMÁTICO
      emit(HomeError('Sem conexão com o servidor. \nTentando reconectar em 10 segundos...'));

      // Espera 10 segundos e chama a si mesmo recursivamente
      Timer(const Duration(seconds: 10), () {
        if (!isClosed) { // Garante que a tela ainda está aberta antes de refazer a chamada
          getUserLocationAndData();
        }
      });
    }
  }
}