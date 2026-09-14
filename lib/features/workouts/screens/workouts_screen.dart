import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/language_service.dart';
import '../data/workout_mock_data.dart';
import '../widgets/muscle_group_card.dart';
import '../widgets/need_workout_card.dart';
import '../widgets/target_focus_card.dart';
import 'category_workouts_screen.dart';
import 'workout_search_screen.dart';

class WorkoutsScreen extends StatelessWidget {
  final VoidCallback? onSearchTap;
  final VoidCallback? onFilterTap;

  const WorkoutsScreen({
    super.key,
    this.onSearchTap,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
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
                      onTap: onSearchTap ??
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
                      onTap: onFilterTap,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Section 1: Muscle Group
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

          // Muscle Group Rows (Horizontal scrollable edge-to-edge)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: WorkoutMockData.muscleGroupsRow1.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: MuscleGroupCard(
                        item: item,
                        onTap: () => _openCategoryWorkouts(context, item.title),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: WorkoutMockData.muscleGroupsRow2.map((item) {
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
            ),
          ),

          const SizedBox(height: 26),

          // Section 2: Focus on target
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

          // Target Focus Horizontal Scroll
          SizedBox(
            height: 125,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: WorkoutMockData.targetFocusList.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = WorkoutMockData.targetFocusList[index];
                return TargetFocusCard(
                  item: item,
                  onTap: () => _openCategoryWorkouts(context, item.title),
                );
              },
            ),
          ),

          const SizedBox(height: 26),

          // Section 3: Guess you may need
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

          // Dynamic Grid of quick workouts
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                for (int i = 0;
                    i < WorkoutMockData.guessYouNeedList.length;
                    i += 2) ...[
                  if (i > 0) const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: NeedWorkoutCard(
                          item: WorkoutMockData.guessYouNeedList[i],
                          onTap: () => _openCategoryWorkouts(
                            context,
                            WorkoutMockData.guessYouNeedList[i].title,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (i + 1 < WorkoutMockData.guessYouNeedList.length)
                        Expanded(
                          child: NeedWorkoutCard(
                            item: WorkoutMockData.guessYouNeedList[i + 1],
                            onTap: () => _openCategoryWorkouts(
                              context,
                              WorkoutMockData.guessYouNeedList[i + 1].title,
                            ),
                          ),
                        )
                      else
                        const Expanded(child: SizedBox.shrink()),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleActionButton({
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFF1B1B1D),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1.0,
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  void _openCategoryWorkouts(BuildContext context, String category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryWorkoutsScreen(initialCategory: category),
      ),
    );
  }
}
