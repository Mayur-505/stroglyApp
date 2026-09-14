import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/language_service.dart';
import '../data/progress_mock_data.dart';
import '../models/progress_models.dart';
import '../widgets/progress_stat_card.dart';
import '../widgets/steps_gauge_card.dart';
import '../widgets/weekly_bar_chart_card.dart';
import '../widgets/weekly_calendar_card.dart';
import 'progress_detail_screen.dart';

class ProgressScreen extends StatelessWidget {
  final VoidCallback? onBack;

  const ProgressScreen({
    super.key,
    this.onBack,
  });

  void _navigateToDetail(BuildContext context, ProgressTabType tab) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProgressDetailScreen(initialTab: tab),
      ),
    );
  }

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
          // Top Bar: Back Arrow + "Progress" Title
          Row(
            children: [
              GestureDetector(
                key: const ValueKey('progress_back_button'),
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
          WeeklyCalendarCard(
            days: ProgressMockData.weekDays,
            onTap: () => _navigateToDetail(context, ProgressTabType.history),
          ),

          const SizedBox(height: 14),

          // 2. 2x2 Stats Grid:
          // Row 1: Workout (min) & Calories (cal) -> Tapping opens Summary Tab
          Row(
            children: [
              Expanded(
                child: ProgressStatCard(
                  stat: ProgressMockData.workoutStat,
                  onTap: () =>
                      _navigateToDetail(context, ProgressTabType.summary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ProgressStatCard(
                  stat: ProgressMockData.caloriesStat,
                  onTap: () =>
                      _navigateToDetail(context, ProgressTabType.summary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 2: Weight (lbs) & Steps (Radial Arc Gauge) -> Tapping opens Summary Tab
          Row(
            children: [
              Expanded(
                child: ProgressStatCard(
                  stat: ProgressMockData.weightStat,
                  onTap: () =>
                      _navigateToDetail(context, ProgressTabType.summary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StepsGaugeCard(
                  currentSteps: ProgressMockData.currentSteps,
                  targetSteps: ProgressMockData.targetSteps,
                  onTap: () =>
                      _navigateToDetail(context, ProgressTabType.summary),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 3. Workout Weekly Chart Card -> Tapping opens Summary Tab
          WeeklyBarChartCard(
            chartData: ProgressMockData.workoutChart,
            onTap: () => _navigateToDetail(context, ProgressTabType.summary),
          ),

          const SizedBox(height: 14),

          // 4. Calorie Weekly Chart Card -> Tapping opens Summary Tab
          WeeklyBarChartCard(
            chartData: ProgressMockData.calorieChart,
            onTap: () => _navigateToDetail(context, ProgressTabType.summary),
          ),
        ],
      ),
    );
  }
}

