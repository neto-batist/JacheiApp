import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class RegisterModule {

  // Configuração Global do Dio (HTTP Client)
  @lazySingleton
  Dio get dio {
    final dio = Dio(BaseOptions(
      // ⚠️ ATENÇÃO AO IP:
      // Se usar Emulador Android: use 'http://10.0.2.2:8080'
      // Se usar Celular Físico: use o IP da sua máquina, ex: 'http://192.168.1.X:8080'
      // Se usar iOS Simulator: use 'http://localhost:8080'
      baseUrl: 'http://192.168.0.7:8080/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Interceptor para logs (ajuda muito a debugar)
    dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: false,
        responseHeader: false
    ));

    return dio;
  }

  // SharedPreferences (Banco de dados local simples para tokens/configs)
  // O @preResolve faz o app esperar o SharedPreferences carregar antes de iniciar
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
}