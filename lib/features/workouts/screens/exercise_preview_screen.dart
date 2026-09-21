import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/exercise_video_player.dart';
import '../models/exercise_detail_models.dart';
import 'active_workout_landscape_screen.dart';

class ExercisePreviewScreen extends StatefulWidget {
  final int dayNumber;
  final String workoutTitle;
  final bool showStartButton;
  final int initialIndex;
  final List<ExerciseDetailItem>? exercises;
  final String? planId;
  final VoidCallback? onStart;
  final VoidCallback? onComplete;

  const ExercisePreviewScreen({
    super.key,
    this.dayNumber = 1,
    this.workoutTitle = 'Full Body Burn',
    this.showStartButton = false,
    this.initialIndex = 0,
    this.exercises,
    this.planId,
    this.onStart,
    this.onComplete,
  });

  @override
  State<ExercisePreviewScreen> createState() => _ExercisePreviewScreenState();
}

class _ExercisePreviewScreenState extends State<ExercisePreviewScreen> {
  late List<ExerciseDetailItem> _exercises;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.exercises != null && widget.exercises!.isNotEmpty) {
      _exercises = List<ExerciseDetailItem>.from(widget.exercises!);
    } else {
      _exercises = [];
    }
    _currentIndex = (widget.initialIndex >= 0 &&
            widget.initialIndex < _exercises.length)
        ? widget.initialIndex
        : 0;
  }

  void _previousExercise() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  void _nextExercise() {
    if (_currentIndex < _exercises.length - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_exercises.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D0D0E),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Text(
            'No exercises available for this workout.',
            style: GoogleFonts.outfit(color: Colors.white70),
          ),
        ),
      );
    }
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final currentExercise = _exercises[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0E),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Back Arrow on Left, < 1/13 > Carousel on Right
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Arrow Button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D1D20),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),

                  // Carousel Pagination: < 1/13 >
                  Row(
                    children: [
                      // Previous Arrow Button (<)
                      GestureDetector(
                        onTap: _currentIndex > 0 ? _previousExercise : null,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1D1D20),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Icon(
                            Icons.chevron_left_rounded,
                            color: _currentIndex > 0
                                ? Colors.white
                                : Colors.white24,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Index indicator: e.g. 1/13
                      Text(
                        '${_currentIndex + 1}/${_exercises.length}',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Next Arrow Button (>)
                      GestureDetector(
                        onTap: _currentIndex < _exercises.length - 1
                            ? _nextExercise
                            : null,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1D1D20),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Icon(
                            Icons.chevron_right_rounded,
                            color: _currentIndex < _exercises.length - 1
                                ? Colors.white
                                : Colors.white24,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  left: 20.0,
                  right: 20.0,
                  top: 8.0,
                  bottom: widget.showStartButton
                      ? 20.0
                      : (30.0 + (bottomInset > 0 ? bottomInset : 10.0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Exercise Title
                    Text(
                      currentExercise.title,
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Target Area Capsule Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14.0,
                        vertical: 5.0,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C1F),
                        borderRadius: BorderRadius.circular(14.0),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Text(
                        currentExercise.targetArea,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // White Rounded Card with Illustration
                    Container(
                      width: double.infinity,
                      height: 280,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ExerciseVideoPlayer(
                            videoUrl: currentExercise.videoUrl,
                            imagePath: currentExercise.imagePath,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Instructions Section
                    Text(
                      currentExercise.title,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...currentExercise.instructions.map((instruction) {
                      return _buildBulletItem(instruction);
                    }),
                    const SizedBox(height: 22),

                    // Key Tips Section
                    Text(
                      'Key Tips',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...currentExercise.keyTips.map((tip) {
                      return _buildBulletItem(tip);
                    }),
                  ],
                ),
              ),
            ),

            // Optional Sticky Bottom "Start" Button (Hidden when opened from Ready to go screen)
            if (widget.showStartButton)
              Padding(
                padding: EdgeInsets.only(
                  left: 20.0,
                  right: 20.0,
                  bottom: 16.0 + (bottomInset > 0 ? bottomInset : 8.0),
                  top: 8.0,
                ),
                child: GestureDetector(
                  onTap: () {
                    widget.onStart?.call();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ActiveWorkoutLandscapeScreen(
                          dayNumber: widget.dayNumber,
                          workoutTitle: widget.workoutTitle,
                          initialExerciseIndex: _currentIndex,
                          exercises: _exercises,
                          onComplete: () {
                            widget.onComplete?.call();
                          },
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLime,
                      borderRadius: BorderRadius.circular(26.0),
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
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4.0, right: 10.0),
            child: Text(
              '✦',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.70),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
