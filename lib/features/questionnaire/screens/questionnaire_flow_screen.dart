import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/language_service.dart';
import '../../../core/services/preference_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../widgets/questionnaire_layout.dart';
import '../../home/screens/home_screen.dart';

class QuestionnaireFlowScreen extends StatefulWidget {
  final String selectedGender;

  const QuestionnaireFlowScreen({
    super.key,
    this.selectedGender = 'Male',
  });

  @override
  State<QuestionnaireFlowScreen> createState() =>
      _QuestionnaireFlowScreenState();
}

class _QuestionnaireFlowScreenState extends State<QuestionnaireFlowScreen> {
  late final PageController _pageController;
  int _currentStep = 0;

  // Profile Form State
  late UserProfile _profile;

  // Controllers for Screen 106
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;
  late final TextEditingController _ageController;
  late final TextEditingController _manualTimeController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _profile = UserProfile(gender: widget.selectedGender);
    _heightController = TextEditingController(text: '${_profile.height}');
    _weightController = TextEditingController(text: '${_profile.weight}');
    _ageController = TextEditingController(text: '${_profile.age}');
    _manualTimeController = TextEditingController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _manualTimeController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentStep < 6) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeQuestionnaire();
    }
  }

  void _prevPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _completeQuestionnaire() async {
    // Save state to permanent storage
    await PreferenceService.saveUserProfile(_profile);
    await PreferenceService.setOnboardingCompleted(true);

    // Sync to backend API
    ApiClient.instance.post(
      ApiConstants.questionnaire,
      {
        'gender': _profile.gender,
        'height': _profile.height,
        'heightUnit': _profile.heightUnit,
        'weight': _profile.weight,
        'weightUnit': _profile.weightUnit,
        'age': _profile.age,
        'activityLevel': _profile.activityLevel,
        'goals': _profile.goals,
        'workoutPlace': _profile.workoutPlace,
        'fitnessLevel': _profile.fitnessLevel,
        'duration': _profile.duration,
        'trainingDays': _profile.trainingDays,
      },
    ).catchError((_) => ApiResponse(success: false, statusCode: 500));

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      onPageChanged: (index) {
        setState(() {
          _currentStep = index;
        });
      },
      children: [
        _buildScreen106BodyMetrics(),
        _buildScreen107MainGoals(),
        _buildScreen108WorkoutPlace(),
        _buildScreen109FitnessLevel(),
        _buildScreen110WorkoutTime(),
        _buildScreen111TrainingFrequency(),
        _buildScreen112PersonalizedPlan(),
      ],
    );
  }

  // ==========================================
  // Screen 106: "LET'S UNDERSTAND YOUR BODY"
  // ==========================================
  Widget _buildScreen106BodyMetrics() {
    return QuestionnaireLayout(
      title: LanguageService.tr('lets_understand_body'),
      subtitle: LanguageService.tr('personalize_fitness_journey'),
      onBack: _prevPage,
      onNext: () {
        _profile.height = int.tryParse(_heightController.text) ?? 175;
        _profile.weight = int.tryParse(_weightController.text) ?? 75;
        _profile.age = int.tryParse(_ageController.text) ?? 25;
        _nextPage();
      },
      child: Column(
        children: [
          _buildMetricInputRow(
            label: LanguageService.tr('height'),
            icon: Icons.height_rounded,
            controller: _heightController,
            unit: _profile.heightUnit,
            unitOptions: const ['CM', 'FT'],
            onUnitChanged: (val) {
              setState(() => _profile.heightUnit = val);
            },
          ),
          const SizedBox(height: 16),
          _buildMetricInputRow(
            label: LanguageService.tr('weight'),
            icon: Icons.monitor_weight_outlined,
            controller: _weightController,
            unit: _profile.weightUnit,
            unitOptions: const ['Kg', 'Lbs'],
            onUnitChanged: (val) {
              setState(() => _profile.weightUnit = val);
            },
          ),
          const SizedBox(height: 16),
          _buildMetricInputRow(
            label: LanguageService.tr('age'),
            icon: Icons.calendar_today_outlined,
            controller: _ageController,
          ),
          const SizedBox(height: 16),
          _buildActivityLevelRow(),
        ],
      ),
    );
  }

  Widget _buildMetricInputRow({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    String? unit,
    List<String>? unitOptions,
    ValueChanged<String>? onUnitChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 48.0, bottom: 6.0),
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Colors.white54,
            ),
          ),
        ),
        Row(
          children: [
            Icon(icon, color: AppColors.primaryLime, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1B1D),
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.10),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    if (unit != null && unitOptions != null && onUnitChanged != null)
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: unit,
                          borderRadius: BorderRadius.circular(14.0),
                          dropdownColor: const Color(0xFF222226),
                          elevation: 6,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.white70,
                            size: 20,
                          ),
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          items: unitOptions.map((opt) {
                            final isSelected = opt == unit;
                            return DropdownMenuItem(
                              value: opt,
                              child: Text(
                                opt,
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight:
                                      isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.primaryLime
                                      : Colors.white,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) onUnitChanged(val);
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityLevelRow() {
    final activityOptions = [
      {'val': 'Sedentary', 'label': LanguageService.tr('sedentary')},
      {'val': 'Moderate', 'label': LanguageService.tr('moderate')},
      {'val': 'High Active', 'label': LanguageService.tr('high_active')},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 48.0, bottom: 6.0),
          child: Text(
            LanguageService.tr('activity_level'),
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Colors.white54,
            ),
          ),
        ),
        Row(
          children: [
            const Icon(
              Icons.directions_run_outlined,
              color: AppColors.primaryLime,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1B1D),
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.10),
                    width: 1.0,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _profile.activityLevel,
                    borderRadius: BorderRadius.circular(14.0),
                    dropdownColor: const Color(0xFF222226),
                    elevation: 6,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white70,
                      size: 20,
                    ),
                    isExpanded: true,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    items: activityOptions.map((opt) {
                      final isSelected = opt['val'] == _profile.activityLevel;
                      return DropdownMenuItem<String>(
                        value: opt['val']!,
                        child: Text(
                          opt['label']!,
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? AppColors.primaryLime
                                : Colors.white,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _profile.activityLevel = val);
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // Screen 107: "WHAT IS YOUR MAIN GOAL?"
  // ==========================================
  Widget _buildScreen107MainGoals() {
    final goals = [
      {'id': 'Lose Weight', 'label': LanguageService.tr('lose_weight'), 'icon': Icons.local_fire_department_rounded},
      {'id': 'Build Muscle', 'label': LanguageService.tr('build_muscle'), 'icon': Icons.fitness_center_rounded},
      {'id': 'Six Pack', 'label': LanguageService.tr('six_pack'), 'icon': Icons.sports_gymnastics_rounded},
      {'id': 'Improve Fitness', 'label': LanguageService.tr('improve_fitness'), 'icon': Icons.favorite_rounded},
      {'id': 'Increase Strength', 'label': LanguageService.tr('increase_strength'), 'icon': Icons.bolt_rounded},
      {'id': 'Stay Active', 'label': LanguageService.tr('stay_active'), 'icon': Icons.sentiment_satisfied_alt_rounded},
    ];

    return QuestionnaireLayout(
      title: LanguageService.tr('select_main_goal'),
      subtitle: LanguageService.tr('select_more_than_one_goal'),
      onBack: _prevPage,
      onNext: _nextPage,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: goals.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.25,
        ),
        itemBuilder: (context, index) {
          final item = goals[index];
          final id = item['id'] as String;
          final title = item['label'] as String;
          final icon = item['icon'] as IconData;
          final isSelected = _profile.goals.contains(id);

          return _GradientBorderCard(
            isSelected: isSelected,
            padding: const EdgeInsets.all(12.0),
            onTap: () {
              setState(() {
                if (isSelected) {
                  _profile.goals.remove(id);
                } else {
                  _profile.goals.add(id);
                }
              });
            },
            child: Stack(
              children: [
                if (isSelected)
                  const Positioned(
                    top: 0,
                    right: 0,
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primaryLime,
                      size: 18,
                    ),
                  ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        color: isSelected
                            ? AppColors.primaryLime
                            : Colors.white,
                        size: 32,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // Screen 108: "WHERE DO YOU PREFER TO WORKOUT?"
  // ==========================================
  Widget _buildScreen108WorkoutPlace() {
    final places = [
      {
        'id': 'Home',
        'title': LanguageService.tr('home'),
        'subtitle': LanguageService.tr('home_place_desc'),
        'icon': Icons.home_rounded,
      },
      {
        'id': 'Gym',
        'title': LanguageService.tr('gym'),
        'subtitle': LanguageService.tr('gym_place_desc'),
        'icon': Icons.fitness_center_rounded,
      },
      {
        'id': 'Outdoor',
        'title': LanguageService.tr('outdoor'),
        'subtitle': LanguageService.tr('outdoor_place_desc'),
        'icon': Icons.park_rounded,
      },
    ];

    return QuestionnaireLayout(
      title: LanguageService.tr('where_prefer_workout'),
      onBack: _prevPage,
      onNext: _nextPage,
      child: Column(
        children: places.map((place) {
          final id = place['id'] as String;
          final title = place['title'] as String;
          final subtitle = place['subtitle'] as String;
          final icon = place['icon'] as IconData;
          final isSelected = _profile.workoutPlace == id;

          return Padding(
            padding: const EdgeInsets.only(bottom: 14.0),
            child: _GradientBorderCard(
              isSelected: isSelected,
              padding: const EdgeInsets.all(18.0),
              onTap: () {
                setState(() => _profile.workoutPlace = id);
              },
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: isSelected ? AppColors.primaryLime : Colors.white,
                    size: 26,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primaryLime,
                      size: 20,
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==========================================
  // Screen 109: "WHAT'S YOUR FITNESS LEVEL?"
  // ==========================================
  Widget _buildScreen109FitnessLevel() {
    final levels = [
      {
        'id': 'Beginner',
        'title': LanguageService.tr('beginner'),
        'subtitle': LanguageService.tr('beginner_desc'),
      },
      {
        'id': 'Intermediate',
        'title': LanguageService.tr('intermediate'),
        'subtitle': LanguageService.tr('intermediate_desc'),
      },
      {
        'id': 'Advanced',
        'title': LanguageService.tr('advanced'),
        'subtitle': LanguageService.tr('advanced_desc'),
      },
    ];

    return QuestionnaireLayout(
      title: LanguageService.tr('fitness_level_title'),
      onBack: _prevPage,
      onNext: _nextPage,
      child: Column(
        children: levels.map((lvl) {
          final id = lvl['id']!;
          final title = lvl['title']!;
          final subtitle = lvl['subtitle']!;
          final isSelected = _profile.fitnessLevel == id;

          return Padding(
            padding: const EdgeInsets.only(bottom: 14.0),
            child: _GradientBorderCard(
              isSelected: isSelected,
              padding: const EdgeInsets.all(20.0),
              onTap: () {
                setState(() => _profile.fitnessLevel = id);
              },
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primaryLime,
                      size: 20,
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==========================================
  // Screen 110: "HOW MUCH TIME DO YOU HAVE?"
  // ==========================================
  Widget _buildScreen110WorkoutTime() {
    final minuteValues = [10, 20, 30, 40, 50, 60];
    final minLabel = LanguageService.tr('min');

    return QuestionnaireLayout(
      title: LanguageService.tr('how_much_time'),
      onBack: _prevPage,
      onNext: _nextPage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LanguageService.tr('input_manually'),
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: const Color(0xFF1B1B1D),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.10),
                width: 1.0,
              ),
            ),
            child: TextField(
              controller: _manualTimeController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: '00000',
                hintStyle: const TextStyle(color: Colors.white24),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                suffixText: minLabel,
                suffixStyle: const TextStyle(color: Colors.white54),
              ),
              onChanged: (val) {
                if (val.isNotEmpty) {
                  setState(() => _profile.duration = '$val $minLabel');
                }
              },
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: minuteValues.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 2.2,
            ),
            itemBuilder: (context, index) {
              final m = minuteValues[index];
              final dur = '$m $minLabel';
              final isSelected = _profile.duration.startsWith('$m');

              return _GradientBorderCard(
                isSelected: isSelected,
                borderRadius: 14.0,
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                onTap: () {
                  setState(() {
                    _profile.duration = dur;
                    _manualTimeController.clear();
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dur,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primaryLime,
                        size: 18,
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Screen 111: "HOW OFTEN CAN YOU TRAIN?"
  // ==========================================
  Widget _buildScreen111TrainingFrequency() {
    final dayCounts = [1, 2, 3, 4, 5, 6];
    final dayLabel = LanguageService.tr('day');
    final daysLabel = LanguageService.tr('days');
    final everyDayLabel = LanguageService.tr('every_day');

    return QuestionnaireLayout(
      title: LanguageService.tr('how_often_train'),
      onBack: _prevPage,
      onNext: _nextPage,
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dayCounts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 2.2,
            ),
            itemBuilder: (context, index) {
              final count = dayCounts[index];
              final dText = '$count ${count == 1 ? dayLabel : daysLabel}';
              final isSelected = _profile.trainingDays.startsWith('$count');

              return _GradientBorderCard(
                isSelected: isSelected,
                borderRadius: 14.0,
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                onTap: () {
                  setState(() => _profile.trainingDays = dText);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dText,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primaryLime,
                        size: 18,
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          _GradientBorderCard(
            isSelected: _profile.trainingDays == 'Every Day' || _profile.trainingDays == everyDayLabel,
            borderRadius: 14.0,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            onTap: () {
              setState(() => _profile.trainingDays = everyDayLabel);
            },
            child: SizedBox(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    everyDayLabel,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  if (_profile.trainingDays == 'Every Day' || _profile.trainingDays == everyDayLabel)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primaryLime,
                      size: 18,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Screen 112: "YOUR PERSONALIZED PLAN"
  // ==========================================
  Widget _buildScreen112PersonalizedPlan() {
    final genderStr = _profile.gender == 'Male'
        ? LanguageService.tr('men')
        : LanguageService.tr('women');

    final goalTranslations = {
      'Lose Weight': LanguageService.tr('lose_weight'),
      'Build Muscle': LanguageService.tr('build_muscle'),
      'Six Pack': LanguageService.tr('six_pack'),
      'Improve Fitness': LanguageService.tr('improve_fitness'),
      'Increase Strength': LanguageService.tr('increase_strength'),
      'Stay Active': LanguageService.tr('stay_active'),
    };

    final levelTranslations = {
      'Beginner': LanguageService.tr('beginner'),
      'Intermediate': LanguageService.tr('intermediate'),
      'Advanced': LanguageService.tr('advanced'),
    };

    final placeTranslations = {
      'Home': LanguageService.tr('home'),
      'Gym': LanguageService.tr('gym'),
      'Outdoor': LanguageService.tr('outdoor'),
    };

    final goalDisplay = _profile.goals.isEmpty
        ? LanguageService.tr('stay_active')
        : _profile.goals.map((g) => goalTranslations[g] ?? g).join(', ');

    final rows = [
      {'label': LanguageService.tr('gender'), 'val': genderStr},
      {'label': LanguageService.tr('height'), 'val': '${_profile.height} ${_profile.heightUnit}'},
      {'label': LanguageService.tr('weight'), 'val': '${_profile.weight} ${_profile.weightUnit}'},
      {'label': LanguageService.tr('age'), 'val': '${_profile.age}'},
      {
        'label': LanguageService.tr('goal'),
        'val': goalDisplay,
      },
      {'label': LanguageService.tr('level'), 'val': levelTranslations[_profile.fitnessLevel] ?? _profile.fitnessLevel},
      {'label': LanguageService.tr('workout'), 'val': placeTranslations[_profile.workoutPlace] ?? _profile.workoutPlace},
      {'label': LanguageService.tr('duration'), 'val': _profile.duration},
      {'label': LanguageService.tr('days_per_week'), 'val': _profile.trainingDays},
    ];

    return QuestionnaireLayout(
      title: LanguageService.tr('personalized_plan_title'),
      buttonText: LanguageService.tr('get_started'),
      onBack: _prevPage,
      onNext: _completeQuestionnaire,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 22.0),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1B1D),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1.0,
          ),
        ),
        child: Column(
          children: rows.map((r) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    r['label']!,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryLime,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    child: Text(
                      r['val']!,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _GradientBorderCard extends StatelessWidget {
  final bool isSelected;
  final double borderRadius;
  final Widget child;
  final VoidCallback onTap;
  final EdgeInsetsGeometry? padding;

  const _GradientBorderCard({
    required this.isSelected,
    this.borderRadius = 16.0,
    required this.child,
    required this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isSelected
                ? const [
                    Color(0xFFA3D223), // #A3D223 bright at top (Frame 17)
                    Color(0x66A3D223), // #A3D223 40% at bottom (Frame 17)
                  ]
                : const [
                    Color(0xFFA3D223), // #A3D223 100% at top (Frame 18)
                    Color(0x00A3D223), // #A3D223 0% at bottom (Frame 18)
                  ],
          ),
        ),
        padding: const EdgeInsets.all(1.0),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius - 1.0),
            gradient: isSelected
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF1B1B1D),
                      Color(0xFF384F14),
                    ],
                  )
                : null,
            color: isSelected ? null : const Color(0xFF1B1B1D),
          ),
          child: child,
        ),
      ),
    );
  }
}
