import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strongly/core/services/language_service.dart';
import 'package:strongly/features/gender_selection/screens/gender_selection_screen.dart';
import 'package:strongly/features/questionnaire/screens/questionnaire_flow_screen.dart';
import 'package:strongly/features/home/screens/home_screen.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LanguageService.instance.init();
    await LanguageService.instance.setLanguage('en');
  });

  testWidgets('GenderSelectionScreen and QuestionnaireFlowScreen convert dynamically on language change',
      (WidgetTester tester) async {
    // 1. Switch language to Gujarati
    await LanguageService.instance.setLanguage('gu');

    await tester.pumpWidget(
      MaterialApp(
        key: ValueKey(LanguageService.instance.currentLanguage),
        home: const GenderSelectionScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Gujarati strings on GenderSelectionScreen
    expect(find.text('પુરુષ'), findsOneWidget);
    expect(find.text('મહિલા'), findsOneWidget);
    expect(find.text('આગળ વધો'), findsOneWidget);

    // 2. Switch to Hindi and pump QuestionnaireFlowScreen
    await LanguageService.instance.setLanguage('hi');

    await tester.pumpWidget(
      MaterialApp(
        key: ValueKey(LanguageService.instance.currentLanguage),
        home: const QuestionnaireFlowScreen(selectedGender: 'Male'),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Hindi metrics on Screen 106
    expect(find.text('कद'), findsOneWidget);
    expect(find.text('वज़न'), findsOneWidget);
    expect(find.text('उम्र'), findsOneWidget);
    expect(find.text('सक्रियता स्तर'), findsOneWidget);
    expect(find.text('आगे बढ़ें'), findsOneWidget);
  });

  testWidgets('HomeScreen and tabs reflect selected language',
      (WidgetTester tester) async {
    await LanguageService.instance.setLanguage('gu');

    await tester.pumpWidget(
      MaterialApp(
        key: ValueKey(LanguageService.instance.currentLanguage),
        home: const HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Gujarati Home strings
    expect(find.text('સુપ્રભાત, Alex 👋'), findsOneWidget);
    expect(find.text('શું તમે પરસેવો પાડવા તૈયાર છો?'), findsOneWidget);
    expect(find.text('ઝડપી કેટેગરી'), findsOneWidget);
    expect(find.text('તમારા માટે ભલામણ કરેલ'), findsOneWidget);
    expect(find.text('હોમ'), findsOneWidget);
    expect(find.text('વર્કઆઉટ'), findsOneWidget);
    expect(find.text('પ્રગતિ'), findsOneWidget);
    expect(find.text('પ્રોફાઇલ'), findsOneWidget);
  });
}
