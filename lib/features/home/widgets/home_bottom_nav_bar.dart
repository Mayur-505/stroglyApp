import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/language_service.dart';
import '../models/home_models.dart';

class HomeBottomNavBar extends StatelessWidget {
  final List<HomeNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const HomeBottomNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  String _getTranslatedLabel(String label) {
    switch (label.toLowerCase()) {
      case 'home':
        return LanguageService.tr('nav_home');
      case 'workout':
      case 'workouts':
        return LanguageService.tr('nav_workout');
      case 'progress':
        return LanguageService.tr('nav_progress');
      case 'profile':
        return LanguageService.tr('nav_profile');
      default:
        return LanguageService.tr(label);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1.0,
          ),
        ),
      ),
      padding: EdgeInsets.only(
        top: 10.0,
        bottom: 10.0 + (bottomInset > 0 ? bottomInset : 4.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isSelected = index == selectedIndex;

          return GestureDetector(
            onTap: () => onItemSelected(index),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 68,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.icon,
                    size: 22,
                    color: isSelected ? AppColors.primaryLime : Colors.white54,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getTranslatedLabel(item.label),
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color:
                          isSelected ? AppColors.primaryLime : Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
