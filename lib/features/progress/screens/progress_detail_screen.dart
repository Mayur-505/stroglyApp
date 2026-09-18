import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/language_service.dart';
import '../models/progress_models.dart';
import '../widgets/monthly_calendar_card.dart';
import '../widgets/progress_summary_card.dart';
import '../widgets/progress_tab_bar.dart';
import '../widgets/workout_history_card.dart';

class ProgressDetailScreen extends StatefulWidget {
  final ProgressTabType initialTab;

  const ProgressDetailScreen({
    super.key,
    this.initialTab = ProgressTabType.summary,
  });

  @override
  State<ProgressDetailScreen> createState() => _ProgressDetailScreenState();
}

class _ProgressDetailScreenState extends State<ProgressDetailScreen> {
  late ProgressTabType _currentTab;
  String _month = 'September 2026';
  List<WorkoutHistoryLogItem> _historyLogs = [];
  WeeklyActivityChartData? _workoutChart;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
    _fetchHistory();
    LanguageService.instance.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    LanguageService.instance.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    if (mounted) {
      _fetchHistory();
    }
  }

  Future<void> _fetchHistory() async {
    try {
      final res = await ApiClient.instance.get('/progress/history');
      if (res.isOk && res.data != null) {
        final data = res.data as Map<String, dynamic>;
        _month = data['month']?.toString() ?? 'September 2026';
        final rawLogs = data['workoutHistoryLogs'] as List<dynamic>? ?? [];
        _historyLogs = rawLogs
            .map((e) => WorkoutHistoryLogItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }

      final dashRes = await ApiClient.instance.get('/progress/dashboard');
      if (dashRes.isOk && dashRes.data != null) {
        final charts = dashRes.data['charts'] as Map<String, dynamic>? ?? {};
        if (charts['workoutChart'] != null) {
          _workoutChart = WeeklyActivityChartData.fromJson(
            Map<String, dynamic>.from(charts['workoutChart'] as Map),
          );
        }
      }

      if (mounted) {
        setState(() {});
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0E),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Back Arrow + "Progress" Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  GestureDetector(
                    key: const ValueKey('progress_detail_back_button'),
                    onTap: () => Navigator.of(context).pop(),
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
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Tab Bar: Summary | History
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ProgressTabBar(
                selectedTab: _currentTab,
                onTabChanged: (tab) {
                  setState(() {
                    _currentTab = tab;
                  });
                },
              ),
            ),

            // Tab Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(
                  left: 20.0,
                  right: 20.0,
                  top: 18.0,
                  bottom: 30.0,
                ),
                child: _currentTab == ProgressTabType.summary
                    ? _buildSummaryContent()
                    : _buildHistoryContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Text(
          'August 2026',
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white60,
          ),
        ),
        const SizedBox(height: 12),

        // Summary Average Card
        ProgressSummaryCard(
          days: _workoutChart?.days,
          averageValue: _workoutChart?.weeklyAverageText ?? '1',
        ),
      ],
    );
  }

  Widget _buildHistoryContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Monthly Calendar Card
        MonthlyCalendarCard(
          monthTitle: _month,
        ),
        const SizedBox(height: 22),

        // Section Header
        Text(
          'August 2026',
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white60,
          ),
        ),
        const SizedBox(height: 12),

        // Workout History Card
        WorkoutHistoryCard(
          logs: _historyLogs,
          totalWorkouts: _historyLogs.length,
        ),
      ],
    );
  }
}
