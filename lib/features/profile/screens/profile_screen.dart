import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/auth_session_manager.dart';
import '../../../core/services/language_service.dart';
import '../../../core/widgets/app_image.dart';
import '../widgets/backup_restore_card.dart';
import '../widgets/profile_settings_card.dart';
import '../models/profile_models.dart';
import 'go_premium_screen.dart';
import 'edit_profile_screen.dart';
import '../../language/screens/language_selection_screen.dart';
import '../../home/screens/home_screen.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/screens/signup_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const ProfileScreen({
    super.key,
    this.onBack,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    if (AuthSessionManager.instance.isGuest || !AuthSessionManager.instance.isAuthenticated) return;
    try {
      final res = await ApiClient.instance.get(ApiConstants.me);
      if (res.isOk && res.data != null) {
        dynamic userData = res.data;
        if (userData is Map && userData.containsKey('data')) {
          userData = userData['data'];
        }

        if (userData is Map) {
          final name = userData['name']?.toString();
          final email = userData['email']?.toString();
          final avatar = userData['avatar']?.toString();
          await AuthSessionManager.instance.saveSession(
            token: AuthSessionManager.instance.token ?? '',
            userId: AuthSessionManager.instance.userId ?? '',
            isGuest: false,
            name: name,
            email: email,
            avatar: avatar,
          );
          if (mounted) setState(() {});
        }
      }
    } catch (_) {}
  }
  @override
  Widget build(BuildContext context) {
    final isGuest = AuthSessionManager.instance.isGuest || !AuthSessionManager.instance.isAuthenticated;
    final userName = AuthSessionManager.instance.userName ?? 'Athlete';

    // Build Settings items list dynamically
    final settingsList = <ProfileSettingItem>[];

    if (isGuest) {
      settingsList.add(
        const ProfileSettingItem(
          id: 'login_signup',
          title: 'Log In / Sign Up',
          icon: Icons.mood_rounded,
        ),
      );
    } else {
      settingsList.add(
        const ProfileSettingItem(
          id: 'my_profile',
          title: 'My Profile',
          icon: Icons.mood_rounded,
        ),
      );
    }

    settingsList.add(
      const ProfileSettingItem(
        id: 'language',
        title: 'Language',
        icon: Icons.translate_rounded,
      ),
    );

    // If user is logged in (not guest), add Logout item to settings
    if (!isGuest) {
      settingsList.add(
        const ProfileSettingItem(
          id: 'logout',
          title: 'Log Out',
          icon: Icons.logout_rounded,
        ),
      );
    }

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
          // 1. Top Bar: Back Arrow + "My profile" Title + "👑 Go Premium" Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button + Title
              Row(
                children: [
                  GestureDetector(
                    key: const ValueKey('profile_back_button'),
                    onTap: () {
                      if (widget.onBack != null) {
                        widget.onBack!();
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

              // "👑 Go Premium" Outline Pill Button (Figma UI)
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
            ],
          ),
          const SizedBox(height: 20),

          // 2. Backup & Restore Card (ONLY shown when user is Guest)
          if (isGuest) ...[
            BackupRestoreCard(
              onLoginTap: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
                if (result == true && mounted) {
                  setState(() {});
                }
              },
              onSignInTap: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                );
                if (result == true && mounted) {
                  setState(() {});
                }
              },
            ),
            const SizedBox(height: 24),
          ] else ...[
            // Logged-In User Profile Banner (Figma Premium UI)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFF161619),
                borderRadius: BorderRadius.circular(18.0),
                border: Border.all(
                  color: AppColors.primaryLime.withValues(alpha: 0.25),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  // Default User Avatar Circle with Lime Ring
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLime.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryLime.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    child: ClipOval(
                      child: (AuthSessionManager.instance.userAvatar ?? '').isNotEmpty
                          ? AppImage(
                              imagePath: AuthSessionManager.instance.userAvatar!,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorWidget: const Center(
                                child: Icon(
                                  Icons.person_rounded,
                                  color: AppColors.primaryLime,
                                  size: 28,
                                ),
                              ),
                            )
                          : const Center(
                              child: Icon(
                                Icons.person_rounded,
                                color: AppColors.primaryLime,
                                size: 28,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Sleek Status Pill (Synchronized Account)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 3.0,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLime.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryLime,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Synchronized Account',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryLime,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // 3. Setting Section Title
          Text(
            LanguageService.tr('setting'),
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          // 4. Settings List Card (Figma UI)
          ProfileSettingsCard(
            items: settingsList,
            onItemTap: (item) {
              if (item.id == 'login_signup') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
                return;
              }
              if (item.id == 'my_profile') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                ).then((updated) {
                  if (updated == true && mounted) {
                    setState(() {});
                  }
                });
                return;
              }
              if (item.id == 'language') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const LanguageSelectionScreen(isFromSettings: true),
                  ),
                );
                return;
              }
              if (item.id == 'logout') {
                _showLogoutConfirmationDialog(context);
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

  // Show Log Out Confirmation Dialog
  void _showLogoutConfirmationDialog(BuildContext context) {
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
                Icons.logout_rounded,
                color: Color(0xFFFF5B5B),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Log Out',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to log out of your account? Your progress will remain saved in your account.',
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
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              _handleLogout(context);
            },
            child: Text(
              'Log Out',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Handle Logout
  Future<void> _handleLogout(BuildContext context) async {
    // 1. Call Backend Logout API
    try {
      await ApiClient.instance.post(ApiConstants.logout);
    } catch (_) {}

    // 2. Clear Auth Session from Local Storage
    await AuthSessionManager.instance.clearSession();

    // Re-initialize guest session in background
    try {
      final res = await ApiClient.instance.post(ApiConstants.guestLogin, {
        'language': LanguageService.instance.currentLanguage,
      });
      if (res.isOk && res.data is Map) {
        final token = res.data['token']?.toString();
        final user = res.data['user'];
        if (token != null && user != null) {
          await AuthSessionManager.instance.saveSession(
            token: token,
            userId: user['_id']?.toString() ?? '',
            isGuest: true,
            name: user['name']?.toString(),
          );
        }
      }
    } catch (_) {}

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF1B1B1D),
          content: Text(
            'Logged out successfully',
            style: GoogleFonts.outfit(
              color: AppColors.primaryLime,
              fontWeight: FontWeight.w600,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16.0),
          duration: const Duration(seconds: 3),
        ),
      );

      // Open Home Screen on logout
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  // Show Auth Bottom Sheet (Log In / Sign In)
  void _showAuthBottomSheet(BuildContext context, {required bool isLogin}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161619),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (sheetCtx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isLogin ? 'Log In to Strongly' : 'Create an Account',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(sheetCtx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                isLogin
                    ? 'Enter your credentials to access your saved progress.'
                    : 'Sign up to synchronize your workouts and body metrics.',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.white60,
                ),
              ),
              const SizedBox(height: 20),
              // Email Field placeholder
              TextField(
                decoration: InputDecoration(
                  hintText: 'Email Address',
                  hintStyle: GoogleFonts.outfit(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF222226),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: GoogleFonts.outfit(color: Colors.white),
              ),
              const SizedBox(height: 12),
              // Password Field placeholder
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: GoogleFonts.outfit(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF222226),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: GoogleFonts.outfit(color: Colors.white),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLime,
                    foregroundColor: const Color(0xFF111113),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(sheetCtx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF1B1B1D),
                        content: Text(
                          isLogin ? 'Logged in successfully!' : 'Account created!',
                          style: GoogleFonts.outfit(
                            color: AppColors.primaryLime,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                  child: Text(
                    isLogin ? 'Log In' : 'Sign Up',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
