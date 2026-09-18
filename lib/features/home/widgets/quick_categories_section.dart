import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/language_service.dart';
import '../models/home_models.dart';

class QuickCategoriesSection extends StatelessWidget {
  final List<WorkoutCategory> categories;
  final String selectedCategoryId;
  final ValueChanged<String> onCategorySelected;
  final VoidCallback? onSeeAll;

  const QuickCategoriesSection({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  LanguageService.tr('quick_categories'),
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
                onTap: onSeeAll,
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

        // Categories Horizontal Scroll (Edge-to-edge full width)
        SizedBox(
          height: 42,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = cat.id == selectedCategoryId;

              return GestureDetector(
                onTap: () => onCategorySelected(cat.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 10.0,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryLime
                        : const Color(0xFF1B1B1D),
                    borderRadius: BorderRadius.circular(24.0),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryLime
                          : Colors.white.withValues(alpha: 0.12),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        cat.icon,
                        size: 16,
                        color: isSelected ? Colors.black : Colors.white70,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        cat.name,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected ? Colors.black : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
