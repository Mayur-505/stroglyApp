import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

/// Dims a premium-only widget and shows an unlock badge on top.
class PremiumLockOverlay extends StatelessWidget {
  final Widget child;
  final bool locked;
  final String label;
  final VoidCallback onUnlock;

  const PremiumLockOverlay({
    super.key,
    required this.child,
    required this.locked,
    required this.onUnlock,
    this.label = 'Unlock with Premium',
  });

  @override
  Widget build(BuildContext context) {
    if (!locked) return child;
    return GestureDetector(
      onTap: onUnlock,
      child: Stack(
        children: [
          IgnorePointer(child: Opacity(opacity: 0.25, child: child)),
          Positioned.fill(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F290F),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryLime, width: 1.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_rounded, color: AppColors.primaryLime, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      label,
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
          ),
        ],
      ),
    );
  }
}
