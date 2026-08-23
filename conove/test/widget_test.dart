import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:conove/main.dart';
import 'package:conove/core/services/storage_service.dart';
import 'package:conove/data/gesture_database.dart';
import 'package:conove/data/quiz_database.dart';
import 'package:conove/data/scenario_database.dart';
import 'package:conove/models/category.dart';
import 'package:conove/state/settings_provider.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });

  test('GestureDatabase contains complete dataset across all 6 categories', () {
    expect(GestureDatabase.items.isNotEmpty, isTrue);
    for (final cat in CategoryInfo.allCategories) {
      final items = GestureDatabase.getByCategory(cat.type);
      expect(items.isNotEmpty, isTrue, reason: 'Category ${cat.title} should have signals');
    }
  });

  test('QuizDatabase contains image-card grid questions and valid answers', () {
    expect(QuizDatabase.questions.isNotEmpty, isTrue);
    final imageQuestions = QuizDatabase.getImageCardQuestions();
    expect(imageQuestions.isNotEmpty, isTrue, reason: 'Must have questions with visual image cards');

    for (final q in QuizDatabase.questions) {
      expect(q.options.any((o) => o.isCorrect), isTrue, reason: 'Question ${q.id} must have at least one correct answer');
      expect(q.explanation.isNotEmpty, isTrue);
      expect(q.keyVisualClue.isNotEmpty, isTrue);
    }
  });

  test('ScenarioDatabase contains sales and workplace simulations', () {
    expect(ScenarioDatabase.scenarios.isNotEmpty, isTrue);
    final salesScenario = ScenarioDatabase.getById('scenario_sales_closing');
    expect(salesScenario, isNotNull);
    expect(salesScenario!.steps.isNotEmpty, isTrue);
    expect(salesScenario.steps.first.choices.any((c) => c.isBestAction), isTrue);
  });

  test('StorageService persists bookmarks and user progress correctly', () async {
    expect(StorageService.isBookmarked('duchenne_smile'), isFalse);
    await StorageService.toggleBookmark('duchenne_smile');
    expect(StorageService.isBookmarked('duchenne_smile'), isTrue);

    final progress = StorageService.loadProgress();
    final updated = progress.recordQuizResult('Test Visual', 100);
    await StorageService.saveProgress(updated);

    final reloaded = StorageService.loadProgress();
    expect(reloaded.totalQuizzesTaken, equals(1));
    expect(reloaded.totalPoints, greaterThan(0));
  });

  testWidgets('ConoVeApp launches and renders main navigation bar and new tools', (WidgetTester tester) async {
    await tester.pumpWidget(const ConoVeApp());
    await tester.pumpAndSettle();

    expect(find.text('ConoVe'), findsOneWidget);
    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Manual'), findsOneWidget);
    expect(find.text('Práctica'), findsOneWidget);
    expect(find.text('Escenarios'), findsOneWidget);
    expect(find.text('Comparador Visual A/B'), findsOneWidget);

    // Scroll down to check Árbol de Decisión and Guía de Bolsillo
    await tester.drag(find.byType(ListView).first, const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(find.text('Árbol de Decisión Social'), findsOneWidget);
    expect(find.text('Guía de Bolsillo (Cheat Sheet)'), findsOneWidget);
  });

  testWidgets('SettingsProvider toggles theme, high contrast and motion dynamically', (WidgetTester tester) async {
    await tester.pumpWidget(const ConoVeApp());
    await tester.pumpAndSettle();

    final settings = SettingsProvider();
    expect(settings.themeMode, equals(ThemeMode.system));

    // Switch to dark mode
    await settings.setThemeMode(ThemeMode.dark);
    await tester.pumpAndSettle();
    expect(settings.themeMode, equals(ThemeMode.dark));

    // Switch to high contrast
    await settings.setHighContrast(true);
    await tester.pumpAndSettle();
    expect(settings.isHighContrast, isTrue);

    // Switch reduce motion
    await settings.setReduceMotion(true);
    await tester.pumpAndSettle();
    expect(settings.isReduceMotion, isTrue);
  });
}

