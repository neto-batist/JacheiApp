// lib/core/widgets/prestador_card.dart
import 'package:flutter/material.dart';
import 'package:jachei_app/features/home/data/models/prestador_model.dart';

class PrestadorCard extends StatelessWidget {
  final PrestadorModel prestador;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap; // <--- O PARÂMETRO DECLARADO AQUI

  const PrestadorCard({
    super.key,
    required this.prestador,
    this.onTap,
    this.onFavoriteTap, // <--- O PARÂMETRO INSERIDO NO CONSTRUTOR AQUI
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),

        // --- FOTO DE PERFIL ---
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: primaryColor.withOpacity(0.2),
          backgroundImage: prestador.fotoPerfil.isNotEmpty
              ? NetworkImage(prestador.fotoPerfil)
              : null,
          child: prestador.fotoPerfil.isEmpty
              ? Text(
              prestador.nome.isNotEmpty ? prestador.nome[0].toUpperCase() : '?',
              style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 20)
          )
              : null,
        ),

        // --- NOME E DADOS ---
        title: Text(prestador.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(prestador.servicoPrincipal), // Dado Real vindo da API
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                // Exibe a nota formatada, ou "Novo" se for 0.0
                Text(
                  prestador.mediaAvaliacoes > 0
                      ? prestador.mediaAvaliacoes.toStringAsFixed(1)
                      : 'Novo',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),

        // --- ÍCONES (24H, DELIVERY E CORAÇÃO) ---
        trailing: Row(
          mainAxisSize: MainAxisSize.min, // Impede que a Row empurre o título
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (prestador.atende24H)
                  const Icon(Icons.access_time_filled, color: Colors.orange, size: 18),
                if (prestador.fazDelivery)
                  const Padding(
                    padding: EdgeInsets.only(top: 4.0),
                    child: Icon(Icons.two_wheeler, color: Colors.teal, size: 18),
                  ),
              ],
            ),
            const SizedBox(width: 12), // Espaço entre os ícones e o coração

            // O botão de Favoritar!
            GestureDetector(
              onTap: onFavoriteTap, // <--- A AÇÃO DO CLIQUE
              child: Icon(
                prestador.isFavorito ? Icons.favorite : Icons.favorite_border,
                color: prestador.isFavorito ? Colors.red : Colors.grey.shade400,
                size: 28,
              ),
            ),
          ],
        ),

        // --- AÇÃO DO CLIQUE NO CARD INTEIRO ---
        onTap: onTap,
      ),
    );
  }
}