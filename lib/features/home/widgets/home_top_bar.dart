import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../splash/widgets/strongly_logo.dart';

class HomeTopBar extends StatelessWidget {
  final VoidCallback? onNotificationTap;

  const HomeTopBar({
    super.key,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const StronglyLogo(
          fontSize: 24,
          letterSpacing: -1.2,
        ),
        GestureDetector(
          onTap: onNotificationTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF1B1B1D),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1.0,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                Positioned(
                  top: 10,
                  right: 11,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLime,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
