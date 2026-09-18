import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/language_service.dart';
// import '../widgets/backup_restore_card.dart';
import '../widgets/profile_settings_card.dart';
// import 'go_premium_screen.dart';
import '../../language/screens/language_selection_screen.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback? onBack;

  const ProfileScreen({
    super.key,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        top: 10.0,
        bottom: 30.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Bar: Back Arrow + "My profile" Title + "👑 Go Premium" Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button + Title
              Row(
                children: [
                  GestureDetector(
                    key: const ValueKey('profile_back_button'),
                    onTap: () {
                      if (onBack != null) {
                        onBack!();
                      } else if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    LanguageService.tr('my_profile'),
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              // "👑 Go Premium" Outline Pill Button (Commented out for now)
              /*
              GestureDetector(
                key: const ValueKey('profile_go_premium_button'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const GoPremiumScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F290F),
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: AppColors.primaryLime,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.workspace_premium_rounded,
                        color: AppColors.primaryLime,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        LanguageService.tr('go_premium'),
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryLime,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              */
            ],
          ),
          const SizedBox(height: 20),

          // Backup & Restore Card (Commented out for now)
          /*
          BackupRestoreCard(
            onGoogleTap: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF1B1B1D),
                  content: Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryLime,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Backing up to Google Cloud...',
                        style: GoogleFonts.outfit(
                          color: AppColors.primaryLime,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );

              try {
                final res = await ApiClient.instance.post('/user/backup', {
                  'profile': {
                    'syncedAt': DateTime.now().toIso8601String(),
                  },
                });

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF1B1B1D),
                      content: Text(
                        res['message']?.toString() ?? 'Data synchronized with Google Cloud! ☁️',
                        style: GoogleFonts.outfit(
                          color: AppColors.primaryLime,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }
              } catch (_) {}
            },
          ),
          const SizedBox(height: 26),
          */

          // Setting Section Title
          Text(
            LanguageService.tr('setting'),
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          // Settings List Card
          ProfileSettingsCard(
            onItemTap: (item) {
              if (item.id == 'language') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const LanguageSelectionScreen(isFromSettings: true),
                  ),
                );
                return;
              }
              if (item.id == 'delete_account') {
                _showDeleteAccountDialog(context);
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF1B1B1D),
                  content: Text(
                    'Opening ${item.title}...',
                    style: GoogleFonts.outfit(
                      color: AppColors.primaryLime,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF161619),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF2C1414),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.delete_forever_rounded,
                color: Color(0xFFFF5B5B),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              LanguageService.tr('delete_account'),
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to permanently delete your account and all workout progress? This action cannot be undone.',
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.white70,
            height: 1.4,
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.outfit(
                color: Colors.white60,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4D4D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () async {
              Navigator.of(dialogCtx).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: const Color(0xFF1B1B1D),
                  content: Text(
                    'Account deletion request submitted. Your data will be erased.',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFF6B6B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  duration: const Duration(seconds: 3),
                ),
              );

              try {
                await ApiClient.instance.delete('/user/account');
              } catch (_) {}
            },
            child: Text(
              'Delete Permanently',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
