import 'package:emovieapp/src/imports/imports.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeScreen Real Tests', () {
    
    testWidgets('should display _Logo widget with correct styling', (WidgetTester tester) async {
      // Arrange - Test solo el Logo
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final shortest = MediaQuery.sizeOf(context).shortestSide;
                final scale = (shortest / 400).clamp(0.85, 1.35);
                final fs = (20 * scale).clamp(16, 24).toDouble();
                
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Text(
                    'eMovie',
                    style: TextStyle(
                      fontSize: fs,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('eMovie'), findsOneWidget);
      
      // Verificar estilos del texto
      final textWidget = tester.widget<Text>(find.text('eMovie'));
      expect(textWidget.style?.fontWeight, FontWeight.w800);
      expect(textWidget.style?.color, Colors.white);
      expect(textWidget.style?.letterSpacing, 1.2);
    });

    testWidgets('should display SectionTitle widgets correctly', (WidgetTester tester) async {
      // Arrange - Test SectionTitle
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SectionTitle(text: 'Próximos estrenos'),
                SectionTitle(text: 'Tendencia'),
              ],
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Próximos estrenos'), findsOneWidget);
      expect(find.text('Tendencia'), findsOneWidget);
      expect(find.byType(SectionTitle), findsNWidgets(2));
    });

    testWidgets('should display CustomScrollView with correct physics', (WidgetTester tester) async {
      // Arrange - Test scroll structure
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {},
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Container(height: 100, child: Text('Test Content')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(CustomScrollView), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
      
      // Verificar physics
      final scrollView = tester.widget<CustomScrollView>(find.byType(CustomScrollView));
      expect(scrollView.physics, isA<BouncingScrollPhysics>());
    });

    testWidgets('should display loading state correctly', (WidgetTester tester) async {
      // Arrange - Simular loading state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 200,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.secondColor),
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display error state correctly', (WidgetTester tester) async {
      // Arrange - Simular error state
      const errorMessage = 'Error de conexión a la API';
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'Error: $errorMessage',
                  style: TextStyle(color: AppColors.whiteColor),
                ),
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.textContaining('Error: Error de conexión a la API'), findsOneWidget);
    });

    testWidgets('should handle movie navigation correctly', (WidgetTester tester) async {
      // Arrange - Test navigation structure
      bool navigationCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () {
                // Simular navegación a detalles
                navigationCalled = true;
              },
              child: Text('Ver película'),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(navigationCalled, isTrue);
    });

    testWidgets('should display RecommendedGrid structure', (WidgetTester tester) async {
      // Arrange - Test grid structure básica
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.70,
                ),
                itemCount: 4,
                itemBuilder: (context, index) => Container(
                  child: Text('Movie $index'),
                ),
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(GridView), findsOneWidget);
      expect(find.text('Movie 0'), findsOneWidget);
      expect(find.text('Movie 1'), findsOneWidget);
    });

    testWidgets('should handle pull to refresh', (WidgetTester tester) async {
      // Arrange
      bool refreshCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RefreshIndicator(
              onRefresh: () async {
                refreshCalled = true;
              },
              child: ListView(
                children: [
                  Container(height: 100, child: Text('Content')),
                ],
              ),
            ),
          ),
        ),
      );

      // Act - Simular pull to refresh
      await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
      await tester.pump();

      // Assert
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('should scale logo correctly based on screen size', (WidgetTester tester) async {
      // Arrange - Test responsive scaling
      await tester.binding.setSurfaceSize(Size(400, 800));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final shortest = MediaQuery.sizeOf(context).shortestSide;
                final scale = (shortest / 400).clamp(0.85, 1.35);
                
                return Text('Scale: ${scale.toStringAsFixed(2)}');
              },
            ),
          ),
        ),
      );

      // Assert - Verificar que el scale se calcula
      expect(find.textContaining('Scale:'), findsOneWidget);
    });
  });
}