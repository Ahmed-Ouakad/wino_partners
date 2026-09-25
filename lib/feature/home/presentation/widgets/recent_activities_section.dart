import 'package:flutter/material.dart';

class RecentActivitiesSection extends StatelessWidget {
  const RecentActivitiesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Activités Récentes',
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
                  'Tout voir',
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

        const SizedBox(height: 12),

        // List of recent activity items
        _buildActivityItem(
          icon: Icons.notifications_active_outlined,
          iconColor: theme.colorScheme.primary,
          iconBgColor: theme.colorScheme.primary.withValues(alpha: 0.12),
          title: 'Nouvelle commande #4829',
          time: '1 min',
          subtitle: 'Reçue de Sarah M. • 3 articles (142,50 T...)',
          theme: theme,
        ),
        const SizedBox(height: 12),
        _buildActivityItem(
          icon: Icons.fact_check_outlined,
          iconColor: theme.colorScheme.secondary,
          iconBgColor: theme.colorScheme.secondary.withValues(alpha: 0.2),
          title: 'Mise à jour stock terminée',
          time: '33 min',
          subtitle: 'Boutique synchronisée avec le catalogue...',
          theme: theme,
        ),
        const SizedBox(height: 12),
        _buildActivityItem(
          icon: Icons.chat_bubble_outline_rounded,
          iconColor: theme.colorScheme.onSurface,
          iconBgColor: theme.colorScheme.surfaceContainer,
          title: 'Avis 5 étoiles reçu',
          time: '2h',
          subtitle: '“Superbe qualité et envoi très soigné !”',
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String time,
    required String subtitle,
    required ThemeData theme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Leading Icon with circular container
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconBgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 22,
          ),
        ),

        const SizedBox(width: 12),

        // Title, timestamp, and subtitle details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
