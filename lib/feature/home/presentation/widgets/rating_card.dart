import 'package:flutter/material.dart';

class RatingCard extends StatelessWidget {
  final String rating;
  final String label;

  const RatingCard({
    super.key,
    this.rating = '4.7',
    this.label = 'Note Moyenne',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 5 stars outline
          Row(
            children: List.generate(
              5,
              (index) => Padding(
                padding: const EdgeInsets.only(right: 2.0),
                child: Icon(
                  Icons.star_border_rounded,
                  size: 15,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Rating value and filled star
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                rating,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.star_rounded,
                size: 18,
                color: theme.colorScheme.secondary,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
        ],
      ),
    );
  }
}
