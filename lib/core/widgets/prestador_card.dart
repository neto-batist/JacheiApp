import 'package:flutter/material.dart';
import 'package:jachei_app/features/home/data/models/prestador_model.dart';

class PrestadorCard extends StatelessWidget {
  final PrestadorModel prestador;
  final VoidCallback? onTap;

  const PrestadorCard({
    super.key,
    required this.prestador,
    this.onTap, // Permite que cada tela decida o que acontece ao clicar
  });

  @override
  Widget build(BuildContext context) {
    // Puxa a cor primária do tema global automaticamente
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
              prestador.nome.isNotEmpty ? prestador.nome[0] : '?',
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
            Text(prestador.categoriaMock), // Em breve vindo do banco real
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(prestador.notaMock, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),

        // --- ÍCONES DE STATUS (24h / Delivery) ---
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (prestador.atende24H)
              const Icon(Icons.access_time_filled, color: Colors.orange, size: 20),
            if (prestador.fazDelivery)
              const Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Icon(Icons.two_wheeler, color: Colors.teal, size: 20),
              ),
          ],
        ),

        // --- AÇÃO DO CLIQUE ---
        onTap: onTap ?? () {
          // Ação padrão: Por enquanto não faz nada, mas futuramente vai pra tela de detalhes
        },
      ),
    );
  }
}