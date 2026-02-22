// lib/features/home/presentation/home_cubit.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:jachei_app/features/home/data/models/categoria_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/home_repository.dart';
import '../data/models/prestador_model.dart';

abstract class HomeState {}
class HomeInitial extends HomeState {}
class HomeLoading extends HomeState {}
class HomeLoaded extends HomeState {
  final String city;
  final List<PrestadorModel> prestadores;
  final List<CategoriaModel> categorias;
  HomeLoaded(this.city, this.prestadores, this.categorias);
}
class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository repository;
  final SharedPreferences prefs; // Precisamos do Prefs para pegar o UID na hora de favoritar!

  HomeCubit(this.repository, this.prefs) : super(HomeInitial());

  Future<void> getUserLocationAndData({bool isRefresh = false}) async {
    if (!isRefresh && state is! HomeError) emit(HomeLoading());

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Ative o GPS');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw Exception('Permissão negada');
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      String city = 'Cidade Desconhecida';
      if (placemarks.isNotEmpty) {
        city = placemarks.first.subAdministrativeArea ?? placemarks.first.locality ?? 'Cidade Desconhecida';
      }

      // --- NOMES ATUALIZADOS PARA BATER COM O REPOSITÓRIO NOVO ---
      final results = await Future.wait([
        repository.buscarPrestadoresProximos(position.latitude, position.longitude),
        repository.buscarCategorias(),
      ]);

      final prestadores = results[0] as List<PrestadorModel>;
      final categorias = results[1] as List<CategoriaModel>;

      emit(HomeLoaded(city, prestadores, categorias));

    } catch (e) {
      emit(HomeError('Sem conexão com o servidor. \nTentando reconectar em 10 segundos...'));
      Timer(const Duration(seconds: 10), () {
        if (!isClosed) getUserLocationAndData();
      });
    }
  }

  // ===========================================================================
  // NOVO MÉTODO: TOGGLE FAVORITO (Otimista)
  // ===========================================================================
  Future<void> toggleFavorito(PrestadorModel prestador) async {
    // Só podemos favoritar se a tela já estiver carregada com a lista
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;

      // 1. Atualização Otimista (Muda na UI antes do servidor responder para parecer instantâneo)
      final bool novoStatus = !prestador.isFavorito;

      // Cria uma cópia da lista para forçar o Flutter a redesenhar a tela
      final prestadoresAtualizados = currentState.prestadores.map((p) {
        if (p.id == prestador.id) {
          p.isFavorito = novoStatus;
        }
        return p;
      }).toList();

      emit(HomeLoaded(currentState.city, prestadoresAtualizados, currentState.categorias));

      // 2. Manda a requisição pro Backend em background
      try {
        final uid = prefs.getString('user_uid');
        if (uid != null) {
          await repository.alternarFavoritoBackend(uid, prestador.id);
        }
      } catch (e) {
        // Se a internet falhar ou der erro 500, revertemos o coração para o estado anterior!
        final prestadoresRevertidos = currentState.prestadores.map((p) {
          if (p.id == prestador.id) {
            p.isFavorito = !novoStatus;
          }
          return p;
        }).toList();
        emit(HomeLoaded(currentState.city, prestadoresRevertidos, currentState.categorias));
      }
    }
  }
}