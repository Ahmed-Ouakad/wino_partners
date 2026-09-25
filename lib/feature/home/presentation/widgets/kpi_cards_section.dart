import 'package:flutter/material.dart';
import 'package:wino_partners/feature/home/presentation/widgets/rating_card.dart';
import 'package:wino_partners/feature/home/presentation/widgets/views_card.dart';

export 'package:wino_partners/feature/home/presentation/widgets/rating_card.dart';
export 'package:wino_partners/feature/home/presentation/widgets/views_card.dart';

class KpiCardsSection extends StatelessWidget {
  const KpiCardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Card: Note Moyenne
          Expanded(
            child: RatingCard(),
          ),

          SizedBox(width: 12),

          // Right Card: Vues Totales
          Expanded(
            child: ViewsCard(),
          ),
        ],
      ),
    );
  }
}
