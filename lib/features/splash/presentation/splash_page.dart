// lib/features/splash/presentation/splash_page.dart
import 'package:flutter/material.dart';
import 'package:jachei_app/features/auth/data/repositories/auth_repository.dart';
import 'package:jachei_app/features/home/presentation/home_page.dart';
import 'package:jachei_app/features/auth/presentation/sign_up_page.dart';
import 'package:jachei_app/core/di/configure_dependencies.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward().then((_) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {

          // ---> A LÓGICA DE DECISÃO COMEÇA AQUI <---
          final prefs = getIt<SharedPreferences>();
          final logadoUid = prefs.getString('user_uid');
          final jwtToken = prefs.getString('jwt_token');

          // Agora a porta só abre se tiver o UID E o Token JWT guardados!
          if (logadoUid != null && logadoUid.isNotEmpty && jwtToken != null && jwtToken.isNotEmpty) {

            final authRepo = getIt<AuthRepository>();
            authRepo.verificarSeUsuarioExiste(logadoUid).then((existe) {
              if (mounted) {
                if (existe) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const HomePage()),
                  );
                } else {
                  // Fantasma ou Token Inválido! Apaga tudo do celular.
                  prefs.remove('user_uid');
                  prefs.remove('jwt_token');
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const SignUpPage()),
                  );
                }
              }
            });

          } else {
            // Se falta o UID ou falta o Token, limpa resquícios e vai pro Cadastro
            prefs.remove('user_uid');
            prefs.remove('jwt_token');
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const SignUpPage()),
            );
          }

        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Pegamos as dimensões exatas do celular do usuário
    final size = MediaQuery.of(context).size;
    final maxRadius = size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor, // Fundo Laranja inicial
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return ClipPath(
            clipper: CircleRevealClipper(maxRadius * _animation.value),
            // Mudamos de SizedBox para um Container para controlar o fundo revelado
            child: Container(
              width: size.width,
              height: size.height,
              // Fundo que vai aparecer junto com a imagem (Mude para a cor do fundo da sua logo, ex: Colors.white)
              color: Colors.white,
              child: Center(
                child: Image.asset(
                  'assets/images/load_page.png',
                  // --- A MÁGICA DA RESPONSIVIDADE AQUI ---
                  // A imagem sempre vai ocupar 60% da largura da tela, seja um celular pequeno ou um tablet
                  width: size.width * 0.6,
                  // contain: Garante que a imagem caiba perfeitamente no espaço sem cortar nada
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- CLASSE AUXILIAR QUE FAZ O RECORTE DO CÍRCULO MATEMATICAMENTE ---
class CircleRevealClipper extends CustomClipper<Path> {
  final double radius;

  CircleRevealClipper(this.radius);

  @override
  Path getClip(Size size) {
    return Path()
      ..addOval(Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2), // Centro exato da tela
        radius: radius,
      ));
  }

  @override
  bool shouldReclip(covariant CircleRevealClipper oldClipper) {
    return oldClipper.radius != radius; // Avisa o Flutter para redesenhar a cada frame
  }
}