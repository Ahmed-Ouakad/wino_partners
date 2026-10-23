import 'package:flutter/material.dart';

import '../../../post/presentation/screens/create_reel_screen.dart';
import '../../../post/presentation/screens/media_screen.dart';
import '../../../product/presentation/screens/add_product_screen.dart';
import '../../../product/presentation/screens/product_list_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../widgets/home_bottom_nav_bar.dart';
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const Center(child: Text('Commandes')),
    const ProductListScreen(),
    const MediaScreen(),
    const ProfileScreen(),
  ];

  void _showQuickActionsSheet(BuildContext context) {
    final theme = Theme.of(context);
    final darkGreen = const Color(0xFF4C6616);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'Actions Rapides',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildModalAction(
                      icon: Icons.inventory_2_outlined,
                      color: theme.colorScheme.primary,
                      label: 'Nouveau\nProduit',
                      onTap: () {
                        Navigator.pop(sheetContext);
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => const AddProductScreen(),
                          ),
                        );
                      },
                    ),
                    _buildModalAction(
                      icon: Icons.percent_rounded,
                      color: darkGreen,
                      label: 'Nouvelle\nPromo',
                      onTap: () {
                        Navigator.pop(sheetContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Fonctionnalité promo à venir.')),
                        );
                      },
                    ),
                    _buildModalAction(
                      icon: Icons.movie_creation_outlined,
                      color: theme.colorScheme.primary,
                      label: 'Nouveau\nReel',
                      onTap: () {
                        Navigator.pop(sheetContext);
                        CreateReelScreen.showPickerAndOpen(context);
                      },
                    ),
                    _buildModalAction(
                      icon: Icons.play_circle_outline_rounded,
                      color: darkGreen,
                      label: 'Nouvelle\nStory',
                      onTap: () {
                        Navigator.pop(sheetContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Fonctionnalité story à venir.')),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalAction({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: HomeBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        onAddTapped: () => _showQuickActionsSheet(context),
      ),
    );
  }
}