import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/language_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/auth_session_manager.dart';
import '../../profile/screens/profile_screen.dart';
import '../../progress/screens/progress_screen.dart';
import '../../workouts/screens/category_workouts_screen.dart';
import '../../workouts/screens/workout_detail_plan_screen.dart';
import '../../workouts/screens/workouts_screen.dart';
import '../models/home_models.dart';
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
  String _selectedCategoryId = '';
  int _selectedNavIndex = 0;
  bool _isLoading = true;

  // GlobalKey to trigger Progress refresh when tab is tapped
  final GlobalKey<ProgressScreenState> _progressScreenKey = GlobalKey<ProgressScreenState>();

  WorkoutItem? _featuredWorkout;
  List<WorkoutCategory> _categories = [];
  List<WorkoutItem> _recommendedWorkouts = [];

  @override
  void initState() {
    super.initState();
    _fetchHomeFeed();
    LanguageService.instance.currentLanguageNotifier.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    LanguageService.instance.currentLanguageNotifier.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    _fetchHomeFeed();
  }

  Future<void> _fetchHomeFeed() async {
    final hasExistingData = _featuredWorkout != null ||
        _categories.isNotEmpty ||
        _recommendedWorkouts.isNotEmpty;

    if (!hasExistingData) {
      setState(() => _isLoading = true);
    }
    final res = await ApiClient.instance.get(ApiConstants.homeFeed);
    if (!mounted) return;

    if (res.isOk && res.data is Map) {
      final data = res.data as Map<String, dynamic>;
      final featuredMap = data['featuredWorkout'];
      final catList = data['categories'];
      final recList = data['recommendedWorkouts'];

      setState(() {
        if (featuredMap != null && featuredMap is Map<String, dynamic>) {
          _featuredWorkout = WorkoutItem.fromJson(featuredMap);
        } else {
          _featuredWorkout = null;
        }

        if (catList != null && catList is List) {
          _categories = catList
              .map((c) => WorkoutCategory.fromJson(c as Map<String, dynamic>))
              .toList();
          if (_categories.isNotEmpty && _selectedCategoryId.isEmpty) {
            _selectedCategoryId = _categories.first.id;
          }
        } else {
          _categories = [];
        }

        if (recList != null && recList is List) {
          _recommendedWorkouts = recList
              .map((r) => WorkoutItem.fromJson(r as Map<String, dynamic>))
              .toList();
        } else {
          _recommendedWorkouts = [];
        }
        _isLoading = false;
      });
    } else {
      setState(() {
        _featuredWorkout = null;
        _categories = [];
        _recommendedWorkouts = [];
        _isLoading = false;
      });
    }
  }

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
              key: _progressScreenKey,
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
        items: appNavItems,
        selectedIndex: _selectedNavIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
          // Progress tab select hone par fresh API call karo
          if (index == 2) {
            _progressScreenKey.currentState?.fetchDashboard();
          }
        },
      ),
    );
  }

  Widget _buildHomeContent() {
    final athleteName = AuthSessionManager.instance.userName ?? 'Alex';

    return RefreshIndicator(
      onRefresh: _fetchHomeFeed,
      color: AppColors.primaryLime,
      backgroundColor: const Color(0xFF1E293B),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar (STRONGLY logo)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: HomeTopBar(),
            ),

            const SizedBox(height: 18),

            // Greeting
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${LanguageService.tr('good_morning')}, $athleteName 👋',
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

            if (_isLoading && _featuredWorkout == null && _categories.isEmpty && _recommendedWorkouts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primaryLime),
                ),
              )
            else if (_featuredWorkout == null && _categories.isEmpty && _recommendedWorkouts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.fitness_center_rounded, size: 56, color: Colors.white24),
                      const SizedBox(height: 16),
                      Text(
                        'No Workouts Found',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'The database is currently empty. Run database seed or add workouts from the backend to display them here.',
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

            // Featured Workout Card
            if (_featuredWorkout != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: FeaturedWorkoutCard(
                  workout: _featuredWorkout!,
                  onStartWorkout: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => WorkoutDetailPlanScreen(
                          planId: _featuredWorkout!.id,
                          title: _featuredWorkout!.title,
                          heroImage: _featuredWorkout!.imagePath,
                        ),
                      ),
                    );
                  },
                ),
              ),

            if (_categories.isNotEmpty) ...[
              const SizedBox(height: 24),
              QuickCategoriesSection(
                categories: _categories,
                selectedCategoryId: _selectedCategoryId,
                onCategorySelected: (catId) {
                  setState(() {
                    _selectedCategoryId = catId;
                  });
                  final catItem = _categories.firstWhere(
                    (c) => c.id == catId,
                    orElse: () => _categories.first,
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
            ],

            if (_recommendedWorkouts.isNotEmpty) ...[
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
              ..._recommendedWorkouts.map(
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
                            planId: item.id,
                            title: item.title,
                            heroImage: item.imagePath,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
