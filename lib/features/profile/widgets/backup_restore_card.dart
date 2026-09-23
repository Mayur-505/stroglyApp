import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class BackupRestoreCard extends StatelessWidget {
  final VoidCallback? onLoginTap;
  final VoidCallback? onSignInTap;

  const BackupRestoreCard({
    super.key,
    this.onLoginTap,
    this.onSignInTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: const Color(0xFF161619),
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title: Backup & Restore
          Text(
            'Backup & Restore',
            style: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),

          // Subtitle: Synchronize your data
          Text(
            'Synchronize your data',
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Colors.white38,
            ),
          ),
          const SizedBox(height: 16),

          // Row of 2 Buttons: [Log In] and [Sign In]
          Row(
            children: [
              // Log In Button (Lime Solid)
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryLime,
                      foregroundColor: const Color(0xFF111113),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    onPressed: onLoginTap,
                    child: Text(
                      'Log In',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Sign In Button (Dark Gray)
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF38383B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.12),
                          width: 1.0,
                        ),
                      ),
                    ),
                    onPressed: onSignInTap,
                    child: Text(
                      'Sign In',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
