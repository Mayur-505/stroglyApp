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
  DateTime _currentMonthDate = DateTime.now();
  int? _selectedDay;
  Set<int> _completedDays = {};
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

  // Fetch history — accepts explicit [selectedDay] so we never rely on
  // reading _selectedDay after setState (avoids race condition).
  // Adds _t timestamp to bust browser cache and prevent 304 Not Modified.
  Future<void> _fetchHistory({int? selectedDay, bool hasExplicitDay = false, bool skipDashboard = false}) async {
    try {
      final effectiveDay = hasExplicitDay ? selectedDay : (selectedDay ?? _selectedDay);
      final lang = LanguageService.instance.currentLanguage;
      final year = _currentMonthDate.year;
      final month = _currentMonthDate.month;
      final ts = DateTime.now().millisecondsSinceEpoch;

      String path = '/progress/history?lang=$lang&year=$year&month=$month&_t=$ts';
      if (effectiveDay != null) {
        final dayStr = effectiveDay.toString().padLeft(2, '0');
        final monthStr = month.toString().padLeft(2, '0');
        path += '&date=$year-$monthStr-$dayStr';
      }

      final res = await ApiClient.instance.get(path);
      if (res.isOk && res.data != null) {
        final data = res.data as Map<String, dynamic>;
        _month = data['month']?.toString() ?? 'September 2026';

        final rawCompleted = data['completedDays'] as List<dynamic>? ?? [];
        _completedDays = rawCompleted.map((e) => (e as num).toInt()).toSet();

        final rawLogs = data['workoutHistoryLogs'] as List<dynamic>? ?? [];
        _historyLogs = rawLogs
            .map((e) => WorkoutHistoryLogItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }

      if (!skipDashboard) {
        final dashRes = await ApiClient.instance.get('/progress/dashboard');
        if (dashRes.isOk && dashRes.data != null) {
          final charts = dashRes.data['charts'] as Map<String, dynamic>? ?? {};
          if (charts['workoutChart'] != null) {
            _workoutChart = WeeklyActivityChartData.fromJson(
              Map<String, dynamic>.from(charts['workoutChart'] as Map),
            );
          }
        }
      }

      if (mounted) {
        setState(() {});
      }
    } catch (_) {}
  }

  void _onPreviousMonth() {
    setState(() {
      _currentMonthDate = DateTime(_currentMonthDate.year, _currentMonthDate.month - 1, 1);
      _selectedDay = null;
    });
    _fetchHistory(selectedDay: null, hasExplicitDay: true);
  }

  void _onNextMonth() {
    setState(() {
      _currentMonthDate = DateTime(_currentMonthDate.year, _currentMonthDate.month + 1, 1);
      _selectedDay = null;
    });
    _fetchHistory(selectedDay: null, hasExplicitDay: true);
  }

  void _onDaySelected(MonthlyCalendarDay day) {
    if (!day.isCurrentMonth) return;
    // Compute new value BEFORE setState so we can pass it directly to fetch
    final int? newDay = (_selectedDay == day.dayNumber) ? null : day.dayNumber;
    setState(() {
      _selectedDay = newDay;
    });
    // Pass newDay explicitly — never reads _selectedDay after setState
    _fetchHistory(selectedDay: newDay, hasExplicitDay: true, skipDashboard: true);
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
          _month,
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
    final String sectionTitle = _selectedDay != null
        ? '$_month (Day $_selectedDay)'
        : _month;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Monthly Calendar Card
        MonthlyCalendarCard(
          monthTitle: _month,
          completedDays: _completedDays,
          selectedDay: _selectedDay,
          onPreviousMonth: _onPreviousMonth,
          onNextMonth: _onNextMonth,
          onDaySelected: _onDaySelected,
        ),
        const SizedBox(height: 22),

        // Section Header
        Text(
          sectionTitle,
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
