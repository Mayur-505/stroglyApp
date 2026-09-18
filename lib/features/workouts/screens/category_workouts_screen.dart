import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/language_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../models/category_workout_models.dart';
import '../widgets/category_workout_tile.dart';
import '../widgets/workout_customization_flow_sheet.dart';
import '../widgets/workout_unlock_sheet.dart';

class CategoryWorkoutsScreen extends StatefulWidget {
  final String? initialCategory;

  const CategoryWorkoutsScreen({
    super.key,
    this.initialCategory,
  });

  @override
  State<CategoryWorkoutsScreen> createState() => _CategoryWorkoutsScreenState();
}

class _CategoryWorkoutsScreenState extends State<CategoryWorkoutsScreen> {
  late String _selectedCategory;
  List<String> _filterCategories = ['All'];
  List<CategoryWorkoutItem> _workouts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialCategory?.trim();
    if (initial == null || initial.isEmpty || initial.toLowerCase() == 'all') {
      _selectedCategory = 'All';
    } else {
      _selectedCategory = initial.replaceAll('_', ' ');
    }
    _fetchCategoryWorkouts();
    LanguageService.instance.currentLanguageNotifier.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    LanguageService.instance.currentLanguageNotifier.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    _fetchCategoryWorkouts();
  }

  bool _isAllCategory(String cat) {
    final lower = cat.trim().toLowerCase();
    if (lower == 'all' || lower == 'सभी' || lower == 'બધા' || lower == 'todos' || lower == 'tous') {
      return true;
    }
    if (_filterCategories.isNotEmpty && cat == _filterCategories.first) {
      return true;
    }
    return false;
  }

  bool _isCategoryMatch(String chip, String selected) {
    if (_isAllCategory(chip) && _isAllCategory(selected)) {
      return true;
    }
    final normChip = chip.trim().toLowerCase().replaceAll('_', ' ');
    final normSelected = selected.trim().toLowerCase().replaceAll('_', ' ');
    return normChip == normSelected;
  }

  Future<void> _fetchCategoryWorkouts() async {
    setState(() => _isLoading = true);

    final categoryQuery = _isAllCategory(_selectedCategory) ? 'All' : _selectedCategory;
    final res = await ApiClient.instance.get(
      ApiConstants.categoryWorkouts,
      queryParams: {'category': categoryQuery},
    );

    if (!mounted) return;

    if (res.isOk && res.data is Map) {
      final data = res.data as Map<String, dynamic>;
      final catList = data['filterCategories'];
      final workoutList = data['workouts'];

      setState(() {
        if (catList is List && catList.isNotEmpty) {
          _filterCategories = catList.map((c) => c.toString()).toList();
        }

        final matchedCatFromApi = data['matchedCategory']?.toString();

        // 1. Check if selected category directly matches any chip
        int matchIdx = _filterCategories.indexWhere((c) => _isCategoryMatch(c, _selectedCategory));

        // 2. If backend returned a matched category, use that
        if (matchIdx < 0 && matchedCatFromApi != null && matchedCatFromApi.isNotEmpty) {
          matchIdx = _filterCategories.indexWhere((c) => _isCategoryMatch(c, matchedCatFromApi));
        }

        // 3. Substring match (e.g. "Full Body Burn" contains "Full body")
        if (matchIdx < 0) {
          final selLower = _selectedCategory.toLowerCase();
          matchIdx = _filterCategories.indexWhere((c) {
            if (_isAllCategory(c)) return false;
            final cLower = c.toLowerCase();
            return selLower.contains(cLower) || cLower.contains(selLower);
          });
        }

        // 4. Activate matched chip, or fallback to 'All'
        if (matchIdx >= 0) {
          _selectedCategory = _filterCategories[matchIdx];
        } else {
          _selectedCategory = _filterCategories.isNotEmpty ? _filterCategories.first : 'All';
        }

        if (workoutList is List && workoutList.isNotEmpty) {
          _workouts = workoutList
              .map((w) => CategoryWorkoutItem.fromJson(w as Map<String, dynamic>))
              .toList();
        } else {
          _workouts = [];
        }
        _isLoading = false;
      });

      // If category fell back to 'All' and 0 workouts returned, refetch for 'All'
      if (_isAllCategory(_selectedCategory) && categoryQuery != 'All' && _workouts.isEmpty) {
        _fetchCategoryWorkouts();
      }
    } else {
      setState(() {
        _workouts = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0E),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Top Bar: Back button + Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 42,
                      height: 42,
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
                  const SizedBox(width: 8),
                  Text(
                    'Categories',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Horizontal Filter Chips
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                itemCount: _filterCategories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final category = _filterCategories[index];
                  final isSelected = _isCategoryMatch(category, _selectedCategory);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                      _fetchCategoryWorkouts();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22.0,
                        vertical: 10.0,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryLime
                            : const Color(0xFF1B1B1D),
                        borderRadius: BorderRadius.circular(24.0),
                        border: isSelected
                            ? null
                            : Border.all(
                                color: Colors.white.withValues(alpha: 0.12),
                                width: 1.0,
                              ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        category,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.black : Colors.white70,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 18),

            // Workouts List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryLime,
                      ),
                    )
                  : _workouts.isEmpty
                      ? Center(
                          child: Text(
                            'No workouts found',
                            style: GoogleFonts.outfit(
                              color: Colors.white60,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 8.0,
                          ),
                          itemCount: _workouts.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final workout = _workouts[index];
                            return CategoryWorkoutTile(
                              item: workout,
                              onTap: () {
                                if (workout.isLocked) {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) => WorkoutUnlockSheet(
                                      workout: workout,
                                      onUnlocked: () {
                                        Navigator.of(context).pop();
                                        final unlockedItem = workout.copyWith(isFree: true);
                                        setState(() {
                                          _workouts[index] = unlockedItem;
                                        });
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (context) => WorkoutCustomizationFlowSheet(
                                            workout: unlockedItem,
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                } else {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (context) => WorkoutCustomizationFlowSheet(
                                      workout: workout,
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
