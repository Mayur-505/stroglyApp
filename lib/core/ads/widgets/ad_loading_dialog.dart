import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';

/// Small "Loading ad…" dialog shown while a full-screen ad is fetched on
/// demand, so the ad never appears without warning.
class AdLoadingDialog extends StatelessWidget {
  const AdLoadingDialog({super.key});

  /// Shows the dialog while [work] runs and closes it afterwards. If there
  /// is no navigator (or [show] is false) it just awaits [work].
  static Future<T> runWhile<T>(
    GlobalKey<NavigatorState> navigatorKey,
    Future<T> work, {
    bool show = true,
  }) async {
    final navigator = navigatorKey.currentState;
    if (!show || navigator == null) return work;

    var open = true;
    final route = DialogRoute<void>(
      context: navigator.context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (_) => const AdLoadingDialog(),
    );
    navigator.push(route).whenComplete(() => open = false);
    try {
      return await work;
    } finally {
      if (open && route.isActive) navigator.removeRoute(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1C),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: AppColors.primaryLime,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                'Loading ad…',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
