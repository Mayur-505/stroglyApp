import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/language_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../models/workout_models.dart';
import '../widgets/muscle_group_card.dart';
import '../widgets/need_workout_card.dart';
import '../widgets/target_focus_card.dart';
import 'category_workouts_screen.dart';
import 'workout_search_screen.dart';

class WorkoutsScreen extends StatefulWidget {
  final VoidCallback? onSearchTap;
  final VoidCallback? onFilterTap;

  const WorkoutsScreen({
    super.key,
    this.onSearchTap,
    this.onFilterTap,
  });

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  List<MuscleGroupItem> _muscleGroupsRow1 = [];
  List<MuscleGroupItem> _muscleGroupsRow2 = [];
  List<TargetFocusItem> _targetFocusList = [];
  List<QuickWorkoutItem> _guessYouNeedList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchExploreWorkouts();
    LanguageService.instance.currentLanguageNotifier.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    LanguageService.instance.currentLanguageNotifier.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    _fetchExploreWorkouts();
  }

  Future<void> _fetchExploreWorkouts() async {
    final hasExistingData = _muscleGroupsRow1.isNotEmpty ||
        _muscleGroupsRow2.isNotEmpty ||
        _targetFocusList.isNotEmpty ||
        _guessYouNeedList.isNotEmpty;

    if (!hasExistingData) {
      setState(() => _isLoading = true);
    }
    final res = await ApiClient.instance.get(ApiConstants.exploreWorkouts);
    if (!mounted) return;

    if (res.isOk && res.data is Map) {
      final data = res.data as Map<String, dynamic>;
      final r1 = data['muscleGroupsRow1'];
      final r2 = data['muscleGroupsRow2'];
      final tf = data['targetFocusList'];
      final gn = data['guessYouNeedList'];

      setState(() {
        _muscleGroupsRow1 = r1 is List
            ? r1.map((item) => MuscleGroupItem.fromJson(item as Map<String, dynamic>)).toList()
            : [];
        _muscleGroupsRow2 = r2 is List
            ? r2.map((item) => MuscleGroupItem.fromJson(item as Map<String, dynamic>)).toList()
            : [];
        _targetFocusList = tf is List
            ? tf.map((item) => TargetFocusItem.fromJson(item as Map<String, dynamic>)).toList()
            : [];
        _guessYouNeedList = gn is List
            ? gn.map((item) => QuickWorkoutItem.fromJson(item as Map<String, dynamic>)).toList()
            : [];
        _isLoading = false;
      });
    } else {
      setState(() {
        _muscleGroupsRow1 = [];
        _muscleGroupsRow2 = [];
        _targetFocusList = [];
        _guessYouNeedList = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasData = _muscleGroupsRow1.isNotEmpty ||
        _muscleGroupsRow2.isNotEmpty ||
        _targetFocusList.isNotEmpty ||
        _guessYouNeedList.isNotEmpty;

    return RefreshIndicator(
      onRefresh: _fetchExploreWorkouts,
      color: const Color(0xFFA3D223),
      backgroundColor: const Color(0xFF1E293B),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.only(top: 10.0, bottom: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    LanguageService.tr('workouts'),
                    style: GoogleFonts.outfit(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      _buildCircleActionButton(
                        icon: Icons.search_rounded,
                        onTap: widget.onSearchTap ??
                            () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const WorkoutSearchScreen(),
                                ),
                              );
                            },
                      ),
                      const SizedBox(width: 10),
                      _buildCircleActionButton(
                        icon: Icons.tune_rounded,
                        onTap: widget.onFilterTap,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            if (_isLoading && !hasData)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFFA3D223)),
                ),
              )
            else if (!hasData)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.fitness_center_rounded, size: 56, color: Colors.white24),
                      const SizedBox(height: 16),
                      Text(
                        'No Workouts Available',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'The database is currently empty. Workouts will appear here once added or seeded into the database.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Section 1: Muscle Group
            if (_muscleGroupsRow1.isNotEmpty || _muscleGroupsRow2.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  LanguageService.tr('muscle_group'),
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_muscleGroupsRow1.isNotEmpty)
                      Row(
                        children: _muscleGroupsRow1.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: MuscleGroupCard(
                              item: item,
                              onTap: () => _openCategoryWorkouts(context, item.title),
                            ),
                          );
                        }).toList(),
                      ),
                    if (_muscleGroupsRow2.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: _muscleGroupsRow2.map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: MuscleGroupCard(
                              item: item,
                              onTap: () => _openCategoryWorkouts(context, item.title),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 26),
            ],

            // Section 2: Focus on target
            if (_targetFocusList.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  LanguageService.tr('focus_on_target'),
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: _targetFocusList.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: TargetFocusCard(
                        item: item,
                        onTap: () => _openCategoryWorkouts(context, item.title),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 26),
            ],

            // Section 3: Guess you may need
            if (_guessYouNeedList.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  LanguageService.tr('guess_you_may_need'),
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: _guessYouNeedList.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: NeedWorkoutCard(
                        item: item,
                        onTap: () => _openCategoryWorkouts(context, item.title),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCircleActionButton({
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1E293B),
            border: Border.all(
              color: const Color(0xFF334155),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  void _openCategoryWorkouts(BuildContext context, String title) {
    final cleanTitle = title.replaceAll('\n', ' ');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryWorkoutsScreen(
          initialCategory: cleanTitle,
        ),
      ),
    );
  }
}
