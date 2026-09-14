import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../data/categories_mock_data.dart';
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

  @override
  void initState() {
    super.initState();
    _selectedCategory = _resolveInitialCategory(widget.initialCategory);
  }

  String _resolveInitialCategory(String? initial) {
    if (initial == null) return 'All';

    final normalized = initial.trim().toLowerCase();
    for (final cat in CategoriesMockData.filterCategories) {
      final catNorm = cat.toLowerCase();
      if (normalized == catNorm ||
          normalized.contains(catNorm) ||
          catNorm.contains(normalized)) {
        return cat;
      }
    }
    return 'All';
  }

  List<CategoryWorkoutItem> get _filteredWorkouts {
    if (_selectedCategory == 'All') {
      return CategoriesMockData.categoryWorkouts;
    }
    return CategoriesMockData.categoryWorkouts
        .where((item) =>
            item.category.toLowerCase() == _selectedCategory.toLowerCase())
        .toList();
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
                itemCount: CategoriesMockData.filterCategories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final category = CategoriesMockData.filterCategories[index];
                  final isSelected = category == _selectedCategory;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
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
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFF141416)
                              : Colors.white70,
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
              child: _filteredWorkouts.isEmpty
                  ? Center(
                      child: Text(
                        'No workouts found in this category',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          color: Colors.white54,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.only(
                        left: 20.0,
                        right: 20.0,
                        top: 8.0,
                        bottom: 24.0 + MediaQuery.of(context).viewPadding.bottom,
                      ),
                      physics: const BouncingScrollPhysics(),
                      itemCount: _filteredWorkouts.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final item = _filteredWorkouts[index];
                        return CategoryWorkoutTile(
                          item: item,
                          onTap: () => _handleWorkoutTap(item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleWorkoutTap(CategoryWorkoutItem item) {
    if (!item.isFree) {
      // Premium workout: show Unlock sheet first
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        useSafeArea: true,
        constraints: const BoxConstraints(maxWidth: double.infinity),
        builder: (bottomSheetContext) => WorkoutUnlockSheet(
          workout: item,
          onUnlocked: () {
            Navigator.of(bottomSheetContext).pop(); // close unlock sheet
            _openCustomizationFlow(item);
          },
        ),
      );
    } else {
      // Free workout: open customization flow directly
      _openCustomizationFlow(item);
    }
  }

  void _openCustomizationFlow(CategoryWorkoutItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: const BoxConstraints(maxWidth: double.infinity),
      builder: (_) => WorkoutCustomizationFlowSheet(
        workout: item,
      ),
    );
  }
}
