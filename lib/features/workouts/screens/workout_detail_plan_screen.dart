import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/language_service.dart';
import '../../../core/widgets/app_image.dart';
import '../models/workout_detail_models.dart';
import '../widgets/workout_day_card.dart';
import 'day_workout_exercises_screen.dart';
import 'workout_start_schedule_screen.dart';

class WorkoutDetailPlanScreen extends StatefulWidget {
  final String? planId;
  final String? title;
  final String? heroImage;
  final String? difficultyLevel;

  const WorkoutDetailPlanScreen({
    super.key,
    this.planId,
    this.title,
    this.heroImage,
    this.difficultyLevel,
  });

  @override
  State<WorkoutDetailPlanScreen> createState() =>
      _WorkoutDetailPlanScreenState();
}

class _WorkoutDetailPlanScreenState extends State<WorkoutDetailPlanScreen> {
  WorkoutDetailData? _detailData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPlanDetail();
    LanguageService.instance.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    LanguageService.instance.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    if (mounted) {
      _fetchPlanDetail();
    }
  }

  Future<void> _fetchPlanDetail() async {
    setState(() => _isLoading = true);
    try {
      final id = widget.planId ?? 'full_body_burn';
      final response = await ApiClient.instance.get('/plans/$id');
      if (response.isOk && response.data != null) {
        final rawMap = response.data is Map
            ? (response.data as Map<String, dynamic>)['data'] ?? response.data
            : null;
        if (rawMap is Map && mounted) {
          setState(() {
            _detailData = WorkoutDetailData.fromJson(
              Map<String, dynamic>.from(rawMap),
            );
            _isLoading = false;
          });
          return;
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _detailData = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    if (_isLoading && _detailData == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D0D0E),
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryLime),
        ),
      );
    }

    if (_detailData == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D0D0E),
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Center(
          child: Text(
            'Unable to load workout plan.',
            style: GoogleFonts.outfit(color: Colors.white70),
          ),
        ),
      );
    }

    final detail = _detailData!;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0E),
      body: Stack(
        children: [
          // Scrollable Content
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(bottom: 100.0 + bottomInset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Header with Image & Stats
                _buildHeroHeader(),

                const SizedBox(height: 18),

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
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        detail.descriptionParagraph2,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.65),
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 30-Day Workout Cards List
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: detail.days.map((dayItem) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: WorkoutDayCard(
                          item: dayItem,
                          onTap: () => _openExercisePreview(dayItem.dayNumber),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Sticky Bottom "Ready to go! →" Action Button
          Positioned(
            left: 20.0,
            right: 20.0,
            bottom: 18.0 + (bottomInset > 0 ? bottomInset : 8.0),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: _openScheduleScreen,
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLime,
                    borderRadius: BorderRadius.circular(27.0),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Ready to go!',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF141416),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Color(0xFF141416),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader() {
    final data = _detailData!;
    return Stack(
      children: [
        // Background Hero Image
        SizedBox(
          width: double.infinity,
          height: 310,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppImage(
                imagePath: data.heroImage,
                fit: BoxFit.cover,
                memCacheWidth: 800,
                errorWidget: Container(
                  color: const Color(0xFF161619),
                ),
              ),
              // Top & bottom gradient overlays
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
                    stops: const [0.0, 0.40, 1.0],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Foreground content on hero
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Bar: Back Button
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                // Title + Stats Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Left: Title + Strength & Cardio bars
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.title,
                            style: GoogleFonts.outfit(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildIntensityColumn(
                                'Strength',
                                data.strengthLevel,
                              ),
                              const SizedBox(width: 20),
                              _buildIntensityColumn(
                                'Cardio',
                                data.cardioLevel,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Right: 30 Days & 8-15 Minutes per day stats
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${data.totalDays}',
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Days',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              data.dailyDuration,
                              style: GoogleFonts.outfit(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                            Text(
                              'Minutes\nper day',
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Colors.white60,
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
        ),
      ],
    );
  }

  Widget _buildIntensityColumn(String label, int filledBars) {
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
        const SizedBox(height: 5),
        Row(
          children: List.generate(3, (index) {
            final isFilled = index < filledBars;
            return Container(
              width: 14,
              height: 4,
              margin: const EdgeInsets.only(right: 3.0),
              decoration: BoxDecoration(
                color: isFilled ? Colors.white : Colors.white.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(2.0),
              ),
            );
          }),
        ),
      ],
    );
  }

  void _openExercisePreview(int dayNumber) {
    if (_detailData == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DayWorkoutExercisesScreen(
          planId: widget.planId,
          dayNumber: dayNumber,
          workoutTitle: _detailData!.title,
          heroImage: _detailData!.heroImage,
          difficultyLevel: widget.difficultyLevel ?? 'No experience',
        ),
      ),
    );
  }

  void _openScheduleScreen() {
    if (_detailData == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorkoutStartScheduleScreen(
          planId: widget.planId,
          workoutTitle: _detailData!.title,
          heroImage: _detailData!.heroImage,
          difficultyLevel: widget.difficultyLevel ?? 'No experience',
        ),
      ),
    );
  }
}
