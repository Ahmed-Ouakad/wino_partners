import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wino_partners/feature/home/presentation/screens/home_screen.dart';

void main() {
  testWidgets('HomeScreen renders all sections properly without errors', (
    WidgetTester tester,
  ) async {
    // Provide a sized window for widget testing
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFC61D23),
            secondary: Color(0xFF86AB3E),
            onSurface: Color(0xFF1A1A1A),
            onSurfaceVariant: Color(0xFF8d7977),
            outlineVariant: Color(0xFFe8c3c0),
            surface: Color(0xFFF8F9FA),
            surfaceContainer: Color(0xFFF8F9FA),
          ),
        ),
        home: const HomeScreen(),
      ),
    );

    // Verify header
    expect(find.text('Winou'), findsOneWidget);
    expect(find.text('Vendeur'), findsOneWidget);
    expect(find.text('Shop More, Pay Less'), findsOneWidget);
    expect(find.text('Bonjour, Vine Street Boutique !'), findsOneWidget);

    // Verify KPI cards
    expect(find.text('Note Moyenne'), findsOneWidget);
    expect(find.text('4.7'), findsOneWidget);
    expect(find.text('Vues Totales'), findsOneWidget);
    expect(find.text('1 308 432'), findsOneWidget);

    // Verify weekly orders chart card
    expect(find.text('Commandes Semaine Dernière'), findsOneWidget);
    expect(find.text('Performance hebdomadaire'), findsOneWidget);
    expect(find.text('Lundi'), findsOneWidget);
    expect(find.text('Totales'), findsOneWidget);
    expect(find.text('2 836'), findsOneWidget);

    // Verify quick actions
    expect(find.text('Actions Rapides'), findsOneWidget);
    expect(find.text('Personnaliser'), findsOneWidget);
    expect(find.text('Nouveau\nProduit'), findsOneWidget);
    expect(find.text('Nouvelle\nPromo'), findsOneWidget);
    expect(find.text('Nouveau\nReel'), findsOneWidget);
    expect(find.text('Nouvelle\nStory'), findsOneWidget);

    // Verify campaign banner
    expect(find.text('CAMPAGNE WINOU FLASH'), findsOneWidget);
    expect(find.text('Boostez vos ventes du\nweekend'), findsOneWidget);

    // Verify recent activities
    expect(find.text('Activités Récentes'), findsOneWidget);
    expect(find.text('Tout voir'), findsOneWidget);
    expect(find.text('Nouvelle commande #4829'), findsOneWidget);
    expect(find.text('Mise à jour stock terminée'), findsOneWidget);
    expect(find.text('Avis 5 étoiles reçu'), findsOneWidget);
  });
}
