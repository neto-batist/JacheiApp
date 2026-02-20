import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@module
abstract class RegisterModule {
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  // Agora o Dio recebe o prefs por injeção de dependência automaticamente!
  @lazySingleton
  Dio dio(SharedPreferences prefs) {
    final dio = Dio(BaseOptions(
      // ⚠️ ATENÇÃO AO IP:
      // Se usar Emulador Android: use 'http://10.0.2.2:8080'
      // Se usar Celular Físico: use o IP da sua máquina, ex: 'http://192.168.1.X:8080'
      // Se usar iOS Simulator: use 'http://localhost:8080'
      baseUrl: 'http://192.168.0.7:8080/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    // --- O ESPIÃO (INTERCEPTOR) DE SEGURANÇA ---
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Antes de enviar a requisição, pega o Token e injeta no cabeçalho
        final token = prefs.getString('jwt_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Se o Spring Boot reclamar que o token venceu (401), apagamos os dados locais
        if (e.response?.statusCode == 401) {
          prefs.remove('jwt_token');
          prefs.remove('user_uid');
        }
        return handler.next(e);
      },
    ));

    return dio;
  }
}