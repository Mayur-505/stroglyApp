import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/services/language_service.dart';
import '../models/workout_detail_models.dart';
import '../widgets/workout_day_card.dart';
import 'day_workout_exercises_screen.dart';

class WorkoutStartScheduleScreen extends StatefulWidget {
  final String? planId;
  final String workoutTitle;
  final String heroImage;
  final String difficultyLevel;

  const WorkoutStartScheduleScreen({
    super.key,
    this.planId,
    this.workoutTitle = 'Full Body Burn',
    this.heroImage = 'assets/images/image 7 (1).png',
    this.difficultyLevel = 'No experience',
  }); 

  @override
  State<WorkoutStartScheduleScreen> createState() =>
      _WorkoutStartScheduleScreenState();
}

class _WorkoutStartScheduleScreenState
    extends State<WorkoutStartScheduleScreen> {
  late String _selectedLevel;
  late List<WorkoutDayItem> _days;
  WorkoutDetailData? _detailData;

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.difficultyLevel;

    // Generate initial 30 days while loading
    _days = List.generate(30, (index) {
      final dayNum = index + 1;
      return WorkoutDayItem(
        dayNumber: dayNum,
        duration: '09-20 min',
        progress: 0.0,
        isUnlocked: dayNum == 1,
        isCompleted: false,
      );
    });

    _fetchPlan();
    LanguageService.instance.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    LanguageService.instance.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    if (mounted) {
      _fetchPlan();
    }
  }

  Future<void> _fetchPlan() async {
    try {
      final plan = widget.planId ?? 'full_body_burn';
      final res = await ApiClient.instance.get('/plans/$plan');
      if (res.isOk && res.data != null) {
        if (mounted) {
          setState(() {
            _detailData = WorkoutDetailData.fromJson(
              Map<String, dynamic>.from(res['data'] as Map),
            );
            if (_detailData!.days.isNotEmpty) {
              _days = _detailData!.days;
            }
          });
        }
      }
    } catch (_) {}
  }

  int get _completedDaysCount =>
      _days.where((day) => day.isCompleted).length;

  double get _overallProgress =>
      _days.isEmpty ? 0.0 : _completedDaysCount / _days.length;

  void _onDayCardTapped(WorkoutDayItem day) {
    if (!day.isUnlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF1B1B1D),
          content: Text(
            'Complete previous days to unlock Day ${day.dayNumber} 🔒',
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }

    _openDayExercises(day);
  }

  void _openDayExercises(WorkoutDayItem day) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DayWorkoutExercisesScreen(
          planId: widget.planId,
          dayNumber: day.dayNumber,
          workoutTitle: widget.workoutTitle,
          heroImage: widget.heroImage,
          difficultyLevel: _selectedLevel,
          isInProgress: day.isInProgress,
          onStart: () {
            setState(() {
              final index =
                  _days.indexWhere((d) => d.dayNumber == day.dayNumber);
              if (index != -1) {
                _days[index] = _days[index].copyWith(progress: 0.40);
              }
            });
          },
          onRestart: () {
            _resetDay(day.dayNumber);
          },
          onComplete: () {
            _completeDay(day.dayNumber);
          },
        ),
      ),
    );
  }

  void _completeDay(int dayNumber) {
    setState(() {
      final index = _days.indexWhere((d) => d.dayNumber == dayNumber);
      if (index != -1) {
        // Mark current day as completed
        _days[index] = _days[index].copyWith(
          isCompleted: true,
          progress: 1.0,
        );

        // Unlock next day if exists
        final nextIndex = index + 1;
        if (nextIndex < _days.length) {
          _days[nextIndex] = _days[nextIndex].copyWith(
            isUnlocked: true,
            progress: 0.0,
            isCompleted: false,
          );
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1B1B1D),
        content: Text(
          'Day $dayNumber Completed! Day ${dayNumber + 1} Unlocked 🎉',
          style: GoogleFonts.outfit(
            color: AppColors.primaryLime,
            fontWeight: FontWeight.w700,
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _resetDay(int dayNumber) {
    setState(() {
      final index = _days.indexWhere((d) => d.dayNumber == dayNumber);
      if (index != -1) {
        _days[index] = _days[index].copyWith(
          progress: 0.0,
          isCompleted: false,
        );
      }
    });
  }



  void _showChooseLevelSheet() {
    final levels = [
      'No experience',
      'Beginner',
      'Advanced',
      'Expert',
      'Pro',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF161619),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(26.0),
              topRight: Radius.circular(26.0),
            ),
          ),
          padding: EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 20.0,
            bottom: 24.0 + MediaQuery.of(ctx).viewPadding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Choose Difficulty Level',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              ...levels.map((lvl) {
                final isSelected = lvl == _selectedLevel;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedLevel = lvl;
                      });
                      Navigator.of(ctx).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18.0,
                        vertical: 14.0,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryLime.withValues(alpha: 0.15)
                            : const Color(0xFF202024),
                        borderRadius: BorderRadius.circular(14.0),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryLime
                              : Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            lvl,
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? AppColors.primaryLime
                                  : Colors.white,
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_rounded,
                              color: AppColors.primaryLime,
                              size: 18,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showPlanInfoSheet() {
    final detail = _detailData ??
        WorkoutDetailData(
          id: widget.planId ?? 'full_body_burn',
          title: widget.workoutTitle,
          heroImage: widget.heroImage,
          descriptionParagraph1:
              'Get ready to move, sweat, and feel stronger with a complete workout designed to activate your entire body in just 20 minutes.',
          descriptionParagraph2:
              'No matter where you are starting from, all you need is 20 minutes and the determination to show up.',
          days: _days,
        );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewPadding.bottom;

        return Container(
          height: MediaQuery.of(ctx).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Color(0xFF141416),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28.0),
              topRight: Radius.circular(28.0),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // Scrollable Content: Hero Header + Description Paragraphs
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Header with workout title, stats, strength/cardio
                      SizedBox(
                        height: 250,
                        width: double.infinity,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            AppImage(
                              imagePath: widget.heroImage,
                              fit: BoxFit.cover,
                              errorWidget: Container(color: const Color(0xFF161619)),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.45),
                                    Colors.transparent,
                                    const Color(0xFF141416),
                                  ],
                                  stops: const [0.0, 0.45, 1.0],
                                ),
                              ),
                            ),
                            // Content overlay on hero
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                                vertical: 14.0,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      // Title + Strength & Cardio
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              widget.workoutTitle,
                                              style: GoogleFonts.outfit(
                                                fontSize: 24,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                _buildSheetIntensityColumn(
                                                  'Strength',
                                                  detail.strengthLevel,
                                                ),
                                                const SizedBox(width: 16),
                                                _buildSheetIntensityColumn(
                                                  'Cardio',
                                                  detail.cardioLevel,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      // 30 Days & 8-15 Minutes per day
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '${detail.totalDays}',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.white,
                                                  height: 1.0,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Days',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white
                                                      .withValues(alpha: 0.70),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                detail.dailyDuration,
                                                style: GoogleFonts.outfit(
                                                  fontSize: 19,
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.white,
                                                  height: 1.0,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Minutes\nper day',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white
                                                      .withValues(alpha: 0.65),
                                                  height: 1.15,
                                                ),
                                                textAlign: TextAlign.right,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Description Paragraphs
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              detail.descriptionParagraph1,
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha: 0.65),
                                height: 1.48,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              detail.descriptionParagraph2,
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha: 0.65),
                                height: 1.48,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Sticky Bottom "Close" Button
              Padding(
                padding: EdgeInsets.only(
                  left: 20.0,
                  right: 20.0,
                  top: 12.0,
                  bottom: 16.0 + (bottomInset > 0 ? bottomInset : 8.0),
                ),
                child: GestureDetector(
                  onTap: () => Navigator.of(ctx).pop(),
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLime,
                      borderRadius: BorderRadius.circular(26.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Close',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF141416),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSheetIntensityColumn(String label, int filledBars) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: List.generate(3, (index) {
            final isFilled = index < filledBars;
            return Container(
              width: 14,
              height: 4,
              margin: const EdgeInsets.only(right: 3.0),
              decoration: BoxDecoration(
                color: isFilled
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(2.0),
              ),
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0E),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: 30.0 + bottomInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Hero Section with Athlete, Title, Stats & Progress
            _buildHeroHeader(),

            const SizedBox(height: 20),

            // 30 Days Workout List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: _days.map((dayItem) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: WorkoutDayCard(
                      item: dayItem,
                      onTap: () => _onDayCardTapped(dayItem),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Stack(
      children: [
        // Hero Background Image with Dark Fade
        SizedBox(
          width: double.infinity,
          height: 310,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppImage(
                imagePath: widget.heroImage,
                fit: BoxFit.cover,
                errorWidget: Container(color: const Color(0xFF161619)),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.65),
                      Colors.black.withValues(alpha: 0.20),
                      const Color(0xFF0D0D0E),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Foreground: Top Nav & Hero Info
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar: Back Arrow, Help (?), More (⋮)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D1D20),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),

                    // Right action buttons: Help (?) and Popup Menu (⋮)
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _showPlanInfoSheet,
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1D1D20),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12),
                              ),
                            ),
                            child: const Icon(
                              Icons.help_outline_rounded,
                              color: Colors.white,
                              size: 19,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // 3-dots Menu matching Screen 2
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'choose_level') {
                              _showChooseLevelSheet();
                            } else if (value == 'plan_info') {
                              _showPlanInfoSheet();
                            }
                          },
                          color: const Color(0xFF1C1C1F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.0),
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          offset: const Offset(0, 48),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'choose_level',
                              child: Text(
                                'Choose level',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              value: 'plan_info',
                              child: Text(
                                'Plan info',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1D1D20),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12),
                              ),
                            ),
                            child: const Icon(
                              Icons.more_vert_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 60),

                // Workout Title
                Text(
                  widget.workoutTitle,
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 6),

                // Difficulty Level (e.g. 'No experience')
                Text(
                  _selectedLevel,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 10),

                // Finished Days Count: e.g. "0 / 30 Days Finished"
                Row(
                  children: [
                    Text(
                      '$_completedDaysCount / ${_days.length}',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      ' Days Finished',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Overall 30-Day Progress Bar
                Container(
                  width: double.infinity,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFF28282D),
                    borderRadius: BorderRadius.circular(3.0),
                  ),
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: _overallProgress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryLime,
                        borderRadius: BorderRadius.circular(3.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
