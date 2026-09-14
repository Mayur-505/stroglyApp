import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/language_service.dart';
import '../models/progress_models.dart';

class ProgressTabBar extends StatelessWidget {
  final ProgressTabType selectedTab;
  final ValueChanged<ProgressTabType> onTabChanged;

  const ProgressTabBar({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF222226),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabItem(
              title: LanguageService.tr('summary'),
              isSelected: selectedTab == ProgressTabType.summary,
              onTap: () => onTabChanged(ProgressTabType.summary),
            ),
          ),
          Expanded(
            child: _buildTabItem(
              title: LanguageService.tr('history'),
              isSelected: selectedTab == ProgressTabType.history,
              onTap: () => onTabChanged(ProgressTabType.history),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.white38,
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2.5,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryLime : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
