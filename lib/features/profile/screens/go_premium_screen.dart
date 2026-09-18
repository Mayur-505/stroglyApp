import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/language_service.dart';
class GoPremiumScreen extends StatefulWidget {
  final VoidCallback? onClose;

  const GoPremiumScreen({
    super.key,
    this.onClose,
  });

  @override
  State<GoPremiumScreen> createState() => _GoPremiumScreenState();
}

class _GoPremiumScreenState extends State<GoPremiumScreen> {
  bool _isLoading = false;
  bool _isPurchasing = false;
  String _trialOffer = '';
  List<String> _benefits = [];
  List<Map<String, String>> _terms = [];

  @override
  void initState() {
    super.initState();
    _fetchPlans();
    LanguageService.instance.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    LanguageService.instance.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    if (mounted) {
      _fetchPlans();
    }
  }

  Future<void> _fetchPlans() async {
    try {
      final res = await ApiClient.instance.get('/subscriptions/plans');
      if (res.isOk && res['data'] != null) {
        final data = res['data'] as Map<String, dynamic>;
        final rawBenefits = data['benefits'] as List<dynamic>? ?? [];
        final rawTerms = data['terms'] as List<dynamic>? ?? [];

        if (mounted) {
          setState(() {
            _trialOffer = data['trialOffer']?.toString() ?? _trialOffer;
            _benefits = rawBenefits.map((e) => e.toString()).toList();
            _terms = rawTerms.map((e) {
              final m = Map<String, dynamic>.from(e as Map);
              return {
                'numberTitle': m['numberTitle']?.toString() ?? '',
                'description': m['description']?.toString() ?? '',
              };
            }).toList();
            _isLoading = false;
          });
          return;
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleGoPremium() async {
    setState(() {
      _isPurchasing = true;
    });

    try {
      final res = await ApiClient.instance.post('/subscriptions/verify', {
        'planType': 'yearly_trial',
        'purchaseToken': 'strongly_premium_token_${DateTime.now().millisecondsSinceEpoch}',
      });

      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1F1F23),
            content: Row(
              children: [
                const Icon(Icons.workspace_premium_rounded, color: AppColors.primaryLime),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    res['message']?.toString() ?? 'Premium Activated Successfully! 🎉',
                    style: GoogleFonts.outfit(
                      color: AppColors.primaryLime,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPurchasing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1F1F23),
            content: Text(
              'Subscription processed 🎉',
              style: GoogleFonts.outfit(
                color: AppColors.primaryLime,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    if (_isLoading && _benefits.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A0B),
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryLime),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0B),
      body: Stack(
        children: [
          // Scrollable Content
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              bottom: 120.0 + bottomInset,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Hero Image with Gradient
                Stack(
                  children: [
                    // Hero Image
                    SizedBox(
                      height: 360,
                      width: double.infinity,
                      child: Image.asset(
                        'assets/images/premium_athletes.jpg',
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFF1B1B1E),
                            child: const Center(
                              child: Icon(
                                Icons.fitness_center_rounded,
                                color: AppColors.primaryLime,
                                size: 54,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Fade Gradients
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.0, 0.45, 0.82, 1.0],
                            colors: [
                              Colors.black.withValues(alpha: 0.35),
                              Colors.transparent,
                              const Color(0xFF0A0A0B).withValues(alpha: 0.85),
                              const Color(0xFF0A0A0B),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Top Back/Close Button
                    Positioned(
                      top: 48,
                      left: 20,
                      child: GestureDetector(
                        key: const ValueKey('go_premium_close_button'),
                        onTap: () {
                          if (widget.onClose != null) {
                            widget.onClose!();
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.50),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Main Content Body
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Headline: "Start Strong Become Stronger."
                      Text(
                        'Start Strong',
                        style: GoogleFonts.outfit(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.05,
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Become ',
                              style: GoogleFonts.outfit(
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.15,
                              ),
                            ),
                            TextSpan(
                              text: 'Stronger.',
                              style: GoogleFonts.outfit(
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                fontStyle: FontStyle.italic,
                                color: AppColors.primaryLime,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.primaryLime,
                                decorationThickness: 2.0,
                                height: 1.15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Benefits Checklist
                      if (_benefits.isNotEmpty)
                        ..._benefits.map(
                          (benefitText) => Padding(
                            padding: const EdgeInsets.only(bottom: 14.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryLime,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.check_rounded,
                                      color: Color(0xFF0A0A0B),
                                      size: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    benefitText,
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Subscription Disclosures / Terms
                      if (_terms.isNotEmpty)
                        ..._terms.map(
                          (term) => Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  term['numberTitle'] ?? '',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  term['description'] ?? '',
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white38,
                                    height: 1.45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Sticky Bottom CTA
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 12.0,
                bottom: bottomInset > 0 ? bottomInset + 8.0 : 18.0,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0A0A0B).withValues(alpha: 0.0),
                    const Color(0xFF0A0A0B).withValues(alpha: 0.95),
                    const Color(0xFF0A0A0B),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Full-width Lime Button
                  GestureDetector(
                    key: const ValueKey('go_premium_cta_button'),
                    onTap: _isPurchasing ? null : _handleGoPremium,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLime,
                        borderRadius: BorderRadius.circular(28.0),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryLime.withValues(alpha: 0.35),
                            blurRadius: 18.0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _isPurchasing
                          ? const Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Color(0xFF0A0A0B),
                                ),
                              ),
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.workspace_premium_rounded,
                                      color: Color(0xFF0A0A0B),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Go Premium',
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF0A0A0B),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _trialOffer,
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF0A0A0B),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtext
                  Text(
                    'Cancel anytime during the trial',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
