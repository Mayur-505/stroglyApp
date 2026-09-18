import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/language_service.dart';
import '../models/exercise_detail_models.dart';
import 'exercise_preview_screen.dart';

class DayWorkoutExercisesScreen extends StatefulWidget {
  final String? planId;
  final int dayNumber;
  final String workoutTitle;
  final String heroImage;
  final String difficultyLevel;
  final bool isInProgress;
  final VoidCallback? onStart;
  final VoidCallback? onRestart;
  final VoidCallback? onComplete;

  const DayWorkoutExercisesScreen({
    super.key,
    this.planId,
    this.dayNumber = 1,
    this.workoutTitle = 'Full Body Burn',
    this.heroImage = 'assets/images/image 7 (1).png',
    this.difficultyLevel = 'No experience',
    this.isInProgress = false,
    this.onStart,
    this.onRestart,
    this.onComplete,
  });

  @override
  State<DayWorkoutExercisesScreen> createState() =>
      _DayWorkoutExercisesScreenState();
}

class _DayWorkoutExercisesScreenState extends State<DayWorkoutExercisesScreen> {
  late bool _inProgress;
  List<ExerciseDetailItem> _exercises = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _inProgress = widget.isInProgress;
    _fetchDayExercises();
    LanguageService.instance.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    LanguageService.instance.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    if (mounted) {
      _fetchDayExercises();
    }
  }

  Future<void> _fetchDayExercises() async {
    setState(() => _isLoading = true);
    try {
      final plan = widget.planId ?? 'full_body_burn';
      final response = await ApiClient.instance.get('/plans/$plan/days/${widget.dayNumber}');
      if (response.isOk && response.data != null) {
        final rawList = response['data']['exercises'] as List<dynamic>? ?? [];
        if (mounted) {
          setState(() {
            _exercises = rawList
                .map((e) => ExerciseDetailItem.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList();
            _isLoading = false;
          });
          return;
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _exercises = [];
        _isLoading = false;
      });
    }
  }

  void _handleStart() {
    setState(() {
      _inProgress = true;
    });
    widget.onStart?.call();
    _openExerciseDetail(0);
  }

  void _handleRestart() {
    setState(() {
      _inProgress = false;
    });
    widget.onRestart?.call();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1B1B1D),
        content: Text(
          'Day ${widget.dayNumber} Reset to Start ⏱',
          style: GoogleFonts.outfit(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleContinue() {
    _openExerciseDetail(0);
  }

  void _showFinishDialog() {
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
                'Day ${widget.dayNumber} Session',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ready to complete today\'s workout session?',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white60,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final plan = widget.planId ?? 'full_body_burn';
                  try {
                    await ApiClient.instance.post(
                      '/plans/$plan/days/${widget.dayNumber}/complete',
                      {
                        'durationSeconds': 600,
                        'caloriesBurned': 85,
                      },
                    );
                  } catch (_) {}
                  widget.onComplete?.call();
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLime,
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF141416),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Complete Day ${widget.dayNumber}',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF141416),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openExerciseDetail(int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExercisePreviewScreen(
          dayNumber: widget.dayNumber,
          workoutTitle: widget.workoutTitle,
          showStartButton: true,
          initialIndex: index,
          exercises: _exercises,
          onStart: () {
            if (!_inProgress) {
              setState(() {
                _inProgress = true;
              });
              widget.onStart?.call();
            }
          },
          onComplete: () async {
            final plan = widget.planId ?? 'full_body_burn';
            try {
              await ApiClient.instance.post(
                '/plans/$plan/days/${widget.dayNumber}/complete',
                {
                  'durationSeconds': 600,
                  'caloriesBurned': 85,
                },
              );
            } catch (_) {}
            widget.onComplete?.call();
            if (mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    if (_isLoading && _exercises.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D0D0E),
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryLime),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0E),
      body: Stack(
        children: [
          // Scrollable Content
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              bottom: 90.0 + (bottomInset > 0 ? bottomInset : 16.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Hero Section with Athlete, Title, Stats
                _buildHeroHeader(),

                const SizedBox(height: 24),

                // 13 Exercises Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    '${_exercises.length} Exercises',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Exercises List
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: _exercises.asMap().entries.map((entry) {
                      final index = entry.key;
                      final exercise = entry.value;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: GestureDetector(
                          onTap: () => _openExerciseDetail(index),
                          child: Container(
                            height: 76,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14.0,
                              vertical: 10.0,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF161619),
                              borderRadius: BorderRadius.circular(18.0),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.06),
                              ),
                            ),
                            child: Row(
                              children: [
                                // White rounded square thumbnail
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14.0),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  padding: const EdgeInsets.all(4.0),
                                  child: exercise.imagePath.startsWith('http')
                                      ? Image.network(
                                          exercise.imagePath,
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) =>
                                              const Icon(
                                            Icons.fitness_center_rounded,
                                            color: Color(0xFF141416),
                                            size: 26,
                                          ),
                                        )
                                      : Image.asset(
                                          exercise.imagePath,
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) =>
                                              const Icon(
                                            Icons.fitness_center_rounded,
                                            color: Color(0xFF141416),
                                            size: 26,
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 16),

                                // Title and Duration
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        exercise.title,
                                        style: GoogleFonts.outfit(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        exercise.duration,
                                        style: GoogleFonts.outfit(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white60,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Sticky Bottom Buttons Area (Screen 4 vs Screen 5)
          Positioned(
            left: 20.0,
            right: 20.0,
            bottom: 16.0 + (bottomInset > 0 ? bottomInset : 8.0),
            child: _buildBottomButtons(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Stack(
      children: [
        // Background Hero Image
        SizedBox(
          width: double.infinity,
          height: 300,
          child: Stack(
            fit: StackFit.expand,
            children: [
              widget.heroImage.startsWith('http')
                  ? Image.network(
                      widget.heroImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFF161619),
                      ),
                    )
                  : Image.asset(
                      widget.heroImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFF161619),
                      ),
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

        // Foreground Content
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar: Back Arrow and 3-dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'complete_day') {
                          _showFinishDialog();
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
                          value: 'complete_day',
                          child: Text(
                            'Complete Day',
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

                const SizedBox(height: 70),

                // Subtitle: e.g. Full Body Burn No experience
                Text(
                  '${widget.workoutTitle} ${widget.difficultyLevel}',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 6),

                // Main Title: DAY 1
                Text(
                  'DAY ${widget.dayNumber}',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 10),

                // Stats: ⏱ 10 min   🔥 85 Cal
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '10 min',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(width: 18),
                    const Icon(
                      Icons.local_fire_department_rounded,
                      size: 14,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '85 Cal',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    // Screen 4: First Time / Not in progress -> Single "Start" Button
    if (!_inProgress) {
      return GestureDetector(
        onTap: _handleStart,
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primaryLime,
            borderRadius: BorderRadius.circular(26.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            'Start',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF141416),
            ),
          ),
        ),
      );
    }

    // Screen 5: In Progress -> "Restart" (Left) and "Continue" (Right)
    return Row(
      children: [
        // Restart Button
        Expanded(
          flex: 1,
          child: GestureDetector(
            onTap: _handleRestart,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF242428),
                borderRadius: BorderRadius.circular(26.0),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                'Restart',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Continue Button
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: _handleContinue,
            child: Container(
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
                'Continue',
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
    );
  }
}
