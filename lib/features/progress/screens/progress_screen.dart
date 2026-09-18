import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/language_service.dart';
import '../models/progress_models.dart';
import '../widgets/progress_stat_card.dart';
import '../widgets/steps_gauge_card.dart';
import '../widgets/weekly_bar_chart_card.dart';
import '../widgets/weekly_calendar_card.dart';
import 'progress_detail_screen.dart';

class ProgressScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const ProgressScreen({
    super.key,
    this.onBack,
  });

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  List<DayStatusItem> _weekDays = [];
  ProgressStatItem? _workoutStat;
  ProgressStatItem? _caloriesStat;
  ProgressStatItem? _weightStat;
  int _currentSteps = 0;
  int _targetSteps = 6000;
  WeeklyActivityChartData? _workoutChart;
  WeeklyActivityChartData? _calorieChart;

  @override
  void initState() {
    super.initState();
    _fetchDashboard();
    LanguageService.instance.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    LanguageService.instance.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    if (mounted) {
      _fetchDashboard();
    }
  }

  Future<void> _fetchDashboard() async {
    try {
      final res = await ApiClient.instance.get('/progress/dashboard');
      if (res.isOk && res.data != null) {
        final data = res.data as Map<String, dynamic>;
        final rawDays = data['weekDays'] as List<dynamic>? ?? [];
        final stats = data['stats'] as Map<String, dynamic>? ?? {};
        final charts = data['charts'] as Map<String, dynamic>? ?? {};

        if (mounted) {
          setState(() {
            _weekDays = rawDays
                .map((e) => DayStatusItem.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList();

            if (stats['workout'] != null) {
              _workoutStat = ProgressStatItem.fromJson(
                Map<String, dynamic>.from(stats['workout'] as Map),
              );
            }
            if (stats['calories'] != null) {
              _caloriesStat = ProgressStatItem.fromJson(
                Map<String, dynamic>.from(stats['calories'] as Map),
              );
            }
            if (stats['weight'] != null) {
              _weightStat = ProgressStatItem.fromJson(
                Map<String, dynamic>.from(stats['weight'] as Map),
              );
            }
            if (stats['steps'] != null) {
              _currentSteps = stats['steps']['currentSteps'] is int
                  ? stats['steps']['currentSteps']
                  : int.tryParse(stats['steps']['currentSteps']?.toString() ?? '1500') ?? 1500;
              _targetSteps = stats['steps']['targetSteps'] is int
                  ? stats['steps']['targetSteps']
                  : int.tryParse(stats['steps']['targetSteps']?.toString() ?? '6000') ?? 6000;
            }
            if (charts['workoutChart'] != null) {
              _workoutChart = WeeklyActivityChartData.fromJson(
                Map<String, dynamic>.from(charts['workoutChart'] as Map),
              );
            }
            if (charts['calorieChart'] != null) {
              _calorieChart = WeeklyActivityChartData.fromJson(
                Map<String, dynamic>.from(charts['calorieChart'] as Map),
              );
            }
          });
          return;
        }
      }
    } catch (_) {}
  }

  void _navigateToDetail(BuildContext context, ProgressTabType tab) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProgressDetailScreen(initialTab: tab),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xFFCEFF00),
      backgroundColor: const Color(0xFF161619),
      onRefresh: _fetchDashboard,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          top: 10.0,
          bottom: 30.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar: Back Arrow + "Progress" Title
            Row(
              children: [
                GestureDetector(
                  key: const ValueKey('progress_back_button'),
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
                  LanguageService.tr('progress_title'),
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 1. Weekly Day Calendar Card (Tapping opens History Tab)
            if (_weekDays.isNotEmpty)
              WeeklyCalendarCard(
                days: _weekDays,
                onTap: () => _navigateToDetail(context, ProgressTabType.history),
              ),

            const SizedBox(height: 14),

            // 2. 2x2 Stats Grid
            Row(
              children: [
                if (_workoutStat != null)
                  Expanded(
                    child: ProgressStatCard(
                      stat: _workoutStat!,
                      onTap: () =>
                          _navigateToDetail(context, ProgressTabType.summary),
                    ),
                  ),
                const SizedBox(width: 12),
                if (_caloriesStat != null)
                  Expanded(
                    child: ProgressStatCard(
                      stat: _caloriesStat!,
                      onTap: () =>
                          _navigateToDetail(context, ProgressTabType.summary),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Row 2: Weight & Steps
            Row(
              children: [
                if (_weightStat != null)
                  Expanded(
                    child: ProgressStatCard(
                      stat: _weightStat!,
                      onTap: () =>
                          _navigateToDetail(context, ProgressTabType.summary),
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: StepsGaugeCard(
                    currentSteps: _currentSteps,
                    targetSteps: _targetSteps,
                    onTap: () =>
                        _navigateToDetail(context, ProgressTabType.summary),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // 3. Workout Weekly Chart Card
            if (_workoutChart != null)
              WeeklyBarChartCard(
                chartData: _workoutChart!,
                onTap: () => _navigateToDetail(context, ProgressTabType.summary),
              ),

            const SizedBox(height: 14),

            // 4. Calorie Weekly Chart Card
            if (_calorieChart != null)
              WeeklyBarChartCard(
                chartData: _calorieChart!,
                onTap: () => _navigateToDetail(context, ProgressTabType.summary),
              ),
          ],
        ),
      ),
    );
  }
}

