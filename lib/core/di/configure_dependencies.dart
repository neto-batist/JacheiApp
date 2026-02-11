import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:jachei_app/core/di/configure_dependencies.config.dart'; // Vai ficar vermelho, é normal!

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // nome do método gerado
  preferRelativeImports: true, // usa imports relativos
  asExtension: true, // gera código como extensão do GetIt
)
Future<void> configureDependencies() async => getIt.init();