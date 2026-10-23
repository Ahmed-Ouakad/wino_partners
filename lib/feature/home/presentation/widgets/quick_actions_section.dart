import 'package:flutter/material.dart';
import '../../../post/presentation/screens/create_reel_screen.dart';
import '../../../product/presentation/screens/add_product_screen.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final darkGreen = const Color(0xFF4C6616);

    return Column(
      children: [
        // Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Actions Rapides',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  'Personnaliser',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Row of 4 quick action circular buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActionButton(
              icon: Icons.inventory_2_outlined,
              backgroundColor: theme.colorScheme.primary,
              label: 'Nouveau\nProduit',
              theme: theme,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const AddProductScreen(),
                  ),
                );
              },
            ),
            _buildActionButton(
              icon: Icons.percent_rounded,
              backgroundColor: darkGreen,
              label: 'Nouvelle\nPromo',
              theme: theme,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fonctionnalité promo à venir.')),
                );
              },
            ),
            _buildActionButton(
              icon: Icons.movie_creation_outlined,
              backgroundColor: theme.colorScheme.primary,
              label: 'Nouveau\nReel',
              theme: theme,
              onTap: () {
                CreateReelScreen.showPickerAndOpen(context);
              },
            ),
            _buildActionButton(
              icon: Icons.play_circle_outline_rounded,
              backgroundColor: darkGreen,
              label: 'Nouvelle\nStory',
              theme: theme,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fonctionnalité story à venir.')),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color backgroundColor,
    required String label,
    required ThemeData theme,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: backgroundColor.withValues(alpha: 0.28),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              height: 1.2,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
