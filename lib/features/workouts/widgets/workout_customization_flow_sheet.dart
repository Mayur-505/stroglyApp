import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../models/category_workout_models.dart';
import '../models/workout_flow_models.dart';
import '../screens/workout_detail_plan_screen.dart';

class WorkoutCustomizationFlowSheet extends StatefulWidget {
  final CategoryWorkoutItem workout;
  final VoidCallback? onFlowCompleted;

  const WorkoutCustomizationFlowSheet({
    super.key,
    required this.workout,
    this.onFlowCompleted,
  });

  @override
  State<WorkoutCustomizationFlowSheet> createState() =>
      _WorkoutCustomizationFlowSheetState();
}

class _WorkoutCustomizationFlowSheetState
    extends State<WorkoutCustomizationFlowSheet> {
  int _currentStep = 0; // 0: Location, 1: Equipment, 2: Difficulty

  String? _selectedLocationId;
  String? _selectedEquipmentId;
  String _selectedDifficultyId = 'no_experience';

  // Step 1 Locations - using official Figma exported 380x160 assets
  static const List<WorkoutTrainingLocation> _locations = [
    WorkoutTrainingLocation(
      id: 'gym',
      title: 'In the gym',
      imagePath: 'assets/images/image 7 (1).png',
    ),
    WorkoutTrainingLocation(
      id: 'home',
      title: 'At home',
      imagePath: 'assets/images/image 7.png',
    ),
  ];

  // Step 2 Equipment Choices when "In the gym" is selected
  static const List<WorkoutEquipmentChoice> _gymEquipmentChoices = [
    WorkoutEquipmentChoice(
      id: 'gym_full',
      title: 'Full gym equipment',
      subtitle:
          '- Barbells, cable machines, squat rack\n- Weight machines, benches, dumbbells',
      imagePath: 'assets/images/image 7 (1).png',
    ),
    WorkoutEquipmentChoice(
      id: 'gym_none',
      title: 'Without any equipment',
      subtitle:
          '- Bodyweight & calisthenics exercises\n- When machines are busy or not needed',
      imagePath: 'assets/images/image 7.png',
    ),
  ];

  // Step 2 Equipment Choices when "At home" is selected
  static const List<WorkoutEquipmentChoice> _homeEquipmentChoices = [
    WorkoutEquipmentChoice(
      id: 'home_basic',
      title: 'Basic equipment',
      subtitle:
          '- Dumbbells, weights, barbell\n- ab wheel, resistance bands, gym mat',
      imagePath: 'assets/images/image 7 (1).png',
    ),
    WorkoutEquipmentChoice(
      id: 'home_none',
      title: 'Without any equipment',
      subtitle:
          '- When there is no equipment and it is not needed\n- even without a gym mat',
      imagePath: 'assets/images/image 7.png',
    ),
  ];

  List<WorkoutEquipmentChoice> get _currentEquipmentChoices {
    if (_selectedLocationId == 'gym') {
      return _gymEquipmentChoices;
    }
    return _homeEquipmentChoices;
  }

  // Step 3 Difficulty Levels
  static const List<WorkoutDifficultyLevel> _difficultyLevels = [
    WorkoutDifficultyLevel(
      id: 'no_experience',
      title: 'No experience',
      filledStars: 0,
    ),
    WorkoutDifficultyLevel(
      id: 'beginner',
      title: 'Beginner',
      filledStars: 1,
    ),
    WorkoutDifficultyLevel(
      id: 'advanced',
      title: 'Advanced',
      filledStars: 2,
    ),
    WorkoutDifficultyLevel(
      id: 'expert',
      title: 'Expert',
      filledStars: 3,
    ),
    WorkoutDifficultyLevel(
      id: 'pro',
      title: 'Pro',
      filledStars: 4,
    ),
  ];

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    } else {
      _finishFlow();
    }
  }

  void _finishFlow() {
    final nav = Navigator.of(context);
    nav.pop();
    widget.onFlowCompleted?.call();

    final selectedLevel = _difficultyLevels.firstWhere(
      (lvl) => lvl.id == _selectedDifficultyId,
      orElse: () => _difficultyLevels.first,
    );

    nav.push(
      MaterialPageRoute(
        builder: (_) => WorkoutDetailPlanScreen(
          title: widget.workout.title,
          heroImage: widget.workout.imagePath,
          difficultyLevel: selectedLevel.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF141416),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
      ),
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 16.0,
        bottom: 20.0 + (bottomInset > 0 ? bottomInset : 16.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with Close and Title
          _buildHeader(),

          const SizedBox(height: 20),

          // Animated Step Content
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.05, 0.0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _buildCurrentStepContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    String title = '';
    switch (_currentStep) {
      case 0:
        title = 'Where to train';
        break;
      case 1:
        title = 'Training equipment';
        break;
      case 2:
        title = 'Difficulty Level';
        break;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () {
              if (_currentStep > 0) {
                setState(() {
                  _currentStep--;
                });
              } else {
                Navigator.of(context).pop();
              }
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF222226),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.10),
                ),
              ),
              child: Icon(
                _currentStep > 0
                    ? Icons.arrow_back_rounded
                    : Icons.close_rounded,
                color: Colors.white70,
                size: 20,
              ),
            ),
          ),
        ),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildWhereToTrainStep();
      case 1:
        return _buildEquipmentStep();
      case 2:
        return _buildDifficultyStep();
      default:
        return const SizedBox.shrink();
    }
  }

  // STEP 1: Where to train (Figma full width, 160px height, #1B1B1B background, 1px lime gradient border, Rectangle 2 overlay)
  Widget _buildWhereToTrainStep() {
    return Column(
      key: const ValueKey('step_0_where_to_train'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _locations.map((loc) {
        final isSelected = loc.id == _selectedLocationId;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (_selectedLocationId != loc.id) {
                  _selectedEquipmentId = null;
                }
                _selectedLocationId = loc.id;
              });
              _nextStep();
            },
            child: Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isSelected
                      ? [
                          const Color(0xFFA3D223),
                          const Color(0xFFA3D223),
                        ]
                      : [
                          const Color(0xFFA3D223),
                          const Color(0x00A3D223),
                        ],
                ),
              ),
              padding: const EdgeInsets.all(1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1B1B),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Full-card background athlete photo
                    Positioned.fill(
                      child: Image.asset(
                        loc.imagePath,
                        fit: BoxFit.cover,
                        alignment: Alignment.centerRight,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox.shrink(),
                      ),
                    ),

                    // Rectangle 2 Left-to-Right Black/Dark overlay
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xFF000000),
                              Color(0xF2000000),
                              Color(0x80000000),
                              Color(0x00000000),
                            ],
                            stops: [0.0, 0.35, 0.60, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Title Text on left
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          loc.title,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // STEP 2: Training equipment (Figma full width, 160px height, #1B1B1B background, 1px lime gradient border, Rectangle 2 overlay)
  Widget _buildEquipmentStep() {
    return Column(
      key: ValueKey('step_1_equipment_${_selectedLocationId ?? 'default'}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _currentEquipmentChoices.map((equip) {
        final isSelected = equip.id == _selectedEquipmentId;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedEquipmentId = equip.id;
              });
              _nextStep();
            },
            child: Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isSelected
                      ? [
                          const Color(0xFFA3D223),
                          const Color(0xFFA3D223),
                        ]
                      : [
                          const Color(0xFFA3D223),
                          const Color(0x00A3D223),
                        ],
                ),
              ),
              padding: const EdgeInsets.all(1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1B1B),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Full-card background athlete / equipment photo
                    Positioned.fill(
                      child: Image.asset(
                        equip.imagePath,
                        fit: BoxFit.cover,
                        alignment: Alignment.centerRight,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox.shrink(),
                      ),
                    ),

                    // Rectangle 2 Left-to-Right Black/Dark overlay
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xFF000000),
                              Color(0xF2000000),
                              Color(0x80000000),
                              Color(0x00000000),
                            ],
                            stops: [0.0, 0.45, 0.65, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Title + Subtitle Text on left
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 20.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            equip.title,
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            equip.subtitle,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withValues(alpha: 0.75),
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // STEP 3: Difficulty Level (Figma full width, 54px cards, #A3D223 selected, 4 stars)
  Widget _buildDifficultyStep() {
    return Column(
      key: const ValueKey('step_2_difficulty'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _difficultyLevels.map((diff) {
        final isSelected = diff.id == _selectedDifficultyId;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedDifficultyId = diff.id;
              });
              // Finish on selection
              Future.delayed(const Duration(milliseconds: 180), () {
                _finishFlow();
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: double.infinity,
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryLime
                    : const Color(0xFF1B1B1B),
                borderRadius: BorderRadius.circular(16.0),
                border: isSelected
                    ? null
                    : Border.all(
                        color: Colors.white.withValues(alpha: 0.10),
                        width: 1.0,
                      ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    diff.title,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFF141416)
                          : Colors.white,
                    ),
                  ),
                  _buildStars(diff.filledStars, isSelected),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStars(int filledCount, bool isSelected) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        final isFilled = index < filledCount;
        return Padding(
          padding: const EdgeInsets.only(left: 3.0),
          child: Icon(
            isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 19,
            color: isSelected
                ? const Color(0xFF141416)
                : (isFilled ? AppColors.primaryLime : Colors.white38),
          ),
        );
      }),
    );
  }
}
