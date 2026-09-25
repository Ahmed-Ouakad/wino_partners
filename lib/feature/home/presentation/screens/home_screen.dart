import 'package:flutter/material.dart';
import 'package:wino_partners/feature/home/presentation/widgets/campaign_banner_card.dart';
import 'package:wino_partners/feature/home/presentation/widgets/home_header.dart';
import 'package:wino_partners/feature/home/presentation/widgets/kpi_cards_section.dart';
import 'package:wino_partners/feature/home/presentation/widgets/quick_actions_section.dart';
import 'package:wino_partners/feature/home/presentation/widgets/recent_activities_section.dart';
import 'package:wino_partners/feature/home/presentation/widgets/weekly_orders_chart_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              // Top Brand header & Greeting section
              HomeHeader(),
              SizedBox(height: 16),

              // Rating and Total views KPI summary cards
              KpiCardsSection(),
              SizedBox(height: 16),

              // Weekly orders chart card with fl_chart & bottom stats
              WeeklyOrdersChartCard(),
              SizedBox(height: 22),

              // Quick Actions circular buttons
              QuickActionsSection(),
              SizedBox(height: 20),

              // Flash Campaign promotional banner card
              CampaignBannerCard(),
              SizedBox(height: 22),

              // Recent activities list
              RecentActivitiesSection(),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
