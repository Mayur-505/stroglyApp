import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/language_service.dart';
import '../../profile/screens/profile_screen.dart';
import '../../progress/screens/progress_screen.dart';
import '../../workouts/screens/category_workouts_screen.dart';
import '../../workouts/screens/workout_detail_plan_screen.dart';
import '../../workouts/screens/workouts_screen.dart';
import '../data/home_mock_data.dart';
import '../widgets/featured_workout_card.dart';
import '../widgets/home_bottom_nav_bar.dart';
import '../widgets/home_top_bar.dart';
import '../widgets/quick_categories_section.dart';
import '../widgets/recommended_workout_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategoryId = 'home_workout';
  int _selectedNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0E),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedNavIndex,
          children: [
            _buildHomeContent(),
            const WorkoutsScreen(),
            ProgressScreen(
              onBack: () {
                setState(() {
                  _selectedNavIndex = 0;
                });
              },
            ),
            ProfileScreen(
              onBack: () {
                setState(() {
                  _selectedNavIndex = 0;
                });
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: HomeBottomNavBar(
        items: HomeMockData.navItems,
        selectedIndex: _selectedNavIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Bar (STRONGLY logo + Notification icon)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: HomeTopBar(
              onNotificationTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No new notifications'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 18),

          // Greeting
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${LanguageService.tr('good_morning')}, Alex 👋',
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  LanguageService.tr('ready_to_sweat'),
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Featured Workout Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: FeaturedWorkoutCard(
              workout: HomeMockData.featuredWorkout,
              onStartWorkout: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => WorkoutDetailPlanScreen(
                      title: HomeMockData.featuredWorkout.title,
                      heroImage: HomeMockData.featuredWorkout.imagePath,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Quick Categories Section (Full screen width edge-to-edge scroll)
          QuickCategoriesSection(
            categories: HomeMockData.categories,
            selectedCategoryId: _selectedCategoryId,
            onCategorySelected: (catId) {
              setState(() {
                _selectedCategoryId = catId;
              });
              final catItem = HomeMockData.categories.firstWhere(
                (c) => c.id == catId,
                orElse: () => HomeMockData.categories.first,
              );
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CategoryWorkoutsScreen(
                    initialCategory: catItem.name,
                  ),
                ),
              );
            },
            onSeeAll: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CategoryWorkoutsScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Recommended For You Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    LanguageService.tr('recommended_for_you'),
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CategoryWorkoutsScreen(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                    child: Text(
                      LanguageService.tr('see_all'),
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryLime,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Recommended Workout Cards
          ...HomeMockData.recommendedWorkouts.map(
            (item) => Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                bottom: 14.0,
              ),
              child: RecommendedWorkoutCard(
                workout: item,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => WorkoutDetailPlanScreen(
                        title: item.title,
                        heroImage: item.imagePath,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
