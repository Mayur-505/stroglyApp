import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/language_service.dart';
import '../../../core/services/premium_service.dart';

class GoPremiumScreen extends StatefulWidget {
  final VoidCallback? onClose;

  const GoPremiumScreen({
    super.key,
    this.onClose,
  });

  /// Opens the paywall. Returns true if the user is premium when it closes.
  static Future<bool> open(BuildContext context) async {
    if (PremiumService.instance.isPremium) return true;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const GoPremiumScreen()),
    );
    return PremiumService.instance.isPremium;
  }

  @override
  State<GoPremiumScreen> createState() => _GoPremiumScreenState();
}

class _GoPremiumScreenState extends State<GoPremiumScreen> {
  bool _isLoading = true;
  bool _isPurchasing = false;
  String _trialOffer = '';
  List<String> _benefits = [];
  List<Map<String, String>> _terms = [];
  List<PremiumPlan> _plans = [];
  String? _selectedPlanId;

  PremiumService get _premium => PremiumService.instance;

  PremiumPlan? get _selectedPlan {
    for (final p in _plans) {
      if (p.id == _selectedPlanId) return p;
    }
    return _plans.isNotEmpty ? _plans.first : null;
  }

  @override
  void initState() {
    super.initState();
    _fetchPlans();
    _premium.refreshStatus();
    _premium.addListener(_onPremiumChanged);
    LanguageService.instance.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    _premium.removeListener(_onPremiumChanged);
    LanguageService.instance.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onPremiumChanged() {
    if (mounted) setState(() {});
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
        final plans = await _premium.loadPlans();

        if (mounted) {
          setState(() {
            _plans = plans;
            if (_selectedPlanId == null && plans.isNotEmpty) {
              _selectedPlanId = plans
                  .firstWhere((p) => p.isBestValue, orElse: () => plans.first)
                  .id;
            }
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

  void _showMessage(String text, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1F1F23),
        content: Row(
          children: [
            Icon(
              success ? Icons.workspace_premium_rounded : Icons.info_outline_rounded,
              color: success ? AppColors.primaryLime : Colors.white70,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.outfit(
                  color: success ? AppColors.primaryLime : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleGoPremium() async {
    final plan = _selectedPlan;
    if (plan == null) {
      _showMessage('Plans are not available right now. Please try again.');
      return;
    }

    setState(() => _isPurchasing = true);
    final result = await _premium.buy(plan);
    if (!mounted) return;
    setState(() => _isPurchasing = false);

    if (result.success && _premium.isPremium) {
      _showMessage(result.message ?? 'Premium Activated Successfully! 🎉', success: true);
      Navigator.of(context).pop();
    } else if (result.message != null && result.message != 'Purchase canceled.') {
      _showMessage(result.message!);
    }
  }

  Future<void> _handleRestore() async {
    setState(() => _isPurchasing = true);
    await _premium.restore();
    // Restored purchases are verified through the purchase stream
    await Future.delayed(const Duration(seconds: 3));
    await _premium.refreshStatus();
    if (!mounted) return;
    setState(() => _isPurchasing = false);

    if (_premium.isPremium) {
      _showMessage('Purchases restored. Premium active 🎉', success: true);
      Navigator.of(context).pop();
    } else {
      _showMessage('No active subscription found.');
    }
  }

  Future<void> _handleCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B1B1E),
        title: Text(
          'Cancel subscription?',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Auto-renew will be turned off. You keep Premium until the end of the current period.',
          style: GoogleFonts.outfit(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Keep Premium', style: GoogleFonts.outfit(color: AppColors.primaryLime)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Cancel Subscription', style: GoogleFonts.outfit(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isPurchasing = true);
    final result = await _premium.cancel();
    if (!mounted) return;
    setState(() => _isPurchasing = false);

    // iOS: cancellation happens in App Store settings
    if (result.manageUrl != null) {
      await launchUrl(Uri.parse(result.manageUrl!), mode: LaunchMode.externalApplication);
      return;
    }
    _showMessage(
      result.message ?? (result.success ? 'Subscription canceled.' : 'Could not cancel subscription.'),
      success: result.success,
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final d = date.toLocal();
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  String _priceLine(PremiumPlan plan) {
    final price = plan.interval == 'lifetime' ? plan.displayPrice : '${plan.displayPrice}/${plan.intervalLabel}';
    return plan.trialDays > 0 ? 'Free ${plan.trialDays}-day trial, then $price' : price;
  }

  Widget _buildPlanCard(PremiumPlan plan) {
    final selected = plan.id == _selectedPlan?.id;
    return GestureDetector(
      key: ValueKey('premium_plan_${plan.id}'),
      onTap: () => setState(() => _selectedPlanId = plan.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1F290F) : const Color(0xFF141416),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primaryLime : Colors.white.withValues(alpha: 0.12),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: selected ? AppColors.primaryLime : Colors.white38,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          plan.title,
                          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                      if (plan.isBestValue) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLime,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'BEST VALUE',
                            style: GoogleFonts.outfit(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0A0A0B),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (plan.trialDays > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${plan.trialDays}-day free trial',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryLime,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              plan.interval == 'lifetime' ? plan.displayPrice : '${plan.displayPrice}/${plan.intervalLabel}',
              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveCard() {
    final isTrial = _premium.activeSubscription?['isTrial'] == true;
    final dateText = _formatDate(_premium.expiresAt);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F290F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLime, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium_rounded, color: AppColors.primaryLime, size: 20),
              const SizedBox(width: 8),
              Text(
                isTrial ? 'Free trial active' : 'Premium active',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primaryLime),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _premium.autoRenewing ? 'Renews on $dateText' : 'Premium until $dateText (auto-renew off)',
            style: GoogleFonts.outfit(fontSize: 13, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final isPremium = _premium.isPremium;
    final selectedPlan = _selectedPlan;

    if (_isLoading && _benefits.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A0B),
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryLime),
        ),
      );
    }

    final String ctaTitle;
    final String ctaSubtitle;
    final VoidCallback? ctaAction;
    if (isPremium) {
      ctaTitle = _premium.autoRenewing ? 'Cancel Subscription' : 'Done';
      ctaSubtitle = _premium.autoRenewing ? 'Premium stays active until the period ends' : '';
      ctaAction = _premium.autoRenewing ? _handleCancel : () => Navigator.of(context).pop();
    } else {
      ctaTitle = 'Go Premium';
      ctaSubtitle = selectedPlan != null ? _priceLine(selectedPlan) : _trialOffer;
      ctaAction = _handleGoPremium;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0B),
      body: Stack(
        children: [
          // Scrollable Content
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              bottom: 140.0 + bottomInset,
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

                      const SizedBox(height: 12),

                      // Active subscription or plan selection
                      if (isPremium) _buildActiveCard() else ..._plans.map(_buildPlanCard),

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
                    onTap: _isPurchasing ? null : ctaAction,
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
                                      ctaTitle,
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF0A0A0B),
                                      ),
                                    ),
                                  ],
                                ),
                                if (ctaSubtitle.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    ctaSubtitle,
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF0A0A0B),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtext / Restore purchases
                  if (isPremium)
                    Text(
                      'You can also manage it from your store account',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white38,
                      ),
                    )
                  else
                    GestureDetector(
                      key: const ValueKey('go_premium_restore_button'),
                      onTap: _isPurchasing ? null : _handleRestore,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Cancel anytime  •  ',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.white38,
                              ),
                            ),
                            TextSpan(
                              text: 'Restore purchases',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white70,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white70,
                              ),
                            ),
                          ],
                        ),
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
