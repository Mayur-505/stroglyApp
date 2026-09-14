import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/language_service.dart';
import '../data/profile_mock_data.dart';
import '../models/profile_models.dart';

class ProfileSettingsCard extends StatelessWidget {
  final List<ProfileSettingItem> items;
  final ValueChanged<ProfileSettingItem>? onItemTap;

  const ProfileSettingsCard({
    super.key,
    this.items = ProfileMockData.settings,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFF161619),
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildSettingRow(item);
        },
      ),
    );
  }

  Widget _buildSettingRow(ProfileSettingItem item) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (item.onTap != null) {
          item.onTap!();
        } else if (onItemTap != null) {
          onItemTap!(item);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            // Olive rounded square with Lime icon
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF233010),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Center(
                child: Icon(
                  item.icon,
                  color: AppColors.primaryLime,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Title
            Expanded(
              child: Text(
                LanguageService.tr(item.id),
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),

            // Chevron Right
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white38,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
