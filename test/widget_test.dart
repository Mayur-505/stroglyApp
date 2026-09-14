import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strongly/main.dart';
import 'package:strongly/features/splash/widgets/strongly_logo.dart';
import 'package:strongly/features/onboarding/screens/onboarding_screen.dart';
import 'package:strongly/features/gender_selection/screens/gender_selection_screen.dart';
import 'package:strongly/features/questionnaire/screens/questionnaire_flow_screen.dart';
import 'package:strongly/features/language/screens/language_selection_screen.dart';
import 'package:strongly/core/services/language_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:strongly/features/home/screens/home_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    LanguageService.instance.currentLanguageNotifier.value = 'en';
  });

  testWidgets('Strongly splash screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const StronglyApp());

    // Verify logo and tagline exist
    expect(find.byType(StronglyLogo), findsOneWidget);
    expect(find.text('Become Your Strongest.'), findsOneWidget);
  });

  testWidgets('Strongly onboarding screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OnboardingScreen(),
      ),
    );

    // Verify first onboarding slide text
    expect(find.text('BUILD YOUR\nSTRONGEST SELF'), findsOneWidget);
    expect(
      find.text(
        'Personalized workouts designed\naround your body, goals\nand fitness level.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('Strongly gender selection screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: GenderSelectionScreen(),
      ),
    );

    // Verify MEN, WOMEN, and Title exist
    expect(find.text('MEN'), findsOneWidget);
    expect(find.text('WOMEN'), findsOneWidget);
    expect(find.text('TELL US ABOUT\nYOURSELF'), findsOneWidget);
  });

  testWidgets('Strongly questionnaire flow smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: QuestionnaireFlowScreen(selectedGender: 'Male'),
      ),
    );

    // Verify first questionnaire step (Scree106)
    expect(find.text("LET'S UNDERSTAND\nYOUR BODY"), findsOneWidget);
    expect(find.text('Height'), findsOneWidget);
    expect(find.text('Weight'), findsOneWidget);
  });

  testWidgets('Strongly home screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );

    // Verify home screen elements
    expect(find.text('STRONGLY'), findsOneWidget);
    expect(find.text('Good Morning, Alex 👋'), findsOneWidget);
    expect(find.text('Quick Categories'), findsOneWidget);
    expect(find.text('Recommended For You'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Workout'), findsOneWidget);
    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // Tap on Workout tab in bottom navigation bar
    await tester.tap(find.text('Workout'));
    await tester.pumpAndSettle();

    // Verify Workouts screen is displayed
    expect(find.text('Workouts'), findsOneWidget);
    expect(find.text('Muscle Group'), findsOneWidget);
    expect(find.text('Focus on target'), findsOneWidget);
    expect(find.text('Guess you may need'), findsOneWidget);
    expect(find.text('ABS'), findsOneWidget);
    expect(find.text('LOSE WEIGHT'), findsOneWidget);

    // Tap search icon button to open WorkoutSearchScreen
    await tester.tap(find.byIcon(Icons.search_rounded));
    await tester.pumpAndSettle();

    // Verify search screen elements
    expect(find.text('Body Focus'), findsOneWidget);
    expect(find.text('Hot Topics'), findsOneWidget);
    expect(find.text('Abs'), findsOneWidget);
    expect(find.text('Chest'), findsOneWidget);
    expect(find.text('Lose weight'), findsOneWidget);
    expect(find.text('Build muscle'), findsOneWidget);

    // Tap a tag to test interactivity
    await tester.tap(find.text('HIIT'));
    await tester.pumpAndSettle();

    // Tap close button (Icons.close_rounded) to navigate back
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    // Verify back on Workouts screen
    expect(find.text('Workouts'), findsOneWidget);

    // Tap on ABS workout card to open CategoryWorkoutsScreen
    await tester.tap(find.text('ABS'));
    await tester.pumpAndSettle();

    // Verify Categories screen elements
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Classic abs'), findsOneWidget);

    // Tap 'All' filter chip to show all categories
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();

    expect(find.text('Classic arm'), findsOneWidget);
    expect(find.text('Classic leg'), findsOneWidget);
    expect(find.text('Free'), findsWidgets);

    // Tap on a Free workout ('Classic abs')
    await tester.tap(find.text('Classic abs'));
    await tester.pumpAndSettle();

    // Verify Free workout directly opens 'Where to train' sheet
    expect(find.text('Where to train'), findsOneWidget);
    expect(find.text('In the gym'), findsOneWidget);
    expect(find.text('At home'), findsOneWidget);

    // Step 1: Select 'In the gym' -> advances to Step 2
    await tester.tap(find.text('In the gym'));
    await tester.pumpAndSettle();

    // Verify Step 2: 'Training equipment' for Gym
    expect(find.text('Training equipment'), findsOneWidget);
    expect(find.text('Full gym equipment'), findsOneWidget);
    expect(find.text('Without any equipment'), findsOneWidget);

    // Tap sheet back button to test 'At home' equipment options
    await tester.tap(find.byIcon(Icons.arrow_back_rounded).last);
    await tester.pumpAndSettle();

    // Step 1: Select 'At home' -> advances to Step 2
    await tester.tap(find.text('At home'));
    await tester.pumpAndSettle();

    // Verify Step 2: 'Training equipment' for Home
    expect(find.text('Training equipment'), findsOneWidget);
    expect(find.text('Basic equipment'), findsOneWidget);
    expect(find.text('Without any equipment'), findsOneWidget);

    // Step 2: Select 'Basic equipment' -> advances to Step 3
    await tester.tap(find.text('Basic equipment'));
    await tester.pumpAndSettle();

    // Verify Step 3: 'Difficulty Level'
    expect(find.text('Difficulty Level'), findsOneWidget);
    expect(find.text('No experience'), findsOneWidget);
    expect(find.text('Beginner'), findsOneWidget);

    // Step 3: Select 'No experience' -> finishes setup flow and opens WorkoutDetailPlanScreen
    await tester.tap(find.text('No experience'));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    // Verify WorkoutDetailPlanScreen elements
    expect(find.text('Days'), findsOneWidget);
    expect(find.text('Strength'), findsOneWidget);
    expect(find.text('Cardio'), findsOneWidget);
    expect(find.text('Ready to go!'), findsOneWidget);

    // Test Image 2 -> Image 3 flow:
    // Scroll Day 1 into view and tap it in WorkoutDetailPlanScreen
    await tester.ensureVisible(find.text('1').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('1').first);
    await tester.pumpAndSettle();

    // Verify ExercisePreviewScreen (Image 3) elements
    expect(find.text('Jumping Jacks'), findsWidgets);
    expect(find.text('Full body'), findsOneWidget);
    expect(find.text('Key Tips'), findsOneWidget);
    expect(find.text('1/13'), findsOneWidget);

    // Verify Start button is NOT shown as requested!
    expect(find.text('Start'), findsNothing);

    // Test carousel next arrow (>)
    await tester.tap(find.byIcon(Icons.chevron_right_rounded));
    await tester.pumpAndSettle();
    expect(find.text('2/13'), findsOneWidget);
    expect(find.text('Squats'), findsWidgets);

    // Tap back button from ExercisePreviewScreen
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    // Now tap 'Ready to go!' to open WorkoutStartScheduleScreen
    await tester.tap(find.text('Ready to go!'));
    await tester.pumpAndSettle();

    // Verify WorkoutStartScheduleScreen elements
    expect(find.text('No experience'), findsOneWidget);
    expect(find.text('0 / 30'), findsOneWidget);
    expect(find.text(' Days Finished'), findsOneWidget);
    expect(find.text('DAY'), findsWidgets);

    // Tap Day 1 to open DayWorkoutExercisesScreen (Screen 4)
    await tester.tap(find.text('1').first);
    await tester.pumpAndSettle();

    // Verify DayWorkoutExercisesScreen Screen 4 elements
    expect(find.text('DAY 1'), findsOneWidget);
    expect(find.text('13 Exercises'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);

    // Tap 'Start' -> opens ExercisePreviewScreen (Jumping Jacks) with Start button!
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    // Verify Jumping Jacks screen is opened
    expect(find.text('Jumping Jacks'), findsWidgets);
    expect(find.text('1/13'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);

    // Tap 'Start' on Jumping Jacks screen -> opens ActiveWorkoutLandscapeScreen!
    await tester.tap(find.text('Start'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Verify ActiveWorkoutLandscapeScreen elements (Screen 1):
    expect(find.text('Exercise 1/13'), findsOneWidget);
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    // Tap Pause button -> opens Pause overlay (Screen 2)
    await tester.tap(find.byIcon(Icons.pause_rounded));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Pause'), findsOneWidget);
    expect(find.text('Restart this exercise'), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);
    expect(find.text('Quit'), findsOneWidget);

    // Tap Resume -> returns to exercising
    await tester.tap(find.text('Resume'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Pause'), findsNothing);

    // Tap Checkmark button -> advances to Rest/Next screen (Screen 3)
    await tester.tap(find.byIcon(Icons.check_rounded));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Rest'), findsOneWidget);
    expect(find.text('+20s'), findsOneWidget);
    expect(find.text('Next 2/13'), findsOneWidget);
    expect(find.text('Squats'), findsOneWidget);

    // Tap 'Skip' on Rest screen -> advances to Squats (Exercise 2/13)
    await tester.tap(find.text('Skip').last);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Exercise 2/13'), findsOneWidget);

    // Tap back chevron to open Pause -> Quit -> Why quit? (Screen 5)
    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Pause'), findsOneWidget);
    await tester.tap(find.text('Quit'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Why quit?'), findsOneWidget);
    expect(find.text('Just take a look'), findsOneWidget);
    expect(find.text('Too hard'), findsOneWidget);
    expect(find.text('Too easy'), findsOneWidget);

    // Tap 'Just take a look' -> exits back to ExercisePreviewScreen
    await tester.tap(find.text('Just take a look'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Tap Back to return to DayWorkoutExercisesScreen
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    // Verify DayWorkoutExercisesScreen is now in progress (Screen 5 with Restart and Continue)
    expect(find.text('Restart'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    // Tap 'Continue' -> also opens ExercisePreviewScreen (Jumping Jacks)!
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Jumping Jacks'), findsWidgets);
    expect(find.text('1/13'), findsOneWidget);

    // Tap back to return to DayWorkoutExercisesScreen
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    // Complete Day via 3-dots popup menu
    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Complete Day'), findsOneWidget);
    await tester.tap(find.text('Complete Day'));
    await tester.pumpAndSettle();

    expect(find.text('Complete Day 1'), findsOneWidget);
    await tester.tap(find.text('Complete Day 1'));
    await tester.pumpAndSettle();

    // Verify back on WorkoutStartScheduleScreen with updated count 1 / 30
    expect(find.text('1 / 30'), findsOneWidget);

    // Tap info icon (help_outline_rounded) to test the Plan Info modal bottom sheet
    await tester.tap(find.byIcon(Icons.help_outline_rounded));
    await tester.pumpAndSettle();

    // Verify Plan Info sheet elements match design
    expect(find.text('Close'), findsOneWidget);
    expect(find.text('Strength'), findsWidgets);
    expect(find.text('Cardio'), findsWidgets);
    expect(find.text('Minutes\nper day'), findsOneWidget);

    // Tap 'Close' to dismiss
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Close'), findsNothing);

    // Tap back button to return to WorkoutDetailPlanScreen
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    // Scroll back up and tap back button to return to Categories screen
    await tester.ensureVisible(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    // Now test Premium workout flow:
    // First tap 'All' to show all categories
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();

    // Scroll down vertical list to bring 'Stretch' into view
    await tester.drag(find.byType(ListView).last, const Offset(0, -300));
    await tester.pumpAndSettle();

    // Tap on a Premium workout ('Stretch')
    await tester.tap(find.text('Stretch'));
    await tester.pumpAndSettle();

    // Verify Premium workout shows 'Watch video to unlock' sheet
    expect(find.text('Watch video to unlock'), findsOneWidget);
    expect(find.text('Watch video'), findsOneWidget);
    expect(find.text('Go Premium'), findsOneWidget);

    // Tap 'Watch video' to unlock
    await tester.tap(find.text('Watch video'));
    await tester.pumpAndSettle();

    // Verify unlocks into 'Where to train' sheet
    expect(find.text('Where to train'), findsOneWidget);

    // Close the sheet
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    // Tap back button to return to Workouts
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    // Verify back on Workouts screen
    expect(find.text('Workouts'), findsOneWidget);

    // Switch to Progress tab in bottom navigation bar
    await tester.tap(find.text('Progress'));
    await tester.pumpAndSettle();

    // Verify Progress screen elements matching Figma design
    expect(find.text('Progress'), findsWidgets);
    expect(find.text('Workout (min)'), findsOneWidget);
    expect(find.text('Calories (cal)'), findsOneWidget);
    expect(find.text('Weight (lbs)'), findsOneWidget);
    expect(find.text('Steps'), findsOneWidget);
    expect(find.text('1500'), findsOneWidget);
    expect(find.text('stp'), findsOneWidget);
    expect(find.text('<1 min'), findsOneWidget);
    expect(find.text('<1 Calories'), findsOneWidget);
    expect(find.text('Weekly Average'), findsWidgets);
    expect(find.text('30'), findsOneWidget);

    // 1. Tap Weekly Calendar Card -> opens History tab in ProgressDetailScreen
    await tester.tap(find.text('30'));
    await tester.pumpAndSettle();

    // Verify History screen elements
    expect(find.text('Summary'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('September 2026'), findsOneWidget);
    expect(find.text('August 2026'), findsOneWidget);
    expect(find.text('Full Body Shred Level 1'), findsWidgets);
    expect(find.text('11'), findsWidgets);
    expect(find.text('Workouts'), findsOneWidget);

    // 2. Switch tab to Summary
    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();

    // Verify Summary screen elements
    expect(find.text('Average (min)'), findsOneWidget);

    // 3. Tap back button to return to Progress overview
    await tester.tap(find.byKey(const ValueKey('progress_detail_back_button')));
    await tester.pumpAndSettle();

    // Verify back on Progress overview screen
    expect(find.text('Workout (min)'), findsOneWidget);

    // 4. Tap lower card (Workout (min)) -> opens Summary tab directly!
    await tester.tap(find.text('Workout (min)'));
    await tester.pumpAndSettle();

    // Verify Summary tab is active
    expect(find.text('Average (min)'), findsOneWidget);

    // Tap back button
    await tester.tap(find.byKey(const ValueKey('progress_detail_back_button')));
    await tester.pumpAndSettle();

    // 5. Tap back button on Progress screen to return to Home tab
    await tester.tap(find.byKey(const ValueKey('progress_back_button')));
    await tester.pumpAndSettle();

    // Verify back on Home tab
    expect(find.text('STRONGLY'), findsWidgets);

    // 6. Switch to Profile tab in bottom navigation bar
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    // Verify My profile screen elements
    expect(find.text('My profile'), findsOneWidget);
    expect(find.text('Backup & Restore'), findsOneWidget);
    expect(find.text('Google'), findsOneWidget);
    expect(find.text('Setting'), findsOneWidget);
    expect(find.text('My Workouts'), findsOneWidget);
    expect(find.text('General Settings'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Rate Us'), findsOneWidget);

    // 7. Tap 'Go Premium' button in top bar -> opens GoPremiumScreen
    await tester.tap(find.byKey(const ValueKey('profile_go_premium_button')));
    await tester.pumpAndSettle();

    // Verify GoPremiumScreen elements
    expect(find.text('Start Strong'), findsOneWidget);
    expect(find.text('Step-by-Step Video Coaching'), findsOneWidget);
    expect(find.text('100+ Home Workouts'), findsOneWidget);
    expect(find.text('1. Auto-Renewal'), findsOneWidget);
    expect(find.text('Free 7-day trail, then ₹2,300.00/year'), findsOneWidget);

    // Tap close button to return to My profile
    await tester.tap(find.byKey(const ValueKey('go_premium_close_button')));
    await tester.pumpAndSettle();

    // Verify back on My profile
    expect(find.text('My profile'), findsOneWidget);

    // 8. Tap back button on My profile to return to Home
    await tester.tap(find.byKey(const ValueKey('profile_back_button')));
    await tester.pumpAndSettle();

    // Verify back on Home tab
    expect(find.text('STRONGLY'), findsWidgets);
  });

  testWidgets('Strongly language selection screen and 10 languages smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: LanguageSelectionScreen(),
      ),
    );

    // Verify Title and Subtitle
    expect(find.text('Select Language'), findsOneWidget);
    expect(find.text('Choose your preferred language for the best workout experience'), findsOneWidget);

    // Verify all 10 requested languages are present
    expect(find.text('English'), findsWidgets);
    expect(find.text('हिन्दी'), findsOneWidget);
    expect(find.text('Hindi'), findsOneWidget);
    expect(find.text('ગુજરાતી'), findsOneWidget);
    expect(find.text('Gujarati'), findsOneWidget);
    expect(find.text('Español'), findsOneWidget);
    expect(find.text('Spanish'), findsOneWidget);
    expect(find.text('Français'), findsOneWidget);
    expect(find.text('French'), findsOneWidget);
    expect(find.text('Deutsch'), findsOneWidget);
    expect(find.text('German'), findsOneWidget);
    expect(find.text('العربية'), findsOneWidget);
    expect(find.text('Arabic'), findsOneWidget);
    expect(find.text('中文'), findsOneWidget);
    expect(find.text('Chinese'), findsOneWidget);
    expect(find.text('Português'), findsOneWidget);
    expect(find.text('Portuguese'), findsOneWidget);
    expect(find.text('日本語'), findsOneWidget);
    expect(find.text('Japanese'), findsOneWidget);

    // Select Gujarati
    await tester.tap(find.byKey(const ValueKey('language_item_gu')));
    await tester.pumpAndSettle();

    // Tap Continue
    await tester.tap(find.byKey(const ValueKey('language_continue_button')));
    await tester.pumpAndSettle();

    // Verify LanguageService updated to Gujarati
    expect(LanguageService.instance.currentLanguage, 'gu');
    expect('select_language'.tr, 'ભાષા પસંદ કરો');
    expect('tell_us_about_yourself'.tr, 'તમારા વિશે\nજણાવો');

    // Reset back to English for remaining tests
    await LanguageService.instance.setLanguage('en');
    expect(LanguageService.instance.currentLanguage, 'en');
  });

  testWidgets('Onboarding transitions to LanguageSelectionScreen on Get Started', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OnboardingScreen(),
      ),
    );

    // Verify Onboarding slide 1
    expect(find.text('BUILD YOUR\nSTRONGEST SELF'), findsOneWidget);

    // Advance to slide 2
    await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
    await tester.pumpAndSettle();

    // Advance to slide 3
    await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
    await tester.pumpAndSettle();

    // Verify slide 3 has "Get Started"
    expect(find.text('Get Started'), findsOneWidget);

    // Tap "Get Started"
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // Verify LanguageSelectionScreen is displayed (marked red rectangle in user diagram)
    expect(find.text('Select Language'), findsOneWidget);
    expect(find.text('ગુજરાતી'), findsOneWidget);
    expect(find.text('हिन्दी'), findsOneWidget);
    expect(find.text('English'), findsWidgets);

    // Tap Continue from LanguageSelectionScreen -> navigates to GenderSelectionScreen (Scree105)
    await tester.tap(find.byKey(const ValueKey('language_continue_button')));
    await tester.pumpAndSettle();

    // Verify now on GenderSelectionScreen (Scree105)
    expect(find.text('TELL US ABOUT\nYOURSELF'), findsOneWidget);
    expect(find.text('MEN'), findsOneWidget);
    expect(find.text('WOMEN'), findsOneWidget);
  });

  testWidgets('Tapping See All on Quick Categories opens CategoryWorkoutsScreen (Image 2)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify HomeScreen Quick Categories has See All
    final seeAllWidgets = find.text('See All');
    expect(seeAllWidgets, findsWidgets);

    // Ensure See All is visible and tap it
    await tester.ensureVisible(seeAllWidgets.first);
    await tester.pumpAndSettle();
    await tester.tap(seeAllWidgets.first);
    await tester.pumpAndSettle();

    // Verify Categories screen (Image 2) elements
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Classic abs'), findsOneWidget);
    expect(find.text('Classic arm'), findsOneWidget);
    expect(find.text('Classic chest & back'), findsOneWidget);
    expect(find.text('Classic leg'), findsOneWidget);
    expect(find.text('Classic shoulder'), findsOneWidget);
    expect(find.text('Stretch'), findsWidgets);
    expect(find.text('Fat burning HIIT'), findsOneWidget);
    expect(find.text('Full Body Power'), findsOneWidget);
    expect(find.text('Free'), findsWidgets);
  });

  testWidgets('Tapping recommended workout card opens WorkoutDetailPlanScreen',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Recommended Workout Card exists
    final fatBurnCard = find.text('20 MIN FAT BURN');
    expect(fatBurnCard, findsOneWidget);

    // Ensure it is visible and tap it
    await tester.ensureVisible(fatBurnCard);
    await tester.pumpAndSettle();
    await tester.tap(fatBurnCard);
    await tester.pumpAndSettle();

    // Verify WorkoutDetailPlanScreen is displayed with workout title
    expect(find.text('20 MIN FAT BURN'), findsOneWidget);
    expect(find.text('Ready to go!'), findsOneWidget);
  });
}


