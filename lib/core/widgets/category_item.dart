// lib/core/widgets/category_item.dart
import 'package:flutter/material.dart';
import 'package:jachei_app/features/home/data/models/categoria_model.dart';

class CategoryItem extends StatelessWidget {
  final CategoriaModel categoria;
  final VoidCallback? onTap;

  const CategoryItem({
    super.key,
    required this.categoria,
    this.onTap,
  });

  // --- DICIONÁRIO DE ÍCONES INTELIGENTE ---
  // A IA ou o Back-end só mandam o nome. O Front decide o melhor ícone visual!
  IconData _getIconForCategory(String name) {
    final lowerName = name.toLowerCase();

    if (lowerName.contains('elé')) return Icons.electrical_services;
    if (lowerName.contains('hidrá')) return Icons.plumbing;
    if (lowerName.contains('limp')) return Icons.cleaning_services;
    if (lowerName.contains('transp')) return Icons.local_shipping;
    if (lowerName.contains('bel')) return Icons.spa; // ou Icons.content_cut
    if (lowerName == 'ti' || lowerName.contains('tecno')) return Icons.computer;

    return Icons.build; // Ícone genérico de fallback
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final iconData = _getIconForCategory(categoria.nome);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: primaryColor.withOpacity(0.1),
              child: Icon(iconData, color: primaryColor, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              categoria.nome.length > 12
                  ? '${categoria.nome.substring(0, 10)}...'
                  : categoria.nome,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}